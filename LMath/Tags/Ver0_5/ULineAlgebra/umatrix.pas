unit uMatrix;

{$mode objfpc}{$H+}

interface

uses
  uTypes, uMinMax, uErrors;
operator + (V:TVector; R:Float) Res : TVector;
operator - (V:TVector; R:Float) Res : TVector;
operator / (V:TVector; R:Float) Res : TVector;
operator * (V:TVector; R:Float) Res : TVector;

operator + (M:TMatrix; R:Float) Res : TMatrix;
operator - (M:TMatrix; R:Float) Res : TMatrix;
operator / (M:TMatrix; R:Float) Res : TMatrix;
operator * (M:TMatrix; R:Float) Res : TMatrix;

operator + (V1:TVector; V2:TVector) Res : TVector; // element-wise
operator - (V1:TVector; V2:TVector) Res : TVector;


{These functions use _Ziel_ array if it is not _nil_ by call. Otherwise, new array is allocated.}
function VecFloatAdd(V:TVector; R:Float; Lb, Ub : integer; 
              Ziel : TVector = nil; ResLb : integer = 1): TVector;
function VecFloatSubtr(V:TVector; R:Float; Lb, Ub : integer; 
              Ziel : TVector = nil; ResLb : integer = 1): TVector;
function VecFloatDiv(V:TVector; R:Float; Lb, Ub : integer; 
              Ziel : TVector = nil; ResLb : integer = 1): TVector;
function VecFloatMul(V:TVector; R:Float; Lb, Ub : integer;  
              Ziel : TVector = nil; ResLb : integer = 1): TVector;

function MatFloatAdd(M:TMatrix; R:Float; Lb, Ub1, Ub2 : integer; Ziel : TMatrix = nil) : TMatrix;
function MatFloatSubtr(M:TMatrix; R:Float; Lb, Ub1, Ub2 : integer; Ziel : TMatrix = nil) : TMatrix;
function MatFloatDiv(M:TMatrix; R:Float; Lb, Ub1, Ub2 : integer; Ziel : TMatrix = nil) : TMatrix;
function MatFloatMul(M:TMatrix; R:Float; Lb, Ub1, Ub2 : integer; Ziel : TMatrix = nil) : TMatrix;

function VecAdd(V1,V2:TVector; Ziel : TVector = nil): TVector;
function VecSubtr(V1,V2:TVector; Ziel : TVector = nil): TVector;

{This function multiplies elements of one vector by elements of other.}
function VecElemMul(V1,V2:TVector; Ziel : TVector = nil): TVector;
function VecDiv(V1,V2:TVector; Ziel : TVector = nil): TVector;

function VecDotProd(V1,V2:TVector; Lb, Ub : integer) : float;
function VecOuterProd(V1, V2:TVector; Lb, Ub1, Ub2 : integer; Ziel : TMatrix = nil):TMatrix;
function VecCrossProd(V1, V2:TVector; Lb: integer; Ziel :TVector = nil):TVector;
function VecEucLength(V:TVector; LB, Ub : integer) : float;
function MatVecMul(M:TMatrix; V:TVector; LB: integer; Ziel: TVector = nil): TVector;

function MatMul(A, B : TMatrix; LB : integer; Ziel : TMatrix = nil) : TMatrix;

function MatTranspose(M:TMatrix; LB: integer; Ziel: TMatrix = nil): TMatrix;
procedure MatTransposeInPlace(M:TMatrix; Lb, Ub : integer);

implementation
type
  TBigArray = array[0..10000000] of float;
  PBigArray = ^TBigArray;

function VecFloatAdd(V:TVector; R:Float;  Lb, Ub : integer; Ziel : TVector = nil; ResLb : integer = 1): TVector;
var
  I,M,HZ:Integer;
begin
  HZ := ResLb + Ub - Lb;
  if Ziel = nil then
    DimVector(Ziel, HZ);
  M := Lb - ResLb;
  if High(Ziel) < HZ then
  begin
    SetErrCode(MatErrDim);
    Result := nil;
    Exit;
  end;
  for I := Lb to Ub do
    Ziel[I-M] := V[I]+R;
  Result := Ziel;
end;

function VecFloatSubtr(V:TVector; R:Float;  Lb, Ub : integer; Ziel : TVector = nil; ResLb : integer = 1): TVector;
var
  I,M,HZ:Integer;
begin
  HZ := ResLb + Ub - Lb;
  if Ziel = nil then
    DimVector(Ziel,HZ);
  M := Lb - ResLb;
  if High(Ziel) < HZ then
  begin
    SetErrCode(MatErrDim);
    Result := nil;
    Exit;
  end;
  for I := Lb to Ub do
    Ziel[I-M] := V[I]-R;
  Result := Ziel;
