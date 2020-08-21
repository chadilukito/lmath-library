{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lmmathstat;

{$warn 5023 off : no warning about unused units}
interface

uses
  lmath.uanova1, lmath.uanova2, lmath.ubartlet, lmath.ubinom, lmath.ucorrel, lmath.udistrib, lmath.uexpdist, 
  lmath.ugamdist, lmath.uibtdist, lmath.uigmdist, lmath.uinvbeta, lmath.uinvgam, lmath.uinvnorm, lmath.ukhi2, 
  lmath.umeansd, lmath.umeansd_md, lmath.umedian, lmath.unonpar, lmath.unormal, lmath.upca, lmath.upoidist, 
  lmath.uskew, lmath.usnedeco, lmath.ustdpair, lmath.ustudind, lmath.uwoolf, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lmmathstat', @Register);
end.
