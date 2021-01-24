unit uFilters;

{$mode objfpc}{$H+}

interface

uses
  uTypes, uErrors, uMedian, uMeanSD, uIntervals, uVectorHelper;

procedure GaussFilter(var Data:TVector; ASamplingRate: Float;  ACutFreq: Float; Lb, Ub: integer);

procedure MovingAverageFilter(var Data:TVector; WinLength:integer; Lb, Ub: integer);

procedure MedianFilter(var Data:TVector; WinLength:integer; Lb, Ub: integer);

// notch filter rejects AFreqReject, aBW is rejected bandwidth, measured at 0.5 power (0.7 amplitude)
procedure NotchFilter(var Data:TVector; ASamplingRate: Float; AFreqReject: Float; ABW: Float;Lb, Ub : integer);

// notch filter passes AFreqReject, aBW is rejected bandwidth, measured at 0.5 power (0.7 amplitude)
procedure BandPassFilter(var Data:TVector; ASamplingRate: Float; AFreqPass: Float; ABW: Float; Lb, Ub : integer);

//finds effective cutoff frequency of cascade of 2 gaussian filters
function GaussCascadeFreq(Freq1, Freq2:Float):Float;

// finds risetime (10-90%) of a gaussian filter with given cut-off frequency
function GaussRiseTime(Freq:Float):Float;

//risetime of moving average filter (0-100%)
function MovAvRiseTime(SamplingRate:Float; WLength:integer):Float;

//cut-off freq. of moving average filter, given sampling rate and window length
function MoveAvCutOffFreq(SamplingRate:Float; WLength:integer):Float;

//find required window length from desired cut-off freq. and sampling rate
function MoveAvFindWindow(SamplingRate, CutOffFreq:Float):Integer;

implementation

{%REGION Moving Average}
function MovAvRiseTime(SamplingRate: Float; WLength: integer): Float;
begin
  Result := WLength/SamplingRate;
end;

function MoveAvCutOffFreq(SamplingRate: Float; WLength: integer): Float;
begin
  Result := 0.44292/Sqrt(WLength*WLength-1)*SamplingRate;
end;

function MoveAvFindWindow(SamplingRate, CutOffFreq: Float): Integer;
var
  F:Float;
begin
  F := CutOffFreq/SamplingRate;
  Result := Round(Sqrt(0.196196+F*F)/F);
end;

procedure MovingAverageFilter(var Data:TVector; WinLength:integer; Lb, Ub: integer);
var
  Buffer : Float;
  First  :float;
  IndNext: integer;
  I      :integer;
begin
  if Lb >= Ub then
    SetErrCode(MatErrDim);
  if WinLength > Ub - Lb then
    SetErrCode(lmDSPFilterWinError);
  if MathErr <> MatOK then
    Exit;
  IndNext := Lb + WinLength;  // points on first element after window
  Buffer := Sum(Data,Lb,IndNext-1);
  for I := Lb to Ub - WinLength do
  begin
    First := Data[I];
    Data[I] := Buffer / WinLength;
    Buffer := Buffer - First;
    Buffer := Buffer + Data[IndNext];
    Inc(IndNext);
  end;
  for I := Ub - WinLength + 1 to Ub do
  begin
    First := Data[I];
    Data[I] := Buffer / WinLength;
    Buffer := Buffer - First;
    Buffer := Buffer + Data[Ub];
  end;
end;

{%ENDREGION}

{%REGION Gaussian Filter}
type
  TPT = 0..3;
  TPTArray = array[TPT] of Float;

procedure GSFindParams (ASamplingRate:Float; ACutFreq: Float; out Sigma, BL, Q : Float; out Bs:TPTArray);
var
  Q2, Q3 : Float;
