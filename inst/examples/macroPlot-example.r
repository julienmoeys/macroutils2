
library( "macroutils2" )



# ====== Example 1: MACRO model input file ======

#   Path to the file to be read
( filenm <- system.file( c( 
    "bintest/chat_winCer_GW-D_1kgHa_d298_annual_output.bin", 
    "bintest/chat_pot_GW-D_1kgHa_d119_biennial_output.bin" ), 
    package  = "macroutils2", 
    mustWork = TRUE 
) )

#   Read these 2 files
out1  <- macroReadBin( f = filenm[ 1 ] ) 

out2 <- macroReadBin( f = filenm[ 2 ] ) 

#   Inspect the data:
head( out1 ); dim( out1 ) 
head( out2 ); dim( out2 ) 


#   Shorten the 2nd file to the same length as the 1st
out2 <- out2[ out2[, "Date" ] %in% out1[, "Date" ], ]


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
