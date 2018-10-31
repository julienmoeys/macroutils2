
library( "macroutils2" ) 

#   Path to the file to be read
( filenm <- system.file( 
    "bintest/output_chat_winCer_GW-C_1kgHa_d298.bin", 
    package = "macroutils2", mustWork = TRUE ) )

res <- rmacroliteFocusGWConc( x = filenm ) 

res 

attr( res, "more" ) 

#   Clean-up
rm( filenm, res )  


