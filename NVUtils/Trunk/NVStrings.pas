(* This file is part of NVUtils package. 
Copyright V.V. Nesterov (2015).

Distributed under GNU LGPL licence v. 3.0. Copy of the license is included into
the package. *)
unit NVStrings;

interface
uses SysUtils, Classes, Strings;

function FileMatchesMask(FileName, Mask: string):boolean;
function StringMatchesMask(Source, Mask: string):boolean;
function LastPos(Ch:Char; const Source: string):integer; //< last entrance of Ch in Source

// line in TStrings from Pos in TStrings as text
function FindLineByPos(Strings:TStrings;Pos:integer):integer;

function StrChangeFileExt(Source, NewExt:PChar; out Dest:PChar):PChar;

//function Pas2PChar(out Dest:PChar; const S:string):PChar;

implementation

function LastPos(Ch:Char; const Source: string):integer;
var
  I:Integer;
begin
  Result := 0;
  for I := length(Source) downto 1 do
  if Source[I] = Ch then
  begin
    Result := I;
    Break;
  end;
end;

function FindLineByPos(Strings: TStrings; Pos: integer): integer;
var
  I,J:integer;
begin
  Result := -1;
  J := 0;
  for I := 0 to Strings.Count-1 do
  begin
    J := J+length(Strings[I]+LineEnding);
    if Pos < J then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function StringMatchesMask(Source, Mask: string):boolean;
var
  BufS, BufE:string;
  I,J:integer;
begin
  Result := false;
  Mask := UpperCase(Mask);
  Source := UpperCase(Source);
  I := pos('*',Mask);
  J := pos('?',Mask);
  if I <> 0 then
  begin
    BufS := copy(Mask,1,I-1);
    if BufS <> copy(Source, 1, I-1) then Exit; // no match; return false
    BufE := copy(Mask,I+1,length(Mask));
    if BufE = '' then
      Result := true
    else
      Result := BufE = copy(Source,length(Source)-length(BufE)+1,length(BufE));
  end else if J <> 0 then
  begin
    if length(Source) <> length(Mask) then Exit;
    for I := 1 to length(Mask) do
      if Mask[I] = '?' then Source[I] := '?';
    Result := Mask = Source;
  end else
    Result := Mask = Source;
  Result := Result;
end;

function FileMatchesMask(FileName, Mask: string):boolean;
var
  Buf1, Buf2:string;
  I,J:Integer;
begin
  Result := false;
  I := LastPos('.',FileName);
  if I <> 0 then
    Buf1 := copy(FileName,1,I-1)
  else
    Buf1 := FileName;
  J := LastPos('.',Mask);
  if J <> 0 then
    Buf2 := copy(Mask,1,J-1)
  else
    Buf2 := Mask;
  if StringMatchesMask(Buf1,Buf2) then
  begin
    if J = 0 then
    begin
      Result := true;
      Exit;
    end;
    if I = 0 then Exit;
    Buf1 := copy(FileName,I+1,length(FileName));
    Buf2 := copy(Mask,J+1,length(Mask));
    Result := StringMatchesMask(Buf1,Buf2);
  end;
  Result := Result;
end;

function StrChangeFileExt(Source, NewExt: PChar; out Dest : PChar): PChar;
var
  P:PChar;
  L,LL:integer;
begin
  L := StrLen(Source);
  P := Strrscan(Source,'.');
  if P <> nil then
    L :=  sizeuint(P) - sizeuint(Source);
  LL := L + StrLen(NewExt);
  Dest := StrAlloc(LL+1);
  StrLCopy(Dest,Source,L);
  StrCat(Dest,NewExt);
  Result := Dest;
end;

function Pas2PChar(out Dest:PChar; const S: string): PChar;
begin
  Dest := StrAlloc(length(S)+1);
  StrPCopy(Dest,S);
  Result := Dest;
end;


end.
