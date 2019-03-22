unit uMatrix;

{$mode objfpc}{$H+}

interface

uses
  uTypes, uErrors, uMath;

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
operator * (V1:TVector; V2:TVector) Res : Float; // dot product

operator * (M:TMatrix; V:TVector;) Res : TVector;

operator * (M1, M2 : TMatrix) Res : TMatrix;

//sets low bound for vector/matrix operations, 0 or 1 (defaults to 1)
procedure matSetLowBound(LB:integer);
function  matGetLowBound:integer;

procedure VecFloatAdd(V:TVector; R:Float; Res : TVector);
procedure VecFloatSubstr(V:TVector; R:Float; Res : TVector);
procedure VecFloatDiv(V:TVector; R:Float Res; Res : TVector);
procedure VecFloatMul(V:TVector; R:Float; Res : TVector);

procedure MatFloatAdd(M:TMatrix; R:Float; Res : TMatrix);
procedure MatFloatSubstr(M:TMatrix; R:Float; Res : TMatrix);
procedure MatFloatDiv(M:TMatrix; R:Float; Res : TMatrix);
procedure MatFloatMul(M:TMatrix; R:Float; Res : TMatrix);

procedure AddVectors(V1,V2:TVector; Res : TVector);
procedure VecElemSubstr(V1,V2:TVector; Res : TVector);
procedure ElementalMultiplyVectors(V1,V2:TVector; Res : TVector);
procedure DivVectors(V1,V2:TVector; Res : TVector);
function VecDot(V1,V2:TVector) : float;
procedure MatVecMul(M:TMatrix; V:TVector; Res :TVector);

procedure MatMul(A, B, Res: TMatrix; LB : integer = -1);

procedure matTranspose(M, Res:TMatrix);


implementation
type
  TBigArray = array[0..10000000] of float;
  PBigArray = ^TBigArray;

var LBound: integer = 0;

procedure MatMul(A, B, Res: TMatrix; LB : integer = -1);
var
  I,J,L : integer;
  BufB, BufC : PBigArray;
  Af: Float;
  HiRow1, HiCol1, HiRow2, HiCol2 : integer;
begin
  if LB = -1 then
    LB := LBound;
  HiRow1 := High(A);
  HiCol1 := High(A[1]);
  HiRow2 := High(B);
  HiCol2 := High(B[1]);
  if not ((HiRow2 = HiCol1) and
    (High(Res) = HiRow1) and (High(Res[1]) = HiCol2)) then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;

  for I := LB to HiRow1 do
  begin
    BufC := @Res[I,LB];  // moved to next row in C
    for j := 0 to HiCol2-LB do
        BufC^[j] := 0;      // nulled it
    for L := 0 to HiCol1 - LB do
    begin
      BufB := @B[L,LB];   // moved to next line in B
      Af := A[I,L];
      for j := 0 to HiCol2-LB do
        BufC^[J] := BufC^[J] + Af * BufB^[j];
    end;
  end;
end;

operator + (V: TVector; R: Float) Res : TVector;
begin
  DimVector(Res, High(V));
  VecFloatAdd(V,R,Res);
end;

operator - (V: TVector; R: Float) Res : TVector;
begin
  DimVector(Res, High(V));
  VecFloatSubstr(V,R,Res);
end;

operator / (V: TVector; R: Float): Res TVector;
begin
  DimVector(Res, High(V));
  VecFloatDiv(V,R,Res);
end;

operator * (V: TVector; R: Float) Res : TVector;
begin
  DimVector(Res, High(V));
  VecFloatAdd(V,R,Res);
end;

