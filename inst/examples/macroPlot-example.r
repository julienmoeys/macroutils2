
library( "macroutils2" )



# ====== Example 1: SOIL model input file ======

#   Path to the file to be read
( filenm <- system.file( c( 
    "bintest/output_chat_winCer_GW-C_1kgHa_d298.bin", 
    "bintest/output_chat_winCer_Met-GW-C_1kgHa_d298.bin" ), 
    package  = "macroutils2", 
    mustWork = TRUE 
) )

#   Read these 2 files
out1  <- macroReadBin( f = filenm[ 1 ] ) 

out2 <- macroReadBin( f = filenm[ 2 ] ) 

#   Inspect the data:
head( out1 ); dim( out1 ) 
head( out2 ); dim( out2 ) 



# ====== Plot the data ======

#   With sub-plots
macroPlot( x = out1[, 1:4 ], gui = FALSE ) 

#   In one plot (not so meaningful in this case!)
macroPlot( x = out1[, 1:4 ], gui = FALSE, subPlots = FALSE ) 

#   Plot Multiple tables at once 
#   Format a list of tables (as when interactively imported)
out1out2        <- list( out1[, 1:4 ], out2[, 1:4 ] ) 
names(out1out2) <- c( "out1", "out2" ) 

macroPlot( x = out1out2, gui = FALSE, subPlots = TRUE ) 
