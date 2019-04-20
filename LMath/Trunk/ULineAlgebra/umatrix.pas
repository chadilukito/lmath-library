unit uMatrix;

{$mode objfpc}{$H+}

interface

uses
  uTypes, uErrors;

operator + (V:TVector; R:Float) Res : TVector; //add float to every element         
operator - (V:TVector; R:Float) Res : TVector; //substract float from every element 
operator / (V:TVector; R:Float) Res : TVector; //divide every element by float      
operator * (V:TVector; R:Float) Res : TVector; //multiply every element by float    

operator + (M:TMatrix; R:Float) Res : TMatrix; //add float to every element        
operator - (M:TMatrix; R:Float) Res : TMatrix; //substract float from every element
operator / (M:TMatrix; R:Float) Res : TMatrix; //divide every element by float     
operator * (M:TMatrix; R:Float) Res : TMatrix; //multiply every element by float   

operator + (V1:TVector; V2:TVector) Res : TVector; // element-wise
operator - (V1:TVector; V2:TVector) Res : TVector;
operator * (V1:TVector; V2:TVector) Res : Float; // dot product

operator * (M:TMatrix; V:TVector) Res : TVector;

operator * (M1, M2 : TMatrix) Res : TMatrix;

//sets low bound for vector/matrix operations, 0 or 1 (defaults to 1)
procedure matSetLowBound(LB:integer);
function  matGetLowBound:integer;

{These functions are used by operators. One important difference is that 
operators _always allocate new array_ for result, while these functions 
use _Ziel_ array if it is not _nil_ by call. Otherwise, new array is allocated.}
function VecFloatAdd(V:TVector; R:Float; Ziel : TVector = nil): TVector;
function VecFloatSubstr(V:TVector; R:Float; Ziel : TVector = nil): TVector;
function VecFloatDiv(V:TVector; R:Float; Ziel : TVector = nil): TVector;
function VecFloatMul(V:TVector; R:Float; Ziel : TVector = nil): TVector;

function MatFloatAdd(M:TMatrix; R:Float; Ziel : TMatrix = nil) : TMatrix;
function MatFloatSubstr(M:TMatrix; R:Float; Ziel : TMatrix = nil) : TMatrix;
function MatFloatDiv(M:TMatrix; R:Float; Ziel : TMatrix = nil) : TMatrix;
function MatFloatMul(M:TMatrix; R:Float; Ziel : TMatrix = nil) : TMatrix;

function AddVectors(V1,V2:TVector; Ziel : TVector = nil): TVector;
function VecElemSubstr(V1,V2:TVector; Ziel : TVector = nil): TVector;

{This function multiplies elements of one vector by elenets of other. 
There is no corresponding operator. Operator * is for dot product.}
function ElementalMultiplyVectors(V1,V2:TVector; Ziel : TVector = nil): TVector;
function DivVectors(V1,V2:TVector; Ziel : TVector = nil): TVector;
function VecDot(V1,V2:TVector) : float;
function VecEucLength(V:TVector; LB : integer = -1) : float;
function MatVecMul(M:TMatrix; V:TVector; Ziel: TVector = nil; LB: integer = -1): TVector;

function MatMul(A, B, Ziel: TMatrix; LB : integer = -1) : TMatrix;

function matTranspose(M, Ziel:TMatrix; LB: integer = -1) : TMatrix;


implementation
type
  TBigArray = array[0..10000000] of float;
  PBigArray = ^TBigArray;

var LBound: integer = 0;

operator + (V: TVector; R: Float) : TVector;
begin
  Result := VecFloatAdd(V,R,nil);
end;

operator - (V: TVector; R: Float) : TVector;
begin
  Result := VecFloatSubstr(V,R,nil);
end;

operator / (V: TVector; R: Float) : TVector;
begin
  Result := VecFloatDiv(V,R,nil);
end;

operator * (V: TVector; R: Float) : TVector;
begin
  Result := VecFloatMul(V,R,nil);
end;

operator + (M: TMatrix; R: Float) : TMatrix;
begin
  Result := MatFloatAdd(M, R, nil);
end;

operator - (M: TMatrix; R: Float) : TMatrix;
begin
  Result := MatFloatSubstr(M, R, nil);
end;

operator / (M: TMatrix; R: Float) : TMatrix;
begin
  Result := MatFloatDiv(M, R, nil);
end;

operator * (M: TMatrix; R: Float) : TMatrix;
begin
  Result := MatFloatMul(M, R, nil);
end;

operator + (V1: TVector; V2: TVector) : TVector;
begin
  Result := AddVectors(V1, V2, nil);
end;

operator - (V1: TVector; V2: TVector) : TVector;
begin
  Result := VecElemSubstr(V1, V2, nil);
end;

operator * (V1: TVector; V2: TVector) : Float;
begin
  Result := VecDot(V1,V2);
end;

operator * (M: TMatrix; V: TVector) : TVector;
begin
  Result := MatVecMul(M,V,nil,LBound);
