unit lmRecursFilters;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uTypes, lmFilters, uFindFilterCoeffs, uVectorHelper;

type

  {%REGION THighPassFilter }

  THighPassFilter = class(TOneFreqFilter)
    private
      X, Old0, Old1: float;
      NewVal : float;
      A0, A1 : float;
    public
      procedure SetupFilter(ASamplingRate, ACornerFreq : Float); override;
      procedure Filter(StartIndex, EndIndex:integer); override;
      procedure InitFiltering; override;
      procedure NextPoint; override;
  end;
 {%ENDREGION}
 {%REGION TNarrowBandFilter}

 { TNarrowBandFilter }

 TNarrowBandFilter = class(TOneFreqFilter)
    private
      FBW:float;
      A : TInCoeffs;
      B : TRecursCoeffs;
      K, R, CoF : float;
    protected
      Old: array[-2..0] of Float;
      New: array[-2..0] of Float;
      NewVal: float;
      procedure SetBandWidth(ABandWidth:float); virtual;
      procedure SetSamplingrate(AValue: Float); override;
      procedure SetCornerFreq(ACornerFreq:float); override;
    public
      procedure SetupFilter(ASamplingRate, ACornerFreq : Float); override;
      procedure SetupNarrowBandFilter(ASamplingRate, ABandFreq, ABandWidth : float); virtual;
      procedure Filter(StartIndex: integer; EndIndex:integer); override;
      procedure InitFiltering; override;
      procedure NextPoint; override;
   published
      property BandWidth : float read FBW write SetBandWidth;
  end;
  {%ENDREGION}
  {%REGION TNotchFilter }

  TNotchFilter = class(TNarrowBandFilter)
    public
      procedure SetupNarrowBandFilter(ASamplingRate, ABandFreq, ABandWidth : float); override;
  end;
 {%ENDREGION}
  {%REGION TBandPassFilter }

  TBandPassFilter = class(TNarrowBandFilter)
  public
    procedure SetupNarrowBandFilter(ASamplingRate, ABandFreq, ABandWidth : float); override;
  end;
  {%ENDREGION}
  {%REGION TChebyshevFilter }

  { TChebyshevFilter }

  TChebyshevFilter = class(TOneFreqFilter)
    private
      A,B       : TVector;
      FNumPoles : integer;
      FRipple   : float;
      FHighPass : boolean;
      BR           : TVector;
      Old, NewData : TVector;
    public
      procedure Filter(StartIndex, EndIndex:integer); override;
      procedure SetupChebyshevFilter(ASamplingRate: Float; ACornerFreq: Float;
                              ANPoles: integer; APRipple: float; AHighPass:boolean);
      procedure SetupFilter(ASamplingRate, ACornerFreq : float); override;
      procedure InitFiltering; override;
      procedure NextPoint; override;
  end;
 {%ENDREGION}
  procedure Register;

implementation

{%REGION TChebyshevFilter }

procedure TChebyshevFilter.SetupChebyshevFilter(ASamplingRate: Float; ACornerFreq: Float;
                              ANPoles: integer; APRipple: float; AHighPass:boolean);
var
  I,J:integer;
begin
  if not (ANPoles in [2,4,6,8,10]) then
    Raise EFilterException.Create('Number of poles must be even between 2 and 10.');
  if ACornerFreq > 0.5*ASamplingRate then
    Raise EFilterException.Create('Cut-off frequenca must be below half of sampling rate.');
  if (APRipple < 0) or (APRipple > 29.0) then
    Raise EFilterException.Create('Passband ripple must be between 0 and 29%.');
  FCornerFreq := ACornerFreq;
  FSamplingRate := ASamplingRate;
  FRipple := APRipple;
  FHighPass := AHighPass;
  FNumPoles := ANPoles;
  FindChebyshevCoeffs(ASamplingRate,ACornerFreq,AHighPass,APRipple,ANPoles,A,B);
  DimVector(Old,FNumPoles);
  DimVector(BR,FNumPoles);
  DimVector(NewData,FNumPoles);
  J := FNumPoles;
  for I := 0 to FNumPoles do
  begin                   // reverse B
    BR[J] := B[I];
    Dec(J);
  end;
