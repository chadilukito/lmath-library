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