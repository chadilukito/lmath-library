{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lmplotter;

{$warn 5023 off : no warning about unused units}
interface

uses
  lmath.uhsvrgb, lmath.uplot, lmath.utexplot, lmath.uwinplot, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lmplotter', @Register);
end.
