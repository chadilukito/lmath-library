{
    This file was modified from BufStream from the Free Component Library.
    Here error which prevented backward seek in the original BufStream was
    correceted; otherwise it is identical to original one.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{$mode objfpc}
{$H+}
unit nvbufstream;

interface

uses
  Classes, SysUtils;

Const
  DefaultBufferCapacity : Integer = 16; // Default buffer capacity in Kb.

Type


  { TNVBufStream }
  TNVBufStream = Class(TOwnerStream)
  Private
    FTotalPos : Int64;
    Fbuffer: Pointer;
    FBufPos: Integer;
    FBufSize: Integer;
    FCapacity: Integer;
    procedure SetCapacity(const AValue: Integer);
  Protected
    function GetPosition: Int64; override;
    function GetSize: Int64; override;
    procedure BufferError(const Msg : String);
    Procedure FillBuffer; Virtual;
    Procedure FlushBuffer; Virtual;
  Public
    Constructor Create(ASource : TStream; ACapacity: Integer);
    Constructor Create(ASource : TStream);
    Destructor Destroy; override;
    Property Buffer : Pointer Read Fbuffer;
    Property Capacity : Integer Read FCapacity Write SetCapacity;
    Property BufferPos : Integer Read FBufPos; // 0 based.
    Property BufferSize : Integer Read FBufSize; // Number of bytes in buffer.
  end;

  { TNVReadBufStream }

  TNVReadBufStream = Class(TNVBufStream)
  Public
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function Read(var ABuffer; ACount : LongInt) : Integer; override;
  end;

  { TNVWriteBufStream }

  TNVWriteBufStream = Class(TNVBufStream)
  Public
    Destructor Destroy; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function Write(Const ABuffer; ACount : LongInt) : Integer; override;
  end;

implementation

Resourcestring
  SErrCapacityTooSmall = 'Capacity is less than actual buffer size.';
  SErrCouldNotFLushBuffer = 'Could not flush buffer';
  SErrInvalidSeek = 'Invalid buffer seek operation';

{ TNVBufStream }

procedure TNVBufStream.SetCapacity(const AValue: Integer);
begin
  if (FCapacity<>AValue) then
    begin
    If (AValue<FBufSize) then
      BufferError(SErrCapacityTooSmall);
    ReallocMem(FBuffer,AValue);
    FCapacity:=AValue;
    end;
end;

function TNVBufStream.GetPosition: Int64;
begin
  Result:=FTotalPos;
end;

function TNVBufStream.GetSize: Int64;
begin
  Result:=Source.Size;
end;

procedure TNVBufStream.BufferError(const Msg: String);
begin
  Raise EStreamError.Create(Msg);
end;

procedure TNVBufStream.FillBuffer;

Var
  RCount : Integer;
  P : PChar;

begin
  P:=Pchar(FBuffer);
  // Reset at beginning if empty.
  If FBufSize <= FBufPos then
  begin
    FBufSize:=0;
    FBufPos:=0;
  end;
  Inc(P,FBufSize);
  RCount:=1;
  while (RCount<>0) and (FBufSize<FCapacity) do
  begin
    RCount:=FSource.Read(P^,FCapacity-FBufSize);
    Inc(P,RCount);
    Inc(FBufSize,RCount);
  end;
end;

procedure TNVBufStream.FlushBuffer;

Var
  WCount : Integer;
  P : PChar;

begin
  P:=Pchar(FBuffer);
  Inc(P,FBufPos);
  WCount:=1;
  While (WCount<>0) and ((FBufSize-FBufPos)>0) do
    begin
    WCount:=FSource.Write(P^,FBufSize-FBufPos);
    Inc(P,WCount);
    Inc(FBufPos,WCount);
    end;
  If ((FBufSize-FBufPos)<=0) then
    begin
    FBufPos:=0;
    FBufSize:=0;
    end
  else
    BufferError(SErrCouldNotFLushBuffer);
end;

constructor TNVBufStream.Create(ASource: TStream; ACapacity: Integer);
begin
  Inherited Create(ASource);
  SetCapacity(ACapacity);
end;

constructor TNVBufStream.Create(ASource: TStream);
begin
  Create(ASource,DefaultBufferCapacity*1024);
end;

destructor TNVBufStream.Destroy;
begin
  FBufSize:=0;
  SetCapacity(0);
  inherited Destroy;
end;

{ TNVReadBufStream }

function TNVReadBufStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
var
  NewTotalPos, Delta, NewBufPos: Int64;
begin
  case Origin of
    soCurrent:
      NewTotalPos := FTotalPos + Offset;
    soBeginning: begin
      if Offset < 0 then
        InvalidSeek;
      NewTotalPos := Offset;
    end;
    soEnd: begin
      if Offset > 0 then
        InvalidSeek;
      NewTotalPos := Size + Offset;
    end;
  end;
  if NewTotalPos > Size then
    NewTotalPos := Size;
  if NewTotalPos < 0 then
    NewTotalPos := 0;
  Delta := NewTotalPos - FTotalPos;
  NewBufPos := Delta + FBufPos;
  if (NewBufPos > 0) and (NewBufPos < FBufSize) then
  begin
    FBufPos := NewBufPos;  //if Seek function moves inside the data which are in the Buffer, we only reposition FBufPos
    FTotalPos := NewTotalPos;
  end
  else // otherwise find desired place in the source stream and invalidate buffer
  begin
    FTotalPos := FSource.Seek(NewTotalPos,soBeginning);
    FBufPos := 0;
    FBufSize := 0;
  end;
  Result := FTotalPos;
end;

function TNVReadBufStream.Read(var ABuffer; ACount: LongInt): Integer;

Var
  P,PB : PChar;
  Avail, MSize : Int64;

begin
  Result:=0;
  P:=PChar(@ABuffer);
  Avail:=1;
  While (Result < ACount) and (Avail > 0) do
  begin
    If FBufSize <= FBufPos then
      FillBuffer;
    Avail:=FBufSize-FBufPos;
    If Avail > 0 then
    begin
      MSize:=ACount-Result;
      If (MSize > Avail) then
        MSize := Avail;
      PB := PChar(FBuffer);
      Inc(PB,FBufPos);
      Move(PB^,P^,MSize);  // filled from buffer
      Inc(FBufPos,MSize);
      Inc(P,MSize);
      Inc(Result, MSize);
    end;
  end;
  Inc(FTotalPos,Result);
end;


{ TNVWriteBufStream }

destructor TNVWriteBufStream.Destroy;
begin
  FlushBuffer;
  inherited Destroy;
end;

function TNVWriteBufStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;

begin
  if (Offset=0) and (Origin=soCurrent) then
    Result := FTotalPos
  else begin
    Result := 0;
    BufferError(SErrInvalidSeek);
  end;
end;

function TNVWriteBufStream.Write(const ABuffer; ACount: LongInt): Integer;

Var
  P,PB : PChar;
  Avail,MSize : Integer;

begin
  Result:=0;
  P:=PChar(@ABuffer);
  While (Result<ACount) do
    begin
    If (FBufSize=FCapacity) then
      FlushBuffer;
    Avail:=FCapacity-FBufSize;
    MSize:=ACount-Result;
    If (MSize>Avail) then
      MSize:=Avail;
    PB:=PChar(FBuffer);
    Inc(PB,FBufSize);
    Move(P^,PB^,MSIze);
    Inc(FBufSize,MSize);
    Inc(P,MSize);
    Inc(Result,MSize);
    end;
  Inc(FTotalPos,Result);
end;


end.
