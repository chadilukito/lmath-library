{   Pascal translation by V.V. Nesterov from FORTRAN 77 subroutine written
    by Prof. M.Powell. Source code was taken from here:
    http://mat.uc.pt/~zhang/software.html#cobyla

    This is relatively crude translation with most of
    GoTo statements. Matrices in the calculations are dealt with fortran
    order "columns first". So, there is place for optimization. If somebody
    endeavors this, please let me know.

     This subroutine minimizes an objective function F(X) subject to M
     inequality constraints on X, where X is a vector of variables that has
     N components. The algorithm employs linear approximations to the
     objective and constraint functions, the approximations being formed by
     linear interpolation at N+1 points in the space of the variables.
     We regard these interpolation points as vertices of a simplex. The
     parameter RHO controls the size of the simplex and it is reduced
     automatically from RHOBEG to RHOEND. For each RHO the subroutine tries
     to achieve a good vector of variables for the current size, and then
     RHO is reduced until the value RHOEND is reached. Therefore RHOBEG and
     RHOEND should be set to reasonable initial values and the required
     accuracy in the variables respectively, but this accuracy should be
     viewed as a subject for experimentation because it is not guaranteed.
     The subroutine has an advantage over many of its competitors, however,
     which is that it treats each constraint individually when calculating
     a change to the variables, instead of lumping the constraints together
     into a single penalty function. The name of the subroutine is derived
     from the phrase Constrained Optimization BY Linear Approximations.

     The user must set the values of N, M, RHOBEG and RHOEND, and must
     provide an initial vector of variables in X.

     SIGMA is a penalty parameter, it being assumed that a change to X is an
     improvement if it reduces the merit function
                F(X)+SIGMA*MAX(0.0,-C1(X),-C2(X),...,-CM(X)),
     where C1,C2,...,CM denote the constraint functions that should become
     nonnegative eventually, at least to the precision of RHOEND. This term
     multiplied by SIGMA is returned by the function and is called MAXCV, which
     stands for 'MAXimum Constraint Violation'. The argument MAXFUN is an integer
     variable that must be set by the user to a limit on the number of calls of
     CALCFC, the purpose of this routine being given below.
     The value of MAXFUN will be altered to the number of calls
     of CALCFC that are made.
     In order to define the objective and constraint functions, we pass a procedure
     of the form:

                procedure CALCFC(N, M : integer; const X : TVector;
                                out F:Float; var CON: TVector);

     It is defined as TCobylaObjectProc in uTypes unit, package uGenMath.

     The values of N and M are fixed and have been defined already, while
     X is now the current vector of variables. The procedure should return
     the objective and constraint functions at X in F and CON[1],CON[2],
     ...,CON[M]. Note that we are trying to adjust X so that F[X] is as
     small as possible subject to the constraint functions being nonnegative.
            }
{$goto ON}
unit uCobyla;
interface
uses uTypes, uErrors, uMinMax, uMath, uMatrix, uTrsTlp;

procedure COBYLA(
    N     : integer; // Number of variables to optimize, residing in X[N] array
    M     : integer; // Number of inequality constrains
    X     : TVector; // Array of variables to be optimized. Guess values before call, optimized after.
out F     : float;   // Function value upon minimization
out MaxCV : float;   // maximal constraint violation
    RHOBEG: float;   // Initial size of simplex. Must be set by user, but how?
    RHOEND: float;   // End size of simplex: desired precision of objective function and constrain satisfaction
var MaxFun: integer;// limit on the number of calls of CALCFC user-supplied function, at the end number of actual calls
    CalcFC: TCobylaObjectProc
);

implementation
var
  OldLowBound : integer;
  MPP : integer; // M + 2

  {working space}
  W, Con, VSig, Veta, SigBar, DX : TVector;
  Sim, Simi, DATMat, A : TMatrix;

