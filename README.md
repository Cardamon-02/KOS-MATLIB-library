MATLIB.ks is an attempt to emulate certain matlab functions within
KOS. Matrix functionality especially is focused on here. You will be
able to generate an arbitrarily sized matrix and specify values in the
matrix. Matrix and vector operations are also implemented, such as matrix
multiplication, dot product, cross product and inverse.
This library is also written to rectify problems with the KLA library,
Such as the lack of documentation and error handling.

MATLIB currently has the added functionality of saving Matrices to .csv
via 'toMatrix', as well as a basic implementation of an RK4 solver.

Examples of MATLIB's functions are contained within 'matlibTest.ks"
