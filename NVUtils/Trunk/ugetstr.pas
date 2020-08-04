{$H-}{$J+}
Unit uGetStr;
interface
Uses SysUtils, StrUtils, Crt, CrtExt, NVStrings, llist, ustringlists;

Const
  keyBack  =  #8;
  keyCR    = #13;
  keySpace = #32;
  keyEsc   = #27;

  LeftKey  = #75;     HomeKey = #71;
  RightKey = #77;     EndKey  = #79;
  InsKey   = #82;     DelKey  = #83;
  UpKey    = #72;     DownKey = #80;
  MaxLen = 255;
var
  Ins : boolean;
  History : TStrList;
  MaxHistoryCount : integer = 500;

function GetString(AString:string) : string;

implementation
var
  BrowsingHistory : boolean; // true if history browsing with "Up" or "Down" started

// finds a string beginning from known substring. Used in a search by "Up" or "Down" commands
function FindByStart(Item:TListNode):boolean;
begin
  Result := RefStr = '';
  if not Result then
    Result := AnsiStartsText(RefStr,(Item as TStringNode).Str^);
end;

// finds completely equal string. Used after command issue to find duplicate
function StrEqual(Item:TListNode):boolean;
begin
  Result := UpperCase((Item as TStringNode).Str^) = UpperCase(RefStr);
end;

function Max(A,B:integer):integer;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function Min(A,B:integer):integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;


procedure FindDuplicate(S:string);
var
  Item:TStringNode;
begin
  RefStr := S;
  StrComparator := @StrEqual;
  with History do
  begin
    Item := TStringNode(LastThat(@StrEqual));
    if Item <> nil then
    begin
      Delete(Item);
      Insert(Item);
    end else
      InsertString(S);
  end;
end;

function FindHistoryEntry(var BrowsingHistory : boolean; Buff:string; code : char):string;
const
  Mask:string = '';
var
  Item : TStringNode;
begin
  if not BrowsingHistory then
  begin
    Mask := Buff;
    BrowsingHistory := true;
    case Code of
      UpKey  : History.Selected := History.Last;
      DownKey: History.Selected := History.First;
    end;
  end else
  case Code of
    UpKey  : History.Selected := History.Selected.Prev;
    DownKey: History.Selected := History.Selected.Next;
  end;
  StrComparator := @FindByStart;
  if Code = UpKey then
    Item := History.FindStrBackward(Mask)
  else
    Item := History.FindStrForward(Mask);
  if Item <> nil then
    Result := Item.Str^
  else
    Result := Buff;
end;

function GetString(AString:string):string;
Var
  Buff      : string[MaxLen];
  BuffOut   : string;
  CurrLen   : byte absolute Buff[0];
  OldLen    : byte;
  MinX : integer;
  MaxY : integer;
  RowLength  : integer;
  InitRowLength : integer; // available length of line on which write begins (LineLength - InitX)
  InitX, InitY  : integer; // screen position from which buffer starts to be written
  VertOffset    : integer; // For how many lines cursor moves down by write(Buff)
  X, Y          : integer;  // current cursor position on screen
  XEnd, YEnd    : integer;  // screen position of end of string with existing IntX, InitY
  CurrPos : integer; // current position within a string
  I       : Integer;
  T       : Char;
  Changed : boolean;

  procedure FindScreenPos(PosInStr:integer; out X,Y:integer);
  var
    L:integer;
  begin
    if (PosInStr <= InitRowLength) then
    begin
      Y := InitY;
      X := InitX + PosInStr - 1;
    end else
    begin
      L := PosInStr - InitRowLength - 1;
      Y := InitY + L div RowLength + 1;
      X := L mod RowLength + MinX;
    end
  end;

Begin
  MinX := GetMinX;
  RowLength := GetWinWidth;
  MaxY := GetMaxY;
  InitX := WhereX; {X-pos of first char of string}
  InitY := WhereY; // Y-pos of the first char
  InitRowLength := RowLength - InitX + 1;
  Buff := AString;
  if CurrLen < MaxLen then
    CurrPos := CurrLen+1
  else
    CurrPos := MaxLen;
  Changed := true;
  OldLen := CurrLen;
  Repeat
    if Changed then
    begin
      BuffOut := PadRight(Buff,max(OldLen,CurrLen));
      OldLen := CurrLen;
      FindScreenPos(CurrLen,XEnd,YEnd);
      VertOffset := YEnd - MaxY - 1;
      CursorOff;
      GoToXY(InitX,InitY);
      write(BuffOut);
      if VertOffset > 0 then
        InitY := InitY - VertOffset;
    end;
    Changed := false;
    FindScreenPos(CurrPos,X,Y);
    GoToXY(X,Y);
    CursorOn;
    T := ReadKey;
    if T = #0 then             {special keys <-, ->, Ins, Home, End, Del}
    begin
      T := ReadKey;
      if not (T in [UpKey, DownKey]) then
        BrowsingHistory := false;
      case T Of
        LeftKey  : if CurrPos > 1 then
                      Dec(CurrPos);
        RightKey : If (CurrPos <= CurrLen) and (CurrPos < MaxLen) then
                        Inc(CurrPos);
        InsKey   : Ins := Not Ins;
        HomeKey  : CurrPos := 1;
        EndKey   : CurrPos := min(CurrLen+1,MaxLen);
        DelKey   : If CurrPos <= CurrLen then
                   begin
                     For I := CurrPos to CurrLen-1 do
                       Buff[I] := Buff[I+1];
                     dec(CurrLen);
                     Changed := true;
                   end;
        UpKey,DownKey : begin
           Buff := FindHistoryEntry(BrowsingHistory,Buff,T);
           Changed := true;
        end;
      end    {Case T Of}
    end else
    begin
      BrowsingHistory := false;
      case T of
        keyBack:
          If CurrPos > 1 then                {delete currpos-1}
          begin
            for I := CurrPos-1 to CurrLen-1 do
              Buff[i] := Buff[i+1];
            Dec(CurrPos);
            Dec(CurrLen);
            Changed := true;
          end;    {If}
        keySpace..'~':
           begin
            if not ins then
            begin
              Buff[CurrPos] := T;
              inc(CurrPos);
            end else
            if CurrLen < MaxLen - 1 then
            begin
              For I := CurrLen + 1 DownTo CurrPos Do
                Buff[i+1] := Buff[i];
              Buff[CurrPos] := T;
              Inc(CurrLen);
              inc(CurrPos);
            end;
            Changed := true;
          end;    {If}
      end;   {Case T Of}
    end;
  until (T = keyCR) or (T = keyEsc);
  if (T = keyCR) and (CurrLen > 0) then
  begin
    FindDuplicate(Buff);
    Result := Buff;
  end
  else begin
    FillChar(Buff[1],CurrLen,' ');
    GoToXY(InitX,InitY);
    OutString(InitX,InitY,Buff);
    Result := '';
    Exit;
  end;
  WriteLn;
end;

initialization
begin
  Ins := true;
  History := TStrList.Create(MaxHistoryCount);
End;

finalization;
begin
  History.Free;
end;

end.
