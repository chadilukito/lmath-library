{**************************************************************************
 *   LinePars: unit, defining object to parse command line                *
 *          Copyright (C) 1999, Viatcheslav V. Nesterov                   *
 **************************************************************************
This file is part of NVUtils package.
Distributed under GNU LGPL licence v. 3.0. Copy of the license is included into
the package.

 Ideology:
 Command line consists of 2 types of statements: flags, which define mode
 of operation for the program, and parameters, which define object to
 operate on (for example, name of a file.) E.g.:
   copy source.dat dest.dat /B
 Here sourse.dat and dest.dat are parameters; /B is flag.
 There exists finite set of modes of operation => finite set of flags can
 be defined. In contrast, parameter may be any text.
 Our TCommandLineParser object analyses command line and puts parameters in
 one list; flags, stripped from leading "-" or "/" - into another.
 Both flags and params are kept in upper case.
 Parameter may have a value. Then syntax is: /T:10 (for example). In this
 version only real values are supported. If user provides a value, it is
 kept in Value field, othervise this field has your default meaning.
 You can easily define set of defined flags, using constructor call like this:
 CommandLineParser := TcommandLineParser.Create(NewParam(
   'B',90,NewParam('L',80,nil)));
 You can learn whether specific flag is present in the command line using
 FindCommandFlag function and you can get parameter in defined position using
 function GetParam(Index)
}

unit LinePars;
interface
uses Classes, SysUtils;

const
  ErrUnknownFlag = 'Flag %s is unknown!';
  ErrInvalidNumber = 'Invalid number of parameters!';

type
  TParamNode = class
    Param:String;
    Value:real;
    Next:TParamNode;
    constructor Create(const ParamText:string; AValue:double; NextNode:TParamNode);
    destructor Destroy; override;
  end;

  function NewParam(const ParamText:string; AValue:double; NextParam:TParamNode):TParamNode;