begin
  Sigma := ASamplingrate*0.83/(TwoPi*ACutFreq);
  if Sigma >= 2.5 then
    Q := 0.98711 * Sigma - 0.96330
  else
    Q := 3.97156 - 4.14554 * Sqrt(1 - 0.26891 * Sigma);
  Q2 := Q*Q;
  Q3 := Q2*Q;
  Bs[0] := 1.57825 + 2.44413*Q + 1.4281*Q2 + 0.422205*Q3;
  Bs[1] := 2.44413*Q + 2.85619*Q2 + 1.26661*Q3;
  Bs[2] := -1.4281*Q2 - 1.26661*Q3;
  Bs[3] := 0.422205*Q3;
  BL    := 1 - (Bs[1] + Bs[2] + Bs[3])/Bs[0];
end;

procedure GSForwardFilter(var Data:TVector; Bs:TPTArray; Bl:Float; Lb, Ub:integer);
var
  WD : TPTArray;
  Pt : array [TPT] of TPT;
  I  : integer;
  J  : TPT;
begin
  WD[0] := Data[Lb];
  Pt[0] := 0;
  for I := 1 to 3 do
  begin
    WD[I] := WD[0];  //data are padded before beginning with Data[Lb]
    Pt[I] := I;
  end;
  for I := Lb to Ub - 1 do
  begin
    Data[I] := WD[Pt[3]];
    WD[Pt[3]] := BL*Data[I+1]+(WD[Pt[2]]*Bs[1]+WD[Pt[1]]*Bs[2]+Bs[3]*WD[Pt[0]])/Bs[0];
    for J := 0 to 3 do
      if Pt[J] < 3 then
        Pt[J] := Succ(Pt[J])
      else
        Pt[J] := 0;
  end;
  Data[Ub] := WD[Pt[3]];
end;

procedure GSBackwardFilter(var Data:TVector; Bs:TPTArray; BL: Float; Lb, Ub:integer);
var
  WD : TPTArray;
  Pt : array [TPT] of TPT;
  I  : integer;
  J  : TPT;
begin
  WD[0] := Data[Ub];
  Pt[0] := 0;
  for J := 1 to 3 do
  begin
    Pt[J] := J;
    WD[J] := WD[0];
  end;
  for I := Ub downto Lb+1 do
  begin
    Data[I] := WD[Pt[3]];
    WD[Pt[3]] := BL*Data[I-1]+(WD[Pt[2]]*Bs[1]+WD[Pt[1]]*Bs[2]+Bs[3]*WD[Pt[0]])/Bs[0];
    for J := 0 to 3 do
      if Pt[J] < High(TPT) then
        Pt[J] := Succ(Pt[J])
      else
        Pt[J] := Low(TPT);
  end;
  Data[Lb] := WD[Pt[3]];
end;

procedure GaussFilter(var Data:TVector; ASamplingRate: Float;  ACutFreq: Float; Lb, Ub: integer);
var
  Sigma : Float;
      Q : Float;
     Bs : TPTarray;
     BL : Float;
begin
  GSFindParams(ASamplingRate,ACutFreq,Sigma,BL,Q,Bs);
  GSForwardFilter(Data,Bs,BL,Lb,Ub);
  GSBackwardFilter(Data,Bs,BL,Lb,Ub);
end;

function GaussCascadeFreq(Freq1, Freq2: Float): Float;
begin
  if Freq1 = 0 then
    Result := Freq2
  else if Freq2 = 0 then
    Result := Freq1
  else
    Result := 1/Sqrt(1/Freq1/Freq1 + 1/Freq2/Freq2);
end;

function GaussRiseTime(Freq: Float): Float;
begin
  if Freq = 0 then
    Result := MaxNum
  else
    Result := 0.33/Freq;
end;
{%ENDREGION}

{%REGION Median Filter}
procedure MedianFilter(var Data:TVector; WinLength:integer; Lb, Ub: integer);
var
  I,HighWin : integer;
  Buffer:TVector;
