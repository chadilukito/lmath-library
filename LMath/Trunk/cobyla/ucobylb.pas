{$goto ON}
unit uCobylB;
interface
uses uTypes, uErrors, uMinMax, uMath, uTrsTlp, SysUtils;

procedure COBYLB(N, M, MPP : integer; var X:TVector; RHOBEG, RHOEND : float; IPRINT, MAXFUN: integer;
     var CON:TVector; var SIM, SIMI, DATMAT, A : TMatrix; var VSIG, VETA, SIGBAR, DX, W : TVector;
     CalcFC: TCobylaObjectProc);

implementation
const
   OutputFmt = 'NFVALS = %6.4d F = %13.6g  MaxCV = %13.6g';
procedure COBYLB(N, M, MPP : integer; var X:TVector; RHOBEG, RHOEND : float; IPRINT, MAXFUN: integer;
     var CON:TVector; var SIM, SIMI, DATMAT, A : TMatrix; var VSIG, VETA, SIGBAR, DX, W : TVector;
     CalcFC: TCobylaObjectProc);
var
  IFull:integer; // 1 means succcessful return from trstlp; 0 means degenerate gradient and fail
  iptem, iptemp:integer;
  F:float;  // value of user's function. Probably it is a good idea to return it.
  NFVals : integer; // number of function evaluations so far
  NP: integer; // N+1
  MP: integer; // M+1
  alpha, beta, gamma, delta : float;
  Rho: float; // current size of vertex
  Temp: float;
  error: float; // rounding error
  ResMax: Float;

  procedure FillOutput;
  var
    i: Integer;
  begin
    if ifull <> 1 then
    begin
      for i := 1 to n do
         x[i] := sim[i,np];
      F := datmat[mp,np];
      Resmax := datmat[mpp,np];
    end;
    maxfun := nfvals;

    if iprint >= 1 then
    begin
       if MathErr = optOK then
         writeln('normal return from subroutine cobyla')
       else
         writeln(MathErrMessage);
    end;

    if iprint >= 1 then
    begin
      writeln(Format(OutputFmt,[nfvals,F,resmax]));
      writeln('X:');
      for I := 1 to N do
         writeln(X[i]);
    end; // if
  end;

label
  40,130,140,370,440,550;
var
  I,J, k, jdrop, ibrnch, nbest, iflag, L:integer;
  parmu, phimin, parsig, pareta, phi, vmold, vmnew, trured, edgmax, cmin, cmax: float;
  tempa, wsig, weta, cvmaxp, cvmaxm, sum, dxsign, resnew, barmu, prerec, prerem, ratio, denom: float;

begin
   {Set the initial values of some parameters. The last column of SIM holds
   the optimal vertex of the current simplex, and the preceding N columns
   hold the displacements from the optimal vertex to the other vertices.
   Further, SIMI holds the inverse of the matrix that is contained in the
   first N columns of SIM.}
    SetErrCode(OptOK);
    iptem := min(n,5);
    iptemp := iptem+1;
    np := n+1;
    mp := m+1;
    alpha := 0.25;
    beta := 2.1;
    gamma := 0.5;
    delta := 1.1;
    rho := rhobeg;
    parmu := 0.0;
    if iprint >= 2 then
      writeln('The initial value of RHO is' ,Rho,' and PARMU is set to zero.');
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

  { Make the next call of the user-supplied subroutine CALCFC. These
   instructions are also used for calling CALCFC during the iterations of
   the algorithm. }

 40:if (nfvals >= maxfun) and (nfvals > 0) then
    begin
      SetErrCode(cobMaxFunc);
      FillOutput;
      Exit;
    end;
    inc(nfvals);
    CalcFC(N,M,X,F,Con);
    resmax := 0.0;
    for k := 1 to M do // Con is array of constrains; at the end must be non-negative
       resmax := max(ResMax,-Con[k]); // here largest violation is calculated
    Con[mp] := F;
    Con[mpp] := ResMax;
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
      FillOutput;
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
    if ifull = 0 then
    begin
      temp := 0.0;
      for i := 1 to N do
        temp := temp+dx[i]**2;
      if (temp < 0.25*rho*rho) then
      begin
        ibrnch := 1;
        goto 550;
      end;
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
      if iprint >= 2 then
        writeln('increase in parmu to',parmu);
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
    FillOutput;   // labels 600, 620 removed
end;

end.
