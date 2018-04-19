{ --------------------------------------------------

  Title   :  Simple Expression Evaluator
  Version :  1.1
  Author  :  Aleksandar Ruzicic (admin@krcko.net)  
  File    :  fbeval.bas

  BIG thanks goes to Jack W. Crenshaw for his
  "LET'S BUILD A COMPILER!" text series
  (http://compilers.iecc.com/crenshaw/)

  You're free to use this in any way you find it
  useful, just "give credit where credit is due" :)

  --------------------------------------------------
  Pascal version by Jean Debord
  for use with DMath
  -------------------------------------------------- }

unit ueval;

interface

uses
  Classes, SysUtils, utypes, uErrors, uminmax, umath, utrigo, uhyper, uranmt, ufact, ubinom,
  ugamma, uigamma, ubeta, uibeta, ulambert, upoidist, uexpdist, 
  unormal, ugamdist, uibtdist, uigmdist, uinvnorm, uinvgam, uinvbeta; 

function InitEval : Integer;

procedure SetVariable(VarName : string; Value : Float);

procedure SetFunction(FuncName : String; Wrapper : TWrapper);

function Eval(ExpressionString : String) : Float;

procedure DoneEval;

var
  ParsingError    : Boolean;

implementation

{ --------------------------------------------------
  Types and constants
  -------------------------------------------------- }

const
  TAB     = ^I;   { Tab character }

type TEvalVariable = class
  Name  : String;
  Value : Float;
end;

type TEvalFunction = class
  Name    : String;
  Wrapper : TWrapper;
end;

{ ---------------------------------------------------
  Global variables
  --------------------------------------------------- }

const
  DegToRad = Pi / 180.0;
  RadToDeg = 180.0 / Pi;

var
  Variables : TStringList;
  Functions : TStringList;

  NFunc, e        : Integer;
  Position        : Integer;
  CurrentFunction : String;
  Source          : String;
  ErrorTag        : String;
  Look            : Char;

procedure SetVariable(VarName : string; Value : Float);
var
  Variable:TEvalVariable;
  UName: string;
  I:integer;
begin
  UName := UpperCase(VarName);
  if Variables.Find(UName,I) then
    (Variables.Objects[I] as TEvalVariable).Value := Value
  else begin
    Variable := TEvalVariable.Create;
    Variable.Name := VarName;
    Variable.Value := Value;
    Variables.AddObject(UName,Variable);
  end;
end;

function GetVariable(VarName : string) : Float;
var
  I : Integer;
begin
  if ParsingError then
  begin
    GetVariable := 0.0;
    Exit;
  end;
  if Variables.Find(UpperCase(VarName),I) then
    Result := (Variables.Objects[I] as TEvalVariable).Value
  else begin
    e := 3;
    ErrorTag := VarName;
    Position := Position - Length(VarName);
    ParsingError := True;
    GetVariable := 0.0;
  end;
end;

procedure SetFunction(FuncName : String; Wrapper : TWrapper);
var
  I : Integer;
  UName:string;
  Eve: TEvalFunction;
begin
  UName := UpperCase(FuncName);
  if Functions.Find(UName,I) then
  begin
    e := 255;
    ErrorTag := FuncName;
  end else
  begin
    Eve := TEvalFunction.Create;
    Eve.Name := FuncName;
    Eve.Wrapper := Wrapper;
    Functions.AddObject(UName,Eve);
  end;
end;

function GetFunction(FuncName : String; ArgC : Integer; ArgV : TVector; StartPos : Integer) : Float;
var
  I : Integer;
  UName:string;
begin
  if ParsingError then
  begin
    GetFunction := 0.0;
    Exit;
  end;
  UName := UpperCase(FuncName);
  if Functions.Find(UName,I) then
  begin
    CurrentFunction := UName;
    GetFunction := (Functions.Objects[I] as TEvalFunction).Wrapper(ArgC, ArgV);
    CurrentFunction := '';
  end else
  begin
    e := 4;
    ErrorTag := FuncName;
    Position := startPos;
    ParsingError := True;
    GetFunction := 0.0;
  end;