procedure InitCobyla(M,N: integer);
begin
    OldLowBound := matGetLowBound;
    matSetLowBound(1); // sets low bound for vector and matrix operations defined in uMatrix
    mpp := m+2;
    DimVector(W,N);
    DimVector(Con,Mpp); // calcfc returns constraint functions here. Must be non-negative
    DimMatrix(Sim,N,N+1);
    DimMatrix(Simi,N,N+1);
    DimMatrix(DATMat,mpp,N+1);
    DimMatrix(A,N,M+1);
    DimVector(VSig,N);
    DimVector(Veta,N);
    DimVector(SigBar,N);
    DimVector(DX,N);
end;

procedure FinCobyla(ErrCode:integer);
begin
    Finalize(W);
    Finalize(Con);
    Finalize(Sim);
    Finalize(Simi);
    Finalize(DATMat);
    Finalize(A);
    Finalize(VSig);
    Finalize(Veta);
    Finalize(SigBar);
    Finalize(DX);
    matSetLowBound(OldLowBound);
    SetErrCode(ErrCode);
end;

procedure COBYLA(N: integer; M: integer; X: TVector; out F: float; out MaxCV: float; RHOBEG: float; RHOEND: float;
    var MaxFun: integer; CalcFC: TCobylaObjectProc);

var
  IFull:integer; // 1 means succcessful return from trstlp; 0 means degenerate gradient and fail
  NFVals : integer; // number of function evaluations so far
  NP: integer; // N+1
  MP: integer; // M+1
  alpha, beta, gamma, delta : float;
  Rho: float; // current size of vertex
  Temp: float;
  error: float; // rounding error
  ResMax: Float;

label
  40,130,140,370,440,550;
var
  I,J, k, jdrop, ibrnch, nbest, iflag, L:integer;
  parmu, phimin, parsig, pareta, phi, vmold, vmnew, trured, edgmax, cmin, cmax: float;
  tempa, wsig, weta, cvmaxp, cvmaxm, sum, dxsign, resnew, barmu, prerec, prerem, ratio, denom: float;

  // takes N number of params, M number of constrains, X[N] params
  // returns F value of object function and Con[M] values of constraint functions
  procedure CalcObjectFunc;
  var
    k:integer;
  begin
    inc(nfvals);
    CalcFC(N,M,X,F,Con);
    resmax := 0.0;
    for k := 1 to M do // Con is array of constrains; at the end must be non-negative
       resmax := max(ResMax,-Con[k]); // here largest violation is calculated
    Con[mp] := F; // objective function value
    Con[mpp] := ResMax; // largest violation
  end;

begin
   {Set the initial values of some parameters. The last column of SIM holds
   the optimal vertex of the current simplex, and the preceding N columns
   hold the displacements from the optimal vertex to the other vertices.
   Further, SIMI holds the inverse of the matrix that is contained in the
   first N columns of SIM.}
    InitCobyla(M,N);
    SetErrCode(OptOK);
    np := n+1;
    mp := m+1;
    alpha := 0.25;
    beta := 2.1;
    gamma := 0.5;
    delta := 1.1;
    rho := rhobeg;
    parmu := 0.0;
    nfvals := 0;
    temp := 1.0/rho;
    for i := 1 to n do
    begin
      sim[i,np] := x[i]; // filling "optimal vertex" column with guess values for x
      for j := 1 to n do // all other vertices "0"
      begin
        sim[i,j] := 0.0;
        simi[i,j] := 0.0;
      end;
      sim[i,i] := rho; // diagonals
      simi[i,i] := temp;
    end;
    jdrop := np;
    ibrnch := 0;

  { Make the next call of the user-supplied procedure CALCFC. These
   instructions are also used for calling CALCFC during the iterations of
   the algorithm. }

 40:if (nfvals >= MaxFun) and (nfvals > 0) then
    begin
      FinCobyla(cobMaxFunc);
      Exit;
    end;
    CalcObjectFunc;
    if ibrnch = 1 then goto 440;

   {Set the recently calculated function values in a column of DATMAT. This
   array has a column for each vertex of the current simplex, the entries of
   each column being the values of the constraint functions (if any)
   followed by the objective function and the greatest constraint violation
   at the vertex.}

    for k := 1 to mpp do
      datmat[k,jdrop] := Con[k];
    if nfvals > np then goto 130;

    {Exchange the new vertex of the initial simplex with the optimal vertex if
    necessary. Then, if the initial simplex is not complete, pick its next
    vertex and calculate the function values there.}

    if jdrop <= n then
    begin
      if datmat[mp,np] <= F then
        x[jdrop] := sim[jdrop,np]
      else begin
        sim[jdrop,np] := x[jdrop];
        for k := 1 to mpp do
        begin
          datmat[k,jdrop] := datmat[k,np];
          datmat[k,np] := con[k];
        end;
        for k := 1 to jdrop do
        begin
          sim[jdrop,k] := -rho;
          temp := 0.0;
          for i := K to JDrop do
            Temp := Temp - Simi[I,K];
          simi[jdrop,k] := temp;
        end;
      end;
    end;
    if NFVals <= N then
    begin
      jdrop := nfvals;
      x[jdrop] := x[jdrop]+rho;
      GoTo 40;
    end;
