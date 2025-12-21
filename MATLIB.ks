@lazyglobal off.
//____________________________________________________________________________________________
//____________________________________MATRIX DEFINITION_______________________________________
//____________________________________________________________________________________________

local function init {
	parameter m,n is m,val is 0.
	// m = rows, n = columns, val = value.
	local a is list(). // create a list to stand in as a matrix.
	local end is m*n. // get final index of matrix a.
	from {local i is 0.} until i = end step {set i to i + 1.} do {
	a:add(val).
	}

	local function setval {
		parameter row,col,val.
		if (row <= m) AND (col <= n){
			// using COLUMN MAJOR order, one based indexing.
			local lin_ind is (col - 1)*n + row - 1.
			set a[lin_ind] to val.			
		} else if row > m {
			print "The row ("+row+") index is greater than the rows in the matrix, "+m+".".
		} else if col > n {
			print "The column ("+col+") index is greater than the columns in the matrix, "+n+".".
		} else {
			print "Both the row ("+row+") and column ("+col+") indexes are greater than the matrix size, "+m+" X "+n +".".
		}
		return.
	}

	local function getval {
		parameter row,col.
		if (row <= m) AND (col <= n){
			// using COLUMN MAJOR order, one based indexing.
			local lin_ind is (col - 1)*n + row - 1.
			return a[lin_ind].			
		} else if row > m {
			print "The row ("+row+") index is greater than the rows in the matrix, "+m+".".
		} else if col > n {
			print "The column ("+col+") index is greater than the columns in the matrix, "+n+".".
		} else {
			print "Both the row ("+row+") and column ("+col+") indexes are greater than the matrix size, "+m+" X "+n +".".
		}
		return.
	}

	return lexicon("rows",m,"cols",n,"data",a,"set",setval,"get",getval,"isQuat",false).
}

//____________________________________________________________________________________________
//____________________________________GENERAL FUNCTIONS_______________________________________
//____________________________________________________________________________________________

function MATLIBPrint {
	parameter a.
	// if the input is a matrix it will output a printed matrix, otherwise
	// the scalar will be printed. if its not either, an error occurs.
	if a:istype("Lexicon"){
		local m is a:rows. // get rows
		local n is a:cols. // get columns
		// Go along rows, then jump down a row.
		from { local i is 1. } until i > m step { set i to i + 1. } do {
			local s is "".
			from { local j is 1. }  until j > n step { set j to j + 1. } do {
				local pos is (i - 1) * n + j - 1.
				set s to s + ("" + round(a:data[pos], 4)):padLeft(6) + "    ".
			}
			print s.
		}
	} else if a:istype("Scalar") {
		print a.
	} else {
		print "Error in MATLIBPrint: Input was neither a Matrix or Scalar.".
	}
}

function writeMatrix {
	parameter a, flnm.
	if NOT a:istype("Lexicon") {
		print("Error in writeMatrix: input is not a matrix.").
	}
	// writes matrix a to a file and checks to ensure the filetype is a .csv
	local flnm to "0:/MatricesOut/" + flnm. // changes the flnm to be a path
	if exists(flnm) {
		deletepath(flnm).
	}
	local m is a:rows. // get rows
	local n is a:cols. // get columns
	// Go along rows, then jump down a row.
	from { local i is 1. } until i > m step { set i to i + 1. } do {
		local s is "".
		from { local j is 1. }  until j > n step { set j to j + 1. } do {
			local pos is (i - 1) * n + j - 1.
			set s to s + ("" + a:data[pos] + ", ").
		}
		log s to flnm.
	}
}

function zeros {
	parameter m, n is m. 
	return init(m,n,0).
}

function ones {
	parameter m, n is m. 
	return init(m,n,1).
}

function eye {
	parameter n.
	local A is init(n).
	from {local i is 1.} until i = n step {set i to i + 1.} do {
		A:set(i,i,1).
	}
}

