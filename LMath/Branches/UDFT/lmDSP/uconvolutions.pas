unit uConvolutions;

{$mode objfpc}

interface

uses
  uTypes, uMinMax, uErrors, uMatrix;

//Convolutes Signal[Lb..Ub] with FIR[Flb..High(Fir)] in time domain.
function Convolve(Signal:array of Float; FIR:array of float; Lb, Ub: integer;
         FLb : integer = 0; Ziel : TVector= nil):TVector;

implementation

function Convolve(Signal:array of float; FIR:array of float; Lb, Ub: integer;
         FLb : integer = 0; Ziel : TVector= nil):TVector;
var
  I, J, LS, LR, LF, Ind, Indc, HF, HFLb : integer;
  B:Float;
begin
  LS := Ub - Lb + 1;       // length of signal
  LF := length(FIR) - Flb; // length of FIR
  LR := LF + LS - 1;       // length of Result
  HF := High(FIR);
  if Ziel <> nil then
  begin
    Result := Ziel;
    if length(Ziel) < LR then
    begin
      SetErrCode(MatErrDim);
      Exit;
    end;
  end else
  begin
    DimVector(Result,LR-1);
    if Result = nil then
    begin
      SetErrCode(MatErrDim,'Too long array or no memory');
      Result := nil;
      Exit;
    end;
  end;
  if LS = 1 then
  begin
    B := Signal[Lb];
    for I := Flb to HF do
      Result[I-Flb] := Fir[I]*B;
    Exit;
  end;
  Indc := Lb - LF + 1 - FLb;
  HFLb := HF + Lb;
  for I := 0 to LF - 1 do
  begin
    Result[I] := 0;
    Ind := Indc + I;
    for J := Flb to HF do
    begin
      if Ind+J < Lb then
        Continue;
      Result[I] := Result[I] + Signal[Ind+J]*Fir[HFLb - J];
    end;
  end;

  for I := LF to LR-1-LF do
  begin
    Result[I] := 0;
    Ind := Indc + I;
    for J := FLb to HF do
      Result[I] := Result[I] + Signal[Ind+J]*FIR[HFLb - J];
  end;

  for I := LR - LF to LR - 1 do
  begin
    Result[I] := 0;
    Ind := Indc + I;
    for J := FLb to HF do
    begin
      if Ind+J > Ub then
        Break;
      Result[I] := Result[I] + Signal[Ind+J]*FIR[HFLb - J];
    end;
  end;
end;

end.

