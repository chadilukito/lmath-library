unit CRTExt;
{$mode objfpc}{$H-}
interface

uses Windows, CRT;

function GetConsoleBackColor:byte;
function GetConsoleTextColor:byte;
function GetMinX:integer;
function GetMaxX:integer;
function GetMinY:integer;
function GetMaxY:integer;
function GetWinHeight:integer;
function GetWinWidth:integer;
procedure InvertColors;
procedure NormalColors;
procedure OutString(X,Y:integer;S:string); //writes string to specified position

implementation
var
  ConsoleInfo: TConsoleScreenBufferinfo;
  {< CONSOLE_SCREEN_BUFFER_INFO = packed record
       dwSize : COORD;
       dwCursorPosition : COORD;
       wAttributes : WORD;
       srWindow : SMALL_RECT;
       dwMaximumWindowSize : COORD;
    end; }

   Fore, Back:byte;

function GetMinX:integer;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) then
  with ConsoleInfo do
    Result := srWindow.Left + 1
  else
    Result := 1;
end;

function GetMaxX:integer;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) then
  with ConsoleInfo do
    Result := srWindow.Right + 1
  else
    Result := 80;
end;

function GetMinY:integer;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) then
  with ConsoleInfo do
    Result := srWindow.Top + 1
  else
    Result := 1;
end;

function GetMaxY:integer;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) then
  with ConsoleInfo do
    Result := srWindow.Bottom + 1
  else
    Result := 25;
end;


function GetWinHeight : integer;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) then
  with ConsoleInfo do
    Result := srWindow.Bottom - srWindow.Top + 1
  else
    Result := 25;
end;

function GetWinWidth : integer;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) then
  with ConsoleInfo do
    Result := srWindow.Right - srWindow.Left + 1
  else
    Result := 80;
end;

procedure OutString(X,Y:integer;S:string);
var
  OX,OY:integer;
begin
  OX := WhereX;
  OY := WhereY;
  CursorOff;
  GoToXY(X,Y);
  write(S);
  GoToXY(OX,OY);
  CursorOn;
end;

function GetConsoleTextColor:byte;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) then
    Result := Lo(ConsoleInfo.wAttributes)
  else
    Result := LightGray;
end;

function GetConsoleBackColor:byte;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) then
    Result := Hi(ConsoleInfo.wAttributes)
  else
    Result := Black;
end;

procedure InvertColors;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) then
  begin
    Fore := Lo(ConsoleInfo.wAttributes);
    Back := Hi(ConsoleInfo.wAttributes);
    TextColor(Back);
    TextBackGround(Fore);
  end;
end;

procedure NormalColors;
begin
  TextColor(Fore);
  TextBackground(Back);
end;

end.