operator + (M: TMatrix; R: Float) Res : TMatrix;
begin
  DimMatrix(Res, High(M), High(M[0]);
  MatFloatAdd(M, R, Res);
end;

operator - (M: TMatrix; R: Float) Res : TMatrix;
begin
  DimMatrix(Res, High(M), High(M[0]);
  MatFloatSubstr(M, R, Res);
end;

operator / (M: TMatrix; R: Float) Res : TMatrix;
begin
  DimMatrix(Res, High(M), High(M[0]);
  MatFloatDiv(M, R, Res);
end;

operator * (M: TMatrix; R: Float) Res : TMatrix;
begin
  DimMatrix(Res, High(M), High(M[0]);
  MatFloatMul(M, R, Res);
end;

operator + (V1: TVector; V2: TVector) Res : TVector;
begin
  DimVector(Res, High(V1));
  AddVectors(V1, V2, Res);
end;

operator - (V1: TVector; V2: TVector) Res : TVector;
begin
  DimVector(Res, High(V1));
  SubstrVectors(V1, V2, Res);
end;

operator * (V1: TVector; V2: TVector) Res : Float;
begin
  Res := VecDot(V1,V2);
end;

operator * (M: TMatrix; V: TVector) Res : TVector;
begin

end;

operator * (M1, M2: TMatrix) R : TMatrix;
begin
  DimMatrix(R,High(M1),High(M1[0]);
  MatMul(M1,M2,R);
  Result := R;
end;

procedure matSetLowBound(LB: integer);
begin
  LBound := LB;
end;

function matGetLowBound: integer;
begin
  Result := LBound;
end;

procedure VecFloatAdd(V:TVector; R:Float; Res : TVector);
var
  I:Integer;
begin
  for I := 0 to High(V) do
    Res[I] := V[I]+R;
end;

procedure VecFloatSubstr(V:TVector; R:Float; Res : TVector);
var
  I:Integer;
begin
  for I := 0 to High(V) do
    Res[I] := V[I]-R;
end;

procedure VecFloatDiv(V:TVector; R:Float Res; Res : TVector);
var
  I:Integer;
begin
  for I := 0 to High(V) do
    Res[I] := V[I]/R;
end;

procedure VecFloatMul(V:TVector; R:Float; Res : TVector);
var
  I:Integer;
begin
  for I := 0 to High(V) do
    Res[I] := V[I]*R;
end;

procedure MatFloatAdd(M:TMatrix; R:Float; Res : TMatrix);
var
  I, J:Integer;
begin
  for I := 0 to High(V) do
    for J := 0 to High(V[0]) do
      Res[I,J] := M[I,J]+R;
end;

procedure MatFloatSubstr(M:TMatrix; R:Float; Res : TMatrix);
var
  I, J:Integer;
begin
  for I := 0 to High(V) do
    for J := 0 to High(V[0]) do
      Res[I,J] := M[I,J]-R;
end;

procedure MatFloatDiv(M:TMatrix; R:Float; Res : TMatrix);
var
  I, J:Integer;
begin
  for I := 0 to High(V) do
    for J := 0 to High(V[0]) do
      Res[I,J] := M[I,J]/R;
end;

procedure MatFloatMul(M:TMatrix; R:Float; Res : TMatrix);
var
  I, J:Integer;
begin
  for I := 0 to High(V) do
    for J := 0 to High(V[0]) do
      Res[I,J] := M[I,J]*R;
end;

procedure AddVectors(V1,V2:TVector; Res : TVector);
var
  I,H:Integer;
begin
  H := High(V1);
  if (High(V2) = H) and (High(Res) = H) then
    for I := 0 to H do
      Result[I] := V1[I] + V2[I];
  else
    SetErrCode(MatErrDim);
end;

procedure SubstractVectors(V1,V2:TVector; Res : TVector);
var
  I,H:Integer;
begin
  H := High(V1);
  if (High(V2) = H) and (High(Res) = H) then
    for I := 0 to H do
      Result[I] := V1[I] - V2[I];
  else
    SetErrCode(MatErrDim);
end;

procedure ElementalMultiplyVectors(V1,V2:TVector; Res : TVector);
var
  I,H:Integer;
begin
  H := High(V1);
  if (High(V2) = H) and (High(Res) = H) then
    for I := 0 to H do
      Result[I] := V1[I] * V2[I];
  else
    SetErrCode(MatErrDim);
end;

procedure DivVectors(V1,V2:TVector; Res : TVector);
var
  I,H:Integer;
begin
  H := High(V1);
  if (High(V2) = H) and (High(Res) = H) then
    for I := 0 to H do
      Result[I] := V1[I] / V2[I];
  else
    SetErrCode(MatErrDim);
end;

function VecDot(V1, V2: TVector): float;
var
  I,H:Integer;
begin
  H := High(V1);
  if High(V2) = H then
  begin
    Result := 0;
    for I := 0 to H do
      Result := Result + V1[I] * V2[I];
  end else
    Result := DefaultVal(MatErrDim,0);
end;

function MatVecMul(M: TMatrix; V: TVector): TVector;
begin

end;

procedure matTranspose(M, Res:TMatrix);
begin

end;

end.

