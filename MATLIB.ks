@lazyglobal off.

// This library is an attempt to emulate certain matlab functions within
// KOS. Matrix functionality especially is focused on here. You will be
// able to generate an arbitrarily sized matrix and specify values in the
// matrix. Matrix and vector operations are also implemented, such as matrix
// multiplication, dot product, cross product and inverse.
// This library is also written to rectify problems with the KLA library,
// Such as the lack of documentation and error handling.
//
// MATLIB currently has the added functionality of saving Matrices to .csv
// via 'toMatrix', as well as a basic implementation of an RK4 solver.
//
// Examples of MATLIB's functions are contained within 'matlibTest.ks"

local function init {
	parameter m, n, val. 
	// m = rows, n = columns, v = value.
	local a is list(m, n). // create a list to stand in as a matrix.
	// the first two values in the matrix are actually its dimensions,
	// so make sure to skip these when doing operations.
	local end is m * n + 2. // get end index of the matrix.
	from { local i is 2. } until i = end step { set i to i + 1. } do {
		a:add(val).
	}
	return a.
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
	parameter m.
	local a is zeros(m).
	from { local i is 1. } until i > m step {set i to i + 1. } do {
		setVal(a,i,i,1).
	}
	return a.
}

function setVal {
	parameter a, row, col, val.
	// This function will set the value at a given position in a given matrix.
	// basic error handling is implemented.
	local m is a[0].
	local n is a[1].
	if (row <= m) AND (col <= n) {
		local pos is (row - 1) * n + col + 1. 
		set a[pos] to val.
	} else if (row >= m) AND (col >= n) {
		print "Both the row ("+row+") and column ("+col+") indexes are greater than the matrix size, "+m+" X "+n +".".
	} else if row >= m { 
		print "The row ("+row+") index is greater than the rows in the matrix, "+m+".".
	} else if row >= m { 
		print "The column ("+col+") index is greater than the columns in the matrix, "+n+".".
	}
}

function getVal {
	parameter a, row, col.
	// This function will set the value at a given position in a given matrix.
	// basic error handling is implemented.
	local m is a[0]. // get rows
	local n is a[1]. // get columns
	if (row <= m) AND (col <= n) {
		local pos is (row - 1) * n + col + 1.  
		return a[pos].
	} else if (row >= m) AND (col >= n) {
		print "Both the row ("+row+") and column ("+col+") indexes are greater than the matrix size, "+m+" X "+n +".".
	} else if row >= m { 
		print "The row ("+row+") index is greater than the rows in the matrix, "+m+".".
	} else if row >= m { 
		print "The column ("+col+") index is greater than the columns in the matrix, "+n+".".
	}
}

function MATLIBSum {
	parameter a, b.
	// this function will perform elementwise summation of two matrices and has basic error handling
	if (a:typename = "List") AND (b:typename = "List") {
		local m1 is a[0]. // get first matrix rows
		local n1 is a[1]. // get first matrix columns
		local m2 is b[0]. // get second matrix rows
		local n2 is b[1]. // get second matrix columns
		if (m1=m2) AND (n1=n2) {
			local c is list(m1,n1).
			from { local i is 2. } until i = a:length step { set i to i + 1. } do {
				c:add(a[i] + b[i]).
			}
			return c.
		} else {
			print "Inputs to MATLIBSum must be two matrices of identical size.".
			print "Inputs were not identical sizes.".
			return -1.
		}
	} else if a:typename = "List" AND b:typename = "Scalar" {
		local c is list(a[0],a[1]).
		from {local i is 2. } until i = a:length step { set i to i + 1. } do {
			c:add(a[i] + b).
		}
		return c.
	} else {
		print "Inputs to MATLIBSum must be two matrices of identical size".
		print "or a Matrix and a Scalar.".
		return -1.
	}
}

