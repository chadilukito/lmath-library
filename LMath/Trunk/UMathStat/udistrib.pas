{ ******************************************************************
  Statistical distribution (histogram)
  Calling program must first call DimStatClassVector to allocate
  the histogram, than supply it to Distrib. Array is used beginning from 1.
  ****************************************************************** }

unit udistrib;

interface

uses
  utypes;

{ Allocates an array of statistical classes (histogram bins).
A is lower border of histogram; B is upper border; H is bin width.
Function calculates number of bins and allocates them. Number of bins is returned.
If allocation is impossible, nil is returned.}
function DimStatClassVector(out C : TStatClassVector; A, B, H : float):integer;

{ Distributes the values of array X[Lb..Ub] into M classes with
  equal width H, according to the following scheme:

              C[1]    C[2]                    C[M]
           ]-------]-------].......]-------]-------]
           A      A+H     A+2H                     B

  such that B = A + M * H }
procedure Distrib(X       : TVector;
                  Lb, Ub  : Integer;
                  A       : Float; // A:lower border of histogram. Upper one is found from length of C.
                  H       : Float; // H is bin width. Number of bins is calculated
                  C       : TStatClassVector);

implementation

function DimStatClassVector(out C : TStatClassVector; A, B, H : float):integer;
var
  M : Integer;
begin
  M := Round((B - A) / H) + 1; // number of bins
  { Check bounds }
  if (M < 0) or (M > MaxSize) then
    C := nil
  else
    SetLength(C, M + 1);
  Result := M;
end;

function NumCls(X, A, H : Float) : Integer;
{ Returns the index of the class containing X
  A is the lower bound of the first class
  H is the class width }
var
  Y : Float;
  I : Integer;
begin
  Y := (X - A) / H;
  I := Trunc(Y);
  if Y <> I then Inc(I);
  NumCls := I;
end;

procedure Distrib(X       : TVector;
                  Lb, Ub  : Integer;
                  A,    H : Float;
                  C       : TStatClassVector);
var
  I, K, M, Nt : Integer;
begin
  M := High(C); // number of bins
  for K := 1 to M do
    C[K].N := 0;
  for I := Lb to Ub do
    begin
      K := NumCls(X[I], A, H);
      Inc(C[K].N);
    end;
  Nt := Ub - Lb + 1;
  for K := 1 to M do
    with C[K] do
      begin
        Inf := A + (K - 1) * H;
        Sup := Inf + H;
        F := N / Nt;
        D := F / H;
      end;
end;

end.