function horzcat {
	parameter A, B. // take two matrices as input
	// horzcat copies A, places B's data on the right hand side of A prime (C), and returns C.
	// check to make sure A and B are matrices with the same number of rows.
	if NOT A:istype("Lexicon") OR NOT B:istype("Lexicon") {
		print "Error in horzcat: One or more inputs was not a matrix.".
		return -1.
	} else if A:rows <> B:rows {
		print "Error in horzcat: Input matrice dimension mismatch. Check # of rows or use vertcat.".
		return -1.
	}
	local C is A:copy.
	set C:cols to A:cols + B:cols.
	// we got here so the inputs will work. concatenate B on the right of A
	from {local i is 1.} until i > A:rows step {set i to i + 1.} do {
		from {local j is 1.} until j > B:cols step {set j to j + 1.} do {
			C:data:insert(B:data[(i-1)*B:cols + j - 1],(i*A:cols - 1) + (i - 1)*B:cols + j).
		}
	}
	return C.
}

function vertcat {
	parameter A, B. // take two matrices as input
	// vertcat copies A, places B's data below A prime (C), and returns C.
	// check to make sure A and B are matrices with the same number of rows.
	if NOT A:istype("Lexicon") OR NOT B:istype("Lexicon") {
		print "Error in vertcat: One or more inputs was not a matrix.".
		return -1.
	} else if A:cols <> B:cols {
		print "Error in vertcat: Input matrice dimension mismatch. Check # of cols or use horzcat.".
		return -1.
	}
	local C is A:copy.
	set C:rows to A:rows + B:rows.
	for entry in B:data { // add all the data from B onto the end of C.
		C:data:add(entry).
	}
	return C.
}

function getRow {
	parameter a,Row.
	// get the whole row from matrix a. basic error handling implemented.
	if NOT a:istype("Lexicon") {
		print "Error in getRow: Attempted to retrieve a row from a non-matrix datatype.".
		return -1.
	}
	if Row > a:rows {
		print "Error in getRow: Requested row is > the number of rows.".
		return -1.
	} else if Row < 1{
		print "Error in getRow: Requested row is < the first index (1).".
		return -1.
	} else {
		if a:cols = 1 { // if a is a column vector, return the data at the linear index.
			return a:data[Row - 1]. 
		} else {
			local b is zeros(1,a:cols). // create a list to stand in as our result matrix.
			from {local i is 1. } until i > n step {set i to i + 1. } do {
				set b:data[i] to a:getval(Row,i).
			}
			return b.
		}
	}
}

function setRow {
	parameter a, b, m.
	// sets row m of matrix a to values of vector or scalar b.
	if a:istype("Lexicon") AND b:istype("Lexicon") { // if both might be valid inputs
		if a:cols <> b:cols AND b:rows <> 1 { // if rows are not the same length or b is not a row vector
			print "Error in setRow: Input must be a matrix, a row vector with the same width, and a row index.".
			return -1. // Throw an error back
		}
	} else if a:istype("Lexicon") AND b:istype("Scalar") { // we received a matrix and a scalar
		if a:cols = 1 { // is the matrix a column vector?
			a:setval(m,1,b). // if yes, then set the value at that row and exit.
			return.
		} else {
			print "Error in setRow: Input must be a matrix, a row vector with the same width, and a row index.".
			return -1.
		}
	} else { // inputs were entirely invalid
		print "Error in setRow: Input must be a matrix, a row vector with the same width, and a row index.".
		return -1.
	}
	// if we got here, it must be a matrix and a vector of appropriate size.
	from { local i is 0. } until i = a:cols step{ set i to i + 1. } do {
		a:setval(m,i+1,b:data[i]).
	}
	return.
}