end;

procedure TChebyshevFilter.SetupFilter(ASamplingRate, ACornerFreq: float);
begin
  if ReadyToUse then
    SetupChebyshevFilter(ASamplingRate, ACornerFreq, FNumPoles, FRipple, FHighPass)
  else
    SetupChebyshevFilter(ASamplingRate, ACornerFreq, 6, 0.5, false);
end;

procedure TChebyshevFilter.InitFiltering;
begin
  inherited InitFiltering;
  Old.Clear;
  NewData.Clear;
end;

procedure TChebyshevFilter.NextPoint;
var
  J:integer;
  CurrVal:float;
begin
  Old.Insert(FOnInput(Index),0); // value is inserted into beginning of Old, others are shifted to the right; last lost
  CurrVal := 0;
  for J := 0 to FNumPoles do
    CurrVal := CurrVal + Old[J]*A[J] + NewData[J]*BR[J];
  FOnOutput(CurrVal,Index);
  NewData[FNumPoles] := CurrVal;
  NewData.Remove(0); // all elements shifted to left; length remains unchanged
  inc(Index);
end;

procedure TChebyshevFilter.Filter(StartIndex, EndIndex: integer);
var
  I, J         : integer;
  CurrVal      : float;
begin
  J := FNumPoles;
  Old.Clear;
  NewData.Clear;
  for I := StartIndex to EndIndex do
  begin
    Old.Insert(FOnInput(I),0); // value is inserted into beginning of Old, others are shifted to the right; last lost
    CurrVal := 0;
    for J := 0 to FNumPoles do
      CurrVal := CurrVal + Old[J]*A[J] + NewData[J]*BR[J];
    FOnOutput(CurrVal,I);
    NewData[FNumPoles] := CurrVal;
    NewData.Remove(0); // all elements shifted to left; length remains unchanged
  end;
end;
{%ENDREGION}
{%REGION THighPassFilter }

procedure THighPassFilter.SetupFilter(ASamplingRate, ACornerFreq : Float);
begin
  inherited SetupFilter(ASamplingRate,ACornerFreq);
  X := exp(-TwoPi*FCornerFreq/FSamplingRate);
  A0 := (1+X)/2;
  A1 := -A0;
  NewVal := 0;
end;

procedure THighPassFilter.Filter(StartIndex, EndIndex: integer);
var
  I : integer;
begin
  Old0 := OnInput(StartIndex);
  for I := StartIndex+1 to EndIndex do
  begin
    Old1 := Old0;
    Old0 := OnInput(I);
    NewVal := Old0*A0 + Old1*A1 + NewVal*X;
    OnOutput(NewVal,I);
  end;
end;

procedure THighPassFilter.InitFiltering;
begin
  X := exp(-TwoPi*FCornerFreq/FSamplingRate);
  A0 := (1+X)/2;
  A1 := -A0;
  NewVal := 0;
  Index := 0;
  Old0 := 0;
end;

procedure THighPassFilter.NextPoint;
begin
  Old1 := Old0;
  Old0 := OnInput(Index);
  NewVal := Old0*A0 + Old1*A1 + NewVal*X;
  OnOutput(NewVal,Index);
  inc(Index);
end;
{%ENDREGION}
{%REGION TNarrowBandFilter}
procedure TNarrowBandFilter.SetBandWidth(ABandWidth: float);
begin
  if ABandWidth = FBW then exit;
  SetupNarrowBandFilter(FSamplingrate, FCornerFreq, ABandWidth);
end;

procedure TNarrowBandFilter.SetSamplingrate(AValue: Float);
begin
  if AValue = FSamplingrate then exit;
  SetupNarrowBandFilter(AValue, FCornerFreq, FBW);
