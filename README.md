```
   __       __   ______   ________  __        ______  _______          ______       ______  
  /  \     /  | /      \ /        |/  |      /      |/       \        /      \     /      \ 
  $$  \   /$$ |/$$$$$$  |$$$$$$$$/ $$ |      $$$$$$/ $$$$$$$  |      /$$$$$$  |   /$$$$$$  |
  $$$  \ /$$$ |$$ |__$$ |   $$ |   $$ |        $$ |  $$ |__$$ |      $$$  \$$ |   $$ ___$$ |
  $$$$  /$$$$ |$$    $$ |   $$ |   $$ |        $$ |  $$    $$<       $$$$  $$ |     /   $$< 
  $$ $$ $$/$$ |$$$$$$$$ |   $$ |   $$ |        $$ |  $$$$$$$  |      $$ $$ $$ |    _$$$$$  |
  $$ |$$$/ $$ |$$ |  $$ |   $$ |   $$ |_____  _$$ |_ $$ |__$$ |      $$ \$$$$ |__ /  \__$$ |
  $$ | $/  $$ |$$ |  $$ |   $$ |   $$       |/ $$   |$$    $$/       $$   $$$  |$$    $$/ 
  $$/      $$/ $$/   $$/    $$/    $$$$$$$$/ $$$$$$/ $$$$$$$/         $$$$$$/ $$/  $$$$$$/  
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
____________________________________________________________________________________________

 This library is an attempt to emulate certain matlab functions within KOS. Matrix
 functionality especially is focused on here. You will be able to generate an arbitrarily
 sized matrix and specify values in the matrix. Matrix and vector operations are also
 implemented, such as matrix multiplication, dot product, cross product and inverse. This
 library is also written to rectify problems with the KLA library, Such as the lack of
 documentation and error handling. MATLIB currently has the added functionality of saving
 Matrices to .csv via 'writeMatrix', as well as a basic implementation of an RK4 solver.
 Examples of MATLIB's functions are contained within 'matlibTest.ks"

____________________________________________________________________________________________
________________________________________CHANGELOG___________________________________________
____________________________________________________________________________________________
 8/4/2025 - Author:_cardamon_
 Description: added a function for exporting matrices as a .csv. function will check to see
				if a file already exists in the provided location, if the file exists it will
				delete it and replace it with a new .csv.

 8/5/2025 - Author:_cardamon_
 Description: Added several Quaternion based functions, for converting from quaternions to
				DCMs, Euler Parameters, Yaw, Pitch & Roll, and for conversion from two
				direction vectors to a quaternion. Also added a function to multiply two
				quaternions with eachother. All new functions have error handling to ensure
				inputs are appropriate, i.e. input is a list, input is the right dimensions
				(one coulmn, four rows), input has appropriate magnitude (1 for quaternions).
 VERSION CHANGE: MATLIB 0.2

 8/6/2025 - Author:_cardamon_
 Description: Incorporated input from reddit user u/nuggreat to use ISTYPE() instead of
				:TYPENAME = in most cases. Also changed  the way toMatrix() checked for an
				existing file. no longer  uses IF exists(flnm) = 1 {}, instead uses IF
				exists(flnm) {}, since = 1 was redundant.

 8/8/2025 - Author:_cardamon_
 Description: Added several new matrix math functions, namely trace(), check for norm(),
				normalize(). Revised the quaternion functions to norm(qbar) <> 1, instead of
				MATLIBDotProd(qbar,qbar) <> 1.
 NOTE: Was suggested to use a Pseudo-Class for matrices instead of purely a list. 
 		 Suggestion has not been taken yet, however a script (MatrixDef.ks) containing
		 the provided example has been made.

 12/8/2025 - Author:_cardamon_
 Description: Added a new lexicon/Pseudo-Class based definition of matrices to replace the 
				old definition of matrices. Updated most functions to work with this new 
				definition. RK4 has not been re-implemented with the new Matrix definition.
				Quaternions have not been fully re-implemented, but the pseudo-class has an
				entry for flagging if a matrix is also a quaternion.
 VERSION CHANGE: MATLIB 0.3

 12/9/2025 - Author:_cardamon_
 Description: Restored functionality of trace, norm, normalize, setRow, and RK4 to MATLIB.
				Restored functionality of all Quaternion functions from MATLIB 0.2. Next steps
				are to add functions for 'raw' control, such as functions for finding a crafts
				Mass Moment of Inertia and available torque. This control may not be necessary
				for nearly any users, but is my ultimate goal for my own projects.

 12/10/2025 - Author:_cardamon_
 Description: Added horzcat and vercat to MATLIB, offering a method to concatenate matrices
				by row or column. Both functions have basic error handling to check for
				appropriate dimensions and datatype (Lexicon).