130:ibrnch := 1;

   //Identify the optimal vertex of the current simplex.
140:phimin := datmat[mp,np]+parmu*datmat[mpp,np];
    nbest := np;
    for j := 1 to N do
    begin
      temp := datmat[mp,j]+parmu*datmat[mpp,j];
      if temp < phimin then
      begin
        nbest := j;
        phimin := temp;
      end else if (temp  =  phimin) and (parmu  =  0.0) then
        if datmat[mpp,j] < datmat[mpp,nbest] then
          NBest := j;
    end;

   {Switch the best vertex into pole position if it is not there already,
   and also update SIM, SIMI and DATMAT. }

    if nbest <= n then
    begin
      for i := 1 to mpp do
      begin
        temp := datmat[i,np];
        datmat[i,np] := datmat[i,nbest];
        datmat[i,nbest] := temp;
      end;
      for i := 1 to N do
      begin
        temp := sim[i,nbest];
        sim[i,nbest] := 0.0;
        sim[i,np] := sim[i,np]+temp;
        tempa := 0.0;
        for k := 1 to N do
        begin
          sim[i,k] := sim[i,k]-temp;
          tempa := tempa-simi[k,i];
        end;
        simi[nbest,i] := tempa;
      end;
    end;

   {Make an error return if SIGI is a poor approximation to the inverse of
   the leading N by N submatrix of SIG.}

    error := 0.0;
    for i := 1 to N do
      for j := 1 to N do
      begin
        temp := 0.0;
        if i = j then
          temp := temp-1.0;
        for k := 1 to N do
          temp := temp+simi[i,k]*sim[k,j];
        error := max(error,abs(temp));
      end;
    if error > 0.1 then
    begin
      SetErrCode(cobRoundErrors);
      Exit;
    end;

   {Calculate the coefficients of the linear approximations to the objective
   and constraint functions, placing minus the objective function gradient
   after the constraint gradients in the array A. The vector W is used for
   working space.}

    for k := 1 to MP do
    begin
      Con[k] := -datmat[k,np];
      for j := 1 to N do
        W[j] := datmat[k,j]+con[k];
      for i := 1 to N do
      begin
        temp := 0.0;
        for j := 1 to N do
          temp := temp+W[j]*simi[j,i];
        if k = MP then
          temp := -temp;
        A[i,k] := temp;
      end;
    end;

   {Calculate the values of sigma and eta, and set IFLAG := 0 if the current
   simplex is not acceptable. }

    iflag := 1;
    parsig := alpha*rho;
    pareta := beta*rho;
    for j := 1 to N do
    begin
      wsig := 0.0;
      weta := 0.0;
      for i := 1 to N do
      begin
        wsig := wsig+simi[j,i]**2;
        weta := weta+sim[i,j]**2;
      end;
      vsig[j] := 1.0/sqrt(wsig);
      veta[j] := sqrt(weta);
      if (vsig[j] < parsig) or (veta[j] > pareta) then
        iflag := 0;
    end;

   {If a new vertex is needed to improve acceptability, then decide which
   vertex to drop from the simplex.}

    if (ibrnch = 1) or (iflag = 1) then goto 370;
    jdrop := 0;
    temp := pareta;
    for j := 1 to N do
    if veta[j] > temp then
    begin
      jdrop := j;
      temp := veta[j];
    end;
    if jdrop = 0 then
    for j := 1 to N do
    if vsig[j] < temp then
    begin
      jdrop := j;
      temp := vsig[j];
    end;

   // Calculate the step to the new vertex and its sign.

    temp := gamma*rho*vsig[jdrop];
    for i := 1 to N do
      dx[i] := temp*simi[jdrop,i];
    cvmaxp := 0.0;
    cvmaxm := 0.0;
    for k := 1 to MP do
    begin
      sum := 0.0;
      for i := 1 to N do
        sum := sum+a[i,k]*dx[i];
      if k < mp then
      begin
        temp := datmat[k,np];
        cvmaxp := max(cvmaxp,-sum-temp);
        cvmaxm := max(cvmaxm,sum-temp);
      end;
    end;
    dxsign := 1.0;
    if parmu*(cvmaxp - cvmaxm) > 2*sum then
      dxsign := -1.0;

   // Update the elements of SIM and SIMI, and set the next X.

    temp := 0.0;
    for i := 1 to N do
    begin
      dx[i] := dxsign*dx[i];
      sim[i,jdrop] := dx[i];
      temp := temp+simi[jdrop,i]*dx[i];
    end;
    for i := 1 to N do
      simi[jdrop,i] := simi[jdrop,i]/temp;
    for j := 1 to N do
    begin
      if j <> jdrop then
      begin
        temp := 0.0;
        for i := 1 to N do
          temp := temp+simi[j,i]*dx[i];
        for i := 1 to N do
          simi[j,i] := simi[j,i]-temp*simi[jdrop,i];
      end;
      x[j] := sim[j,np]+dx[j];
    end;
    goto 40;

