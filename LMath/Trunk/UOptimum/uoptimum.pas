{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit uOptimum;

{$warn 5023 off : no warning about unused units}
interface

uses
  ubfgs, ueval, ugenalg, ugoldsrc, ulinmin, ulinminq, umarq, umcmc, uminbrak, unewton, usimann, usimplex, uCobyla, 
  uTrsTlp, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('uOptimum', @Register);
end.
