unit uMatrix;

{$mode objfpc}{$H+}

interface

uses
  uTypes, uErrors, uMath;

operator + (V:TVector; R:Float) : TVector;
operator - (V:TVector; R:Float) : TVector;
operator / (V:TVector; R:Float) : TVector;
operator * (V:TVector; R:Float) : TVector;

operator + (R:Float; V:TVector) : TVector;
operator - (R:Float; V:TVector) : TVector;
operator / (R:Float; V:TVector) : TVector;
operator * (R:Float; V:TVector) : TVector;

operator + (M:TMatrix; R:Float) : TMatrix;
operator - (M:TMatrix; R:Float) : TMatrix;
operator / (M:TMatrix; R:Float) : TMatrix;
operator * (M:TMatrix; R:Float) : TMatrix;

operator + (R:Float; M:TMatrix) : TMatrix;
operator - (R:Float; M:TMatrix) : TMatrix;
operator / (R:Float; M:TMatrix) : TMatrix;
operator * (R:Float; M:TMatrix) : TMatrix;

operator + (V1:TVector; V2:TVector) : TVector; // element-wise
operator - (V1:TVector; V2:TVector) : TVector;
operator * (V1:TVector; V2:TVector) : Float; // dot product

operator * (V:TVector; M:TMatrix)   : TVector;
operator * (M:TMatrix; V:TVector)   : TVector;

operator * (M1, M2 : TMatrix)       : TMatrix;

//sets low bound for vector/matrix operations, 0 or 1 (defaults to 1)
procedure matSetLowBound(LB:integer);
function  matGetLowBound:integer;

function VecFloatAdd(V:TVector; R:Float) : TVector;
function VecFloatSubstr(V:TVector; R:Float) : TVector;
function VecFloatDiv(V:TVector; R:Float) : TVector;
function VecFloatMul(V:TVector; R:Float) : TVector;

function MatFloatAdd(M:TMatrix; R:Float) : TVector;
function MatFloatSubstr(M:TMatrix; R:Float) : TVector;
function MatFloatDiv(M:TMatrix; R:Float) : TVector;
function MatFloatMul(M:TMatrix; R:Float) : TVector;

function AddVectors(V1,V2:TVector) : TVector;
function VecElemSubstr(V1,V2:TVector) : TVector;
function VecElemMul(V1,V2:TVector) : TVector;
function VecElemDiv(V1,V2:TVector) : TVector;
function VecDot(V1,V2:TVector) : float;
function VecMatMul(V:TVector; M:TMatrix):TVector;
function MatVecMul(M:TMatrix; V:TVector):TVector;
function matMul(A, B: TMatrix; LB : integer = -1): TMatrix;

function matTranspose(M:TMatrix): TMatrix;


implementation
type
  TBigArray = array[0..10000000] of float;
  PBigArray = ^TBigArray;

var LBound: integer = 0;

function MatMul(A, B: TMatrix; LB : integer = -1): TMatrix;
var
  I,J,L : integer;
  BufB, BufC : PBigArray;
  C: TMatrix;
  Af: Float;
  HiRow1, HiCol1, HiRow2, HiCol2 : integer;
begin
  if LB = -1 then
    LB := LBound;
  HiRow1 := High(A);
  HiCol1 := High(A[1]);
  HiRow2 := High(B);
  HiCol2 := High(B[1]);
  if HiRow2 <> HiCol1 then
  begin
    SetErrCode(MatErrDim);
    Result := nil;
    Exit;
  end;
  DimMatrix(C,HiRow1,HiCol2);

  for I := LB to HiRow1 do
  begin
    BufC := @C[I,LB];  // moved to next row in C
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
  Result := C;
end;

operator + (V: TVector; R: Float): TVector;
begin

end;

operator - (V: TVector; R: Float): TVector;
begin

end;

operator / (V: TVector; R: Float): TVector;
begin

end;

operator * (V: TVector; R: Float): TVector;
begin

end;

operator + (R: Float; V: TVector): TVector;
begin

end;

operator - (R: Float; V: TVector): TVector;
begin

end;

operator / (R: Float; V: TVector): TVector;
begin

end;

operator * (R: Float; V: TVector): TVector;
begin

end;

operator + (M: TMatrix; R: Float): TMatrix;
begin

end;

operator - (M: TMatrix; R: Float): TMatrix;
begin

end;

operator / (M: TMatrix; R: Float): TMatrix;
begin

end;

operator * (M: TMatrix; R: Float): TMatrix;
begin

end;

operator + (R: Float; M: TMatrix): TMatrix;
begin

end;

operator - (R: Float; M: TMatrix): TMatrix;
begin

end;

operator / (R: Float; M: TMatrix): TMatrix;
begin

end;

