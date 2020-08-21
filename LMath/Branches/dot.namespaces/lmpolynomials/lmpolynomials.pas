{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lmpolynomials;

{$warn 5023 off : no warning about unused units}
interface

uses
  lmath.ucrtptpol, lmath.upolutil, lmath.upolynom, lmath.urootpol, lmath.urtpol1, lmath.urtpol2, lmath.urtpol3, 
  lmath.urtpol4, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lmpolynomials', @Register);
end.
