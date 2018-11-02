
library( "macroutils2" )

# ====== Example 1: MACRO In FOCUS output file ====== 

#   Path to the file to be read
( filenm <- system.file( 
    "bintest/output_chat_winCer_GW-C_1kgHa_d298.bin", 
    package = "macroutils2", mustWork = TRUE ) )

#   Read the file - Generic method for reading column names 
#   (result not always 100 percent clean)
tmp1 <- macroReadBin( f = filenm ) 

#   Read the file - Trim the column names to a known length 
#   and do not perform any further column name cleaning.
#   Optimal length depend on the type of bin-file.
tmp2 <- macroReadBin( f = filenm, trimLength = 52L, 
    rmSuffixes = FALSE, rmNonAlphaNum = FALSE, 
    rmSpaces = FALSE, rmRunID = FALSE ) 

#   Read the file - No column names cleaning
tmp3 <- macroReadBin( f = filenm, rmSuffixes = FALSE, 
    rmNonAlphaNum = FALSE, rmSpaces = FALSE, 
    rmRunID = FALSE ) 

colnames( tmp1 ) 
colnames( tmp2 )
colnames( tmp3 ) 

dim( tmp1 ) 
dim( tmp2 )
dim( tmp3 ) 

#   Clean-up
rm( filenm, tmp1, tmp2, tmp3 )



# ====== Example 2: MACRO metabolite intermediate-file ====== 

#   Path to the file to be read
( filenm <- system.file( 
    "bintest/int-file_chat_winCer_GW-C_1kgHa_d298_y1926.bin", 
    package = "macroutils2", mustWork = TRUE ) ) 

#   Note: this file has been shortened to only 1 year of data    

#   Read the file
tmp1 <- macroReadBin( f = filenm ) 

#   Using different settings
tmp3 <- macroReadBin( f = filenm, rmNonAlphaNum = FALSE, 
    rmSpaces = FALSE, rmRunID = FALSE ) 

colnames( tmp1 ) # Some column names are not fully cleaned
colnames( tmp3 )

dim( tmp1 ) 
dim( tmp3 )

#   Clean-up
rm( filenm, tmp1, tmp3 )
