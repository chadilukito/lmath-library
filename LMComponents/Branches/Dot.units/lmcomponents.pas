{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lmComponents;

{$warn 5023 off : no warning about unused units}
interface

uses
  lmath.ufilters, lmath.unumericeditdialogs, lmath.unumericedits, lmath.uPointsVec, lmath.ucoordsys, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('lmath.ufilters', @lmath.ufilters.Register);
  RegisterUnit('lmath.unumericedits', @lmath.unumericedits.Register);
  RegisterUnit('lmath.ucoordsys', @lmath.ucoordsys.Register);
end;

initialization
  RegisterPackage('lmComponents', @Register);
end.
