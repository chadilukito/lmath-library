unit uVectorHelper;
{$mode objfpc}
{$MODESWITCH TYPEHELPERS}
interface

uses
  Classes, SysUtils, uTypes, uSorting, uStrings;

type

{ TVectorHelper }

TVectorHelper = type helper for TVector
  procedure Insert(value:Float; index:integer);
  procedure Remove(index:integer);
  procedure Swap(ind1,ind2:integer);
  procedure Fill(St, En : integer; Val:Float);
  procedure Sort(Descending:boolean);
  procedure InsertFrom(Source:TVector; Lb, Ub: integer; ind:integer);
  function ToString(Index:integer):string;
  //Sends string representation of the subarray to Dest. If Indices, sends
  //indices as well, ';' used as delimiter
  function ToStrings(Dest:TStrings; First, Last:integer;
            Indices:boolean; Delimiter: char):integer;
end;

{ TIntVectorHelper }

TIntVectorHelper = type helper for TIntVector
  procedure Insert(value:Integer; index:integer);
  procedure Remove(index:integer);
  procedure Swap(ind1,ind2:integer);
  procedure Fill(St, En : integer; Val:Integer);
  procedure InsertFrom(Source:TIntVector; Lb, Ub: integer; ind:integer);
  function ToString(Index:integer):string;
  //Sends string representation of the subarray to Dest. If Indices, sends
  //indices as well, ';' used as delimiter
  function ToStrings(Dest:TStrings; First, Last:integer;
            Indices:boolean; Delimiter: char):integer;
end;


implementation

{ TIntVectorHelper }

procedure TIntVectorHelper.Insert(value: integer; index: integer);
var
  I: DWord;
begin
  for I := High(self) downto index+1 do
    self[I] := self[I-1];
  self[Index] := value;
end;

procedure TIntVectorHelper.Remove(index: integer);
var
  I: Integer;
begin
  for I := index to high(self)-2 do
    self[I] := self[I+1];
end;

procedure TIntVectorHelper.Swap(ind1, ind2: integer);
var
  F:integer;
begin
  F := self[ind1];
  self[ind1] := self[ind2];
  self[ind2] := F;
end;

procedure TIntVectorHelper.Fill(St, En: integer; Val: integer);
var
  I: Integer;
begin
  for I := St to En do
    self[I] := Val;
end;

procedure TIntVectorHelper.InsertFrom(Source: TIntVector; Lb, Ub: integer;
  ind: integer);
var
  I, C: Integer;
begin
  C := Ub - Lb + 1;
  SetLength(self, length(self)+C);
  for I := high(self) downto ind do
    self[I] := self[I-C]; // moving existing values freeing place for newly inserted
  for I := Lb to Ub do
    self[ind+I-Lb] := source[I];
end;

function TIntVectorHelper.ToString(Index: integer): string;
begin
  Result := IntStr(self[Index]);
end;

function TIntVectorHelper.ToStrings(Dest: TStrings; First, Last: integer;
  Indices: boolean; Delimiter: char): integer;
var
  I:integer;
  Buf:string;
begin
  if (not Assigned(Dest)) then
  begin
    Result := -1;
    Exit;
  end;
  for I := First to Last do
  begin
    if Indices then
      Buf := IntStr(I)+Delimiter+' '
    else
      Buf := '';
    Buf := Buf + ToString(I);
    Dest.Add(Buf);
  end;
  Result := 0;
end;

{ TVectorHelper }

procedure TVectorHelper.Insert(value: Float; index: integer);
var
  I: DWord;
begin
  for I := High(self) downto index+1 do
    self[I] := self[I-1];
  self[Index] := value;
end;

procedure TVectorHelper.Remove(index: integer);
var
  I: Integer;
begin
  for I := index to high(self)-2 do
    self[I] := self[I+1];
end;

procedure TVectorHelper.Swap(ind1, ind2: integer);
var
  F:Float;
begin
  F := self[ind1];
  self[ind1] := self[ind2];
  self[ind2] := F;
end;

procedure TVectorHelper.Fill(St, En: integer; Val: Float);
var
  I: Integer;
begin
  for I := St to En do
    self[I] := Val;
end;

procedure TVectorHelper.Sort(Descending: boolean);
begin
  if length(self) > 0 then
    HeapSort(self, 0, high(self), Descending);
end;

procedure TVectorHelper.InsertFrom(Source:TVector; Lb, Ub: integer; ind:integer);
var
  I, C: Integer;
begin
  C := Ub - Lb + 1;
  SetLength(self, length(self)+C);
  for I := high(self) downto ind do
    self[I] := self[I-C]; // moving existing values freeing place for newly inserted
  for I := Lb to Ub do
    self[ind+I-Lb] := source[I];
end;

function TVectorHelper.ToString(Index: integer): string;
begin
  Result := FloatStr(self[Index]);
end;

function TVectorHelper.ToStrings(Dest: TStrings; First, Last: integer; Indices: boolean; Delimiter: char): integer;
var
  I:integer;
  Buf:string;
begin
  if (not Assigned(Dest)) then
  begin
    Result := -1;
    Exit;
  end;
  for I := First to Last do
  begin
    if Indices then
      Buf := IntStr(I)+Delimiter+' '
    else
      Buf := '';
    Buf := Buf + ToString(I);
    Dest.Add(Buf);
  end;
  Result := 0;
end;

end.

