{ ******************************************************************
  Median
  ****************************************************************** }

unit umedian;

interface

uses
  utypes, uMinMax;

{Returns median for vector X. This is fast algorithm, but input array is rearranged! }
function Median(X : TVector; Lb, Ub : Integer) : Float;

implementation

function Median(X: TVector; Lb, Ub: integer): float;
var
   I,J,M:integer;
   A,Buf:float;
begin
   M := Lb + (Ub - Lb) div 2;
   while Lb < Ub - 1 do
   begin
     A := X[M];
     I := Lb; J := Ub;
     repeat
       while X[I] < A do inc(I);
       while X[J] > A do dec(J);
       if I <= J then
       begin
         Swap(X[I],X[J]);
         inc(I); dec(J);
       end;
     until I > J;
     if J < M then Lb := I;
     if I > M then Ub := J;
   end;
   Result := X[M];
end;


end.