end;

function VecFloatDiv(V:TVector; R:Float;  Lb, Ub : integer; Ziel : TVector = nil; ResLb : integer = 1): TVector;
var
  I,M,HZ:Integer;
begin
  HZ := ResLb + Ub - Lb;
  if Ziel = nil then
    DimVector(Ziel,HZ);
  M := Lb - ResLb;
  if High(Ziel) < HZ then
  begin
    SetErrCode(MatErrDim);
    Result := nil;
    Exit;
  end;
  for I := Lb to Ub do
    Ziel[I-M] := V[I]/R;
  Result := Ziel;
end;

function VecFloatMul(V:TVector; R:Float;  Lb, Ub : integer; Ziel : TVector = nil; ResLb : integer = 1): TVector;
var
  I,M,HZ:Integer;
begin
  HZ := ResLb + Ub - Lb;
  if Ziel = nil then
    DimVector(Ziel,HZ);
  M := Lb - ResLb;
  if High(Ziel) < HZ then
  begin
    SetErrCode(MatErrDim);
    Result := nil;
    Exit;
  end;
  for I := Lb to Ub do
    Ziel[I-M] := V[I]*R;
  Result := Ziel;
end;

function MatFloatAdd(M:TMatrix; R:Float; Lb, Ub1, Ub2 : integer; Ziel : TMatrix = nil) : TMatrix;
var
  I, J:Integer;
begin
  if Ziel = nil then
    DimMatrix(Ziel, Ub1, Ub2);
  for I := Lb to Ub1 do
    for J := Lb to Ub2 do
      Ziel[I,J] := M[I,J]+R;
  Result := Ziel;
end;

function MatFloatSubtr(M:TMatrix; R:Float; Lb, Ub1, Ub2 : integer; Ziel : TMatrix = nil) : TMatrix;
var
  I, J:Integer;
begin
  if Ziel = nil then
    DimMatrix(Ziel, Ub1, Ub2);
  for I := Lb to Ub1 do
    for J := Lb to Ub2 do
      Ziel[I,J] := M[I,J]-R;
  Result := Ziel;
end;

function MatFloatDiv(M:TMatrix; R:Float; Lb, Ub1, Ub2 : integer; Ziel : TMatrix = nil) : TMatrix;
var
  I, J:Integer;
begin
  if Ziel = nil then
    DimMatrix(Ziel, Ub1, Ub2);
  for I := Lb to Ub1 do
    for J := Lb to Ub2 do
      Ziel[I,J] := M[I,J]/R;
  Result := Ziel;
end;

function MatFloatMul(M:TMatrix; R:Float; Lb, Ub1, Ub2 : integer; Ziel : TMatrix = nil) : TMatrix;
var
  I, J:Integer;
begin
  if Ziel = nil then
    DimMatrix(Ziel, Ub1, Ub2);
  for I := Lb to Ub1 do
    for J := Lb to Ub2 do
      Ziel[I,J] := M[I,J]*R;
  Result := Ziel;
end;

function VecAdd(V1,V2:TVector; Ziel : TVector = nil) : TVector;
var
  I,H:Integer;
begin
  H := High(V1);
  if Ziel = nil then
    DimVector(Ziel,H);
  H := High(V1);
  if (High(V2) = H) and (High(Ziel) = H) then
  begin
    for I := 0 to H do
      Ziel[I] := V1[I] + V2[I];
    Result := Ziel;
  end else
  begin
    SetErrCode(MatErrDim);
    Result := nil;
  end;
end;

function VecSubtr(V1,V2:TVector; Ziel : TVector = nil): TVector;
var
  I,H:Integer;
begin
  H := High(V1);
  if Ziel = nil then
    DimVector(Ziel,H);
  if (High(V2) = H) and (High(Ziel) = H) then
  begin
    for I := 0 to H do
      Ziel[I] := V1[I] - V2[I];
    Result := Ziel;
  end
  else begin
    SetErrCode(MatErrDim);
    Result := nil;
  end;
  Result := Ziel;
end;

function VecElemMul(V1,V2:TVector; Ziel : TVector = nil): TVector;
var
  I,H:Integer;
begin
  H := High(V1);
  if Ziel = nil then
    DimVector(Ziel,H);
  if (High(V2) = H) and (High(Ziel) = H) then
  begin
    for I := 0 to H do
      Ziel[I] := V1[I] * V2[I];
    Result := Ziel;
  end
  else begin
    SetErrCode(MatErrDim);
    Result := nil;
  end;
