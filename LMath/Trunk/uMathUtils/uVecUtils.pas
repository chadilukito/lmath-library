unit uVecUtils;

interface
uses uTypes, uMinMax, uRealPoints, uIntPoints;

type
  TTestFunc    = function(X:Float):boolean;
  TIntTestFunc = function(X:Integer):boolean;
  TTransformFunc = function(X:float):float;
  TIntTransformFunc = function(X:integer):integer;

  TMatCoords = record
    Row, Col :integer;
  end;
  
  function tmCoords(ARow,ACol:integer):TMatCoords;

  procedure Apply(V:TVector; Lb, Ub: integer; Func:TTransformFunc); overload;
  procedure Apply(M:TMatrix; LRow, URow, LCol, UCol: integer; Func:TTransformFunc); overload;
  procedure Apply(V:TIntVector; Lb, Ub: integer; Func:TIntTransformFunc); overload;
  procedure Apply(M:TIntMatrix; LRow, URow, LCol, UCol: integer; Func:TIntTransformFunc); overload;

  { Checks if each component of vector X is within a fraction Tol of
  the corresponding component of the reference vector Xref. In this
  case, the function returns True, otherwise it returns False}
function CompVec(X, Xref : TVector; Lb, Ub  : Integer; Tol : Float) : Boolean;

// applies Test function to every enement in [Lb..Ub] and returns true
// if for any of them Test returns true
function Any(Vector:TVector; Lb, Ub : integer; Test:TTestFunc):boolean; overload;
function Any(M:TMatrix; LRow, URow, LCol, UCol : integer; Test:TTestFunc):boolean; overload;
function Any(Vector:TIntVector; Lb, Ub : integer; Test:TIntTestFunc):boolean; overload;
function Any(M:TIntMatrix; LRow, URow, LCol, UCol : integer; Test:TIntTestFunc):boolean; overload;

function FirstElement(Vector:TVector; Lb, Ub : integer; Ref:float; Comparator:TComparator):integer; overload;
function FirstElement(M:TMatrix; LRow, URow, LCol, UCol : integer; Ref:float; Comparator:TComparator):TMatCoords; overload;

function FirstElement(Vector:TVector; Lb, Ub : integer; Test:TTestFunc):integer; overload;
function FirstElement(M:TMatrix; LRow, URow, LCol, UCol : integer; Test:TTestFunc):TMatCoords; overload;

function FirstElement(Vector:TIntVector; Lb, Ub : integer; Ref:integer; Comparator:TIntComparator):integer; overload;
function FirstElement(M:TIntMatrix; LRow, URow, LCol, UCol : integer; Ref:integer; Comparator:TIntComparator):TMatCoords; overload;

function FirstElement(Vector:TVector; Lb, Ub : integer; Ref:float; CompType:TCompOperator):integer; overload;
function FirstElement(M:TMatrix; LRow, URow, LCol, UCol : integer; Ref:float; CompType:TCompOperator):TMatCoords; overload;

function FirstElement(Vector:TIntVector; Lb, Ub : integer; Ref:integer; CompType:TCompOperator):integer; overload;
function FirstElement(M:TIntMatrix; LRow, URow, LCol, UCol : integer; Ref:integer; CompType:TCompOperator):TMatCoords; overload;

function MaxLoc(Vector:TVector; Lb, Ub:integer):integer; overload;
function MaxLoc(M:TMatrix; LRow,URow,LCol,UCol:integer):TMatCoords;overload;

function MaxLoc(Vector:TIntVector; Lb, Ub:integer):integer; overload;
function MaxLoc(M:TIntMatrix; LRow,URow,LCol,UCol:integer):TMatCoords;overload;

function MinLoc(Vector:TVector; Lb, Ub:integer):integer; overload;
function MinLoc(M:TMatrix; LRow,URow,LCol,UCol:integer):TMatCoords;overload;

function MinLoc(Vector:TIntVector; Lb, Ub:integer):integer; overload;
function MinLoc(M:TIntMatrix; LRow,URow,LCol,UCol:integer):TMatCoords;overload;

//generates arithmetic progression
function Seq(Lb, Ub : integer; first, increment:Float; Vector:TVector = nil):TVector;
function ISeq(Lb, Ub : integer; first, increment:integer; Vector:TIntVector = nil):TIntVector;

