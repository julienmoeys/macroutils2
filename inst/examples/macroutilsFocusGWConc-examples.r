
library( "macroutils2" ) 

#   Path to the file to be read
( filenm <- system.file( 
    "bintest/chat_winCer_GW-D_1kgHa_d298_annual_output.bin", 
    package = "macroutils2", mustWork = TRUE ) )

res <- macroutilsFocusGWConc( x = filenm ) 

res 

#   Clean-up
rm( filenm, res )  


