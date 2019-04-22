unit uVecUtils;

interface
uses uTypes;

type
  TTestFunc    = function(X:Float):boolean;
  TIntTestFunc = function(X:Integer):boolean;
  
{ Checks if each component of vector X is within a fraction Tol of
  the corresponding component of the reference vector Xref. In this
  case, the function returns True, otherwise it returns False}
function CompVec(X, Xref : TVector;
                 Lb, Ub  : Integer;
                 Tol     : Float) : Boolean;

// applies Test function to any enement in [Lb..Ub] and returns true
// if for any of them Test returns true
function Any(Vector:TVector; Lb, Ub : integer; Test:TTestFunc):boolean; overload;
function Any(M:TMatrix; Lb1, Ub1, Lb2, Ub2 : integer; Test:TTestFunc):boolean; overload;
function Any(Vector:TIntVector; Lb, Ub : integer; Test:TIntTestFunc):boolean; overload;
function Any(M:TIntMatrix; Lb1, Ub1, Lb2, Ub2 : integer; Test:TIntTestFunc):boolean; overload;

function FirstElement(Vector:TVector; Lb, Ub : integer; Test:TTestFunc):integer; overload;
function FirstElement(M:TMatrix; Lb1, Ub1, Lb2, Ub2 : integer; Test:TTestFunc):TIntegerPoint; overload;

function FirstElement(Vector:TIntVector; Lb, Ub : integer; Test:TIntTestFunc):integer; overload;
function FirstElement(M:TIntMatrix; Lb1, Ub1, Lb2, Ub2 : integer; Test:TIntTestFunc):TIntegerPoint; overload;

implementation

function CompVec(X, Xref : TVector; Lb, Ub  : Integer; Tol : Float) : Boolean;
var
  I    : Integer;
  Ok   : Boolean;
  ITol : Float;
begin
  I := Lb;
  Ok := True;
  repeat
    ITol := Tol * Abs(Xref[I]);
    if ITol < MachEp then ITol := MachEp;
    Ok := Ok and (Abs(X[I] - Xref[I]) < ITol);
    I := I + 1;
  until (not Ok) or (I > Ub);
  CompVec := Ok;
end;

// applies Test function to any enement in [Lb..Ub] and returns true
// if for any of them Test returns true
function Any(Vector:TVector; Lb, Ub : integer; Test:TTestFunc):boolean;
var
  I:Integer;
begin
  for I := Lb to Ub do
    if Test(Vector[I]) then
    begin
      Result := true;
      Exit;
    end; 
  Result := false;
end;

function Any(M:TMatrix; Lb1, Ub1, Lb2, Ub2 : integer; Test:TTestFunc):boolean;
var
  I,J:integer;
begin
  for I := Lb1 to Ub1 do
    for J := Lb2 to Ub2 do
      if Test(M[I,J]) then
      begin
        Result := true;
        Exit;
      end; 
  Result := false;
end;

function Any(Vector:TIntVector; Lb, Ub : integer; Test:TIntTestFunc):boolean;
var
  I:Integer;
begin
  for I := Lb to Ub do
    if Test(Vector[I]) then
    begin
      Result := true;
      Exit;
    end; 
  Result := false;
end;

function Any(M:TIntMatrix; Lb1, Ub1, Lb2, Ub2 : integer; Test:TIntTestFunc):boolean;
var
  I,J:integer;
begin
  for I := Lb1 to Ub1 do
    for J := Lb2 to Ub2 do
      if Test(M[I,J]) then
      begin
        Result := true;
        Exit;
      end; 
  Result := false;
end;

function FirstElement(Vector:TVector; Lb, Ub : integer; Test:TTestFunc):integer;
var
  I:Integer;
begin
  for I := Lb to Ub do
    if Test(Vector[I]) then
    begin
      Result := I;
      Exit;
    end; 
  Result := Ub + 1;
end;

function FirstElement(M:TMatrix; Lb1, Ub1, Lb2, Ub2 : integer; Test:TTestFunc):TIntegerPoint;
var
  I,J:integer;
begin
  for I := Lb1 to Ub1 do
    for J := Lb2 to Ub2 do
      if Test(M[I,J]) then
      begin
        Result.X := I;
        Result.Y := J;
        Exit;
      end;
  Result.X := Ub1+1;
  Result.Y := Ub2+1; 
end;

function FirstElement(Vector:TIntVector; Lb, Ub : integer; Test:TIntTestFunc):integer;
var
  I:Integer;
begin
  for I := Lb to Ub do
    if Test(Vector[I]) then
    begin
      Result := I;
      Exit;
    end;
  Result := Ub+1; 
end;

function FirstElement(M:TIntMatrix; Lb1, Ub1, Lb2, Ub2 : integer; Test:TIntTestFunc):TIntegerPoint;
var
  I,J:integer;
begin
  for I := Lb1 to Ub1 do
    for J := Lb2 to Ub2 do
      if Test(M[I,J]) then
      begin
        Result.X := I;
        Result.Y := J;
        Exit;
      end;
  Result.X := Ub1+1;
  Result.Y := Ub2+1; 
end;

end.