function getCol {
	parameter a,Col.
	// get the whole column from matrix a. basic error handling implemented.
	if NOT a:istype("Lexicon") {
		print "Error in getCol: Attempted to retrieve a col from a non-matrix datatype.".
		return -1.
	}
	if Col > a:cols {
		print "Error in getCol: Requested col is > the number of columns.".
		return -1.
	} else if Col < 1{
		print "Error in getCol: Requested col is < the first index (1).".
		return -1.
	} else {
		if a:rows = 1 { // if a is a row vector, return the data at the linear index.
			return a:data[Col - 1]. 
		} else {
			local b is zeros(a:rows,1). // create a list to stand in as our result matrix.
			from {local i is 1. } until i > n step {set i to i + 1. } do {
				set b:data[i] to a:getval(i,Col).
			}
			return b.
		}
	}
}

function MATLIBSum {
	parameter a, b.
	local m is a:rows.
	local n is a:cols.
	// this function will perform elementwise summation of two matrices and has basic error handling
	if a:istype("Lexicon") AND b:istype("Lexicon") {
		if m = b:rows AND n = b:cols {
			local c is init(m,n). // initialize a blank matrix
			from {local i is 1.} until i = m step {set i to i + 1.} do{
				from {local j is 1.} until j = n step {set j to j + 1.} do{
					c:set(i,j,a:get(i,j) + b:get(i,j)). // c(i,j) = a(i,j) + b(i,j)
				}
			}
			return c.
		} else {
			print "Inputs to MATLIBSum must be two matrices of identical size, or a matrix and scalar.".
			print "Inputs were not identical sizes.".
			return -1.
		}
	} else if a:istype("Lexicon") AND b:istype("Scalar") {
		local c is init(m,n). // initialize a blank matrix
		from {local i is 1.} until i = m step {set i to i + 1.} do{
			from {local j is 1.} until j = n step {set j to j + 1.} do{
				c:set(i,j,a:get(i,j) + b).
			}
		}
		return c.
	} else {
		print "Inputs to MATLIBSum must be two matrices of identical size, or a matrix and scalar.".
		return 1.
	}
}

function MATLIBDot {
	parameter a, b.
	// elementwise multiply two matrices, or multiply a scalar by 
	// a matrix. if both inputs are scalar this returns the two 
	// multiplied. check if one, or both, are matrices.
	if a:istype("Lexicon") AND b:istype("Lexicon") {
		// if both are potentially matrices.
		local m1 is a:rows.
		local n1 is a:cols.
		local m2 is b:rows.
		local n2 is b:cols.
		if (m1=m2) AND (n1=n2) {
			// if dimensions are an exact match
			local c is init(m1,n1). // initialize a blank matrix
			from {local i is 0.} until i = (m1*n1 - 1) step {set i to i + 1.} do{
				set c:data[i] to a:data[i] * b:data[i]. // write directly to data.
			}
			return c.
		} else {
			print "Error in MATLIBDot: Dimension miss-match, matrices must be equal size.".
			return -1.
		}
	} else if a:istype("Lexicon") AND b:istype("Scalar"){
		// elementwise multiply a by b
		local c is init(m1,n1). // make a blank the same size as a
		from {local i is 0.} until i = (m1*n1 - 1) step {set i to i + 1.} do{
			set c:data[i] to a:data[i] * b.
		}
		return c.
	} else if b:istype("Lexicon") AND a:istype("Scalar"){
		local c is init(m2,n2). // make a blank the same size as b
		from {local i is 0.} until i = (m2*n2 - 1) step {set i to i + 1.} do{
			set c:data[i] to b:data[i] * a.
		}
		return c.
	} else if a:istype("Scalar") AND b:istype("Scalar"){
		print "Warning from MATLIBDot: You are multiplying two Scalars together, use * multiplication".
		return a*b.
	} else {
		print "Error in MATLIBDot: One or more inputs were neither Scalar nor Matrix.".
		return -1.
	}
}