end;

function VecDiv(V1,V2:TVector; Ziel : TVector = nil): TVector;
var
  I,L,H:Integer;
begin
  H := High(V1);
  if Ziel = nil then
    DimVector(Ziel,H);
  if (High(V2) = H) and (High(Ziel) = H) then
  begin
    if V2[0] = 0 then
      L := 1
    else
      L := 0;
    for I := L to H do
      Ziel[I] := V1[I] / V2[I];
    Result := Ziel;
  end
  else begin
    SetErrCode(MatErrDim);
    Result := nil;
  end;
end;

function VecDotProd(V1, V2: TVector; Lb, Ub : integer): float;
var
  I:Integer;
begin
  Result := 0;
  if (High(V1) >= Ub) and (High(V2) >= Ub) then
    for I := Lb to Ub do
      Result := Result + V1[I] * V2[I]
  else
      SetErrCode(MatErrDim);
end;

function VecOuterProd(V1, V2: TVector; Lb, Ub1, Ub2: integer; Ziel: TMatrix = nil): TMatrix;
var
  I:integer;
begin
  if Ziel = nil then
    DimMatrix(Ziel,Ub1,Ub2)
  else begin
    if (High(Ziel) < Ub1) or (High(Ziel[0]) < Ub2) then
    begin
      SetErrCode(MatErrDim);
      Result := nil;
    end;
  end;
  for I := Lb to Ub1 do
    Ziel[I] := VecFloatMul(V2,V1[I],Lb,Ub2,Ziel[I],Lb);
  Result := Ziel;
end;

function VecCrossProd(V1, V2: TVector; Lb: integer; Ziel: TVector): TVector;
var
  Y,Z:integer;
begin
  Y:= Lb+1;
  Z := Lb+2;
  if Ziel = nil then
    DimVector(Ziel,Z);
  Ziel[Lb] := V1[Y]*V2[Z]  - V1[Z]*V2[Y];
  Ziel[Y]  := V1[Z]*V2[Lb] - V1[Lb]*V2[Z];
  Ziel[Z]  := V1[Lb]*V2[Y] - V1[Y]*V2[Lb];
  Result := Ziel;
end;

function VecEucLength(V:TVector; LB, Ub : integer): float;
var
  I:integer;
begin
  Result := 0;
  for I := LB to Ub do
    Result := Result + Sqr(V[I]);
end;

function MatVecMul(M:TMatrix; V:TVector; LB: integer; Ziel: TVector = nil): TVector;
var
  HighRow, HighCol : integer;
  I,J:integer;
  R:float;
begin
  HighRow := High(M);
  HighCol := High(M[0]);
  if Ziel = nil then
    DimVector(Ziel,HighRow);
  if (HighCol = High(V)) and (HighRow = High(Ziel)) then
  begin
    for I := LB to HighRow do
    begin
      R := 0.0;
      for J := LB to HighCol do
        R := R + V[J]*M[I,J];
      Ziel[I] := R;
    end;
    Result := Ziel;
  end
  else begin
    SetErrCode(MatErrDim);
    Result := nil;
  end;
end;

function MatMul(A, B : TMatrix; LB : integer; Ziel : TMatrix = nil) : TMatrix;
var
  I,J,L : integer;
  BufB, BufC : PBigArray;
  Af: Float;
  HiRow1, HiCol1, HiRow2, HiCol2 : integer;
begin
  HiRow1 := High(A);
  HiCol1 := High(A[1]);
  HiRow2 := High(B);
  HiCol2 := High(B[1]);
  if Ziel = nil then
    DimMatrix(Ziel, HiRow1, HiCol2);
  if not ((HiRow2 = HiCol1) and
    (High(Ziel) = HiRow1) and (High(Ziel[1]) = HiCol2)) then
  begin
    SetErrCode(MatErrDim);
    Result := nil;
    Exit;
  end;
  for I := LB to HiRow1 do
  begin
    BufC := @(Ziel[I,LB]);  // moved to next row in C
    for j := 0 to HiCol2-LB do
        BufC^[j] := 0;      // nulled it
    for L := 0 to HiCol1 - LB do
    begin
      BufB := @(B[L,LB]);   // moved to next line in B
      Af := A[I,L];
      for j := 0 to HiCol2-LB do
        BufC^[J] := BufC^[J] + Af * BufB^[j];
    end;
  end;
  Result := Ziel;
end;

function MatTranspose(M:TMatrix; LB: integer; Ziel: TMatrix = nil): TMatrix;
var
 I,J,H,W:integer;
