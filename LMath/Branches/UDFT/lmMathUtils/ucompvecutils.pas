unit uCompVecUtils;

{$mode objfpc}{$H+}

interface

uses
  uTypes, uMinMax, uErrors, uComplex;

type
  // general function for testing complex value for a condition
  // function(Val:complex):boolean
  TComplexTestFunc = function(Val:complex):boolean;

  // general complex function of complex argument
  // function(Arg:complex):Complex
  TComplexFunc = function(Arg:Complex):complex;

  // general function for comparison of complex
  // function(Val, Ref:complex):boolean
  // FirstElement and SelElements pass array elements to Val and
  // user-supplied Ref value to Ref
  TComplexComparator = function(Val, Ref:complex):boolean;

function ExtractReal(CVec:TCompVector; Lb, Ub:integer):TVector;
function ExtractImaginary(CVec:TCompVector; Lb, Ub:integer):TVector;
function CombineCompVec(VecRe, VecIm:TVector; Lb, Ub:integer):TCompVector;

function CMakePolar(V:TCompVector; Lb, Ub:integer):TCompVector;
function CMakeRectangular(V:TCompVector; Lb, Ub:integer):TCompVector;

function MaxReLoc(CVec:TCompVector; Lb, Ub:integer):integer;
function MaxImLoc(CVec:TCompVector; Lb, Ub:integer):integer;
function MinReLoc(CVec:TCompVector; Lb, Ub:integer):integer;
function MinImLoc(CVec:TCompVector; Lb, Ub:integer):integer;

procedure Apply(V:TCompVector; Lb, Ub: integer; Func:TComplexFunc); overload;
function CompareCompVec(X, Xref : TCompVector; Lb, Ub  : Integer; Tol : Float) : Boolean; overload;
function Any(Vector:TCompVector; Lb, Ub : integer; Test:TComplexTestFunc):boolean; overload;
function FirstElement(Vector:TCompVector; Lb, Ub : integer; Ref:complex; Comparator:TComplexComparator):integer; overload;
function ComplexSeq(Lb, Ub : integer; firstRe, firstIm, incrementRe, incrementIm:Float; Vector:TCompVector = nil):TCompVector;
function SelElements(Vector:TCompVector; Lb, Ub, ResLb : integer;
         Ref:complex; Comparator:TComplexComparator):TIntVector; overload;
function ExtractElements(Vector:TCompVector; Mask:TIntVector; Lb:integer):TCompVector; overload;

implementation

function ExtractReal(CVec: TCompVector; Lb, Ub: integer): TVector;
var
  I:integer;
begin
  DimVector(Result, Ub);
  for I := Lb to Ub do
    Result[I] := CVec[I].X;
end;

function ExtractImaginary(CVec: TCompVector; Lb, Ub: integer): TVector;
var
  I:integer;
begin
  DimVector(Result, Ub);
  for I := Lb to Ub do
    Result[I] := CVec[I].Y;
end;

function CombineCompVec(VecRe, VecIm: TVector; Lb, Ub: integer): TCompVector;
var
  I:integer;
begin
  DimVector(Result, Ub);
  for I := Lb to Ub do
  begin
    Result[I].X := VecRe[I];
    Result[I].Y := VecIm[I];
  end;
end;

function MaxReLoc(CVec: TCompVector; Lb, Ub: integer): integer;
var
  I:integer;
  MaxVal:float;
begin
  Result := Lb;
  Ub := min(Ub,High(CVec));
  if Lb > Ub then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  MaxVal := CVec[Lb].X;
  for I := Lb+1 to Ub do
    if CVec[I].X > MaxVal then
    begin
      MaxVal := CVec[I].X;
      Result := I;
    end;
end;

function MaxImLoc(CVec: TCompVector; Lb, Ub: integer): integer;
var
  I:integer;
  MaxVal:float;
begin
  Result := Lb;
  Ub := min(Ub,High(CVec));
  if Lb > Ub then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  MaxVal := CVec[Lb].Y;
  for I := Lb+1 to Ub do
    if CVec[I].X > MaxVal then
    begin
      MaxVal := CVec[I].Y;
      Result := I;
    end;
end;

function MinReLoc(CVec: TCompVector; Lb, Ub: integer): integer;
var
  I:integer;
  MinVal:float;
begin
  Result := Lb;
  Ub := min(Ub,High(CVec));
  if Lb > Ub then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  MinVal := CVec[Lb].X;
  for I := Lb+1 to Ub do
    if CVec[I].X < MinVal then
    begin
      MinVal := CVec[I].Y;
      Result := I;
    end;
end;

function MinImLoc(CVec: TCompVector; Lb, Ub: integer): integer;
var
  I:integer;
  MinVal:float;