function MATLIBDotProd {
	parameter a, b.
	// get the dot product of two vectors of arbitrary length. Basic error handling is implemented,
	// non matrix inputs, mismatched dimensions and wrong size is caught.
	if NOT a:istype("Lexicon") OR NOT b:istype("Lexicon") {
		print "Error in MATLIBDotProd: One or more inputs was a non-matrix datatype.".
		return -1.
	} else if (a:cols * a:rows) <> (b:cols * b:rows) { // inputs are not the same size.
		print "Error in MATLIBDotProd: Input matrices are not the same size.".
		return -1.
	} else if ((a:cols <> 1) AND (a:rows <> 1)) OR ((a:cols <> 1) AND (a:rows <> 1)) { // one or more inputs are two dimensional.
		print "Error in MATLIBDotProd: One or more inputs was two dimensional.".
		return -1.
	}
	local c is MATLIBDot(a,b).
	if c:rows * c:cols = 1 {
		return c:data[0]. // if the result from MATLIBDot was a scalar return the scalar value
	} else {
		local val is c:data[0].
		from {local i is 1.} until i = (c:rows * c:cols - 1) step {set i to i + 1.} do{
			set val to val + c:data[i].
		}
		return val.
	}
}

function MATLIBMult {
	parameter a, b.
	// Both inputs must be of appropriate size for matrix multiplication.
	// Matrix multiplication will always be [A] * [B].
	if a:istype("Lexicon") AND b:istype("Lexicon") {
		if a:cols = b:rows { // Check for dimension match.
			local m is a:rows. // get the # of rows
			local n is b:cols. // get the # of columns
			local c is zeros(m,n). // initialize matrix
			// go by rows in matrix one, dot with columns in matrix two.
			from {local i is 1.} until i > m step {set i to i + 1.} do {
				// go along the rows in matrix a.
				local row is getRow(a,i).
				from {local j is 1.} until j > n step {set j to j + 1.} do {
					// now go along the columns in matrix b.
					local col is getCol(b,j).
					setval(c,i,j,MATLIBDotProd(row,col)).
				}
			} // end of the from loop
			if c:rows * c:cols = 1 {
				return c:data[0].
			} else {
				return c.
			}
		} else {
			print "Error in MATLIBMult: Dimension mismatch.".
			return -1.
		}
	} else {
		print "Error in MATLIBMult: Inputs were not matrices.".
		return -1.
	}
}

function MATLIBCross {
	parameter a, b.
	// perform a cross product of two vectors and return a column vector.
	local c is zeros(1,3).
	// check that both inputs are 1x3 or 3x1 matrices
	if a:istype("Lexicon") AND b:istype("Lexicon") AND (a:cols * a:rows) = 3 AND (b:rows * b:cols) = 3 {
		set c:setval(1,1) to a:data[1] * b:data[2] - a:data[2] * b:data[1].
		set c:setval(1,2) to a:data[2] * b:data[0] - a:data[0] * b:data[2].
		set c:setval(1,3) to a:data[0] * b:data[1] - a:data[1] * b:data[0].
		return c.
	} else {
		print "Error in MATLIBCross: Inputs must be two row or column matrices of length 3.".
		return -1.
	}
}

function trace {
	parameter a.
	// sums the diagonal of a matrix and returns the scalar it produces.
	// Error handling.
	if NOT a:istype("Lexicon") {
		print "Error in trace: Input was not a matrix.".
		return 0.
	} else if a:rows <> a:cols {
		print "Error in trace: Input was not a square matrix.".
		return 0.
	} else if a:rows <= 0 {
		print "Error in trace: Input matrix has nonsense dimensions.".
		return 0.
	}
	local n is a:rows.
	local trace to 0.
	from { local i is 1. } until i > n step {set i to i + 1. } do {
		set trace to trace + a:getVal(i,i).
	}
	return trace.
}

