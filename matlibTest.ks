runpath("MATLIB.ks").
set m to 3.
set n to 5.
set Mat to ones(m,n).
set Mat2 to Mat.
local Row123 is list(1,3,1,2,3).
local Row456 is list(1,3,4,5,6).

clearscreen.
print "MATLIBPrint". // show functionality of printing matrices
MATLIBPrint(Mat).
print "Set matrix value". // show functionality of changing specific matrix values
setVal(Mat, 2, 4, 13).
MATLIBPrint(Mat).
set Mat3 to MATLIBSum(Mat,Mat2). // show functionality of summing matrices
print "Summation".
MATLIBPrint(Mat3).
print "Matrix typename". // show the typename for a matrix
print Mat3:typename.
print "Mat dot Mat". // show functionality of elementwise multiplication
MATLIBPrint(MATLIBDot(Mat,Mat3)).
print "Mat dot Scalar". // show functionality of scalar multiplication
MATLIBPrint(MATLIBDot(Mat,2)).
print "Scalar dot Matrix". // show that scalar can be in either position
MATLIBPrint(MATLIBDot(2,Mat3)).
print "Errors". // show basic error handling functionality
MATLIBDot("a",2).
MATLIBDot(2,"a").
print "Type n to continue.".
wait until Terminal:Input:getchar() = "n".
clearscreen.

print "Scalar dot Scalar". // show that scalars can be multiplied with this function
MATLIBPrint(MATLIBDot(2,2)).
print "Identity matrix". // show identity matrix creation
MATLIBPrint(eye(4)).
print "get row". // show that a row can be retrieved from a matrix
set Row to getRow(Mat3,2).
MATLIBPrint(Row).
print "get column". // show that a column can be retrieved from a matrix
set Col to getCol(Mat3,4).
MATLIBPrint(Col).
Set Row to getRow(eye(3),2).
print "Row dot Column". // show dot product functionality
MATLIBPrint(MATLIBDotProd(Row,Col)).
print "Matrix Multiplication". // show matrix multiplication functionality (use identity matrix)
MATLIBPrint(MATLIBMult(eye(3),Mat)).
print "Cross Product". // show cross product functionality.
MATLIBPrint(MATLIBCross(Row123,Row456)).
print "Type n to continue.".
wait until Terminal:Input:getchar() = "n".
clearscreen.
print "set row". // show that a row can be assigned in one function call.
local eye3 is eye(3).
setRow(eye3,row123,2).
MATLIBPrint(eye3).
print "Runge-Kutta 4 algorithm". // show functionality of the RK4 implementation
local IC is list(1,2,100,0). // y0 = 100 m, y_dot0 = 0.
local t0 is 0.
local dt is 0.1.
local tf is 1.
local S is RK4(rk4test@,t0,dt,tf,IC).
MATLIBPrint(S).
toMatrix(S,"RK4Test.csv").
print "Type n to continue.".
wait until Terminal:Input:getchar() = "n".
clearscreen.

print "Runge-Kutta 4 algorithm, Ballistic Drag example". // show functionality of the RK4 implementation
local IC is list(1,4,0,5,20,10). // x0 = 0 m, y0 = 50 m, x_dot0 = 20 m/s, y_dot0 = 10 m/s.
local t0 is 0.
local dt is 0.05.
local tf is 1.
local S is RK4(rk4test2@,t0,dt,tf,IC).
MATLIBPrint(S).

toMatrix(S,"RK4Test2.csv").





function rk4test{
	parameter t, s.
	local dsdt is zeros(1,2).
	setVal(dsdt,1,1,getval(s,1,2)).
	setVal(dsdt,1,2,-9.8).
	return dsdt. // DO NOT FORGET THIS. RK4 WILL NOT WORK WITHOUT.
}

function rk4test2{
	parameter t, s.
	local g is 9.8.
	local dsdt is zeros(1,4).
	local Vel is sqrt(getval(s,1,3)^2 + getval(s,1,4)^2).
	local Drag is 0.6*(Vel^2).
	setVal(dsdt,1,1,getval(s,1,3)).
	setVal(dsdt,1,2,getval(s,1,4)).
	setVal(dsdt,1,3,-Drag*getval(s,1,3)/Vel).
	setVal(dsdt,1,4,-(Drag*getval(s,1,4)/Vel) -g).
	return dsdt. // DO NOT FORGET THIS. RK4 WILL NOT WORK WITHOUT.
}