//    Calculate DX := x[*]-x[0]. Branch if the length of DX is less than 0.5*RHO.

370: trstlp(N,M,A,Con,Rho,dx,ifull);
    if (ifull = 0) and (vecEucLength(DX,1) < 0.25*sqr(Rho)) then
    begin
      ibrnch := 1;
      goto 550;
    end;

   {Predict the change to F and the new maximum constraint violation if the
   variables are altered from x[0] to x[0]+DX.   }

    resnew := 0.0;
    con[mp] := 0.0;
    for k := 1 to MP do
    begin
      sum := con[k];
      for i := 1 to N do
        sum := sum-a[i,k]*dx[i];
      if (k < mp) then
        resnew := max(resnew,sum);
    end;

   {Increase PARMU if necessary and branch back if this change alters the
   optimal vertex. Otherwise PREREM and PREREC will be set to the predicted
   reductions in the merit function and the maximum constraint violation
   respectively.}

    barmu := 0.0;
    prerec := datmat[mpp,np]-resnew;
    if prerec > 0.0 then
       barmu := sum/prerec;
    if parmu < 1.5*barmu then
    begin
      parmu := 2.0*barmu;
      phi := datmat[mp,np]+parmu*datmat[mpp,np];
      for j := 1 to N do
      begin
        temp := datmat[mp,j]+parmu*datmat[mpp,j];
        if (temp < phi) then goto 140;
        if (temp = phi) and (parmu = 0.0) then
          if datmat[mpp,j] < datmat[mpp,np] then
             goto 140;
      end;
    end;
    prerem := parmu*prerec-sum;

  { Calculate the constraint and objective functions at x[*]. Then find the
   actual reduction in the merit function.   }

    for i := 1 to n do
      x[i] := sim[i,np]+dx[i];
    ibrnch := 1;
    goto 40;