end;

procedure GetChar;
begin
  if ParsingError then Exit;

  Inc(Position);

  if Position <= Length(Source) then
    Look := Source[Position]
  else
    e := 0;  { end of expression }
end;

function IsAlpha(C : Char) : Boolean;
begin
  IsAlpha := UpCase(C) in ['A'..'Z', '_'];
end;

function IsDigit(C : Char) : Boolean;
begin
  IsDigit := C in ['0'..'9'];
end;

function IsHexChar(C : Char) : Boolean;
begin
  IsHexChar := UpCase(C) in ['0'..'9', 'A'..'F'];
end;

function IsBinChar(C : Char) : Boolean;
begin
  IsBinChar := C in ['0', '1'];
end;

function IsOctChar(C : Char) : Boolean;
begin
  IsOctChar := C in ['0'..'7'];
end;

function IsAlNum(C : Char) : Boolean;
begin
  IsAlNum := UpCase(C) in ['0'..'9', 'A'..'Z', '_'];
end;

function IsWhite(C : Char) : Boolean;
begin
  IsWhite := C in [' ', TAB];
end;

function IsAddop(C : Char) : Boolean;
begin
  IsAddop := C in ['+', '-'];
end;

function IsMulop(C : Char) : Boolean;
begin
  IsMulop := C in ['*', '/'];
end;

function IsShiftop(C : Char) : Boolean;
begin
  IsShiftop := C in ['<', '>'];
end;

procedure SkipWhite;
begin
  while IsWhite(Look) do
    GetChar;
end;

procedure Unexpected;
begin
  e := 1;
  ErrorTag := Look;
  ParsingError := True;
end;

function Match(What : Char) : Boolean;
begin
  if ParsingError then
  begin
    Match := False;
    Exit;
  end;

  if Look = What then
  begin
    GetChar;
    SkipWhite;
    Match := True;
  end
  else begin
    Unexpected;
    Match := False;
  end;
end;

function GetName : String;
var
  Token : String;
begin
  if ParsingError then
    begin
      GetName := '';
      Exit;
    end;

  if not IsAlpha(Look) then
    begin
      Unexpected;
      GetName := '';
      Exit;
    end;

  Token := '';
  while IsAlNum(Look) do
    begin
      Token := Token + Look;
      GetChar;
    end;

  SkipWhite;

  GetName := Token;
end;

function GetNum : Float;
var
  Num     : String;
  dot,
  isHex,
  isOct,
  isBin   : Boolean;
  X       : Float;
  ErrCode : Integer;
begin
  if ParsingError then
    begin
      GetNum := 0.0;
      Exit;
    end;

  Num   := '';
  dot   := False;
  isHex := False;
  isOct := False;
  isBin := False;

  if Look = '&' then
    begin
      Match('&');

      if Look = 'H' then
        begin
          isHex := True;
          Num := '&H';
        end
      else if Look = 'B' then
        begin
          isBin := True;
          Num := '&B';
        end
      else if Look = 'O' then
        begin
          isOct := True;
          Num := '&O';
        end
      else
        begin
          Unexpected;
          GetNum := 0.0;
          Exit;
        end;

      GetChar;
    end
  else if not (IsDigit(Look) or (Look = '.')) then
    begin
      Unexpected;
      GetNum := 0.0;
      Exit;
    end;

  if isHex or isBin or isOct then
    while (IsHexChar(Look) and isHex) or (IsBinChar(Look) and IsBin) or (IsOctChar(Look) and isOct) do
      begin
        Num := Num + Look;
        GetChar;
      end
  else
    begin
      Num := '0';
      while (IsDigit(Look) or (Look = '.')) do
        begin
          if Look = '.' then
            begin
              if dot then
                begin
                  Unexpected;
                  GetNum := 0.0;
                  Exit;
                end
              else
                begin
                  Num := Num + '.';
                  dot := True;
                end;
            end
          else
            Num := Num + Look;

          GetChar;
        end;
    end;

  SkipWhite;

  Val(Num, X, ErrCode);
  GetNum := X;