begin
  HighWin := WinLength-1;
  for I := Lb to Ub-WinLength do
  begin
    Buffer := copy(Data,I,WinLength);
    Data[I] := Median(Buffer,0,HighWin);
  end;
  for I := Ub-WinLength+1 to Ub do
  begin
    Buffer.InsertFrom(Data,I,Ub,0);
    Buffer.Fill(Ub-I,HighWin,Data[Ub]);
    Data[I] := Median(Buffer,0,HighWin);
  end;
end;


{%ENDREGION}

{%REGION NARROWBAND Filters}
type
  TRecursCoeffs = array[1..2] of Float;
  TInCoeffs = array[0..2] of Float;

procedure FindNarrowBandParams(CentralFreq, BW, SamplingRate : Float; out K, R, CoF : float; out B:TRecursCoeffs);
var
  FrRatio, BWRatio: float;
begin
  FrRatio := CentralFreq/SamplingRate;
  BWratio := BW/SamplingRate;
  R := 1-3*BWRatio;
  CoF := 2*cos(TwoPi*FRRatio);
  K := (1 - R*CoF + R*R)/(2 - CoF);
end;

procedure FindBandPassCoeffs(K, R, Cof : Float; out A:TInCoeffs; out B:TRecursCoeffs);
begin
  A[0] := 1 - K;
  A[1] := (K-R)*CoF;
  A[2] := R*R-K;
  B[1] := R*CoF;
  B[2] := -R*R;
end;

procedure FindNotchCoeffs(K, R, Cof : Float; out A:TInCoeffs; out B:TRecursCoeffs);
begin
  A[0] := K;
  A[1] := CoF * (-K);
  A[2] := K;
  B[1] := R*CoF;
  B[2] := -R*R;
end;

procedure ApplyNarrowBandFilter(var Data: TVector;  Lb: integer; Ub: integer; const A: TInCoeffs; const B: TRecursCoeffs);
var
  I,J: integer;
  Old: array[-2..0] of Float;
begin
  for I := -2 to 0 do
    Old[I] := Data[I+2];
  Data[Lb] := Data[Lb]*A[2]+Data[Lb]*A[1]+Data[Lb]*A[0]+Data[Lb]*B[1]+Data[Lb]*B[2];
  Data[Lb+1] := Data[Lb+1]*A[0]+Data[Lb]*A[1]+Data[Lb]*A[2]+Data[Lb]*B[1]+Data[Lb]*B[2];
  for I := Lb+2 to Ub do
  begin
    for J := -2 to -1 do
      Old[J] := Old[J+1];
    Old[0] := Data[I];
    Data[I] := Data[I]*A[0]+Old[-1]*A[1]+Old[-2]*A[2]+Data[I-1]*B[1]+Data[I-2]*B[2];
  end;
end;

procedure NotchFilter(var Data:TVector; ASamplingRate: Float; AFreqReject: Float; ABW: Float;Lb, Ub : integer);
var
  K, R, CoF : Float;
  A: TInCoeffs;
  B: TRecursCoeffs;
begin
  FindNarrowBandParams(AFreqReject,ABW,ASamplingRate,K,R,CoF,B);
  FindNotchCoeffs(K,R,CoF,A,B);
  ApplyNarrowBandFilter(Data,Lb,Ub,A,B);
end;

// notch filter passes AFreqReject, aBW is rejected bandwidth, measured at 0.5 power (0.7 amplitude)
procedure BandPassFilter(var Data:TVector; ASamplingRate: Float; AFreqPass: Float; ABW: Float; Lb, Ub : integer);
var
  K, R, CoF : Float;
  A: TInCoeffs;
  B: TRecursCoeffs;
begin
  FindNarrowBandParams(AFreqPass,ABW,ASamplingRate,K,R,CoF,B);
  FindBandPassCoeffs(K,R,CoF,A,B);
  ApplyNarrowBandFilter(Data,Lb,Ub,A,B);
end;
{%ENDREGION}
end.

