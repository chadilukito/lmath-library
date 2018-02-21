unit lmPointsVec;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, uTypes, lmSorting;

type
 { TPoints }

 ERealPointsException = class(Exception)
 end;

 TPoints = class
 protected
   function GetMaxX: Float; virtual;
   function GetMaxY: Float; virtual;
   function GetMinX: Float; virtual;
   function GetMinY: Float; virtual;
   function GetRange: Float; virtual;
   function GetRangeY: Float; virtual;
   function GetBuffer(I: integer): pointer;
   function GetX(ind:integer):Float;
   function GetY(ind:integer):Float;
   procedure SetX(ind:integer; value:Float);
   procedure SetY(ind:integer; value:Float);
   function GetPoint(ind:integer):TRealPoint;
   procedure SetPoint(ind:integer; Value:TRealPoint);
 public
   Points:TRealPointVector;
   Capacity:integer;
   Count:integer;
   Index:integer;
   constructor Create(ACapacity:integer);

   // Combine(XVector,YVector:TVector; Lb, Ub:integer)
   //combines TPoints from two TVector
   constructor Combine(XVector,YVector:TVector; Lb, Ub:integer);

   destructor Destroy; override;

   // Append(APoint:TRealPoint)
   //appends a point to the end (Count position). If Capacity riches, outomatically reallocates more space
    procedure Append(APoint:TRealPoint);

    //removes min(ACount, Count-Ind) points starting from Ind, moves rest to left. Returns count of actually removed points.
   function RemovePoints(Ind: integer; ACount:integer):integer;

   //Reallocate(Step:integer) increases Capacity by Step
   function Reallocate(Step:integer):integer;
   procedure FreePoints; virtual;

   //AllocatePoints(ACapacity:integer) allocate given capacity, regardless of what was before
   procedure AllocatePoints(ACapacity:integer);

   // sorts by X
   procedure SortX(descending:boolean);

   //SortY(descending:boolean) sorts by Y
   procedure SortY(descending:boolean);

   // ExtractX(var AXVector:TVector; Lb, Ub: integer) extracts all X from [Lb..Ub] as TVector
   procedure ExtractX(var AXVector:TVector; Lb, Ub: integer);

   // ExtractY(var AYVector:TVector; Lb, Ub: integer) extracts all Y from [Lb..Ub] as TVector
   procedure ExtractY(var AYVector:TVector; Lb, Ub: integer);

   property X[I:integer]:Float read GetX write SetX;
   property Y[I:integer]:Float read GetY write SetY;
   property ThePoints[I:integer]:TRealPoint read GetPoint write SetPoint; default;

   //DataBuffer[I:integer]:pointer
   //pointer to Points[I]. Useful for fast low-level fill-in
   property DataBuffer[I:integer]:pointer read GetBuffer;
   property MinX:Float read GetMinX;
   property MaxX:Float read GetMaxX;
   property MinY:Float read GetMinY;
   property MaxY:Float read GetMaxY;

   // Range:Float MaxX - MinX
   property Range:Float read GetRange;

   // RangeY:Float MaxY - MinY
   property RangeY:Float read GetRangeY;
 end;

implementation

procedure TPoints.Append(APoint: TRealPoint);
begin
  if Count = Capacity then Reallocate(Capacity div 2 + 1);
  Points[Count] := APoint;
  inc(Count);
end;

function TPoints.RemovePoints(Ind: integer; ACount: integer):integer;
var
  I:integer;
begin
  if ACount = 0 then
  begin
    Result := 0;
    Exit;
  end;
  {$ifdef Debug}
  if Ind >= Count then
   Raise ERealPointsException.Create('Remove points: Points index out of range!') at
      get_caller_addr(get_frame),get_caller_frame(get_frame);
  {$endif}
  if Ind + ACount >= Count - 1 then
  begin
    Result := Count - Ind;
    Count := Ind;
  end
  else begin
    for I := Ind to Count - ACount - 1 do
      Points[I] := Points[I+ACount];
    Dec(Count, ACount);
    Result := ACount;
  end;
end;

procedure TPoints.AllocatePoints(ACapacity: integer);
begin
  Count := 0;
  SetLength(Points,ACapacity);
  Capacity := ACapacity;
end;

procedure TPoints.SortX(descending:boolean);
begin
  HeapSortX(Points,0,Count-1,Descending);
end;

procedure TPoints.SortY(descending:boolean);
begin
  HeapSortX(Points,0,Count-1,Descending);
end;

procedure TPoints.ExtractX(var AXVector:TVector; Lb, Ub: integer);
var
  I, L:integer;
begin
  if Lb > Count - 1 then
    Exit;
  if Ub > Count - 1 then
    Ub := Count - 1;
  L := Ub - Lb;
  if High(AXVector) < L-1 then
    SetLength(AXVector, L+1);
  for I := Lb to Ub do
    AXVector[I-Lb] := Points[I].X;
end;

procedure TPoints.ExtractY(var AYVector:TVector; Lb, Ub: integer);
var
  I, L:integer;
