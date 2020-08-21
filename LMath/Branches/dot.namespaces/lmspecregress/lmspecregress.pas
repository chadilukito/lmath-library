{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lmspecregress;

{$warn 5023 off : no warning about unused units}
interface

uses
  lmath.udistribs, lmath.ugauss, lmath.ugaussf, lmath.ugoldman, lmath.uhillfit, lmath.umichfit, lmath.umintfit, 
  lmath.umodels, lmath.upkfit, lmath.usigmatable, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lmspecregress', @Register);
end.
