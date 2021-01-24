unit uConvolutions;

{$mode objfpc}{$H+}

interface

uses
  uTypes, uMinMax, uErrors;

//Convolutes Signal[Lb..Ub] with FIR[Flb..High(Fir)] in time domain.
function Convolve(var Signal:TVector; FIR:TVector; Lb, Ub: integer;
         FLb : integer = 0; Ziel : TVector= nil):TVector;

implementation

function Convolve(var Signal:TVector; FIR:TVector; Lb, Ub: integer;
         FLb : integer = 0; Ziel : TVector= nil):TVector;

var
  I, J, LS, LR, LF, Ind, Indc, HF, HFLb : integer;
begin

  LS := Ub - Lb + 1;
  LF := length(FIR) - Flb;
  LR := LF + LS - 1;
  HF := High(FIR);
  if Ziel <> nil then
  begin
    if length(Ziel) < LR then
    begin
      Result := nil;
      SetErrCode(MatErrDim);
      Exit;
    end else
      Result := Ziel;
  end else
  begin
    DimVector(Result,LR-1);
    if Result = nil then
    begin
      SetErrCode(MatErrDim,'Too long array or no memory');
      Exit;
    end;
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

