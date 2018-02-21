{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit uPlotter;

interface

uses
  uhsvrgb, uplot, utexplot, uwinplot, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('uPlotter', @Register);
end.
