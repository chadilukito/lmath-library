#News in LMath 0.5
Naming of packages and units made more systematic. Now names of all packages begin from u (for example, uTypes), while names of all packages begin from lm (for example, lmMathUtil).

##lmOptimum package
Units **uCobyla** and **utrstpl** were added. They implement minimization algorithm called COnstrained optimization BY Linear Approximation (COBYLA). This algorithm was developed by Prof. M. Powell and translated from FORTRAN 77 to Pascal by me, V.V. Nesterov.
Source code in Fortran can be found here: <https://zhangzk.net/software.html>
This algorithm allows optimization without knowing derivatives and, most importantly, with arbitrary number of inequality constrains. Test program `TestCobyla` is located at Demo\Console\TestCobyla.pas

##lmRegression package
Unit **uConstrNLFit** added, which implements constrained derivative-less non-linear regression with the use of _COBYLA_ algorithm.  

##lmLineAlgebra package
**Unit uCompVec** removed, function _CompVec_ moved to _uVecUtils_ in package _uMathUtils_.

### Unit uMatrix
**Unit uMatrix** written which defines several elementary operators and prodedures om vectors and matrices.
`
operator + (V:TVector; R:Float) Res : TVector; add float to every element
operator - (V:TVector; R:Float) Res : TVector; substract float from every element
operator / (V:TVector; R:Float) Res : TVector; divide every element by float
operator * (V:TVector; R:Float) Res : TVector; multiply every element by float
`
Similar operators for Matrix and float are defined.
`
operator + (V1:TVector; V2:TVector) Res : TVector; // element-wise addition, lengths must be equal
operator - (V1:TVector; V2:TVector) Res : TVector; // element-wise substraction, lengths must be equal.
`

Functions described below are used by operators, but may be called directly. One important difference between operator and direct call of a function is that operators _always allocate new array_ for result, while the functions use _Ziel_ array if it is not _nil_ by call. Otherwise, new array is allocated. Hence, if there is an existing array as a target, direct call of the function is more efficient than the use of an operator. 

```
function VecFloatAdd(V: TVector; R: Float; Lb, Ub: integer; Ziel: TVector = nil) : TVector;
function VecFloatSubstr(V: TVector; R: Float; Lb, Ub: integer; Ziel: TVector = nil) : TVector;
function VecFloatDiv(V: TVector; R: Float; Lb, Ub: integer; Ziel: TVector = nil) : TVector;
function VecFloatMul(V: TVector; R: Float; Lb, Ub: integer; Ziel: TVector = nil) : TVector;

function MatFloatAdd(M: TMatrix; R: Float; Lb, Ub1, Ub2: integer; Ziel: TMatrix = nil) : TMatrix;
function MatFloatSubstr(M: TMatrix; R: Float; Lb, Ub1, Ub2: integer; Ziel: TMatrix = nil) : TMatrix;
function MatFloatDiv(M: TMatrix; R: Float; Lb, Ub1, Ub2: integer; Ziel: TMatrix = nil) : TMatrix;
function MatFloatMul(M: TMatrix; R: Float; Lb, Ub1, Ub2: integer; Ziel: TMatrix = nil) : TMatrix;
```

Following functions define element-wize operations with two vectors of equal length:
```
function VecAdd(V1, V2: TVector; Ziel: TVector = nil) : TVector;
function VecSubstr(V1, V2: TVector; Ziel: TVector = nil) : TVector;
function VecElemMul(V1, V2: TVector; Ziel: TVector = nil) : TVector;
function VecDiv(V1, V2: TVector; Ziel: TVector = nil) : TVector;
```
Dot product of the vectors V1 and V2:
`function VecDotProd(V1,V2:TVector; Lb, Ub : integer) : float;`

Outer product of the vectors V1 and V2:
`function VecOuterProd(V1, V2: TVector; Lb, Ub1, Ub2: integer; Ziel: TMatrix = nil):TMatrix;`
Cross product of two vectors:
`function VecCrossProd(V1, V2: TVector; Lb: integer; Ziel: TVector = nil):TVector;`

Euclidian length of a vector (dot product with itself):
`function VecEucLength(V: TVector; LB, Ub: integer) : float;`

Product of vector V and matrix M. Length of matrix rows must be equal to length of V:
`function MatVecMul(M: TMatrix; V: TVector; LB: integer; Ziel: TVector = nil) : TVector;`

Product of matrix A with matrix B. Length of row in B must be equal to
length of column in A:
`function MatMul(A, B, Ziel: TMatrix; LB: integer) : TMatrix;`

Transposition of matrix. If Ziel is not nil, length of its columns must be
equal to length of rows in M and vice versa.
`function matTranspose(M, Ziel: TMatrix; LB: integer) : TMatrix;`

Transpose square matrix and place result in itself:
`procedure MatTransposeInPlace(M:TMatrix; Lb, Ub: integer);`

##lmGenMath package
###Unit uTypes
Several new types defined.

```
TIntegerPoint = record
  X,Y:Integer
end;
```

`TCompOperator = (LT, LE, EQ, GE, GT, NE);`
Used in comparators for some element-wise functions with TVector and TMatrix.

`TComparator = function(V1, V2 : float) : boolean;`
Used in element-wise comparisons.

`TCobylaObjectProc = procedure (N, M : integer; const X : TVector; out F : Float; CON : TVector);`
Objective function for the COBYLA optimization algorithm.

### Unit uMinMax. 
`function IsNegative(X: float):boolean;`
Returns true if X is negative ( < -DefaultZeroEpsilon )

