{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lmMathUtil;

{$warn 5023 off : no warning about unused units}
interface

uses
  lmath.uqsort, lmath.usearchtrees, lmath.usorting, lmath.ustrings, lmath.uunitsformat, lmath.uVecFunc, 
  lmath.uVecMatPrn, lmath.uVectorHelper, lmath.uVecUtils, lmath.uwinstr, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lmMathUtil', @Register);
end.
