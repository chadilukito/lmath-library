{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit NVUtils;

{$warn 5023 off : no warning about unused units}
interface

uses
  LinePars, NVStrings, LLIST, nvbufstream, CRTExt, ustringlists, uGetStr, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('NVUtils', @Register);
end.
