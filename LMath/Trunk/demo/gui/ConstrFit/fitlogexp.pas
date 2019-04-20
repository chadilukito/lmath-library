unit FitLogExp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uTypes, uMath, uStrings, uWinStr, lmPointsVec;

function logPdf(S,B,X:float):float;
function logPDFTriple(s,p,q,b1,b2,b3,x:float):float;
function RFunc(X:float; B:TVector):float;
procedure Constr(MaxCon: integer; B, Con : TVector);
procedure InitFit(out Variables:TVector);
procedure ReadDataPoints(var DataPoints:TPoints; Source:TStrings);
const
  VarNum = 6;
  ConstrNum = 3;

implementation

function logPdf(S,B,X:float):float;
var
  a:float;
begin
  a := log10(b);
  result := S*2.303*expo(-exp10(X-a))*exp10(x-a);
end;

function logPDFTriple(s,p,q,b1,b2,b3,x:float):float;
begin
  Result := sqrt(abs(p*logPdf(s,b1,x) + q*logPdf(s,b2,x) + (1-p-q)*logPdf(s,b3,x)));
end;

function RFunc(X:float; B:TVector):float;
begin
  Result := logPDFTriple(B[1],B[2],B[3],B[4],B[5],B[6],X);
end;

procedure Constr(MaxCon: integer; B, Con : TVector);
begin
  Con[1] := B[2];
  Con[2] := B[3];
  Con[3] := 1 - B[2] - B[3];
end;

procedure InitFit(out Variables:TVector);
begin
  DimVector(Variables,VarNum);
  Variables[1] := 1.0; Variables[2] := 0.6; Variables[3] := 0.3;
  Variables[4] := 0.003; Variables[5] := 0.02; Variables[6] := 0.1;
end;

procedure ReadDataPoints(var DataPoints:TPoints; Source:TStrings);
var
  S:string;
  SV:TStrVector;
  I,J:integer;
  Pt:TRealPoint;
begin
  DefaultFormatSettings.DecimalSeparator := '.';
  DataPoints := TPoints.Create(Source.Count);
  DimVector(SV,1);
  for J := 0 to Source.Count - 1 do
  begin
    S := trim(Source[J]);
    Parse(S,#9,SV,I);
    Pt.X := StrToFloat(StrDec(SV[0]));
    Pt.Y := StrToFloat(StrDec(SV[1]));
    DataPoints.Append(Pt);
  end;
end;

end.