function norm {
	parameter a.
	// gets the magintude of a vector and returns it as a scalar.
	// Error handling.
	if NOT a:istype("Lexicon") {
		print "Error in norm: Input was not a vector.".
		return 0.
	} else if (a:rows <> 1) AND (a:cols <> 1) {
		print "Error in norm: Input was not a vector.".
		return 0.
	} else if (a:rows <= 0) OR (a:cols <= 0) {
		print "Error in norm: Input matrix has nonsense dimensions.".
	}
	local L to 0.
	if a:rows = 1 {
		set L to a:cols.
	} else {
		set L to a:rows.
	}
	from {local i is 1.} until i > L step {set i to i + 1.} do{
		set norm to norm + a:data[i - 1]^2.
	}
	return sqrt(norm).
}

function normalize {
	parameter a.
	// gets the magintude of a vector and returns it as a scalar.
	// Error handling.
	if NOT a:istype("Lexicon") {
		print "Error in normalize: Input was not a vector.".
		return 0.
	} else if (a:rows <> 1) AND (a:cols <> 1) {
		print "Error in normalize: Input was not a vector.".
		return 0.
	} else if (a:rows <= 0) OR (a:cols <= 0) {
		print "Error in normalize: Input matrix has nonsense dimensions.".
	}
	local L to 0.
	if a:rows = 1 {
		set L to a:cols.
	} else {
		set L to a:rows.
	}
	from {local i is 1.} until i > L step {set i to i + 1.} do{
		set norm to norm + a:data[i - 1]^2.
	}
	from {local i is 1.} until i > L step {set i to i + 1.} do{
		set a:data[i-1] to a:data[i - 1]/norm.
	}
	return.
}
//____________________________________________________________________________________________
//_______________________________________INTEGRATORS__________________________________________
//____________________________________________________________________________________________

function RK4 { 
	parameter f, t0, dt, tf, IC.
	// takes as input an anonymous function, initial time, time step, final time, and initial
	// conditions. The inputs are then used to solve the function, f, with a Runge-Kutta 4
	// constant time step solver.

	local t is t0.
	local L is floor((tf - t0)/dt) + 1. // length (rows) of the S matrix. adds 1 to account for t0
	if IC:istype("Lexicon") AND (IC:rows = 1 OR IC:cols = 1) {
		local S is zeros(L,IC:data:length).
		setRow(S,IC,1). // initializes the state matrix
		from { local i is 2. } until i > L step { set i to i + 1. } do {
			local k1 is MATLIBDot(f(t, getRow(S,i-1)),dt).
			local k2 is MATLIBDot(f(t + 0.5*dt, MATLIBSum(getRow(S,i-1), MATLIBDot(k1,0.5))),dt).
			local k3 is MATLIBDot(f(t + 0.5*dt, MATLIBSum(getRow(S,i-1), MATLIBDot(k2,0.5))),dt).
			local k4 is MATLIBDot(f(t + dt, MATLIBSum(getRow(S,i-1),k3)), dt).
			local k1k2 is MATLIBSum(k1,MATLIBDot(k2,2)).
			local k3k4 is MATLIBSum(k4,MATLIBDot(k3,2)).
			local K_Vals is MATLIBDot(MATLIBSum(k1k2,k3k4),1/6).
			local ds is MATLIBSum(getRow(S,i-1),K_Vals).
			setRow(S,ds,i).
			SET t to t + dt.
		}
		return S.
	} else {
		print "Error in RK4: IC must be a vector.".
		return -1.
	}
}
//____________________________________________________________________________________________
//_____________________________________QUATERNION MATH________________________________________
//____________________________________________________________________________________________