// selects elements from array which compare to Ref value as CompType prescribes.
// CompType can be LT, LE, EQ, GT, GE, NE
// Other form is Ref and Comparator where comparator is function(V1,V2:float):boolean
// elements for which comparator returns true are selected. Element of array is V1, Ref is V2
// Selected elements are copied to Result array beginning from ResLb
function SelElements(Vector:TVector; Lb, Ub, ResLb : integer; Ref: float; CompType:TCompOperator):TVector; overload;
function SelElements(Vector:TVector; Lb, Ub, ResLb : integer; Ref:float; Comparator:TComparator):TVector; overload;

function SelElements(Vector:TIntVector; Lb, Ub, ResLb : integer; Ref: Integer; CompType:TCompOperator):TIntVector; overload;
function SelElements(Vector:TIntVector; Lb, Ub, ResLb : integer; Ref:Integer; Comparator:TIntComparator):TIntVector; overload;

implementation

function tmCoords(ARow,ACol:integer):TMatCoords;
begin
  Result.Row := ARow;
  Result.Col := ACol;
end;

procedure Apply(V: TVector; Lb, Ub: integer; Func: TTransformFunc);
var
  I:integer;
begin
  Ub := max(High(V),Ub);
  for I := Lb to Ub do
    V[I] := Func(V[I]);
end;

procedure Apply(M: TMatrix; LRow, URow, LCol, UCol: integer; Func: TTransformFunc);
var
  I,J:integer;
begin
  URow := min(High(M),URow);
  UCol := min(High(M[LRow]),UCol);
  for I := LRow to URow do
    for J := LCol to UCol do
      M[I,J] := Func(M[I,J]);
end;

procedure Apply(V: TIntVector; Lb, Ub: integer; Func: TIntTransformFunc);
var
  I:integer;
begin
  Ub := min(High(V),Ub);
  for I := Lb to Ub do
    V[I] := Func(V[I]);
end;

procedure Apply(M: TIntMatrix; LRow, URow, LCol, UCol: integer;
  Func: TIntTransformFunc);
var
  I,J:integer;
begin
  URow := min(High(M),URow);
  UCol := min(High(M[LRow]),UCol);
  for I := LRow to URow do
    for J := LCol to UCol do
      M[I,J] := Func(M[I,J]);
end;

function CompVec(X, Xref : TVector; Lb, Ub  : Integer; Tol : Float) : Boolean;
var
  I    : Integer;
  Ok   : Boolean;
  ITol : Float;
begin
  I := Lb;
  Ub := min(Ub,High(X));
  Ub := min(Ub,High(XRef));
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
  Ub := min(Ub,High(Vector));
  for I := Lb to Ub do
    if Test(Vector[I]) then
    begin
      Result := true;
      Exit;
    end; 
  Result := false;
end;

function Any(M:TMatrix; LRow, URow, LCol, UCol : integer; Test:TTestFunc):boolean;
var
  I,J:integer;
begin
  URow := min(URow,High(M));
  UCol := min(UCol,High(M[LRow]));
  for I := LRow to URow do
    for J := LCol to UCol do
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
  Ub := min(Ub,High(Vector));
  for I := Lb to Ub do
    if Test(Vector[I]) then
    begin
      Result := true;
      Exit;
    end; 
  Result := false;
end;

function Any(M:TIntMatrix; LRow, URow, LCol, UCol : integer; Test:TIntTestFunc):boolean;
var
  I,J:integer;
begin
  URow := min(URow,High(M));
  UCol := min(UCol,High(M[LRow]));
  for I := LRow to URow do
    for J := LCol to UCol do
      if Test(M[I,J]) then
      begin
        Result := true;
        Exit;
      end; 
  Result := false;
end;

function FirstElement(Vector:TVector; Lb, Ub : integer; Test:TTestFunc):integer; overload;
var
  I:Integer;
begin
  Ub := min(Ub,High(Vector));
  for I := Lb to Ub do
    if Test(Vector[I]) then
    begin
      Result := I;
      Exit;
    end;
  Result := Ub + 1;
end;

function FirstElement(M:TMatrix; LRow, URow, LCol, UCol : integer; Test:TTestFunc):TMatCoords; overload;
var
  I,J:integer;