begin
  if Lb > Count - 1 then
    Exit;
  if Ub > Count - 1 then
    Ub := Count - 1;
  L := Ub - Lb;
  if High(AYVector) < L-1 then
    SetLength(AYVector, L+1);
  for I := Lb to Ub do
    AYVector[I-Lb] := Points[I].Y;
end;

function TPoints.GetX(ind: integer): Float;
begin
  {$ifdef Debug}if (ind >= 0) and (ind < Count) then{$endif}
    Result := Points[ind].X
  {$ifdef Debug}
  else
    Raise ERealPointsException.Create('Get X: Points index > Points count') at
      get_caller_addr(get_frame),get_caller_frame(get_frame);
  {$endif}
end;

function TPoints.GetMaxX: Float;
var
  I:Integer;
begin
  Result := -MaxNum;
  for I := 0 to Count-1 do
    if Points[I].X > Result then
      Result := Points[I].X;
end;

function TPoints.GetMaxY: Float;
var
  I:Integer;
begin
  Result := -MaxNum;
  for I := 0 to Count-1 do
    if Points[I].Y > Result then
      Result := Points[I].Y;
end;

function TPoints.GetMinX: Float;
var
  I:Integer;
begin
  Result := MaxNum;
  for I := 0 to Count-1 do
    if Points[I].X < Result then
      Result := Points[I].X;
end;

function TPoints.GetMinY: Float;
var
  I:Integer;
begin
  Result := MaxNum;
  for I := 0 to Count-1 do
    if Points[I].Y < Result then
      Result := Points[I].Y;
end;

function TPoints.GetRange: Float;
begin
  Result := MaxX - MinX;
end;

function TPoints.GetRangeY: Float;
begin
  Result := MaxY - MinY;
end;

function TPoints.GetBuffer(I: integer): pointer;
begin
  Result := Addr(Points[I]);
end;

function TPoints.GetY(ind: integer): Float;
begin
  {$ifdef Debug}  if (ind >= 0) and (ind < Count) then {$endif}
    Result := Points[ind].Y
    {$ifdef Debug}  else
    Raise ERealPointsException.Create('Get Y: Points index > Points count') at
      get_caller_addr(get_frame),get_caller_frame(get_frame); {$endif}
end;

procedure TPoints.SetX(ind: integer; value: Float);
begin
  if ind < Capacity then
  begin
    Points[ind].X := value;
    if ind >= Count then
      Count := ind+1;
  end
  {$ifdef Debug}
  else
  Raise ERealPointsException.Create('Set X: Points index > capacity!') at
     get_caller_addr(get_frame),get_caller_frame(get_frame); {$endif}
end;

procedure TPoints.SetY(ind: integer; value: Float);
begin
  {$ifdef Debug}  if ind < Capacity then  {$endif}
  begin
    Points[ind].Y := value;
    if ind >= Count then
      Count := ind+1;
  end
  {$ifdef Debug}
  else
  Raise ERealPointsException.Create('Set Y: Points index > capacity!') at
     get_caller_addr(get_frame),get_caller_frame(get_frame); {$endif}
end;

function TPoints.GetPoint(ind: integer): TRealPoint;
begin
  {$ifdef Debug}  if ind < Count then {$endif}
    Result := Points[ind]
{$ifdef Debug}  else
    Raise ERealPointsException.Create('Get Point: Points index > Count') at
       get_caller_addr(get_frame),get_caller_frame(get_frame); {$endif}
end;

procedure TPoints.SetPoint(ind: integer; Value: TRealPoint);
begin
  {$ifdef Debug}  if ind < Capacity then  {$endif}
  begin
    Points[ind] := value;
    if ind >= Count then
      Count := ind+1;
  end {$ifdef Debug} else
  Raise ERealPointsException.Create('Set point: index > Capacity') at
     get_caller_addr(get_frame),get_caller_frame(get_frame);  {$endif}
end;

constructor TPoints.Create(ACapacity: integer);
begin
  inherited Create;
  setLength(Points,ACapacity);
  Capacity := ACapacity;
end;

constructor TPoints.Combine(XVector, YVector: TVector; Lb, Ub: integer);
var
  I:Integer;
begin
  TObject.Create;
  Capacity := Ub - Lb;
  setLength(Points,Capacity);
  Count := Capacity;
  for I := 0 to Count - 1 do
  begin
    if IsNAN(XVector[I+Lb]) or IsNAN(YVector[I+Lb]) then
      Continue;
    Points[I].X := XVector[I+Lb];
    Points[I].Y := YVector[I+Lb];
  end;
end;

destructor TPoints.Destroy;
begin
  inherited;
  Finalize(Points);
end;

procedure TPoints.FreePoints;
begin
  Finalize(Points);
  Capacity := 0;
  Count := 0;
  Index := 0;
end;

function TPoints.Reallocate(Step: integer):integer;
begin
  try
    SetLength(Points,Capacity+Step);
    Capacity := Capacity + Step;
    Result := Capacity;
  except
    on E:Exception do
      Result := 0;
   end;
end;

end.