440: vmold := datmat[mp,np]+parmu*datmat[mpp,np];
    vmnew := f+parmu*resmax;
    trured := vmold-vmnew;
    if (parmu = 0.0) and (f = datmat[mp,np]) then
    begin
      prerem := prerec;
      trured := datmat[mpp,np]-resmax;
    end;

  { Begin the operations that decide whether x[*] should replace one of the
   vertices of the current simplex, the change being mandatory if TRURED is
   positive. Firstly, JDROP is set to the index of the vertex that is to be
   replaced. }

    ratio := 0.0;
    if trured <= 0.0 then
      ratio := 1.0;
    jdrop := 0;
    for j := 1 to N do
    begin
      temp := 0.0;
      for i := 1 to N do
        temp := temp+simi[j,i]*dx[i];
      temp := abs(temp);
      if (temp > ratio) then
      begin
        jdrop := j;
        ratio := temp;
      end;
      sigbar[j] := temp*vsig[j];
    end;

//Calculate the value of ell.

    edgmax := delta*rho;
    L := 0;
    for j := 1 to N do
    begin
      if (sigbar[j] >= parsig) or (sigbar[j] >= vsig[j]) then
      begin
        temp := veta[j];
        if (trured > 0.0) then
        begin
          temp := 0.0;
          for i := 1 to N do
            temp := temp+(dx[i]-sim[i,j])**2;
          temp := sqrt(temp);
        end;
        if (temp > edgmax) then
        begin
          l := j;
          edgmax := temp;
        end;
      end;
    end;
    if l > 0 then
      jdrop := l;
    if jdrop = 0 then
       goto 550;

 // Revise the simplex by updating the elements of SIM, SIMI and DATMAT.

    temp := 0.0;
    for i := 1 to N do
    begin
      sim[i,jdrop] := dx[i];
      temp := temp+simi[jdrop,i]*dx[i];
    end;
    for i := 1 to N do
      simi[jdrop,i] := simi[jdrop,i]/temp;
    for j := 1 to N do
      if j <> jdrop then
      begin
        temp := 0.0;
        for i := 1 to N do
          temp := temp+simi[j,i]*dx[i];
        for i := 1 to N do
          simi[j,i] := simi[j,i]-temp*simi[jdrop,i];
      end;
    for k := 1 to mpp do
      datmat[k,jdrop] := con[k];

   //Branch back for further iterations with the current RHO.

    if (trured > 0.0) and (trured >=  0.1*prerem) then
      goto 140;
550: if iflag = 0 then
    begin
        ibrnch := 0;
        goto 140;
    end;

   //Otherwise reduce RHO if it is not at its least value and reset PARMU.

    if rho > rhoend then
    begin
      rho := 0.5*rho;
      if rho <= 1.5*rhoend then
        rho := rhoend;
      if parmu > 0.0 then
      begin
        denom := 0.0;
        for k := 1 to mp do
        begin
          cmin := datmat[k,np];
          cmax := cmin;
          for i := 1 to N do
          begin
            cmin := min(cmin,datmat[k,i]);
            cmax := max(cmax,datmat[k,i]);
          end;
          if (k <= m) and (cmin < 0.5*cmax) then
          begin
            temp := max(cmax,0.0)-cmin;
            if (denom <= 0.0) then
                denom := temp
            else
                denom := min(denom,temp);
          end;
        end;
        if (denom = 0.0) then
            parmu := 0.0
        else if (cmax-cmin < parmu*denom) then
            parmu := (cmax-cmin)/denom;
      end;
      goto 140;
    end;

    if IFull = 0 then
    begin
      SetErrCode(cobDegenerate);
      for i := 1 to n do
         x[i] := sim[i,np];
    end;
    F := datmat[mp,np];
    MaxCV := datmat[mpp,np];
    MaxFun := nfvals;
    FinCobyla(optOK);
end;

end.