begin
  URow := min(URow,High(M));
  UCol := min(UCol,High(M[LRow]));
  for I := LRow to URow do
    for J := LCol to UCol do
      if Test(M[I,J]) then
      begin
        Result := tmCoords(I,J);
        Exit;
      end;
  Result := tmCoords(URow+1,UCol+1);
end;

function FirstElement(Vector:TVector; Lb, Ub : integer; Ref:float; Comparator:TComparator):integer;
var
  I:Integer;
begin
  Ub := min(Ub,High(Vector));
  for I := Lb to Ub do
    if Comparator(Vector[I],Ref) then
    begin
      Result := I;
      Exit;
    end; 
  Result := Ub + 1;
end;

function FirstElement(M:TMatrix; LRow, URow, LCol, UCol : integer; Ref:float; Comparator:TComparator):TMatCoords;
var
  I,J:integer;
begin
  URow := min(URow,High(M));
  UCol := min(UCol,High(M[LRow]));
  for I := LRow to URow do
    for J := LCol to UCol do
      if Comparator(M[I,J],Ref) then
      begin
        Result := tmCoords(I,J);
        Exit;
      end;
  Result := tmCoords(URow+1,UCol+1);
end;

function FirstElement(Vector:TIntVector; Lb, Ub : integer; Ref:integer; Comparator:TIntComparator):integer;
var
  I:Integer;
begin
  Ub := min(Ub,High(Vector));
  for I := Lb to Ub do
    if Comparator(Vector[I],Ref) then
    begin
      Result := I;
      Exit;
    end;
  Result := Ub+1; 
end;

function FirstElement(M:TIntMatrix; LRow, URow, LCol, UCol : integer; Ref:integer; Comparator:TIntComparator):TMatCoords;
var
  I,J:integer;
begin
  URow := min(URow,High(M));
  UCol := min(UCol,High(M[LRow]));
  for I := LRow to URow do
    for J := LCol to UCol do
      if Comparator(M[I,J],Ref) then
      begin
        Result := tmCoords(I,J);
        Exit;
      end;
  Result := tmCoords(URow+1,UCol+1);
end;

function FirstElement(Vector:TVector; Lb, Ub : integer; Ref:float; CompType:TCompOperator):integer; overload;
var
  I:integer;
  CMP:boolean;
begin
  Ub := min(Ub,High(Vector));
  for I := Lb to Ub do
  begin
    case CompType of
      LT: CMP := Vector[I] < Ref;
      LE: CMP := Vector[I] <= Ref;
      EQ: CMP := SameValue(Vector[I],Ref);
      GE: CMP := Vector[I] >= Ref;
      GT: CMP := Vector[I] > Ref;
      NE: CMP := not SameValue(Vector[I],Ref);
    end;
    if CMP then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := Ub+1;
end;

function FirstElement(M:TMatrix; LRow, URow, LCol, UCol : integer; Ref:float; CompType:TCompOperator):TMatCoords; overload;
var
  I,J:integer;
  CMP:boolean;
begin
  URow := min(URow,High(M));
  UCol := min(UCol,High(M[LRow]));
  for I := LRow to URow do
    for J := LCol to UCol do
    begin
      case CompType of
        LT: CMP := M[I,J] < Ref;
        LE: CMP := M[I,J] <= Ref;
        EQ: CMP := SameValue(M[I,J],Ref);
        GE: CMP := M[I,J] >= Ref;
        GT: CMP := M[I,J] > Ref;
        NE: CMP := not SameValue(M[I,J],Ref);
      end;
      if CMP then
      begin
        Result := tmCoords(I,J);
        Exit;
      end;
    end;
  Result := tmCoords(URow+1,UCol+1);
end;

function FirstElement(Vector:TIntVector; Lb, Ub : integer; Ref:integer; CompType:TCompOperator):integer; overload;
var
  I:integer;
  CMP:boolean;
begin
  Ub := min(Ub,High(Vector));
  for I := Lb to Ub do
  begin
    case CompType of
      LT: CMP := Vector[I] < Ref;
      LE: CMP := Vector[I] <= Ref;
      EQ: CMP := Vector[I] = Ref;
      GE: CMP := Vector[I] >= Ref;
      GT: CMP := Vector[I] > Ref;
      NE: CMP := Vector[I] <> Ref;
    end;
    if CMP then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := Ub+1;
end;

function FirstElement(M:TIntMatrix; LRow, URow, LCol, UCol : integer; Ref:integer; CompType:TCompOperator):TMatCoords; overload;
var
  I,J:integer;
  CMP:boolean;