type

  TCommandLineParser = class
    ErroneosFlag:string;
    ParamsNumber:shortint;
    FlagsNumber:shortint;
    CommandFlags:TParamNode; {<Contains flags from the actual command line}
    CommandParams:TParamNode; {<Contains parameters from the actual command line}
    DefinedFlags:TParamNode; {<contains flags, defined in the program}
    SelectedFlag:TParamNode;
    Constructor Create(Flags:TParamNode);
    Destructor Destroy; override;
    {by default fills CommandParams and CommandFlags; override it to add
    any desired actions}
    procedure ParseLine; virtual;
     {If the flag is present in CommandFlags sets SelectedFlag on it and returns true}
    function FindCommandFlag(const FlagText:string):boolean; virtual;
    function GetFlagValue(const FlagText:string):double;
     {returns text value of Parameter # Index. '' if no such parameter present}
    function GetParam(Index:integer):String;
    function ValidCommandLine(MinParams,MaxParams:integer):boolean; virtual;
  end;

  implementation

  constructor TParamNode.Create(const Paramtext:string; AValue:double;
                                    NextNode:TParamNode);
  begin
    TObject.Create;
    Param := ParamText;
    Value:=AValue;
    Next := NextNode;
  end;

  destructor TParamnode.Destroy;
  begin
    if Next <> nil then
      FreeAndNil(Next);
    inherited;
  end;

  function NewParam(const ParamText:string; AValue:double; NextParam:TParamNode):TParamNode;
  begin
    NewParam := TParamNode.Create(ParamText,AValue,NextParam);
  end;

  constructor TCommandLineParser.Create(Flags:TParamNode);
  begin
    TObject.Create;
    DefinedFlags := Flags;
    ParseLine;
  end;

  destructor TCommandLineParser.Destroy;
  begin
    if CommandFlags <> nil then FreeAndNil(CommandFlags);
    if CommandParams <> nil then FreeAndNil(CommandParams);
    if DefinedFlags <> nil then FreeAndNil(DefinedFlags);
    inherited Destroy;
  end;

  procedure TCommandLineParser.ParseLine;
  var
    I:Integer;
    Buff,Buff2:String;
    SelectedParam:TParamNode;

  function ParseFlag(const FlagText:string):TParamNode;
  var
    Buff:string;
    Vall:real;
    I,J:integer;
  begin
    Buff := UpCase(Copy(FlagText,2,255));
    I := Pos(':',Buff);
    if I<>0 then
    begin
      Val(copy(Buff,I+1,255),Vall,J);
      if J<>0 then
      begin
        ParseFlag := nil;
        ErroneosFlag := Buff;
        Exit;
      end;
      ParseFlag := TParamNode.Create(copy(Buff,1,I-1),Vall,nil);
    end
      else  {if no ':'}
    ParseFlag := TParamNode.Create(Buff,0,nil);
  end;

  begin
    SelectedFlag := nil; SelectedParam := nil;
    for I := 1 to ParamCount do
    begin
      Buff := ParamStr(I);
      if (Buff[1] = '/') or (Buff[1] = '-') then
      begin
        if SelectedFlag = nil then {if this is first flag}
        begin
          SelectedFlag := ParseFlag(Buff);
          if SelectedFlag = nil then Continue;{if it was invalid flag}
          CommandFlags := SelectedFlag;{because this was first flag}
        end
        else begin
          SelectedFlag.Next := ParseFlag(Buff);
          if SelectedFlag.Next <> nil then {nil can be if flag was invalid}
             SelectedFlag := SelectedFlag.Next
          else
            Continue;
        end;
        Inc(FlagsNumber);
      end
      else begin
        inc(ParamsNumber);
        Buff2 := UpCase(Buff);
        if SelectedParam = nil then
        begin
          SelectedParam := TParamNode.Create(Buff2,0,nil);
          CommandParams := SelectedParam;
        end
        else begin
          SelectedParam.Next := TParamNode.Create(Buff2,0,nil);
          SelectedParam := SelectedParam.Next;
        end;
      end;
    end; {for}
  end; {proc}

  function TCommandLineParser.FindCommandFlag(const FlagText:string):boolean;
  begin
    FindCommandFlag := true;
    SelectedFlag := CommandFlags;
    while SelectedFlag <> nil do
    begin
      if SelectedFlag.Param = UpCase(FlagText) then Exit;
      SelectedFlag := SelectedFlag.Next;
    end;
    FindCommandFlag := false;
  end;

  function TCommandLineParser.GetFlagValue(const FlagText:string):Double;
  begin
    if FindCommandFlag(FlagText) then GetFlagValue := SelectedFlag.Value
    else GetFlagValue := 0;
  end;

  function TCommandLineParser.GetParam(Index:integer):String;
  var
    I:integer;
    Selected:TParamNode;
  begin
    if Index > ParamsNumber then GetParam := '' else
    begin
      Selected := CommandParams;
      for I := 2 to Index do {if Index=1 loop is not executed and GetParam returns CommandParams.Param}
        Selected := Selected.Next;
      GetParam := Selected.Param;
    end;
  end;

  function TCommandLineParser.ValidCommandLine(MinParams,MaxParams:integer):boolean;
  function FindParamText(const ParamText:string):boolean;
  var
    SelD:TParamNode;
  begin
    SelD := DefinedFlags;
    FindParamText := true;
    while SelD <> nil do
    begin
      if SelD.Param = ParamText then Exit;
      SelD := SelD.Next;
    end;
    FindParamText := false;
  end;

  var
    SelC:TParamNode;
    ErrStr:Ansistring;
  begin
    SelC := CommandFlags;
    ValidCommandLine := true;
    ErrStr := '';
    while SelC <> nil do
    begin
      if not FindParamText(SelC.Param) then
      begin
        ValidCommandLine := false;
        FmtStr(ErrStr, ErrUnknownFlag, [SelC.Param]);
        writeln(ErrStr);
      end;
      SelC := SelC.Next;
    end;
    if not (ParamsNumber in [MinParams..MaxParams]) then
    begin
      ValidCommandLine := false;
      writeln(ErrInvalidNumber);
    end;
  end;

end.
