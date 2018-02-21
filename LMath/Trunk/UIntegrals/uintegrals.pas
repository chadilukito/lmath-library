{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit uintegrals;

interface

uses
  ugausleg, urkf, utrapint, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('uintegrals', @Register);
end.