end;

function Expression : Float; forward;
function AddOp      : Float; forward;
function ShiftOp    : Float; forward;
function ModOp      : Float; forward;
function DivOp      : Float; forward;
function MulOp      : Float; forward;
function UnOp       : Float; forward;
function ExpOp      : Float; forward;
function ImpOp      : Float; forward;
function EqvOp      : Float; forward;
function XorOp      : Float; forward;
function OrOp       : Float; forward;
function AndOp      : Float; forward;
function NotOp      : Float; forward;

function Identifier : Float;
var
  Ident   : String;
  Res     : Float;
  ArgV    : TVector;
  ArgC    : Integer;
  FuncPos : Integer;
  Done    : Boolean;
begin
  if ParsingError then
    begin
      Identifier := 0.0;
      Exit;
    end;

  DimVector(ArgV, MaxArg);

  FuncPos := Position;
  Ident := GetName;
  ArgC := 0;

  if Look = '(' then
    begin
      Match('(');

      if Look = ')' then
        begin
          Match(')');
          Res := GetFunction(Ident, 1, ArgV, FuncPos);
        end
      else
        begin
          Done := False;

          repeat
            if ParsingError then
              begin
                Identifier := 0.0;
                Exit;
              end;

            SkipWhite;
            Inc(ArgC);
            ArgV[ArgC] := Expression;
            Done := (Look <> ',');

            if Not Done then GetChar;  { eat comma }
          until Done;

          if Match(')') then
            Res := GetFunction(Ident, ArgC, ArgV, FuncPos);
        end
    end
  else
    Res := GetVariable(Ident);
  SkipWhite;
  Identifier := Res;
end;

function Factor : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      Factor := 0.0;
      Exit;
    end;

  if Look = '(' then
    begin
      Match('(');
      Res := Expression;
      if not Match(')') then
        begin
          e := 2;
          ParsingError := True;
        end;
    end  
  else if IsAlpha(Look) then
    Res := Identifier
  else
    Res := GetNum;

  Factor := Res;
end;

function Expression : Float;
begin
  Expression := AddOp;
end;

function AddOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      AddOp := 0.0;
      Exit;
    end;

  Res := ShiftOp;

  while IsAddop(Look) do
    begin
      if ParsingError then
        begin
          AddOp := 0.0;
          Exit;
        end;

      case Look of
        '+' : begin
                Match('+');
                Res := Res + ShiftOp;
              end;
        '-' : begin
                Match('-');
                Res := Res - ShiftOp;
              end;
      end;
    end;

  AddOp := Res;
end;

function ShiftOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      ShiftOp := 0.0;
      Exit;
    end;

  Res := ModOp;

  while IsShiftop(Look) do
    begin
      if ParsingError then
        begin
          ShiftOp := 0.0;
          Exit;
        end;

      case Look of
        '<' : begin
                Match('<');
                Res := Trunc(Res) shl Trunc(ModOp);
              end;
        '>' : begin
                Match('>');
                Res := Trunc(Res) shr Trunc(ModOp);
              end;  
      end;
    end;
   
  ShiftOp := Res;
end;

function ModOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      ModOp := 0.0;
      Exit;
    end;

  Res := DivOp;

  while Look = '%' do
    begin
      if ParsingError then
        begin
          ModOp := 0.0;
          Exit;
        end;

      Match('%');
      Res := Trunc(Res) mod Trunc(DivOp);
    end;

  ModOp := Res;
end;

function DivOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      DivOp := 0.0;
      Exit;
    end;

  Res := MulOp;

  while Look = '\' do
    begin
      if ParsingError then
        begin
          DivOp := 0.0;
          Exit;
        end;

      Match('\');
      Res := Trunc(Res) div Trunc(MulOp);
    end;
    
  DivOp := Res;
end;

function MulOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      MulOp := 0.0;
      Exit;
    end;

  Res := UnOp;

  while IsMulop(Look) do
    begin
      if ParsingError then
        begin
          MulOp := 0.0;
          Exit;
        end;
    
      case Look of
        '*' : begin
                Match('*');
                Res := Res * UnOp;
              end;
        '/' : begin
                Match('/');
                Res := Res / UnOp;
              end;
      end;
    end;

  MulOp := Res;
end;

Function UnOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      UnOp := 0.0;
      Exit;
    end;

  if IsAddop(Look) then
    case Look of
      '+' : begin
              Match('+');
              Res := ExpOp;
            end;
      '-' : begin
              Match('-');
              Res := - ExpOp;
            end;
    end
  else
    Res := ExpOp;
    
  UnOp := Res;
end;

function ExpOp : Float;
var
  Res : Float;
begin
  if ParsingError then
  begin
    ExpOp := 0.0;
    Exit;
  end;

  Res := ImpOp;
    
  while Look = '^' do
  begin
    if ParsingError then
    begin
      ExpOp := 0.0;
      Exit;
    end;

    Match('^');
    Res := Power(Res, ImpOp);
  end;

  ExpOp := Res;
end;

function ImpOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      ImpOp := 0.0;
      Exit;
    end;

  Res := EqvOp;

  while Look = '@' do
    begin
      if ParsingError then
        begin
          ImpOp := 0.0;
          Exit;
        end;
    
      Match('@');
      Res := (not Trunc(Res)) or Trunc(EqvOp);
    end;

  ImpOp := Res;
end;

function EqvOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      EqvOp := 0.0;
      Exit;
    end;

  Res := XorOp;

  while Look = '=' do
    begin
      if ParsingError then
        begin
          EqvOp := 0.0;
          Exit;
        end;

      Match('=');
      Res := not (Trunc(Res) xor Trunc(XorOp));
    end;
    
  EqvOp := Res;
end;

function XorOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      XorOp := 0.0;
      Exit;
    end;

  Res := OrOp;

  while Look = '$' do
    begin
      if ParsingError then
        begin
          XorOp := 0.0;
          Exit;
        end;

      Match('$');
      Res := Trunc(Res) xor Trunc(OrOp);
    end;

  XorOp := Res;
end;

function OrOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      OrOp := 0.0;
      Exit;
    end;
    
  Res := AndOp;

  while Look = '|' do
    begin
      if ParsingError then
        begin
          OrOp := 0.0;
          Exit;
        end;

      Match('|');
      Res := Trunc(Res) or Trunc(AndOp);
    end;
    
  OrOp := Res;
end;

function AndOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      AndOp := 0.0;
      Exit;
    end;

  Res := NotOp;
    
  while Look = '&' do
    begin
      if ParsingError then
        begin
          AndOp := 0.0;
          Exit;
        end;

      Match('&');
      Res := Trunc(Res) and Trunc(NotOp);
    end;

  AndOp := Res;
end;

function NotOp : Float;
var
  Res : Float;
begin
  if ParsingError then
    begin
      NotOp := 0.0;
      Exit;
    end;

  if Look = '!' then
    Res := not Trunc(Factor)
  else
    Res := Factor;

  NotOp := Res;
end;

function StandardSEEFunctions(ArgC : TArgC; ArgV : TVector) : Float;
var
  Res : Float;
begin
  Res := 0.0;

  if CurrentFunction = 'ABS' then
    Res := Abs(ArgV[1])

  else if CurrentFunction = 'SGN' then
    Res := Sgn(ArgV[1])

  else if CurrentFunction = 'INT' then
    Res := Int(ArgV[1])

  else if CurrentFunction = 'SQRT' then
    begin
      if ArgV[1] > 0.0 then
        Res := Sqrt(ArgV[1])
      else
        SetErrCode(FDomain);
    end

  else if CurrentFunction = 'EXP' then
    Res := Expo(ArgV[1])

  else if CurrentFunction = 'LN' then
    Res := Log(ArgV[1])

  else if CurrentFunction = 'LOG10' then
    Res := Log10(ArgV[1])

  else if CurrentFunction = 'LOG2' then
    Res := Log2(ArgV[1])

  else if CurrentFunction = 'RND' then
    Res := (IRanMT + 2147483648.0) / 4294967296.0

  else if CurrentFunction = 'FACT' then
    Res := Fact(Trunc(ArgV[1]))
    
  else if CurrentFunction = 'BINOMIAL' then
    Res := Binomial(Trunc(ArgV[1]), Trunc(ArgV[2]))

  else if CurrentFunction = 'DEG' then
    Res := ArgV[1] * RadToDeg

  else if CurrentFunction = 'RAD' then
    Res := ArgV[1] * DegToRad

  else if CurrentFunction = 'SIN' then
    Res := Sin(ArgV[1])

  else if CurrentFunction = 'COS' then
    Res := Cos(ArgV[1])

  else if CurrentFunction = 'TAN' then
    Res := Tan(ArgV[1])

  else if CurrentFunction = 'ARCSIN' then
    Res := ArcSin(ArgV[1])

  else if CurrentFunction = 'ARCCOS' then
    Res := ArcCos(ArgV[1])

  else if CurrentFunction = 'ARCTAN' then
    Res := ArcTan(ArgV[1])

  else if CurrentFunction = 'ARCTAN2' then
    Res := ArcTan2(ArgV[1], ArgV[2])

  else if CurrentFunction = 'SINH' then
    Res := Sinh(ArgV[1])

  else if CurrentFunction = 'COSH' then
    Res := Cosh(ArgV[1])

  else if CurrentFunction = 'TANH' then
    Res := Tanh(ArgV[1])

  else if CurrentFunction = 'ARCSINH' then
    Res := ArcSinh(ArgV[1])

  else if CurrentFunction = 'ARCCOSH' then
    Res := ArcCosh(ArgV[1])

  else if CurrentFunction = 'ARCTANH' then
    Res := ArcTanh(ArgV[1])

  else if CurrentFunction = 'GAMMA' then
    Res := Gamma(ArgV[1])

  else if CurrentFunction = 'IGAMMA' then
    Res := IGamma(ArgV[1], ArgV[2])

  else if CurrentFunction = 'BETA' then
    Res := Beta(ArgV[1], ArgV[2])

  else if CurrentFunction = 'IBETA' then
    Res := IBeta(ArgV[1], ArgV[2], ArgV[3])

  else if CurrentFunction = 'ERF' then
    Res := Erf(ArgV[1])

  else if CurrentFunction = 'LAMBERTW' then
    Res := LambertW(ArgV[1], True, False)
    
  else if CurrentFunction = 'PBINOM' then
    Res := PBinom(Trunc(ArgV[1]), ArgV[2], Trunc(ArgV[3]))
    
  else if CurrentFunction = 'FBINOM' then
    Res := PBinom(Trunc(ArgV[1]), ArgV[2], Trunc(ArgV[3]))

  else if CurrentFunction = 'PPOISSON' then
    Res := PPoisson(ArgV[1], Trunc(ArgV[2]))
    
  else if CurrentFunction = 'FPOISSON' then
    Res := FPoisson(ArgV[1], Trunc(ArgV[2]))
    
  else if CurrentFunction = 'DEXPO' then
    Res := DExpo(ArgV[1], ArgV[2])
    
  else if CurrentFunction = 'FEXPO' then
    Res := FExpo(ArgV[1], ArgV[2])
    
  else if CurrentFunction = 'DGAMMA' then
    Res := DGamma(ArgV[1], ArgV[2], ArgV[3])
    
  else if CurrentFunction = 'FGAMMA' then
    Res := FGamma(ArgV[1], ArgV[2], ArgV[3])
    
  else if CurrentFunction = 'DBETA' then
    Res := DBeta(ArgV[1], ArgV[2], ArgV[3])
    
  else if CurrentFunction = 'FBETA' then
    Res := FBeta(ArgV[1], ArgV[2], ArgV[3])
    
  else if CurrentFunction = 'DNORM' then
    Res := DNorm(ArgV[1])
    
  else if CurrentFunction = 'FNORM' then
    Res := FNorm(ArgV[1])
    
  else if CurrentFunction = 'PNORM' then
    Res := PNorm(ArgV[1])
    
  else if CurrentFunction = 'INVNORM' then
    Res := InvNorm(ArgV[1])
    
  else if CurrentFunction = 'DSTUDENT' then
    Res := DStudent(Trunc(ArgV[1]), ArgV[2])
    
  else if CurrentFunction = 'FSTUDENT' then
    Res := FStudent(Trunc(ArgV[1]), ArgV[2])
    
  else if CurrentFunction = 'PSTUDENT' then
    Res := PStudent(Trunc(ArgV[1]), ArgV[2])
    
  else if CurrentFunction = 'INVSTUDENT' then
    Res := InvStudent(Trunc(ArgV[1]), ArgV[2])
    
  else if CurrentFunction = 'DKHI2' then
    Res := DKhi2(Trunc(ArgV[1]), ArgV[2])
    
  else if CurrentFunction = 'FKHI2' then
    Res := FKhi2(Trunc(ArgV[1]), ArgV[2])
    
  else if CurrentFunction = 'PKHI2' then
    Res := PKhi2(Trunc(ArgV[1]), ArgV[2])
    
  else if CurrentFunction = 'INVKHI2' then
    Res := InvKhi2(Trunc(ArgV[1]), ArgV[2])
    
  else if CurrentFunction = 'DSNEDECOR' then
    Res := DSnedecor(Trunc(ArgV[1]), Trunc(ArgV[2]), ArgV[3])
    
  else if CurrentFunction = 'FSNEDECOR' then
    Res := FSnedecor(Trunc(ArgV[1]), Trunc(ArgV[2]), ArgV[3])
    
  else if CurrentFunction = 'PSNEDECOR' then
    Res := PSnedecor(Trunc(ArgV[1]), Trunc(ArgV[2]), ArgV[3])
    
  else if CurrentFunction = 'INVSNEDECOR' then
    Res := InvSnedecor(Trunc(ArgV[1]), Trunc(ArgV[2]), ArgV[3]);
  
  StandardSEEFunctions := Res;
  ParsingError := (MathErr <> FOk);
end;

function InitEval : Integer;
begin
  { Initialize the 'Mersenne Twister' random number generator
    using the standard generator }

  Randomize;
  InitMT(Trunc(Random * 1.0E+8));

  Functions := TStringList.Create;
  Functions.Sorted := true;
  Functions.CaseSensitive := false;
  Functions.Duplicates := dupError;
  Functions.Capacity := 100;
  Functions.OwnsObjects := true;

  Variables := TStringList.Create;
  Variables.Sorted := true;
  Variables.CaseSensitive := false;
  Variables.Duplicates := dupError;
  Variables.Capacity := 50;
  Variables.OwnsObjects := true;

  { Initialize the built-in functions }

  NFunc := 0;
  
  SetFunction('Abs',         @StandardSEEFunctions);
  SetFunction('Sgn',         @StandardSEEFunctions);
  SetFunction('Int',         @StandardSEEFunctions);
  SetFunction('Sqrt',        @StandardSEEFunctions);
  SetFunction('Exp',         @StandardSEEFunctions);
  SetFunction('Ln',          @StandardSEEFunctions);
  SetFunction('Log10',       @StandardSEEFunctions);
  SetFunction('Log2',        @StandardSEEFunctions);
  SetFunction('Fact',        @StandardSEEFunctions);
  SetFunction('Binomial',    @StandardSEEFunctions);
  SetFunction('Rnd',         @StandardSEEFunctions);
  SetFunction('Deg',         @StandardSEEFunctions);
  SetFunction('Rad',         @StandardSEEFunctions);
  SetFunction('Sin',         @StandardSEEFunctions);
  SetFunction('Cos',         @StandardSEEFunctions);
  SetFunction('Tan',         @StandardSEEFunctions);
  SetFunction('ArcSin',      @StandardSEEFunctions);
  SetFunction('ArcCos',      @StandardSEEFunctions);
  SetFunction('ArcTan',      @StandardSEEFunctions);
  SetFunction('ArcTan2',     @StandardSEEFunctions);
  SetFunction('Sinh',        @StandardSEEFunctions);
  SetFunction('Cosh',        @StandardSEEFunctions);
  SetFunction('Tanh',        @StandardSEEFunctions);
  SetFunction('ArcSinh',     @StandardSEEFunctions);
  SetFunction('ArcCosh',     @StandardSEEFunctions);
  SetFunction('ArcTanh',     @StandardSEEFunctions);
  SetFunction('Gamma',       @StandardSEEFunctions);
  SetFunction('IGamma',      @StandardSEEFunctions);
  SetFunction('Beta',        @StandardSEEFunctions);
  SetFunction('IBeta',       @StandardSEEFunctions);
  SetFunction('Erf',         @StandardSEEFunctions);
  SetFunction('LambertW',    @StandardSEEFunctions);
  SetFunction('PBinom',      @StandardSEEFunctions);
  SetFunction('FBinom',      @StandardSEEFunctions);
  SetFunction('PPoisson',    @StandardSEEFunctions);
  SetFunction('FPoisson',    @StandardSEEFunctions);
  SetFunction('DExpo',       @StandardSEEFunctions);
  SetFunction('FExpo',       @StandardSEEFunctions);
  SetFunction('DGamma',      @StandardSEEFunctions);
  SetFunction('FGamma',      @StandardSEEFunctions);
  SetFunction('DBeta',       @StandardSEEFunctions);
  SetFunction('FBeta',       @StandardSEEFunctions);
  SetFunction('DNorm',       @StandardSEEFunctions);
  SetFunction('FNorm',       @StandardSEEFunctions);
  SetFunction('PNorm',       @StandardSEEFunctions);
  SetFunction('InvNorm',     @StandardSEEFunctions);
  SetFunction('DStudent',    @StandardSEEFunctions);
  SetFunction('FStudent',    @StandardSEEFunctions);
  SetFunction('PStudent',    @StandardSEEFunctions);
  SetFunction('InvStudent',  @StandardSEEFunctions);  
  SetFunction('DKhi2',       @StandardSEEFunctions);
  SetFunction('FKhi2',       @StandardSEEFunctions);
  SetFunction('PKhi2',       @StandardSEEFunctions);
  SetFunction('InvKhi2',     @StandardSEEFunctions);  
  SetFunction('DSnedecor',   @StandardSEEFunctions);
  SetFunction('FSnedecor',   @StandardSEEFunctions);
  SetFunction('PSnedecor',   @StandardSEEFunctions);
  SetFunction('InvSnedecor', @StandardSEEFunctions);  

  InitEval := NFunc;
end;

function Eval(ExpressionString : String) : Float;
begin
  Source := '('+StringReplace(UpperCase(ExpressionString),'**','^',[rfReplaceAll])+')'; // cheap and dirty, I know
  e := 0;
  Position := 0;
  ErrorTag := '';
  ParsingError := False;
  GetChar;
  SkipWhite;
  Eval := Expression;
end;

procedure DoneEval;
begin
  FreeAndNil(Functions);
  FreeAndNil(Variables);
end;

end.


