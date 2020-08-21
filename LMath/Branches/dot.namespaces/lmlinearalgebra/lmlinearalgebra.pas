{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lmlinearalgebra;

{$warn 5023 off : no warning about unused units}
interface

uses
  lmath.ubalance, lmath.ubalbak, lmath.ucholesk, lmath.ueigsym, lmath.ueigval, lmath.ueigvec, lmath.uelmhes, 
  lmath.ueltran, lmath.ugausjor, lmath.uhqr, lmath.uhqr2, lmath.ujacobi, lmath.ulineq, lmath.ulu, lmath.uMatrix, 
  lmath.uqr, lmath.usvd, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lmlinearalgebra', @Register);
end.