function q2Euler {
	parameter qbar.
	// converts from quaternion to euler parameters

	// Error Handling
	if NOT qbar:istype("Lexicon") {
		print "Error in q2YPR: Input was not a lexicon.".
		return -1.
	} else if NOT qbar:isQuat {
		if (qbar:cols <> 1) AND (qbar:rows <> 4) {
			print "Error in q2YPR: Input was not a 1x4 vector.".
			return -1.
		} else if round(norm(qbar),4) <> 1 {
			print "Error in q2YPR: Input was not a quaternion, magnitude <> 1.".
			print "Magnitude of qbar was: " + norm(qbar).
			return -1.
		} else {
			// we got here, it must be a quaternion, BUT the flag was not there.
			// Re-identify as quaternion.
			set qbar:isQuat to true.
		}
	}
	local acosq4 is arccos(qbar:data[3]). // grab q4 and get the acos of it
	local qhat is zeros(3,1).
	set qhat:data to list(qbar:data[0],qbar:data[1],qbar:data[2]). // grab qhat
	local ebar is MATLIBDot(qhat,1/sin(acosq4)).  // generate ebar
	local out is lexicon("ebar",ebar,"phi",constant:DegToRad*2*acosq4). // generate a lexicon to return ebar and phi.
	return out.
}

function q2YPR {
	parameter qbar.
	// Converts from quaternion to Yaw, Pitch, and Roll angles.

	// Error Handling
	if NOT qbar:istype("Lexicon") {
		print "Error in q2YPR: Input was not a lexicon.".
		return -1.
	} else if NOT qbar:isQuat {
		if (qbar:cols <> 1) AND (qbar:rows <> 4) {
			print "Error in q2YPR: Input was not a 1x4 vector.".
			return -1.
		} else if round(norm(qbar),4) <> 1 {
			print "Error in q2YPR: Input was not a quaternion, magnitude <> 1.".
			print "Magnitude of qbar was: " + norm(qbar).
			return -1.
		} else {
			// we got here, it must be a quaternion, BUT the flag was not there.
			// Re-identify as quaternion.
			set qbar:isQuat to true.
		}
	}
	// Isolate q1 - q4, since this will be scalar operations and return 3 angles.
	local q1 is qbar:data[0].
	local q2 is qbar:data[1].
	local q3 is qbar:data[2].
	local q4 is qbar:data[3].
	// generate DCM 1,2 and 1,1.
	local DCM12 is 2 * (q1*q2 + q3*q4).
	local DCM11 is (q1^2 + q4^2) - (q2^2 + q3^2).
	// get yaw
	local yaw is constant:DegToRad*arctan2(DCM12,DCM11).
	// get pitch
	local Pitch is constant:DegToRad*arcsin(-2*(q1*q3 - q2*q4)).
	// generate DCM 2,3 and 3,3.
	local DCM23 is 2 * (q2*q3 + q1*q4).
	local DCM33 is q3^2 + q4^2 - q1^2 - q2^2.
	// get roll
	local roll is constant:DegToRad*arctan2(DCM23,DCM33).
	// return YPR.
	return lexicon("Yaw",yaw,"Pitch",pitch,"Roll",roll).
}

function q2DCM {
	parameter qbar.
	// Converts from quaternion to a Direction Cosine Matrix, DCM.

	// Error Handling
	if NOT qbar:istype("Lexicon") {
		print "Error in q2DCM: Input was not a lexicon.".
		return -1.
	} else if NOT qbar:isQuat {
		if (qbar:cols <> 1) AND (qbar:rows <> 4) {
			print "Error in q2DCM: Input was not a 1x4 vector.".
			return -1.
		} else if round(norm(qbar),4) <> 1 {
			print "Error in q2DCM: Input was not a quaternion, magnitude <> 1.".
			print "Magnitude of qbar was: " + norm(qbar).
			return -1.
		} else {
			// we got here, it must be a quaternion, BUT the flag was not there.
			// Re-identify as quaternion.
			set qbar:isQuat to true.
		}
	}	
	// Isolate q1 -q4.
	local q1 is qbar:data[0].
	local q2 is qbar:data[1].
	local q3 is qbar:data[2].
	local q4 is qbar:data[3].
	// Prep the DCM.
	local qhat is zeros(3,1).
	set qhat:data to list(q1,q2,q3). // set qhat.
	local Mat1 is zeros(3,3).
	set Mat1:data to list(0,q3,-q2,-q3,0,q1,q2,-q1,0).
	// Transpose qhat
	local qhatTran is qhat:copy.
	set qhatTran:rows to 1.
	set qhatTran:cols to 3.
	// update Mat1
	set Mat1 to MATLIBDot(Mat1,q4*2).
	// multiply 2*qhat by qhat'
	local A is MATLIBDot(qhat,2).
	local Mat2 is MATLIBMult(A,qhatTran).
	// multiply qhat' by qhat.
	local A is q4^2 - MATLIBMult(qhatTran,qhat).
	// multiply A by eye(3)
	local Mat3 is MATLIBDot(A,eye(3)).
	return MATLIBSum(Mat1,MATLIBSum(Mat2,Mat3)).
}