operator * (R: Float; M: TMatrix): TMatrix;
begin

end;

operator + (V1: TVector; V2: TVector): TVector;
begin

end;

operator - (V1: TVector; V2: TVector): TVector;
begin

end;

operator * (V1: TVector; V2: TVector): Float;
begin

end;

operator * (V: TVector; M: TMatrix): TVector;
begin

end;

operator * (M: TMatrix; V: TVector): TVector;
begin

end;

operator * (M1, M2: TMatrix): TMatrix;
begin
  Result := MatMul(M1,M2);
end;

procedure matSetLowBound(LB: integer);
begin
  LBound := LB;
end;

function matGetLowBound: integer;
begin
  Result := LBound;
end;

function VecFloatAdd(V: TVector; R: Float): TVector;
var
  I, H:Integer;
begin
  H := High(V);
  DimVector(Result,H);
  for I := 0 to H do
    Result[I] := V[I]+R;
end;

function VecFloatSubstr(V: TVector; R: Float): TVector;
var
  I, H:Integer;
begin
  H := High(V);
  DimVector(Result,H);
  for I := 0 to H do
    Result[I] := V[I]-R;
end;

function VecFloatDiv(V: TVector; R: Float): TVector;
var
  I, H:Integer;
begin
  H := High(V);
  DimVector(Result,H);
  for I := 0 to H do
    Result[I] := V[I]/R;
end;

function VecFloatMul(V: TVector; R: Float): TVector;
var
  I, H:Integer;
begin
  H := High(V);
  DimVector(Result,H);
  for I := 0 to H do
    Result[I] := V[I]*R;
end;

function MatFloatAdd(M: TMatrix; R: Float): TMatrix;
var
  I, J, H, H1:Integer;
begin
  H := High(V);
  H1 := High(V[0]);
  DimMatrix(Result,H,H1);
  for I := 0 to H do
    for J := 0 to H1 do
      Result[I,J] := M[I,J]+R;
end;

function MatFloatSubstr(M: TMatrix; R: Float): TMatrix;
var
  I, J, H, H1:Integer;
begin
  H := High(V);
  H1 := High(V[0]);
  DimMatrix(Result,H,H1);
  for I := 0 to H do
    for J := 0 to H1 do
      Result[I,J] := M[I,J]-R;
end;

function MatFloatDiv(M: TMatrix; R: Float): TMatrix;
var
  I, J, H, H1:Integer;
begin
  H := High(V);
  H1 := High(V[0]);
  DimMatrix(Result,H,H1);
  for I := 0 to H do
    for J := 0 to H1 do
      Result[I,J] := M[I,J]/R;
end;

function MatFloatMul(M: TMatrix; R: Float): TMatrix;
var
  I, J, H, H1:Integer;
begin
  H := High(V);
  H1 := High(V[0]);
  DimMatrix(Result,H,H1);
  for I := 0 to H do
    for J := 0 to H1 do
      Result[I,J] := M[I,J]*R;
end;

function AddVectors(V1, V2: TVector): TVector;
var
  I,H:Integer;
begin
  H := High(V1);
  if High(V2) = H then
  begin
    DimVector(Result,H);
    for I := 0 to H do
      Result[I] := V1[I] + V2[I];
  end else
  begin
    Result := nil;
    SetErrCode(MatErrDim);
  end;
end;

function SubstractVectors(V1, V2: TVector): TVector;
var
  I,H:Integer;
begin
  H := High(V1);
  if High(V2) = H then
  begin
    DimVector(Result,H);
    for I := 0 to H do
      Result[I] := V1[I] - V2[I];
  end else
  begin
    Result := nil;
    SetErrCode(MatErrDim);
  end;
end;

function ElementalMultiplyVectors(V1, V2: TVector): TVector;
var
  I,H:Integer;
begin
  H := High(V1);
  if High(V2) = H then
  begin
    DimVector(Result,H);
    for I := 0 to H do
      Result[I] := V1[I] * V2[I];
  end else
  begin
    Result := nil;
    SetErrCode(MatErrDim);
  end;
end;

function DivVectors(V1, V2: TVector): TVector;
var
  I,H:Integer;
begin
  H := High(V1);
  if High(V2) = H then
  begin
    DimVector(Result,H);
    for I := 0 to H do
      Result[I] := V1[I] / V2[I];
  end else
  begin
    Result := nil;
    SetErrCode(MatErrDim);
  end;
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
  begin
    Result := nil;
    SetErrCode(MatErrDim);
  end;
end;

function VecMatMul(V: TVector; M: TMatrix): TVector;
begin

end;

function MatVecMul(M: TMatrix; V: TVector): TVector;
begin

end;

function matTranspose(M: TMatrix): TMatrix;
begin

end;

end.

