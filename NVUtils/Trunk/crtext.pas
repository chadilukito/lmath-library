unit CRTExt;
{$mode objfpc}{$H+}
interface

uses Windows, CRT;

function GetConsoleBackColor:byte;
function GetConsoleTextColor:byte;
function GetWinHeight:integer;
function GetWinWidth:integer;
procedure InvertColors;
procedure NormalColors;

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

function GetWinHeight : integer;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) then
  with ConsoleInfo do
  begin
    Result := srWindow.Bottom - srWindow.Top + 1;
  end else
    Result := 25;
end;

function GetWinWidth : integer;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) then
  with ConsoleInfo do
  begin
    Result := srWindow.Right - srWindow.Left + 1;
  end else
    Result := 80;
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