`function IsPositive(X: float):boolean; overload;`
Returns true if X is positive ( > -DefaultZeroEpsilon )

They are overloaded for Integer. Main intention is the use together with functions _Any_ and _FirstElement_ from _uVecUtils_ unit.

##lmMathUtil package
### unit uSearchTrees
This unit defines object type TStringTreeNode as a named element of a binary
search tree and implements a procedure of a search within it. Old-type object is
used instead of class to save space. I don't want to use a huge _classes_ unit in
LMath. This type is used internally in the _uEval_ unit.

```
TStringTreeNode = object
  Name : string; {Name of the object. Function Finds searches for it}
  Left : PStringTreeNode; {Link to left (lesser) element}
  Right: PStringTreeNode; {Link to right (greater) element}
  constructor Init(AName:string);
  destructor Done;
  function Find(AName:string; out Comparison:integer):PStringTreeNode;
end;
```
`Constructor Init` creates the object and initializes `Name`with `AName` and `Left` and `Right` with nil.
Destructor disposes the object and all its children.
`Find` searches self and children for a member with `Name = AName`. Returns either
found item (`Comparison = 0 in this case`) or, if the tree does not contain
an item which meets condition, then returns an item where a new item with
AName must be inserted. If `AName < Name` and, consequently, the new Item
must be inserted as `Find.Left`, then `Comparison < 0`, if `AName > Name`,
then `Comparison > 0`. 

###unit uVecUtils
**unit uVecUtils** written with some Vector and Matrix utilities.
It includes:
types:
```
  TTestFunc    = function(X:Float):boolean;
  TIntTestFunc = function(X:Integer):boolean;

TMatCoords = record
  Row, Col :integer;
end;
```
Record, representing coordinates of a matrix element.

#### Functions and procedures:
**Apply**
```
procedure Apply(V:TVector; Lb, Ub: integer; Func: TFunc);
procedure Apply(M:TMatrix; LRow, URow, LCol, UCol: integer; Func: TFunc);
procedure Apply(V:TIntVector; Lb, Ub: integer; Func: TIntFunc);
procedure Apply(M:TIntMatrix; LRow, URow, LCol, UCol: integer; Func: TIntFunc);
```
These procedures apply TFunc or TIntFunc to every element of V or M between `LB` and `Ub`.

**Any**
`function Any(Vector:TVector, Lb, Ub : integer; Test:TTestFunc):boolean; overload;`
This function applies Test function to any enement in [Lb..Ub] and returns true
if for any of them Test returns true. Function is overloaded for TMatrix, TIntVector and TIntMatrix.

**FirstElement**
`function FirstElement(Vector:TVector, Lb, Ub : integer; Test:TTestFunc):integer; overload;`
This function applies Test function similar to _Any_, but returns index of a first element which satisfyes _Test_. **Importantly, if no such element found, Ub+1 is returned.**

Function is overloaded for TMatrix:  
_function FirstElement(M:TMatrix, Lb1, Ub1, Lb2, Ub2 : integer; Test:TTestFunc):TIntegerPoint; overload;_
Here _TIntegerPoint_ is returned, with first Index in X and second in Y.
Overloaded functions for _TIntVector_ and _TIntMatrix_ are similar. 

`function CompVec(X, Xref: TVector; Lb, Ub: Integer; Tol: Float) : Boolean;`
Checks if every component of vector X is within a fraction Tol of the corresponding
component of the reference vector Xref. In this case, the function
returns True, otherwise it returns False.

```

```

**unit uVectorHelper** written which implements helper for TVector type.
Following methods implemented:
_procedure Insert(value:Float; index:integer);_ which inserts _value_ intp _index_ position, shifting elements beginning from _index_ to the right. Last element is lost. 

_procedure Remove(index:integer);_ removes element at _Index_ and shifts all righter elements to the left.

_procedure Swap(ind1,ind2:integer);_ swaps elements.

_procedure Fill(St, En : integer; Val:Float);_ fills arraySTarting from _St_ and ENding with _En_ element with value _Val_.

_procedure Sort(Descending:boolean);_ sorts the array. _Descending_: must it be sorted in descending order?

_procedure procedure InsertFrom(Source:TVector; Lb, Ub:integer; ind:integer);_ inserts elements of _source_ from _Lb_ to _Ub_ vector to _ind_ position. All elements to the right of _ind_ are shifted to the right. SetLength is used to accomodate new elements.

_function ToString(Index:integer):string;_ converts element at _index_ to string representation using _function FloatStr_ and format settings from _uStrings_ unit.

_function ToStrings(Dest:TStrings; First, Last:integer; Indices:boolean; 
  Delimiter: char):integer;_ sends string representation of elements between First and Last into Dest. If _indices_ is true, each index is also sent using _Delimiter_ between index and value.

**unit uStrings**
In _procedure SetFormat_ parameter _DecSep_ added with "." or "," values.
Default is ".". _Byte_ is replaced with _integer_ everywhere so this unit may now be used with long strings.

#lmMathStat package
**Unit uDistrib**
_function DimStatClassVector(out C : TStatClassVector; A, B, H : float):integer;_
modified (was procedure DimStatClassVector(var C : TStatClassVector; Ub:integer).
At present: A and B are lower and upper borders of histogram respectively;
H is bin width. Number of bins M is calculated and TStatClassVector[0..M+1]
is allocated. Return value: M. 
Calling program must first call DimStatClassVector to allocate
the histogram, than supply it to Distrib. Array is used beginning from 1.

**unit uMeanSD**
_function Sum(X: TVector; Lb, Ub: integer): Float;_ added.