begin
  URow := min(URow,High(M));
  UCol := min(URow,High(M[LRow]));
  for I := LRow to URow do
    for J := LCol to UCol do
    begin
      case CompType of
        LT: CMP := M[I,J] < Ref;
        LE: CMP := M[I,J] <= Ref;
        EQ: CMP := M[I,J] = Ref;
        GE: CMP := M[I,J] >= Ref;
        GT: CMP := M[I,J] > Ref;
        NE: CMP := M[I,J] <> Ref;
      end;
      if CMP then
      begin
        Result := tmCoords(I,J);
        Exit;
      end;
    end;
  Result := tmCoords(URow+1,UCol+1);
end;

function MaxLoc(Vector:TVector; Lb, Ub:integer):integer; overload;
var
  I:integer;
  MaxVal:float;
begin
  Result := Lb;
  Ub := min(Ub,High(Vector));
  MaxVal := Vector[Lb];
  for I := Lb+1 to Ub do
    if Vector[I] > MaxVal then
    begin
      MaxVal := Vector[I];
      Result := I;
    end;
end;

function MaxLoc(M:TMatrix; LRow,URow,LCol,UCol:integer):TMatCoords;overload;
var
  I,J:integer;
  MaxVal:float;
begin
  URow := min(URow,High(M));
  UCol := min(UCol,High(M[LRow]));
  Result := tmCoords(LRow,LCol);
  MaxVal := M[LRow,LCol];
  for I := LRow to URow do
    for J := LCol to UCol do
    if M[I,J] > MaxVal then
    begin
      MaxVal := M[I,J];
      Result := tmCoords(I,J);
    end;
end;

function MaxLoc(Vector:TIntVector; Lb, Ub:integer):integer; overload;
var
  I:integer;
  MaxVal:float;
begin
  Result := Lb;
  Ub := min(Ub,High(Vector));
  MaxVal := Vector[Lb];
  for I := Lb+1 to Ub do
    if Vector[I] > MaxVal then
    begin
      MaxVal := Vector[I];
      Result := I;
    end;
end;

function MaxLoc(M:TIntMatrix; LRow,URow,LCol,UCol:integer):TMatCoords;overload;
var
  I,J:integer;
  MaxVal:float;
begin
  URow := min(URow,High(M));
  UCol := min(UCol,High(M[LRow]));
  Result := tmCoords(LRow,LCol);
  MaxVal := M[LRow,LCol];
  for I := LRow to URow do
    for J := LCol to UCol do
    if M[I,J] > MaxVal then
    begin
      MaxVal := M[I,J];
      Result := tmCoords(I,J);
    end;
end;

function MinLoc(Vector:TVector; Lb, Ub:integer):integer; overload;
var
  I:integer;
  MinVal:float;
begin
  Ub := min(Ub,High(Vector));
  Result := Lb;
  MinVal := Vector[Lb];
  for I := Lb+1 to Ub do
    if Vector[I] < MinVal then
    begin
      MinVal := Vector[I];
      Result := I;
    end;
end;

function MinLoc(M:TMatrix; LRow,URow,LCol,UCol:integer):TMatCoords;overload;
var
  I,J:integer;
  MinVal:float;
begin
  URow := min(URow,High(M));
  UCol := min(UCol,High(M[LRow]));
  Result := tmCoords(LRow,LCol);
  MinVal := M[LRow,LCol];
  for I := LRow to URow do
    for J := LCol to UCol do
    if M[I,J] < MinVal then
    begin
      MinVal := M[I,J];
      Result := tmCoords(I,J);
    end;
end;

function MinLoc(Vector:TIntVector; Lb, Ub:integer):integer; overload;
var
  I:integer;
  MinVal:float;
begin
  Ub := min(Ub,High(Vector));
  Result := Lb;
  MinVal := Vector[Lb];
  for I := Lb+1 to Ub do
    if Vector[I] < MinVal then
    begin
      MinVal := Vector[I];
      Result := I;
    end;
end;

function MinLoc(M:TIntMatrix; LRow,URow,LCol,UCol:integer):TMatCoords;overload;
var
  I,J:integer;
  MinVal:float;
