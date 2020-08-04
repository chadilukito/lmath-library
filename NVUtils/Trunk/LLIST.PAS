{ This file is part of NVUtils suite.
  Copyright (C) 1995 Viatcheslav Nesterov

  This source is free software; you can redistribute it and/or modify it under the terms of the GNU General Public
  License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later
  version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web at
  <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing to the Free Software Foundation, Inc., 59
  Temple Place - Suite 330, Boston, MA 02111-1307, USA. }
unit llist;
interface
uses classes, SysUtils;

type

  TDoubleList = class;

  TListNode = class
    Prev: TListNode;
    Next : TListNode;
    Owner: TDoubleList;
  end;

  PNodeAction = ^TNodeAction;
  TNodeAction = procedure(Item:TListNode);

  PMatch = ^TMatch;
  TMatch = function(Item:TListNode):boolean;

  { TDoubleList }

  TDoubleList = class(TListNode)
    First: TListNode;
    Last : TListNode;
    Selected : TListNode;
    Counter : cardinal;
    procedure Insert(Item:TListNode); virtual;
    procedure Delete(Item:TListNode); virtual;
    procedure InsertBefore(Item,Target:TListNode); virtual;
    procedure FreeNode(Item:TListNode); virtual;
    procedure ForEach(Action:TNodeAction); virtual;
    function FirstThat(Match:TMatch):TListNode; virtual;
    function LastThat(Match:TMatch):TListNode; virtual;
    function NextThat(Match:TMatch):TListNode; virtual;
    function PrevThat(Match:TMatch):TListNode; virtual;
    procedure Move(Item,Target:TListNode); virtual;
    procedure FreeAll; virtual;
    destructor Destroy; override;
  end;


implementation

procedure TDoubleList.Insert(Item:TListNode);
begin
  if Item = nil then
    Exit;
  Item.Owner := Self;
  if First = nil then
  begin
    First := Item;
    Last := Item;
  end;
  Last.Next := Item;
  Item.Prev := Last;
  Item.Next := First;
  First.Prev := Item;
  Last := Item;
  inc(Counter);
end;

procedure TDoubleList.Delete(Item:TListNode);
begin
  if (Item = nil) or (Item.Owner <> Self) then
    Exit;
  Item.Owner := nil;
  if First = Item then First := Item.Next;
  if Last = Item then Last := Item.Prev;
  if Last = Item then
  begin
    First := nil;
    Last := nil;
  end else
  begin
    Item.Prev.Next := Item.Next;
    Item.Next.Prev := Item.Prev;
  end;
  Dec(Counter);
end;

procedure TDoubleList.InsertBefore(Item,Target:TListNode);
begin
  if (Target = nil) or (Target.Owner <> Self) or (Item = nil) then Exit;
  if Target = First then First := Item;
  Item.Prev := Target.Prev;
  Target.Prev.Next := Item;
  Target.Prev := Item;
  Item.Next := Target;
  Item.Owner := Self;
  Inc(Counter);
end;

procedure TDoubleList.FreeNode(Item:TListNode);
begin
  Delete(Item);
  FreeAndNil(Item);
end;

procedure TDoubleList.FreeAll;
var
  Item:TListNode;
begin
  while First <> nil do
  begin
    Item := Last;
    Last := Item.Prev;
    Item.Free;
    if Item = First then
    begin
      First := nil;
      Last := nil;
      Selected := nil;
    end;
  end;
  Counter := 0;
end;

procedure TDoubleList.ForEach(Action:TNodeAction);
var
  Item:TListNode;
begin
  if First = nil then Exit;
  Item := Last;
  repeat
    Item := Item.Next;
    Action(Item);
  until Item=Last;
end;

function TDoubleList.FirstThat(Match:TMatch):TListNode;
var
  Item:TListNode;
begin
  FirstThat := nil;
  if First = nil then exit;
  Item := Last;
  repeat
    Item := Item.Next;
    if Match(Item) then
    begin
      FirstThat := Item;
      Exit;
    end;
  until Item = Last;
end;

function TDoubleList.LastThat(Match:TMatch):TListNode;
var
  Item:TListNode;
begin
  LastThat := nil;
  if First = nil then exit;
  Item := First;
  repeat
    Item := Item.Prev;
    if Match(Item) then
    begin
      LastThat := Item;
      Exit;
    end;
  until Item = First;
end;

function TDoubleList.NextThat(Match: TMatch): TListNode;
var
  Item:TListNode;
begin
  Result := nil;
  if First = nil then exit;
  if Selected = nil then
    Selected := First;
  Item := selected;
  repeat
    if Match(Item) then
    begin
      NextThat := Item;
      Selected := Item;
      Exit;
    end;
    Item := Item.Next;
  until Item = Selected;
end;

function TDoubleList.PrevThat(Match: TMatch): TListNode;
var
  Item:TListNode;
begin
  Result := nil;
  if First = nil then exit;
  if Selected = nil then
    Selected := Last;
  Item := selected;
  repeat
    if Match(Item) then
    begin
      Result := Item;
      Selected := Item;
      Exit;
    end;
    Item := Item.Prev;
  until Item = Selected;
end;

procedure TDoubleList.Move(Item, Target:TListNode);
begin
  if (Item = nil) or (Item = nil) or
     (Item.Owner <> Self) or
     (Target.Owner <> Self) or
     (Item.Next = Target) or
     (Item = Target) then
  Exit;
  Delete(Item);
  InsertBefore(Item,Target);
end;

destructor TDoubleList.Destroy;
begin
  freeAll;
  inherited Destroy;
end;

end.