begin
  Result := Lb;
  Ub := min(Ub,High(CVec));
  if Lb > Ub then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  MinVal := CVec[Lb].Y;
  for I := Lb+1 to Ub do
    if CVec[I].Y < MinVal then
    begin
      MinVal := CVec[I].Y;
      Result := I;
    end;
end;

procedure Apply(V: TCompVector; Lb, Ub: integer; Func: TComplexFunc);
var
  I:integer;
begin
  Ub := min(High(V),Ub);
  if Lb > Ub then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  for I := Lb to Ub do
    V[I] := Func(V[I]);
end;

function CompareCompVec(X, Xref: TCompVector; Lb, Ub: Integer; Tol: Float): Boolean;
var
  I    : Integer;
  Ok   : Boolean;
  ReTol, ImTol : Float;
begin
  I := Lb;
  Ub := min(Ub,High(X));
  Ub := min(Ub,High(XRef));
  if Lb > Ub then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  Ok := True;
  repeat
    ReTol := Tol * Abs(XRef[I].X);
    ImTol := Tol * Abs(Xref[I].Y);
    if ReTol < MachEp then ReTol := MachEp;
    if ImTol < MachEp then ImTol := MachEp;
    Ok := Ok and (Abs(X[I].Y - Xref[I].Y) < ImTol) and (Abs(X[I].X - Xref[I].X) < ReTol);
    Inc(I);
  until (not Ok) or (I > Ub);
  Result := Ok;
end;

function Any(Vector: TCompVector; Lb, Ub: integer; Test: TComplexTestFunc): boolean;
var
  I:Integer;
begin
  Ub := min(Ub,High(Vector));
  if Lb > Ub then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  for I := Lb to Ub do
    if Test(Vector[I]) then
    begin
      Result := true;
      Exit;
    end;
  Result := false;
end;

function FirstElement(Vector: TCompVector; Lb, Ub: integer; Ref: complex; Comparator: TComplexComparator): integer;
var
  I:Integer;
begin
  Ub := min(Ub,High(Vector));
  if Lb > Ub then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  for I := Lb to Ub do
    if Comparator(Vector[I],Ref) then
    begin
      Result := I;
      Exit;
    end;
  Result := Ub + 1;
end;

function ComplexSeq(Lb, Ub: integer; firstRe, firstIm, incrementRe, incrementIm: Float; Vector: TCompVector = nil): TCompVector;
var
  I:integer;
begin
  if Vector = nil then
    DimVector(Vector, Ub)
  else
    Ub := min(Ub,High(Vector));
  if Lb <= Ub then
  begin
    Vector[Lb].X := 0;
    Vector[Lb].Y := 0;
  end else
    Exit;
  for I := Lb+1 to Ub do
  begin                                          // 2 cycles to avoid rounding error if
    Vector[I].X := Vector[I-1].X + incrementRe;  //First is very large and increment small
    Vector[I].Y := Vector[I-1].Y + incrementIm;
  end;
  for I := Lb to Ub do
  begin
    Vector[I].X := Vector[I].X+firstRe;
    Vector[I].Y := Vector[I].Y+firstIm;
  end;
  Result := Vector;
end;

function SelElements(Vector: TCompVector; Lb, Ub, ResLb: integer; Ref: complex; Comparator: TComplexComparator
  ): TIntVector;
var
  I,N:integer;
begin
  Ub := min(high(Vector),Ub);
  if Lb > Ub then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  DimVector(Result,Ub-Lb+ResLb);
  N := ResLb-1;
  for I := Lb to Ub do
    if Comparator(Vector[I],Ref) then
    begin
      inc(N);
      Result[N] := I;
    end;
  if N >= ResLb then
    SetLength(Result,N+1)
  else
    SetLength(Result,0);
end;

function ExtractElements(Vector: TCompVector; Mask: TIntVector; Lb: integer): TCompVector;
var
  I:integer;
begin
  DimVector(Result,High(Mask));
  for I := Lb to High(Mask) do
    Result[I] := Vector[Mask[I]];
end;

function CMakePolar(V:TCompVector; Lb, Ub:integer):TCompVector;
var
  I:integer;
begin
  if Ub > High(V) then
    Ub := High(V);
  if Ub < Lb then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  DimVector(Result,Ub);
  for I := Lb to Ub do
    Result[I] := CToPolar(V[I]);
end;

function CMakeRectangular(V:TCompVector; Lb, Ub:integer):TCompVector;
var
  I:integer;
begin
  if Ub > High(V) then
    Ub := High(V);
  if Ub < Lb then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  DimVector(Result,Ub);
  for I := Lb to Ub do
    Result[I] := CToRect(V[I]);
end;

end.

