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
      procedure SetupFilter(ASamplingRate, ACutFreq1 : Float); override;
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
      procedure SetCutFreq1(ACutFreq1:float); override;
    public
      constructor Create(AOwner:TComponent); override;
      procedure SetupFilter(ASamplingRate, ABandFreq, ABandWidth : float); virtual;
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
      procedure SetupFilter(ASamplingRate, ABandFreq, ABandWidth : float); override;
  end;
 {%ENDREGION}
  {%REGION TBandPassFilter }

  TBandPassFilter = class(TNarrowBandFilter)
  public
    procedure SetupFilter(ASamplingRate, ABandFreq, ABandWidth : float); override;
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
      constructor Create(AOwner:TComponent); override;
      procedure Filter(StartIndex, EndIndex:integer); override;
      procedure SetupChebyshevFilter(ASamplingRate: Float; ACutFreq: Float;
                              ANPoles: integer; APRipple: float; AHighPass:boolean);
      procedure InitFiltering; override;
      procedure NextPoint; override;
  end;
 {%ENDREGION}
  procedure Register;

implementation

{%REGION TChebyshevFilter }

procedure TChebyshevFilter.SetupChebyshevFilter(ASamplingRate: Float; ACutFreq: Float;
                              ANPoles: integer; APRipple: float; AHighPass:boolean);
var
  I,J:integer;
begin
  SetupFilter(ASamplingRate, ACutFreq);
   if not (ANPoles in [2,4,6,8,10]) then
     Raise EFilterException.Create('Number of poles must be even between 2 and 10.');
  if ACutFreq > 0.5*ASamplingRate then
    Raise EFilterException.Create('Cut-off frequenca must be below half of sampling rate.');
  if (APRipple < 0) or (APRipple > 29.0) then
    Raise EFilterException.Create('Passband ripple must be between 0 and 29%.');
  FNumPoles := ANPoles;
  FRipple := APRipple;
  FHighPass := AHighPass;
  FindChebyshevCoeffs(ASamplingRate,ACutFreq,AHighPass,APRipple,ANPoles,A,B);
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

constructor TChebyshevFilter.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  SetupChebyshevFilter(14440,4000,6,0.5,false);
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

procedure THighPassFilter.SetupFilter(ASamplingRate, ACutFreq1 : Float);
begin
  inherited SetupFilter(ASamplingRate,ACutFreq1);
  X := exp(-TwoPi*FCutFreq1/FSamplingRate);
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
  X := exp(-TwoPi*FCutFreq1/FSamplingRate);
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
  SetupFilter(FSamplingrate, FCutFreq1, ABandWidth);
end;

procedure TNarrowBandFilter.SetSamplingrate(AValue: Float);
begin
  if AValue = FSamplingrate then exit;
  SetupFilter(AValue, FCutFreq1, FBW);
end;

procedure TNarrowBandFilter.SetCutFreq1(ACutFreq1: float);
begin
  if ACutFreq1 = FCutFreq1 then exit;
  SetupFilter(FSamplingrate, ACutFreq1, FBW);
end;

constructor TNarrowBandFilter.Create(AOwner:TComponent);
begin
    inherited Create(AOwner);
    SetupFilter(14400.0,4000.0,5.0);
end;

procedure TNarrowBandFilter.SetupFilter(ASamplingRate, ABandFreq, ABandWidth : float);
begin
  if FCutFreq1 > FSamplingrate / 2 then
    raise EFilterException.Create('Bandpass or Band reject frequency > Sampling rate / 2');
  if ABandWidth > FSamplingrate / 2 then
    raise EFilterException.Create('Bandwidth frequency > Sampling rate / 2');
  FSamplingRate := ASamplingRate;
  FCutFreq1     := ABandFreq;
  FBW           := ABandWidth;
  FindNarrowBandParams(FCutFreq1,FBW,FSamplingRate,K,R,CoF);
end;

procedure TNarrowBandFilter.Filter(StartIndex: integer; EndIndex: integer);
var
  I:integer;
  J:integer;
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
    for J := -2 to -1 do
      Old[J] := Old[J+1];
    Old[0] := OnInput(I);
    NewVal := Old[0]*A[0]+Old[-1]*A[1]+Old[-2]*A[2]+New[-1]*B[1]+New[-2]*B[2];
    New[0] := NewVal;
    for J := -2 to -1 do
      New[J] := New[J+1];
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
var
  J:integer;
begin
  for J := -2 to -1 do
    Old[J] := Old[J+1];
  Old[0] := OnInput(Index);
  NewVal := Old[0]*A[0]+Old[-1]*A[1]+Old[-2]*A[2]+New[-1]*B[1]+New[-2]*B[2];
  New[0] := NewVal;
  for J := -2 to -1 do
    New[J] := New[J+1];
  OnOutput(NewVal,Index);
  inc(Index);
end;

{%ENDREGION}
{%REGION TNotchFilter }

procedure TNotchFilter.SetupFilter(ASamplingRate, ABandFreq, ABandWidth: float);
begin
  inherited SetupFilter(ASamplingRate, ABandFreq, ABandWidth);
  FindNotchCoeffs(K,R,CoF,A,B);
end;
{%ENDREGION}
{%REGION TBandPassFilter }

procedure TBandPassFilter.SetupFilter(ASamplingRate, ABandFreq, ABandWidth: float);
begin
  inherited SetupFilter(ASamplingRate, ABandFreq, ABandWidth);
  FindBandPassCoeffs(K,R,CoF,A,B);
end;
{%ENDREGION}
procedure Register;
begin
  RegisterComponents('LMComponents', [TNotchFilter, TBandPassFilter,THighPassFilter,TChebyshevFilter]);
end;

end.

