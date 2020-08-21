{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lmoptimum;

{$warn 5023 off : no warning about unused units}
interface

uses
  lmath.ubfgs, lmath.uCobyla, lmath.ueval, lmath.ugenalg, lmath.ugoldsrc, lmath.ulinmin, lmath.ulinminq, 
  lmath.uLinSimplex, lmath.umarq, lmath.umcmc, lmath.uminbrak, lmath.unewton, lmath.usimann, lmath.usimplex, 
  lmath.uTrsTlp, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lmoptimum', @Register);
end.
