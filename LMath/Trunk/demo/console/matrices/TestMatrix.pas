program TestMatrix;
uses uTypes, uErrors, uMatrix, uVecUtils, uVecMatPrn, sysutils, dateutils;
const
  LB = 1;

var
  M1, M2, M3, M4, Res : TMatrix;
  ResV, ResV2, Resv3: TVector;
  Rows1, Cols1, Cols2, I : integer;
  time1, time2 : TDateTime;
  ResF: float;
begin
  {%region}
  writeln('Tests with small matrices');
  Rows1 := LB+1; Cols1 := LB+2; // Ro* is highest index of rows and Col* is highest index of columns  1152
  Cols2 := LB+2;

  DimMatrix(M1, Rows1, Cols1);
  DimMatrix(M2, Cols1, Cols2);

     M1[LB,LB] := 1;   M1[LB,LB+1] := 3;    M1[LB,LB+2] := 5;
   M1[LB+1,LB] := 2; M1[LB+1,LB+1] := 4;  M1[LB+1,LB+2] := 7;

    M2[LB,LB] := -5;   M2[LB,LB+1] := 8;   M2[LB,LB+2] := 11;
  M2[LB+1,LB] :=  3; M2[LB+1,LB+1] := 9; M2[LB+1,LB+2] := 21;
  M2[LB+2,LB] :=  4; M2[LB+2,LB+1] := 0; M2[LB+2,LB+2] :=  8;
  {%endregion}
  {%region}
  writeln('Matrix with vector multiplication.');
  writeln('Matrix:');
  PrintMatrix(M2);
  writeln('Vector:');
  printVector(M1[1]);
  ResV := MatVecMul(M2,M1[1],LB);
  writeln('result:');
  PrintVector(ResV);

  writeln('Multiplying matrix:');
  printMatrix(M1);
  writeln('with:');
  printMatrix(M2);
  Res := MatMul(M1,M2,nil,Lb);
  writeln('Result:');
  PrintMatrix(Res);
  {%endregion}
  {%region}
  writeln('Now timing.');
  writeln('First, multiply same matrices 1000000 times.');
  time1 := time;
  DimMatrix(Res,Rows1,Cols2);
  for I := 1 to 1000000 do
    MatMul(M1, M2, Res, LB);
  finalize(res);
  time2 := time;
  writeln('it takes ',inttostr(millisecondsbetween(time2, time1)), ' ms.');

  writeln('Now big matrices, 1500x1500...');
  Rows1 := LB+1500; Cols1 := Rows1; Cols2 := Rows1;
  DimMatrix(M3, Rows1, Cols1);
  DimMatrix(M4, Cols1, Cols2);
  time1 := time;
  DimMatrix(Res,Rows1,Cols2);
  MatMul(M3,M4, Res, LB);
  finalize(res);
  Finalize(M3);
  Finalize(M4);

  time2 := time;
  writeln('it takes ',inttostr(millisecondsbetween(time2, time1)), ' ms.');
 {%endregion}

  write('Press [Enter] to continue...');
  readln;

  Rows1 := LB+1; Cols1 := LB+2;
  writeln('Test of transpose.');
  DimMatrix(Res, Cols1, Rows1);
  matTranspose(M1,Res,LB);
  writeln('initial:');
  Printmatrix(M1);
  writeln('Transposed:');
  printMatrix(Res);
  Finalize(Res);

  write('Press [Enter] to continue...');
  readln;

  writeln('Now playing with vector:');
  printvector(ResV);
  writeln('and matrix');
  printmatrix(M1);

  writeln('+4');
  ResV2 := VecFloatAdd(ResV,4.0,Lb,High(ResV));
  printvector(ResV2);
  writeln;
  Res := M1+4;
  printmatrix(Res);
  Finalize(Res);
  Finalize(ResV2);

  writeln('-4');
  ResV2 := ResV-4;
  printvector(ResV2);
  writeln;
  Res := M1-4;
  printmatrix(Res);
  Finalize(Res);
  Finalize(ResV2);

  writeln('*2');
  ResV2 := ResV*2;
  printvector(ResV2);
  writeln;
  Res := M1*2;
  printmatrix(Res);
  Finalize(Res);
  Finalize(ResV2);

  writeln('/8');
  ResV2 := ResV/8;
  printvector(ResV2);
  writeln;
  Res := M1/8;
  printmatrix(Res);
  Finalize(Res);
  write('Press [Enter] to continue...');
  readln;

  writeln('Elemental operations with vectors');
  resv := resv/9.5;
  printVector(ResV);
  writeln('and');
  printvector(ResV2);

  writeln('Add:');
  ResV3 := ResV+ResV2;
  printvector(ResV3);
  finalize(ResV3);

  writeln('Substract:');
  ResV3 := ResV-ResV2;
  printvector(ResV3);

  writeln('multiply:');
  VecElemMul(ResV,ResV2,ResV3);
  printvector(ResV3);
  finalize(ResV3);

  writeln('Dot product of:');
  printVector(ResV);
  writeln('and');
  printvector(ResV2);
  ResF := VecDotProd(ResV,Resv2,Lb, high(ResV));
  writeln(Format(lmFmtStr,[ResF]));

  writeln('Now testing outer product.');
  ResV := TVector.Create(0,2.0,3.0,4.0,5.0);
  ResV2 := TVector.Create(0,3.0,4.0,5.0);
  PrintVector(ResV);
  writeln('by');
  PrintVector(ResV2);
  writeln('Result:');
  M3 := VecOuterProd(ResV,ResV2,Lb,high(ResV),High(ResV2));
  PrintMatrix(M3);
  writeln('Now opposite order');
  M3 := VecOuterProd(ResV2,ResV,Lb,high(ResV2),High(ResV));
  PrintMatrix(M3);
  DimMatrix(M3,5,5);
  for I := 0 to 5 do
    Seq(0,5,I*10,1,M3[I]);
  writeln('Test for transpose in place.');
  writeln('Original matrix:');
  PrintMatrix(M3);
  MatTransposeInPlace(M3,0,High(M3));
  writeln('Transposed matrix:');
  PrintMatrix(M3);
  write('Press [Enter] to terminate...');
  readln;
end.

