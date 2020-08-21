{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lmRegression;

{$warn 5023 off : no warning about unused units}
interface

uses
  lmath.uConstrNLFit, lmath.uevalfit, lmath.uexlfit, lmath.uexpfit, lmath.ufft, lmath.ufracfit, lmath.ugamfit, 
  lmath.uiexpfit, lmath.ulinfit, lmath.ulogifit, lmath.umulfit, lmath.unlfit, lmath.upolfit, lmath.upowfit, 
  lmath.uregtest, lmath.uSpline, lmath.usvdfit, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lmRegression', @Register);
end.
