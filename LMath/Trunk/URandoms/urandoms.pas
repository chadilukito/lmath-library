{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit urandoms;

interface

uses
  urandom, urangaus, uranmt, uranmult, uranmwc, uranuvag, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('urandoms', @Register);
end.
