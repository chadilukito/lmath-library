{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lmgenmath;

{$warn 5023 off : no warning about unused units}
interface

uses
  lmath.ubeta, lmath.ucomplex, lmath.udigamma, lmath.uErrors, lmath.ufact, lmath.ugamma, lmath.uhyper, lmath.uibeta, 
  lmath.uigamma, lmath.uintervals, lmath.uintpoints, lmath.ulambert, lmath.umath, lmath.uminmax, lmath.upolev, 
  lmath.uRealPoints, lmath.uround, lmath.uScaling, lmath.utrigo, lmath.utypes, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lmgenmath', @Register);
end.