begin
  URow := min(URow,High(M));
  UCol := min(UCol,High(M[LRow]));
  Result := tmCoords(LRow,LCol);
  MinVal := M[LRow,LCol];
  for I := LRow to URow do
    for J := LCol to UCol do
    if M[I,J] < MinVal then
    begin
      MinVal := M[I,J];
      Result := tmCoords(I,J);
    end;
end;

function Seq(Lb, Ub : integer; first, increment:Float; Vector:TVector = nil):TVector;
var
  I:integer;
begin
  if Vector = nil then
    DimVector(Vector, Ub)
  else
    Ub := min(Ub,High(Vector));
  if Lb <= Ub then
    Vector[Lb] := 0
  else
    Exit;
  for I := Lb+1 to Ub do                 // 2 cycles to avoid rounding error if
    Vector[I] := Vector[I-1]+increment;  //First is very large and increment small
  for I := Lb to Ub do
    Vector[I] := Vector[I]+first;
  Result := Vector;
end;

function ISeq(Lb, Ub : integer; first, increment:integer; Vector:TIntVector = nil):TIntVector;
var
  I:integer;
begin
  if Vector = nil then
    DimVector(Vector,Ub)
  else
    Ub := min(Ub,High(Vector));
  if Lb <= Ub then
    Vector[Lb] := First
  else
    Exit;
  for I := Lb+1 to Ub do
    Vector[I] := Vector[I-1]+increment;
  Result := Vector;
end;

function SelElements(Vector:TVector; Lb, Ub, ResLb : integer; Ref: float; CompType:TCompOperator):TVector; overload;
var
  I,N:integer;
  Cmp:boolean;
begin
  DimVector(Result,Ub-Lb+ResLb);
  N := ResLb-1;
  Ub := Min(Ub,High(Vector));
  for I := Lb to Ub do
    begin
    case CompType of
      LT: CMP := Vector[I] < Ref;
      LE: CMP := Vector[I] <= Ref;
      EQ: CMP := SameValue(Vector[I],Ref);
      GE: CMP := Vector[I] >= Ref;
      GT: CMP := Vector[I] > Ref;
      NE: CMP := not SameValue(Vector[I],Ref);
    end;
    if CMP then
    begin
      inc(N);
      Result[N] := Vector[I];
    end;
  end;
  if N > 0 then
    SetLength(Result,N+1)
  else
    SetLength(Result,0);
end;

function SelElements(Vector:TVector; Lb, Ub, ResLb : integer; Ref:float; Comparator:TComparator):TVector; overload;
var
  I,N:integer;
begin
  Ub := min(high(Vector),Ub);
  DimVector(Result,Ub-Lb+ResLb);
  N := ResLb-1;
  for I := Lb to Ub do
    if Comparator(Vector[I],Ref) then
    begin
      inc(N);
      Result[N] := Vector[I];
    end;
  if N > 0 then
    SetLength(Result,N+1)
  else
    SetLength(Result,0);
end;

function SelElements(Vector:TIntVector; Lb, Ub, ResLb : integer; Ref: Integer; CompType:TCompOperator):TIntVector; overload;
var
  I,N:integer;
  Cmp:boolean;
begin
  Ub := min(Ub,High(Vector));
  DimVector(Result,Ub-Lb+ResLb);
  N := ResLb-1;
  for I := Lb to Ub do
    begin
    case CompType of
      LT: CMP := Vector[I] < Ref;
      LE: CMP := Vector[I] <= Ref;
      EQ: CMP := Vector[I] = Ref;
      GE: CMP := Vector[I] >= Ref;
      GT: CMP := Vector[I] > Ref;
      NE: CMP := Vector[I] <> Ref;
    end;
    if CMP then
    begin
      inc(N);
      Result[N] := Vector[I];
    end;
  end;
  if N > 0 then
    SetLength(Result,N+1)
  else
    SetLength(Result,0);
end;

function SelElements(Vector:TIntVector; Lb, Ub, ResLb : integer; Ref:Integer; Comparator:TIntComparator):TIntVector; overload;
var
  I,N:integer;
begin
  Ub := min(Ub,High(Vector));
  DimVector(Result,Ub-Lb+ResLb);
  N := ResLb-1;
  for I := Lb to Ub do
    if Comparator(Vector[I],Ref) then
    begin
      inc(N);
      Result[N] := Vector[I];
    end;
  if N > 0 then
    SetLength(Result,N+1)
  else
    SetLength(Result,0);
end;

end.