function MATLIBDot {
	parameter a, b.
	// elementwise multiply two matrices, or multiply a scalar by 
	// a matrix. if both inputs are scalar this returns the two 
	// multiplied. check if one, or both, are matrices.
	if (a:typename = "List") AND (b:typename = "List") {
		// if both inputs are matrices.
		//print 1 + " " + a:typename + " dot " + b:typename.
		local m1 is a[0]. // get first matrix rows
		local n1 is a[1]. // get first matrix columns
		local m2 is b[0]. // get second matrix rows
		local n2 is b[1]. // get second matrix columns
		if (m1=m2) AND (n1=n2) {
			// if dimensions match exactly
			local c is list(m1,n1).
			from { local i is 2. } until i = a:length step { set i to i + 1. } do {
				c:add(a[i] * b[i]).
			}
			return c.
		} else if (a:length = b:length) AND (m1 = n2 AND n1 = m2) AND (m1 = 1 OR m2 = 1){
			// if matrices share 'transposed' dimensions, and one of the dimensions is length 1.
			local c is list(m1,n1).
			from { local i is 2. } until i = a:length step { set i to i + 1. } do {
				c:add(a[i] * b[i]).
			}
			return c.
		} else { 
			print "Dimension miss match, matrices must be equal size.".
			return -1.
		}
	} else if (a:typename = "List") AND (b:typename = "Scalar") {
		//print 2 + " " + a:typename + " dot " + b:typename.
		local m is a[0].
		local n is a[1].
		local c is list(m,n).
		from { local i is 2. } until i = a:length step { set i to i + 1. } do {
			c:add(a[i] * b).
		}
		return c.
	} else if (a:typename = "Scalar") AND (b:typename = "List") {
		//print 3 + " " + a:typename + " dot " + b:typename.
		local m is b[0].
		local n is b[1].
		local c is list(m,n).
		from { local i is 2. } until i = b:length step { set i to i + 1. } do {
			c:add(a * b[i]).
		}
		return c.
	} else if (a:typename = "Scalar") AND (b:typename = "Scalar") {
		// print 4 + " " + a:typename + " dot " + b:typename.
		return a * b.
	} else {
		print "One or more inputs were not scalar or matrix.".
	}
}

function MATLIBMult {
	parameter a, b.
	// Both inputs must be matrices of appropriate size for matrix multiplication.
	// Matrix multiplication will always be [a] * [b].
	if (a:typename = b:typename) AND ("List" = b:typename) {
		if a[1] = b[0] {
			// initialize c.
			local m is a[0]. // get the # rows in c
			local n is b[1]. // get the # columns in c
			local c is zeros(m,n). // initialize c
			// go by rows in matrix one, dot them with columns in matrix two.
			from {local i is 1. } until i > m step {set i to i + 1. } do {
				// go along rows in a
				local row is getRow(a,i).
				from {local j is 1. } until j > n step {set j to j + 1. } do {
					// go along columns in b
					local col is getCol(b,j).
					local val is MATLIBDotProd(row,col).
					setVal(c,i,j,val).
				}
			}
			return c.
		} else {
			print "Dimension mismatch. Inner dimensions must agree.".
			print "Input was: "+a[0]+", "+a[1]+" by "+b[0]+", "+b[1].
			return -1.
		}
	} else { 
		print "Inputs were not matrices.".
		return -1.
	}
}

function getRow {
	parameter a, m.
	// get the whole row, m, from matrix a. basic error handling implemented
	if a:typename = "List" {
		if m <= a[0]{
			if a[1] = 1 {
				return getVal(a,m,1). // if a is a column vector, do this
			}
			local b is zeros(1,a[1]).
			from {local i is 1. } until i > a[1] step { set i to i + 1. } do {
				local val is getVal(a,m,i).
				setVal(b,1,i,val).
			}
			return b.
		} else {
			print "Input exceeds matrix dimensions.".
			return -1.
		}
	} else {
		print "input was not a matrix".
		return -1.
	}
}

function getCol {
	parameter a, n.
	// get the whole column, m, from matrix a. basic error handling implemented
	if a:typename = "List" {
		if n <= a[1]{
			if a[0] = 1 {
				return getVal(a,1,n). // if a is a row vector, do this
			}
			local b is zeros(a[0],1).
			from {local i is 1. } until i > a[0] step { set i to i + 1. } do {
				local val is getVal(a,i,n).
				setVal(b,i,1,val).
			}
			return b.
		} else {
			print "Input exceeds matrix dimensions.".
			return -1.
		}
	} else {
		print "input was not a matrix".
		return -1.
	}
}

