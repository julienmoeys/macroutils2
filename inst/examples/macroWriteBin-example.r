
library( "macroutils2" )


# ====== Write a binary file in SOIL or MACRO style ======

# 1.1. Read a table, that will then be written back


#   Path to the file to be read
( filenm <- system.file( 
    "bintest/chat_winCer_GW-D_1kgHa_d298_annual_output.bin", 
    package = "macroutils2", mustWork = TRUE ) )

#   Read the file
tmp1 <- macroReadBin( f = filenm, rmRunID = FALSE ) 


# 1.2. Generate a dummy temporary file where the table will be 
#   written

( filenm <- tempfile(  ) )


# 1.3. Write this table in SOIL or MACRO bin style 

#   NB: This table is NOT a standard SOIL or MACRO input file!

macroWriteBin( f = filenm, x = tmp1 ) 

#   NB: When writing the bin file, time zones are ignored!



# 1.4. Read that file again and check that it is the same:

tmp1.b <- macroReadBin( f = filenm, rmRunID = FALSE ) 

# Maximum difference (small numerical differences)
unlist( lapply(
    X      = colnames(tmp1), 
    FUN    = function(X){ 
        max( tmp1[,X] - tmp1.b[,X] ) 
    }   
) ) 



# Remove the temporary file
file.remove( filenm ) 