end;

procedure TNarrowBandFilter.SetCornerFreq(ACornerFreq: float);
begin
  if ACornerFreq = FCornerFreq then exit;
  SetupNarrowBandFilter(FSamplingrate, ACornerFreq, FBW);
end;

procedure TNarrowBandFilter.SetupFilter(ASamplingRate, ACornerFreq: float);
begin
  if ReadyToUse then
    SetupNarrowBandFilter(ASamplingRate, ACornerFreq, FBW)
  else
    SetupNarrowBandFilter(ASamplingRate, ACornerFreq, 5.0);
end;

procedure TNarrowBandFilter.SetupNarrowBandFilter(ASamplingRate, ABandFreq, ABandWidth : float);
begin
  if ABandFreq > ASamplingrate / 2 then
    raise EFilterException.Create('Bandpass or Band reject frequency > Sampling rate / 2');
  if ABandWidth > ASamplingrate / 2 then
    raise EFilterException.Create('Bandwidth frequency > Sampling rate / 2');
  FSamplingRate := ASamplingRate;
  FCornerFreq     := ABandFreq;
  FBW           := ABandWidth;
  FindNarrowBandParams(FCornerFreq,FBW,FSamplingRate,K,R,CoF);
end;

procedure TNarrowBandFilter.Filter(StartIndex: integer; EndIndex: integer);
var
  I:integer;
  En: integer;
begin
  for I := -2 to 0 do
  begin
    Old[I] := 0;
    New[I] := 0;
  end;
  En := EndIndex;
  if not (Assigned(FOnInput) and Assigned(FOnOutput)) then Exit;
  for I := -2 to 0 do
  begin
    Old[I] := OnInput(StartIndex + I + 2);
    New[I] := 0;
  end;
  I := StartIndex+2;
  while I < En do // I := StartIndex+2 to EndIndex do
  begin
    Old[-2] := Old[-1];
    Old[-1] := Old[0];
    Old[0] := OnInput(I);
    NewVal := Old[0]*A[0]+Old[-1]*A[1]+Old[-2]*A[2]+New[-1]*B[1]+New[-2]*B[2];
    New[0] := NewVal;
    New[-2] := New[-1];
    New[-1] := New[0];
    OnOutput(NewVal,I);
    inc(I);
  end;
end;

procedure TNarrowBandFilter.InitFiltering;
var
  I:integer;
begin
  Index := 0;
  for I := -2 to 0 do
  begin
    Old[I] := 0;
    New[I] := 0;
  end;
end;

procedure TNarrowBandFilter.NextPoint;
begin
  Old[-2] := Old[-1];
  Old[-1] := Old[0];
  Old[0] := OnInput(Index);
  NewVal := Old[0]*A[0]+Old[-1]*A[1]+Old[-2]*A[2]+New[-1]*B[1]+New[-2]*B[2];
  New[0] := NewVal;
  New[-2] := New[-1];
  New[-1] := New[0];
  OnOutput(NewVal,Index);
  inc(Index);
end;

{%ENDREGION}
{%REGION TNotchFilter }
procedure TNotchFilter.SetupNarrowBandFilter(ASamplingRate, ABandFreq, ABandWidth: float);
begin
  inherited SetupNarrowBandFilter(ASamplingRate, ABandFreq, ABandWidth);
  FindNotchCoeffs(K,R,CoF,A,B);
end;
{%ENDREGION}
{%REGION TBandPassFilter }

procedure TBandPassFilter.SetupNarrowBandFilter(ASamplingRate, ABandFreq, ABandWidth: float);
begin
  inherited SetupNarrowBandFilter(ASamplingRate, ABandFreq, ABandWidth);
  FindBandPassCoeffs(K,R,CoF,A,B);
end;
{%ENDREGION}
procedure Register;
begin
  RegisterComponents('LMComponents', [TNotchFilter, TBandPassFilter,THighPassFilter,TChebyshevFilter]);
end;

end.

