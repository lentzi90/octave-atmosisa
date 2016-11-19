# octave-atmosisa
An attempt to implement the International Standard Atmosphere in Octave.

In the Aeropsace toolbox for MATLAB, there is a function called `atmosisa`.
This should work as a drop in replacement for that function, and hopefully implement the ISA correctly.

To the best of my knowledge MATLABs `atmosisa` only works for altitudes between 0 and 20000 m.
This Octave version should, however, work for the complete range from -610 to 84000 m.
