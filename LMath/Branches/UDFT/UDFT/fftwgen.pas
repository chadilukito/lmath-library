unit fftwgen;

interface

const
{EPCC (MGB) - FFTW documented constants, taken from "api/fftw3.h". Comments
 to the right of the definitions are transcribed from the original header
 file.}

 FFTW_FORWARD        = -1;
 FFTW_BACKWARD        = 1;

 FFTW_MEASURE         = 0;
 FFTW_DESTROY_INPUT   = 1;   {1U << 0}
 FFTW_UNALIGNED       = 2;   {1U << 1}
 FFTW_CONSERVE_MEMORY = 4;   {1U << 2}
 FFTW_EXHAUSTIVE      = 8;   {1U << 3} {NO_EXHAUSTIVE is default }
 FFTW_PRESERVE_INPUT  = 16;  {1U << 4} {cancels FFTW_DESTROY_INPUT}
 FFTW_PATIENT         = 32;  {1U << 5} {IMPATIENT is default }
 FFTW_ESTIMATE        = 64;  {1U << 6}

{FFTW undocumented constants have not been defined in this implementation.
 They are not required for typical usage of the library.}


type
{$MINENUMSIZE 4} // To be compatible with the fftw. Ignoring this might lead to unintended operations..
  PFFTW_r2r_kind = ^TFFTW_r2r_kind;
  TFFTW_r2r_kind = (
    FFTW_R2HC=0, FFTW_HC2R=1, FFTW_DHT=2,
    FFTW_REDFT00=3, FFTW_REDFT01=4, FFTW_REDFT10=5, FFTW_REDFT11=6,
    FFTW_RODFT00=7, FFTW_RODFT01=8, FFTW_RODFT10=9, FFTW_RODFT11=10
    );

type Tfftwgen_wisdom_writechar = procedure (c: AnsiChar; data: Pointer); cdecl; //  "cdecl" is CRITICAL, do not change..
type Tfftwgen_wisdom_readchar = function (data: Pointer): Integer; cdecl; //  "cdecl" is CRITICAL, do not change..
type Tfftwgen_export_wisdom = procedure (WriteCharFn: Tfftwgen_wisdom_writechar; data: Pointer); cdecl; //  "cdecl" is CRITICAL, do not change..
type Tfftwgen_import_wisdom = function (ReadCharFn: Tfftwgen_wisdom_readchar; data: Pointer): Integer; cdecl; //  "cdecl" is CRITICAL, do not change..
function fftwgen_wisdom_export_AsAnsiString(f: Tfftwgen_export_wisdom): AnsiString;
function fftwgen_wisdom_import_AsAnsiString(f: Tfftwgen_import_wisdom; const AWisdomStr: AnsiString): Integer;

implementation

uses SysUtils;

type
  TWisdomUserData = class(TObject)
    WisdomStr: AnsiString;
    Index: Integer;
  end;
procedure fftwgen_wisdom_write_char(c: AnsiChar; userdata: TWisdomUserData); cdecl; //  "cdecl" is CRITICAL, do not change..
begin
  userdata.WisdomStr := userdata.WisdomStr + c;
end;
function fftwgen_wisdom_export_AsAnsiString(f: Tfftwgen_export_wisdom): AnsiString;
var data: TWisdomUserData;
begin
  Result := '';
  data := TWisdomUserData.Create;
  try
    //f(@fftwgen_wisdom_write_char, data);
    Result := data.WisdomStr;
  finally
    data.Free;
  end;
end;
function fftwgen_wisdom_read_char(userdata: TWisdomUserData): Integer; cdecl; //  "cdecl" is CRITICAL, do not change..
const EOF = -1;
begin
  Inc(userdata.Index);
  if userdata.Index <= Length(userdata.WisdomStr) then Result := Ord(userdata.WisdomStr[userdata.Index])
  else if userdata.Index = (Length(userdata.WisdomStr)+1) then Result := 0
  else Result := EOF;
end;
function fftwgen_wisdom_import_AsAnsiString(f: Tfftwgen_import_wisdom; const AWisdomStr: AnsiString): Integer;
var data: TWisdomUserData;
begin
  //Result := 0;
  data := TWisdomUserData.Create;
  data.WisdomStr := AWisdomStr;
  try
    //Result := f(@fftwgen_wisdom_read_char, data);
  finally
    data.Free;
  end;
end;

end.
