unit ustringlists;

{$mode objfpc}{$H-}

interface

uses
  Classes, SysUtils, NVStrings, llist;

type

{ TStringNode }

TStringNode = class(TListNode)
  Str:PString;
  constructor Create(AStr:String);
  destructor Destroy; override;
end;

{ TStrList }

TStrList = class(TDoubleList)
private
  FMaxCount : cardinal; //< If MaxCount reached, Insert to "last" is accompanied with deletion of "first".
protected
  procedure SetMaxCount(AMaxCount:cardinal); virtual;
public
  constructor Create(AMaxCount:integer);
  function FindStrForward(Mask:string):TStringNode;
  function FindStrBackward(Mask:string):TStringNode;
  procedure InsertString(S:string); virtual;
  property MaxCount : cardinal read FMaxCount write SetMaxCount;
end;

var
  RefStr : string;
  StrComparator : TMatch;

implementation

function StrMatch(Item:TListNode):boolean;
begin
  Result := StringMatchesMask(TStringNode(Item).Str^,RefStr);
end;

{ TStringNode }

constructor TStringNode.Create(AStr: String);
begin
  inherited Create;
  Str := NewStr(AStr);
end;

destructor TStringNode.Destroy;
begin
  DisposeStr(Str);
  inherited Destroy;
end;

{ TStrList }

procedure TStrList.SetMaxCount(AMaxCount: cardinal);
begin
  FMaxCount := AMaxCount;
end;

constructor TStrList.Create(AMaxCount: integer);
begin
  inherited Create;
  StrComparator := @StrMatch;
  FMaxCount := AMaxCount;
end;

function TStrList.FindStrForward(Mask: string): TStringNode;
begin
  RefStr := Mask;
  Result := TStringNode(NextThat(StrComparator));
end;

function TStrList.FindStrBackward(Mask: string): TStringNode;
begin
  RefStr := Mask;
  Result := TStringNode(PrevThat(StrComparator));
end;

procedure TStrList.InsertString(S: string);
begin
  Insert(TStringNode.Create(S));
  if Counter > FMaxCount then
  begin
    FreeNode(First);
    dec(Counter);
  end;
end;

end.