function MATLIBDotProd {
	parameter a, b.
	// get the dot product of two vectors of arbitrary length
	local c is MATLIBDot(a,b).
	local val is 0.
	from { local i is 2. } until i > (c[0] * c[1]) + 1 step { set i to i + 1. } do {
		set val to val + c[i].
	}
	return val.
}

function MATLIBCross { 
	parameter a, b.
	local c is zeros(1,3).
	if a:typename = "List" AND b:typename = "List" AND (a:length = b:length AND a:length = 5) {
		// if input is two 1x3 vectors
		set c[2] to a[3]*b[4] - a[4]*b[3].
		set c[3] to a[4]*b[2] - a[2]*b[4].
		set c[4] to a[2]*b[3] - a[3]*b[2].
	} else {
			print "Input must be either a single matrix or two 1 x 3 vectors.".
			return -1.
	}
		return c.
}

function MATLIBPrint {
	parameter a.
	// if the input is a matrix it will output a printed matrix, otherwise
	// the scalar will be printed. if its not either, an error occurs.
	if a:typename = "List"{
		local m is a[0]. // get rows
		local n is a[1]. // get columns
		// Go along rows, then jump down a row.
		from { local i is 1. } until i > m step { set i to i + 1. } do {
			local s is "".
			from { local j is 1. }  until j > n step { set j to j + 1. } do {
				local pos is (i - 1) * n + j + 1.
				set s to s + ("" + round(a[pos], 4)):padLeft(6) + "    ".
			}
			print s.
		}
	} else if a:typename = "Scalar" {
		print a.
	} else {
		print "Input was neither a Matrix or Scalar.".
	}

}

function RK4 { 
	parameter f, t0, dt, tf, IC.
	// takes as input an anonymous function, initial time, time step,
	// final time, and initial conditions.

	// This should function as a constant timestep Runge-Kutta 4 solver.

	// S can be multi-dimensional, so that must be accounted for within the script.

	local t is t0.
	local L is floor((tf - t0)/dt) + 1. // length (rows) of the S matrix. adds 1 to account for t0
	if IC:typename = "List" AND (IC[0] = 1 OR IC[1] = 1) {
		local S is zeros(L,IC:length - 2).
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
	} else if IC:typename = "Scalar" {
		local S is zeros(L,MATLIBSum(),1).
	} else {
		print "IC must be either scalar or vector (1D)".
		return -1.
	}

}

function setRow {
	parameter a, b, m.
	// sets row m of matrix a to values of vector or scalar b.
	if a:typename = "List" AND b:typename = "List" {
		if a[1] = b[1] AND b[0] = 1 {

		} else {
			print "If input is a matrix and vector, they must be of the same length.".
			print "Two Matrices are also not valid inputs, one must be a rovector.".
			return -1.
		}
	} else if a:typename = "List" AND b:typename = "Scalar" {
		if a[1] = 1 {
			setVal(a,m,b).
		} else {
			print "Inputs must be either a matrix and a row vector, or a row vector and a scalar".
			return -1.
		}
	} else {
		print "Inputs must be either a matrix and a row vector, or a row vector and a scalar".
		return -1.
	}
	// if we got here, it must be a matrix and a vector of appropriate size.
	if m <= a[0] {
		from { local i is 1. } until i > a[1] step{ set i to i + 1. } do {
			setVal(a,m,i,b[i + 1]).
		}
	}
}

function toMatrix {
	parameter a, flnm.
	// writes matrix a to a file and checks to ensure the filetype is a .csv
	local flnm to "0:/MatricesOut/" + flnm. // changes the flnm to be a path
	if exists(flnm) = 1 {
		deletepath(flnm).
	}
	local m is a[0]. // get rows
	local n is a[1]. // get columns
	// Go along rows, then jump down a row.
	from { local i is 1. } until i > m step { set i to i + 1. } do {
		local s is "".
		from { local j is 1. }  until j > n step { set j to j + 1. } do {
			local pos is (i - 1) * n + j + 1.
			set s to s + ("" + a[pos] + ", ").
		}
		log s to flnm.
	}
}