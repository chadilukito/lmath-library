{--------------------------------------------------------------}
{ Delphi interface to the FFTW Version 3.X "Double" library.   }
{ June 9, 2011                                                 }
{ Modified by Serdar S. Kacar                                  }
{ See original file comments below.                            }
{--------------------------------------------------------------}

{--------------------------------------------------------------}
{ Delphi interface to the FFTW library -- FFTW Version 3.0.1.  }
{ Note that this interface is incomplete. Additional function  }
{ interface entries may be added in an anologous manner, see   }
{ fftw  for more details.                  }
{                                                              }
{ Last modified 22/DEC/03                                      }
{ Written by Mark G. Beckett (g.beckett@epcc.ed.ac.uk          }
{--------------------------------------------------------------}

unit fftw_;

interface

uses fftwgen;

const
{$IFDEF WIN32}
  fftw_dllpath = 'libfftw3-32.dll';
{$ENDIF}
{$IFDEF WIN64}
  fftw_dllpath = 'libfftw3-64.dll';
{$ENDIF}

type
  fftw_plan = Pointer;
  Tfftw_real_core = Double;
  Pfftw_real = ^Tfftw_real;
  Tfftw_real = packed record // for fftwl_ compatibility
    v: Tfftw_real_core;
  end;
  Pfftw_complex = ^Tfftw_complex;
  Tfftw_complex = packed array[0..1] of Tfftw_real;
  // alternative Tfftw_complex type definition :
  //Tfftw_complex = packed record
  //  re,im: Tfftw_real;
  //end;

  Pfftw_real_array = ^Tfftw_real_array;
  Tfftw_real_array = array[0..($7FFFFFFF div sizeof(Tfftw_real))-1] of Tfftw_real;
  Pfftw_complex_array = ^Tfftw_complex_array;
  Tfftw_complex_array = array[0..($7FFFFFFF div sizeof(Tfftw_complex))-1] of Tfftw_complex;




function fftw_malloc(n: Integer): Pointer; cdecl; external fftw_dllpath;
procedure fftw_free(p: Pointer); cdecl; external fftw_dllpath;

function fftw_init_threads(): Integer; cdecl; external fftw_dllpath;
procedure fftw_plan_with_nthreads(nthreads: Integer); cdecl; external fftw_dllpath;
procedure fftw_cleanup_threads(); cdecl; external fftw_dllpath;

function fftw_import_system_wisdom(): Integer; cdecl; external fftw_dllpath; // see "fftw-wisdom.exe --help"
procedure fftw_forget_wisdom(); cdecl; external fftw_dllpath;
// Delphi wisdom helper functions :
function fftw_wisdom_export_AsAnsiString(): AnsiString;
function fftw_wisdom_import_AsAnsiString(const AWisdomStr: AnsiString): Integer;

procedure fftw_destroy_plan(plan: fftw_plan); cdecl; external fftw_dllpath;
procedure fftw_execute(plan: fftw_plan); cdecl; external fftw_dllpath;
procedure fftw_execute_dft(plan: fftw_plan;
  inData, outData: Pfftw_complex); cdecl; external fftw_dllpath;
procedure fftw_execute_split_dft(plan: fftw_plan;
  ri, ii, ro, io: Pfftw_real); cdecl; external fftw_dllpath;
procedure fftw_execute_dft_r2c(plan: fftw_plan;
  inData: Pfftw_real; outData: Pfftw_complex); cdecl; external fftw_dllpath;
procedure fftw_execute_split_dft_r2c(plan: fftw_plan;
  inData, ro, io: Pfftw_real); cdecl; external fftw_dllpath;
procedure fftw_execute_dft_c2r(plan: fftw_plan;
  inData: Pfftw_complex; outData: Pfftw_real); cdecl; external fftw_dllpath;
procedure fftw_execute_split_dft_c2r(plan: fftw_plan;
  ri, ii, outData: Pfftw_real); cdecl; external fftw_dllpath;
procedure fftw_execute_r2r(plan: fftw_plan;
  inData, outData: Pfftw_real); cdecl; external fftw_dllpath;

function fftw_plan_dft_1d(n: Integer;
  inData, outData: Pfftw_complex;
  sign: Integer; flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_dft_2d(n0, n1: Integer;
  inData, outData: Pfftw_complex;
  sign: Integer; flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_dft_3d(n0, n1, n2: Integer;
  inData, outData: Pfftw_complex;
  sign: Integer; flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_dft(rank: integer; const n: PInteger;
  inData, outData: Pfftw_complex;
  sign: Integer; flags: Longword): fftw_plan; cdecl; external fftw_dllpath;

function fftw_plan_dft_r2c_1d(n: Integer;
  inData: Pfftw_real; outData: Pfftw_complex;
  flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_dft_r2c_2d(n0, n1: Integer;
  inData: Pfftw_real; outData: Pfftw_complex;
  flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_dft_r2c_3d(n0, n1, n2: Integer;
  inData: Pfftw_real; outData: Pfftw_complex;
  flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_dft_r2c(rank: integer; const n: PInteger;
  inData: Pfftw_real; outData: Pfftw_complex;
  flags: Longword): fftw_plan; cdecl; external fftw_dllpath;

function fftw_plan_dft_c2r_1d(n: Integer;
  inData: Pfftw_complex; outData: Pfftw_real;
  flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_dft_c2r_2d(n0, n1: Integer;
  inData: Pfftw_complex; outData: Pfftw_real;
  flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_dft_c2r_3d(n0, n1, n2: Integer;
  inData: Pfftw_complex; outData: Pfftw_real;
  flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_dft_c2r(rank: integer; const n: PInteger;
  inData: Pfftw_complex; outData: Pfftw_real;
  flags: Longword): fftw_plan; cdecl; external fftw_dllpath;

function fftw_plan_r2r_1d(n: Integer;
  inData, outData: Pfftw_real;
  kind: TFFTW_r2r_kind; flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_r2r_2d(n0, n1: Integer;
  inData, outData: Pfftw_real;
  kind, kind1: TFFTW_r2r_kind; flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_r2r_3d(n0, n1, n2: Integer;
  inData, outData: Pfftw_real;
  kind0, kind1, kind3: TFFTW_r2r_kind; flags: Longword): fftw_plan; cdecl; external fftw_dllpath;
function fftw_plan_r2r(rank: integer; const n: PInteger;
  inData, outData: Pfftw_real;
  const kind: PFFTW_r2r_kind; flags: Longword): fftw_plan; cdecl; external fftw_dllpath;


implementation
{
function fftw_malloc; external fftw_dllpath;
procedure fftw_free; external fftw_dllpath;
function fftw_init_threads; external fftw_dllpath;
procedure fftw_plan_with_nthreads; external fftw_dllpath;
procedure fftw_cleanup_threads; external fftw_dllpath;
function fftw_import_system_wisdom; external fftw_dllpath;
procedure fftw_forget_wisdom; external fftw_dllpath;
procedure fftw_destroy_plan; external fftw_dllpath;
procedure fftw_execute; external fftw_dllpath;
procedure fftw_execute_dft; external fftw_dllpath;
procedure fftw_execute_split_dft; external fftw_dllpath;
procedure fftw_execute_dft_r2c; external fftw_dllpath;
procedure fftw_execute_split_dft_r2c; external fftw_dllpath;
procedure fftw_execute_dft_c2r; external fftw_dllpath;
procedure fftw_execute_split_dft_c2r; external fftw_dllpath;
procedure fftw_execute_r2r; external fftw_dllpath;
function fftw_plan_dft_1d; external fftw_dllpath;
function fftw_plan_dft_2d; external fftw_dllpath;
function fftw_plan_dft_3d; external fftw_dllpath;
function fftw_plan_dft; external fftw_dllpath;
function fftw_plan_dft_r2c_1d; external fftw_dllpath;
function fftw_plan_dft_r2c_2d; external fftw_dllpath;
function fftw_plan_dft_r2c_3d; external fftw_dllpath;
function fftw_plan_dft_r2c; external fftw_dllpath;
function fftw_plan_dft_c2r_1d; external fftw_dllpath;
function fftw_plan_dft_c2r_2d; external fftw_dllpath;
function fftw_plan_dft_c2r_3d; external fftw_dllpath;
function fftw_plan_dft_c2r; external fftw_dllpath;
function fftw_plan_r2r_1d; external fftw_dllpath;
function fftw_plan_r2r_2d; external fftw_dllpath;
function fftw_plan_r2r_3d; external fftw_dllpath;
function fftw_plan_r2r; external fftw_dllpath;
}

procedure fftw_export_wisdom(WriteCharFn: Tfftwgen_wisdom_writechar; data: Pointer); cdecl; external fftw_dllpath;
function fftw_import_wisdom(ReadCharFn: Tfftwgen_wisdom_readchar; data: Pointer): Integer; cdecl; external fftw_dllpath;
function fftw_wisdom_export_AsAnsiString(): AnsiString;
begin
  Result := fftwgen_wisdom_export_AsAnsiString(@fftw_export_wisdom);
end;
function fftw_wisdom_import_AsAnsiString(const AWisdomStr: AnsiString): Integer;
begin
  Result := fftwgen_wisdom_import_AsAnsiString(@fftw_import_wisdom, AWisdomStr);
end;

end.














