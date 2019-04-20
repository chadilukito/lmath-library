unit lmVectorHelper;
{$mode objfpc}
{$MODESWITCH TYPEHELPERS}
interface

uses
  Classes, SysUtils, uTypes, lmSorting, uStrings;

type

{ TVectorHelper }

TVectorHelper = type helper for TVector
  procedure Insert(value:Float; index:integer);
  procedure Remove(index:integer);
  procedure Swap(ind1,ind2:integer);
  procedure Fill(St, En : integer; Val:Float);
  procedure Sort(Descending:boolean);
  procedure InsertFrom(Source:TVector; ind:integer);
  function ToString(Index:integer):string;
  //Sends string representation of the subarray to Dest. If Indices, sends
  //indices as well, ';' used as delimiter
  function ToStrings(Dest:TStrings; First, Last:integer;
            Indices:boolean; Delimiter: char):integer;

end;
implementation

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
  for I := St to En - 1 do
    self[I] := Val;
end;

procedure TVectorHelper.Sort(Descending: boolean);
begin
  if length(self) > 0 then
    HeapSort(self, 0, high(self), Descending);
end;

procedure TVectorHelper.InsertFrom(Source: TVector; ind: integer);
var
  I, C: Integer;
begin
  C := length(Self)+Length(Source);
  SetLength(self, C);
  for I := high(self) downto ind do
    self[I+length(source)] := self[I]; // moving existing values freeing place for newly inserted
  for I := 0 to high(source) do
    self[ind+I] := source[I];
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
      Buf := IntToStr(I)+Delimiter+' '
    else
      Buf := '';
    Buf := Buf + ToString(I);
    Dest.Add(Buf);
  end;
  Result := 0;
end;

end.

