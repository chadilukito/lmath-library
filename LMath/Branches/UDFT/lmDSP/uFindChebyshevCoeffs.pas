 //CHEBYSHEV FILTER- RECURSION COEFFICIENT CALCULATION
unit uFindChebyshevCoeffs;
interface
uses uTypes, uErrors, uMath, uMeanSD, uTrigo, uConvolutions, uVectorHelper;
type
  TAOne = array[0..2] of Float;
  TBOne = array[0..2] of Float;

procedure ChebyshevParams(FC, PR : float; P, NP : integer; AHighPass: boolean; out AOne:TAOne; out BOne:TBOne);

procedure FindChebyshevCoeffs(ASamplingRate, ACutFreq: float; AHighPass : boolean; PR: float;
   NPoles: integer; out A,B:TVector);

implementation
//type
//  TAOne = array[0..2] of Float;
//  TBOne = array[0..2] of Float;

{THIS SUBROUTINE IS CALLED FROM TABLE 20-4, LINE 340
Variables entering subroutine: PI, FC, LH, PR, HP, P%
Variables exiting subroutine: AOne, BOne
Variables used internally: RP, IP, ES, VX, KX, T, W, M, D, K,
X0, X1, X2, Y1, Y2
}
procedure ChebyshevParams(FC, PR : float; P, NP : integer; AHighPass: boolean; out AOne:TAOne; out BOne:TBOne);
var
  RP, IP, ES, VX, KX, T, W, M, D, K, X0, X1, X2, Y1, Y2 : float;
  Tquad : float;
// Calculate the pole location on the unit circle
begin
  RP := -cos(PiDiv2/NP + (P-1)*Pi/NP);
  IP :=  sin(PiDiv2/NP + (P-1)*Pi/NP);
// Warp from a circle to an ellipse
  IF PR <> 0 then 
  begin
    ES := Sqrt(Sqr(100/(100-PR)) - 1); //may be sqr, but looks more like Pythagor calc
    VX := 1/NP*Log(1/ES + Sqrt(1/Sqr(ES) + 1));
    KX := 1/NP*Log(1/ES + Sqrt(1/Sqr(ES) - 1));
    KX := (EXP(KX) + EXP(-KX))/2;
    RP := RP * ((EXP(VX) - EXP(-VX)) /2 )/KX;
    IP := IP * ((EXP(VX) + EXP(-VX)) /2 )/KX;
  end;
  //s-domain to z-domain conversion
  T  := 2 * Tan(1/2);
  TQuad := T*T;
  W  := TwoPi*FC;
  M  := RP*RP + IP*IP;
  D  := 4 - 4*RP*T + M*TQuad;
  X0 := TQuad/D;
  X1 := 2*TQuad/D;
  X2 := TQuad/D;
  Y1 := (8 - 2*M*TQuad)/D;
  Y2 := (-4 - 4*RP*T - M*TQuad)/D;

 // LP TO LP, or LP TO HP transform
  IF AHighPass THEN 
    K := -Cos(W/2 + 1/2) / Cos(W/2 - 1/2)
  else
    K :=  Sin(1/2 - W/2) / Sin(1/2 + W/2);
  D  := 1 + Y1*K - Y2*K*K;
  AOne[0] := (X0 - X1*K + X2*K*K)/D;
  AOne[1] := (-2*X0*K + X1 + X1*K*K - 2*X2*K)/D;
  AOne[2] := (X0*K*K- X1*K + X2)/D;
  BOne[0] := 1;
  BOne[1] := (2*K + Y1 + Y1*K*K - 2*Y2*K)/D;
  BOne[2] := (-(K*K) - Y1*K + Y2)/D;
  IF AHighPass then
  begin
    AOne[1] := -AOne[1];
    BOne[1] := -BOne[1];
  end;
end;

// AHighPass: if we need high or low pass filter; PR percent of ripple in step response, 0 to 29
// NPoles must be even
procedure FindChebyshevCoeffs(ASamplingRate, ACutFreq: float; AHighPass : boolean; PR: float; 
   NPoles: integer; out A,B:TVector);
var
  TA, TB : TVector;
  FC: Float;
  I,J:integer;
  SA, SB, Gain: float;
  AOne:TAOne;
  BOne:TBOne;
begin
  if NPoles Mod 2 <> 0 then
  begin
    A := nil;
    B := nil;
    SetErrCode(lmPolesNumError);
    exit;
  end;
  //DimVector(A,NPoles); DimVector(TA,NPoles);
  //DimVector(B,NPoles); DimVector(TB,NPoles);
  DimVector(A,22); DimVector(TA,22);
  DimVector(B,22); DimVector(TB,22);
  //A[0] := 1.0;
  //B[0] := 1.0;
  A[2] := 1.0;
  B[2] := 1.0;

  FC := ACutFreq/ASamplingRate;
  FOR I := 1 to NPoles div 2 do //LOOP FOR EACH POLE-PAIR
  begin
    ChebyshevParams(FC, PR, I, NPoles, AHighPass, AOne, BOne);
    TA.FillWithArr(0,A);
    TB.FillWithArr(0,B);
    //Convolve(TA,AOne,0,NPoles,0,A);
    //Convolve(TB,BOne,0,I*3-1,0,B);
    for J := 2 to 22 do
    begin
      A[J] := AOne[0]*TA[J] + AOne[1]*TA[J-1] + AOne[2]*TA[J-2];
      B[J] := TB[J] - BOne[1]*TB[J-1] - BOne[2]*TB[J-2];
    end;
  end;

  B[2] := 0; //Finish combining coefficients
  FOR I := 0 TO 20 do
  begin
    A[I] := A[I+2];
    B[I] := -B[I+2];
  end;
  //SA := Sum(A,0,20); //NORMALIZE THE GAIN
  //SB := Sum(B,0,20);
  SA := 0; SB := 0;
  FOR I := 0 TO 20 do
  begin
    if AHighPass and ((I mod 2) = 1) then
    begin
      SA := SA - A[I];
      SB := SB - A[I];
    end else
    begin
      SA := SA + A[I];
      SB := SB + B[I];
    end;
  end;
  GAIN := SA / (1 - SB);
  FOR I := 0 TO 20 do
    A[I] := A[I] / GAIN;
//The final recursion coefficients are in A[ ] and B[ ]
end;

end.

