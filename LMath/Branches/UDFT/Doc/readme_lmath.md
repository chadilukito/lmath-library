#LMath and Cimponents 0.6.0
We introduce new package: DSP, for Digital Signal Processing.
For now:
##lmGenMath package
1. In uTypes.unit Euler constant added, e number (natural logarithms base.
2. In uComplex unit, in one of the previous releases function CReal was erroneously renamed to CFloat. Now it is corrected.
3. In uComplex unit, functions CToPolar and CToRect added, for conversions between polar and rectangular representations of complex numbers.

##lmMathUtils package
4. Unit uCompVecUtils added, similar to uVecUtils but for tCompVec. Following types are defined:
 
 _TComplexTestFunc = function(Val:complex):boolean;_
  General function for testing complex value for a condition.
  
 _TComplexFunc = function(Arg:Complex):complex;_
General complex function of complex argument. 
 
_TComplexComparator = function(Val, Ref:complex):boolean;_
General function for comparison of complex numbers. 
Functions _FirstElement_ and _SelElements_ ( see below) pass array elements to _Val_ and user-supplied Ref value to _Ref_.

Functions and procedures:

_function ExtractReal(CVec:TCompVector; Lb, Ub:integer):TVector;_
Extracts real parts of TCompVector elements and strores them in TVector.
 
_function ExtractImaginary(CVec:TCompVector; Lb, Ub:integer):TVector;_
Extracts imaginary parts of TCompVector elements and strores them in TVector.

_function CombineCompVec(VecRe, VecIm:TVector; Lb, Ub:integer):TCompVector;_
Opposite to previous two, combines vector of complex numbers from two vectors of Float.

_function CMakePolar(V:TCompVector; Lb, Ub:integer):TCompVector;_
Transforms elements of TCompVector from rectangular form to polar.

_function CMakeRectangular(V:TCompVector; Lb, Ub:integer):TCompVector;_
Opposite to the previous one. Transforms elements of TCompVector from polar form to rectangular.

_function MaxReLoc(CVec:TCompVector; Lb, Ub:integer):integer;_
Returns the position of an element with the largest real part.

_function MaxImLoc(CVec:TCompVector; Lb, Ub:integer):integer;_
Returns the position of an element with the largest imaginary part.

_function MinReLoc(CVec:TCompVector; Lb, Ub:integer):integer;_
Returns the position of an element with the minimal real part.

_function MinImLoc(CVec:TCompVector; Lb, Ub:integer):integer;_
Returns the position of an element with the minimal imaginary part.

_procedure Apply(V:TCompVector; Lb, Ub: integer; Func:TComplexFunc); overload;_
Passes every element of _V_ to _Func_ and assignes returned value to the element.

_function CompareCompVec(X, Xref : TCompVector; Lb, Ub  : Integer; Tol : Float) : Boolean; overload;_
Returns _true_ if all elements of _X_ are equal to corresponding elements of _XRef_ to the _Tol_ accuracy.
 
_function Any(Vector:TCompVector; Lb, Ub : integer; Test:TComplexTestFunc):boolean; overload;_
Returns _True_ if any element of _Vector_ satisfies the condition defined by _Test_.
 
_function FirstElement(Vector:TCompVector; Lb, Ub : integer; Ref:complex; Comparator:TComplexComparator):integer; overload;_
Returns the position of the first element which satisfies the condition defined by _Comparator_ and _Ref_.

_function ComplexSeq(Lb, Ub : integer; firstRe, firstIm, incrementRe, incrementIm:Float; Vector:TCompVector = nil):TCompVector;_
Constructs a _TCompVector_, where real and imaginary parts constiute arithmetic progressions beginning with _fistRe_ and _firstIm_ and increments _incrementRe_ and _incrementIm_ correspondingly. If _Vector_ is supplied, its length must be more than Ub_, otherwise new vector with the length _Ub+1_ is created. In both cases _Lb_ is assigned to (firstRe, firstIm), following elements elements up to _Ub_ are (FirstRe + incrementRe*N, FirstM*IncrementIm*N).
 
_function SelElements(Vector:TCompVector; Lb, Ub, ResLb : integer;
         Ref:complex; Comparator:TComplexComparator):TIntVector; overload;_
Returns TIntVector containing numbers of elements which satisfy a condition defined by _Comparator_ and _Ref_.

_function ExtractElements(Vector:TCompVector; Mask:TIntVector; Lb:integer):TCompVector; overload;_
Returns vector of complex containing elements of _Vector_ whose positions are contained in _Mask_. _Mask_ may be obtained for example with a preliminary call of _SelElements_.

##lmOptimum package.
5. uEval now initializes variables _Pi_ and _Euler_ with the values of corresponding constants, so they can be used in expressions. In principle, a user can modify them, but it is of course is not advisable.

##lmRegression package.
6. uDFT unit written for Fourier transform of arrays with arbitrary length, not necessary powers of two.
It defines following procedures:

_Procedure FFTC1D(var A: TCompVector; Lb, Ub: Integer);_
for direct Fourier transform of a complex array. Transform result is placed in the same array which is therefore destroyed.

_Procedure FFTC1DInv(var A: TCompVector; Lb, Ub: Integer);_
for inverse transform of a complex array. Similar, transform result is placed in the same array.

_Procedure FFTR1D(const A: TVector; Lb, Ub: Integer; out F: TCompVector);_
This procedure takes as input a real array _A_ and puts result of direct Fourier transform into a complex array _F_ of the same length.

_Procedure FFTR1DInv(const F: TCompVector; Lb, Ub: Integer; var A: TVector);_
This procedure is opposite of the previous one: it taked as an input a complex array _F_, makes inverse Fourier transform and puts its result into a real array _A_.

7. Bug with an erroneous signe in uFFT unit was corrected. 

#LMath and Components 0.5.1
This is mostly bug fix release.

##Bug fixes
1. All packages are distributed now with very conservative optimization options to ensure compatibility with any system.
2. Fixed bug in COBYLA implementation (package lmOptimum) which delayed convergence and in some cases lead to algorithm failure.
3. Fixed bug in uGauss (package uSpecRegress) which sometimes lead to inaccurate model fit.
4. Fixed errors in TVectorHelper.Remove and TVectorHelper.InsertFrom functions (uVectorHeplers, lmMathUtil).
5. Note that lmLineAlgebra package renamed to lmLinearAlgebra.

##New functionality
6. For convenience, package LMath added, which depends on all packages. Hence, it is sufficient to add it into the dependencies of your project instead of every needed package of the library. Drawback is slightly longer compilation time.
7. Unit uVecFileUtils added to lmMathUtil package. It implements procedures and functions for loading of TVector or TMatrix from a delimited text file, or for saving them into delimited files.
 
#LMath and Components 0.5
This is major release which contains many changes. Main of them are listed here. What was changed in LMath compared in DMath in more detail is described in New_in_LMath.pdf document. Besides, all procedures introduced in this version are labelled as LMath 0.5 in LMath0_5.pdf.

1. Naming of packages and units made more systematic. Now names of all units begin from u (for example, uTypes), while names of all packages begin from lm (for example, lmMathUtil).
2. Units _uVectorHelper, uVecUtils, uVecFunc_ and _uVecPrn_ in _lmMathUtil_ package define several handy functions for work with arrays.
3. Unit _uMatrix_ in _lmLineAlgebra_ defines several general operations over vectors and matrices.
4. COBYLA algorithm for tasks of constrained optimization included in _lmOptimum_ package, unit _uCobyla_.
5. Procedure for constrained non-linear regression _ConstrNLFit_ in the unit _uConstrLNFit_ which uses COBYLA algorithm included in _lmRegression_ package.
6. Procedure _LinProgSolve_ in the unit _uLinSimplex_, package _lmOptimum_ implements simplex method for solution of linear programming problems.
7. Unit _uintPoints_ in _lmGenMath_ package defines operators over TIntPoint, similar to _uRealPoints_.
8. Unit _uUnitsFormat_ in _lmMathUtils_ package allows now using of long prefixes (for example, "pico") along with short ("p") ones.
 
#LMath and Components 0.4
In this version:

1. Fixed bug which prevented use of ueval on Unix systems.
2. Unit lmSearchTrees added which defines object type implementing simple binary tree with a search based on string-type Name.

##LMath 0.3 Difference with ver. 0.2
1. Expression evaluator (unit uEval in Optimum package) supports names of identifiers with arbitrary length, unlimited number of variables and functions; operator \*\* added for exponentiation.
2. LMath and LMComponents are distributed in the single archive; documentation is included into this archive too.
 
##LMath 0.2 Difference with ver. 0.1

1. Fixed bug in SameValue which caused float overflow when -MaxNum and MaxNum were compared.
2. procedure MoveInterval(V:float; var Interval:TInterval); and
   procedure MoveIntervalTo(V:float; var Interval:TInterval); added to Intervals unit. First of them adds V to both 
   Hi and Lo of the interval, efficiently moving it by value V without length change; second one sets Lo equal to V
   and adjusts Hi correspondingly, such that length remains constant, moving interval to V.