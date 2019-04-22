{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit uMathUtil;

{$warn 5023 off : no warning about unused units}
interface

uses
  ustrings, uwinstr, uqsort, uVectorHelper, uVecUtils, usearchtrees, usorting, uunitsformat, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('uMathUtil', @Register);
end.