function qMult {
	parameter qbar1, qbar2.
	// Calculates the product of two given quaternions. This operation represents
	// composing the two rotations. in other words the resulting quaternion is
	// rotation 1 followed by rotation 2.

	// Error Handling
	if NOT qbar1:istype("Lexicon") OR NOT qbar2:istype("Lexicon") { // check to see if they both may be quaternions
		print "Error in q2YPR: One or more inputs was not a lexicon.".
		return -1.
	} else if NOT qbar1:isQuat OR NOT qbar2:isQuat { // do both have the flag?
		if ((qbar1:cols <> 1) AND (qbar1:rows <> 4)) OR ((qbar2:cols <> 1) AND (qbar2:rows <> 4)) {
			// both did not have the flag, are they the right shape?
			print "Error in q2YPR: One or more inputs was not a 1x4 vector.".
			return -1.
		} else if round(norm(qbar1),4) <> 1 OR round(norm(qbar2),4) <> 1 {
			print "Error in q2YPR: One or more inputs was not a quaternion, magnitude <> 1.".
			print "Magnitude of qbar1 was: " + norm(qbar1).
			print "Magnitude of qbar2 was: " + norm(qbar2).
			return -1.
		} else {
			// we got here, both must be quaternions, BUT the flag was not there.
			// Re-identify as quaternion.
			set qbar1:isQuat to true.
			set qbar2:isQuat to true.
		}
	}	
	// Isolate q1 -q4.
	local q1 is qbar2:data[0].
	local q2 is qbar2:data[1].
	local q3 is qbar2:data[2].
	local q4 is qbar2:data[3].
	local qbarPrime is zeros(4,4).
	set qbarPrime:data to list(0,q3,-q2,q1,-q3,0,q1,q2,q2,-q1,0,q3,-q1,-q2,-q3,0).
	set qbarPrime to MATLIBSum(qbarPrime,MATLIBDot(eye(4),q4)).
	local answer is MATLIBMult(qbarPrime,qbar1).
	set answer:isQuat to True.
	return answer.
}

function r1r2Toq {
	parameter r1, r2.
	// Converts two vectors into a quaternion for the angle between them.

	// Error Handling
	if NOT r1:istype("Lexicon") OR NOT r2:istype("Lexicon") {
		print "Error in r1r2Toq: One or more inputs was not a lexicon.".
		return -1.
	} else if ((r1:cols <> 1) AND (r1:rows <> 3)) OR ((r2:cols <> 1) AND (r2:rows <> 3)) {
		print "Error in r1r2Toq: One or more inputs was not a 1x3 vector.".
		return -1.
	}

	local qbar is MATLIBCross(r1,r2).
	local q4 is MATLIBDotProd(r1,r2) + sqrt(MATLIBDotProd(r1,r1)) * sqrt(MATLIBDotProd(r2,r2)).
	qbar:data:add(q4).
	set qbar:rows to 4.
	set qbar:cols to 1.
	set qbar:isQuat to True.
	return MATLIBDot(qbar,1/norm(qbar)).
}
