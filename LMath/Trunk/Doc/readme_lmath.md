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