end;

operator * (M1, M2: TMatrix) : TMatrix;
begin
  Result := MatMul(M1,M2,nil);
end;

procedure matSetLowBound(LB: integer);
begin
  LBound := LB;
end;

function matGetLowBound: integer;
begin
  Result := LBound;
end;

function VecFloatAdd(V:TVector; R:Float; Ziel : TVector = nil): TVector;
var
  I:Integer;
begin
  if Ziel = nil then
    DimVector(Ziel,High(V));
  for I := 0 to High(V) do
    Ziel[I] := V[I]+R;
  Result := Ziel;
end;

function VecFloatSubstr(V:TVector; R:Float; Ziel : TVector = nil): TVector;
var
  I:Integer;
begin
  if Ziel = nil then
    DimVector(Ziel,High(V));
  for I := 0 to High(V) do
    Ziel[I] := V[I]-R;
  Result := Ziel;
end;

function VecFloatDiv(V:TVector; R:Float; Ziel : TVector = nil): TVector;
var
  I:Integer;
begin
  if Ziel = nil then
    DimVector(Ziel,High(V));
  for I := 0 to High(V) do
    Ziel[I] := V[I]/R;
  Result := Ziel;
end;

function VecFloatMul(V:TVector; R:Float; Ziel : TVector = nil): TVector;
var
  I:Integer;
begin
  if Ziel = nil then
    DimVector(Ziel,High(V));
  for I := 0 to High(V) do
    Ziel[I] := V[I]*R;
  Result := Ziel;
end;

function MatFloatAdd(M:TMatrix; R:Float; Ziel : TMatrix = nil) : TMatrix;
var
  I, J:Integer;
begin
  if Ziel = nil then
    DimMatrix(Ziel, High(M), High(M[0]));
  for I := 0 to High(M) do
    for J := 0 to High(M[0]) do
      Ziel[I,J] := M[I,J]+R;
  Result := Ziel;
end;

function MatFloatSubstr(M:TMatrix; R:Float; Ziel : TMatrix = nil) : TMatrix;
var
  I, J:Integer;
begin
  if Ziel = nil then
    DimMatrix(Ziel, High(M), High(M[0]));
  for I := 0 to High(M) do
    for J := 0 to High(M[0]) do
      Ziel[I,J] := M[I,J]-R;
  Result := Ziel;
end;

function MatFloatDiv(M:TMatrix; R:Float; Ziel : TMatrix = nil) : TMatrix;
var
  I, J:Integer;
begin
  if Ziel = nil then
    DimMatrix(Ziel, High(M), High(M[0]));
  for I := 0 to High(M) do
    for J := 0 to High(M[0]) do
      Ziel[I,J] := M[I,J]/R;
  Result := Ziel;
end;

function MatFloatMul(M:TMatrix; R:Float; Ziel : TMatrix = nil) : TMatrix;
var
  I, J:Integer;
begin
  if Ziel = nil then
    DimMatrix(Ziel, High(M), High(M[0]));
  for I := 0 to High(M) do
    for J := 0 to High(M[0]) do
      Ziel[I,J] := M[I,J]*R;
  Result := Ziel;
end;

function AddVectors(V1,V2:TVector; Ziel : TVector = nil) : TVector;
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

function VecElemSubstr(V1,V2:TVector; Ziel : TVector = nil): TVector;
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

function ElementalMultiplyVectors(V1,V2:TVector; Ziel : TVector = nil): TVector;
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

function DivVectors(V1,V2:TVector; Ziel : TVector = nil): TVector;
var
  I,H:Integer;
begin
  H := High(V1);
  if Ziel = nil then
    DimVector(Ziel,H);
  if (High(V2) = H) and (High(Ziel) = H) then
  begin
    for I := 0 to H do
      Ziel[I] := V1[I] / V2[I];
    Result := Ziel;
  end
  else begin
    SetErrCode(MatErrDim);
    Result := nil;
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
    Result := DefaultVal(MatErrDim,0);
end;

function VecEucLength(V: TVector; LB: integer = -1): float;
var
  I:integer;
begin
  if LB = -1 then LB := LBound;
  Result := 0;
  for I := LB to High(V) do
    Result := Result + Sqr(V[I]);
end;

function MatVecMul(M:TMatrix; V:TVector; Ziel: TVector = nil; LB: integer = -1): TVector;
var
  HighRow, HighCol : integer;
  I,J:integer;
  R:float;
begin
  if LB = -1 then
    LB := LBound;
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

function MatMul(A, B, Ziel: TMatrix; LB : integer = -1) : TMatrix;
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

function matTranspose(M, Ziel:TMatrix; LB: integer = -1) : TMatrix;
var
 I,J,H,W:integer;
begin
  H := High(M);
  W := High(M[0]);
  if Ziel = nil then
    DimMatrix(Ziel, W, H);
  if LB = -1 then LB := LBound;
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

end.