begin
  H := High(M);
  W := High(M[0]);
  if Ziel = nil then
    DimMatrix(Ziel, W, H);
  if (High(Ziel) = W) and (High(Ziel[0]) = H) then
  begin
    for I := LB to H do
      for J := LB to W do
        Ziel[J,I] := M[I,J];
    Result := Ziel;
  end else
  begin
    Result := nil;
    SetErrCode(MatErrDim);
  end;
end;

procedure MatTransposeInPlace(M:TMatrix; Lb, Ub : integer);
var
 I,J:integer;
begin
  if (High(M) < Ub) or (High(M[Lb]) < Ub) then
    SetErrCode(MatErrDim)
  else
    for I := Lb to Ub do
      for J := I + 1 to Ub do
        Swap(M[I,J],M[J,I]);
end;

operator+(V: TVector; R: Float)Res: TVector;
var
  I,L:integer;
  Ziel: TVector;
begin
  L := high(V);
  DimVector(Ziel, L);
  for I := 0 to L do
    Ziel[I] := V[I]+R;
  Result := Ziel;
end;

operator-(V: TVector; R: Float)Res: TVector;
var
  I,L:integer;
  Ziel: TVector;
begin
  L := high(V);
  DimVector(Ziel, L);
  for I := 0 to L do
    Ziel[I] := V[I]-R;
  Result := Ziel;
end;

operator/(V: TVector; R: Float)Res: TVector;
var
  I,L:integer;
  Ziel: TVector;
begin
  L := high(V);
  DimVector(Ziel, L);
  for I := 0 to L do
    Ziel[I] := V[I]/R;
  Result := Ziel;
end;

operator*(V: TVector; R: Float)Res: TVector;
var
  I,L:integer;
  Ziel: TVector;
begin
  L := high(V);
  DimVector(Ziel, L);
  for I := 0 to L do
    Ziel[I] := V[I]*R;
  Result := Ziel;
end;

operator+(M: TMatrix; R: Float)Res: TMatrix;
var
  I,J,Ub1,Ub2:integer;
  Ziel: TMatrix;
begin
  Ub1 := high(M);
  Ub2 := high(M[0]);
  DimMatrix(Ziel, Ub1, Ub2);
  for I := 0 to Ub1 do
    for J := 0 to Ub2 do
      Ziel[I,J] := M[I,J]+R;
  Result := Ziel;
end;

operator-(M: TMatrix; R: Float)Res: TMatrix;
var
  I,J,Ub1,Ub2:integer;
  Ziel: TMatrix;
begin
  Ub1 := high(M);
  Ub2 := high(M[0]);
  DimMatrix(Ziel, Ub1, Ub2);
  for I := 0 to Ub1 do
    for J := 0 to Ub2 do
      Ziel[I,J] := M[I,J] - R;
  Result := Ziel;
end;

operator/(M: TMatrix; R: Float)Res: TMatrix;
var
  I,J,Ub1,Ub2:integer;
  Ziel: TMatrix;
begin
  Ub1 := high(M);
  Ub2 := high(M[0]);
  DimMatrix(Ziel, Ub1, Ub2);
  for I := 0 to Ub1 do
    for J := 0 to Ub2 do
      Ziel[I,J] := M[I,J] / R;
  Result := Ziel;
end;

operator*(M: TMatrix; R: Float)Res: TMatrix;
var
  I,J,Ub1,Ub2:integer;
  Ziel: TMatrix;
begin
  Ub1 := high(M);
  Ub2 := high(M[0]);
  DimMatrix(Ziel, Ub1, Ub2);
  for I := 0 to Ub1 do
    for J := 0 to Ub2 do
      Ziel[I,J] := M[I,J] * R;
  Result := Ziel;
end;

operator+(V1: TVector; V2: TVector)Res: TVector;
var
  I,L:integer;
  Ziel:TVector;
begin
  L := high(V1);
  DimVector(Ziel, L);
  if L <> High(V2) then
  begin
    SetErrCode(MatErrDim);
    Result := nil;
    Exit;
  end;
  for I := 0 to L do
    Ziel[I] := V1[I] + V2[I];
  Result := Ziel;
end;

  operator-(V1: TVector; V2: TVector)Res: TVector;
  var
    I,L:integer;
    Ziel:TVector;
  begin
    L := high(V1);
    DimVector(Ziel, L);
    if L <> High(V2) then
    begin
      SetErrCode(MatErrDim);
      Result := nil;
      Exit;
    end;
    for I := 0 to L do
      Ziel[I] := V1[I] - V2[I];
    Result := Ziel;
end;


end.

