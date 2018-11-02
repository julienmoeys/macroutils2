
library( "macroutils2" )



# ====== Read a bin file ======

#   Format the path to a test binary file
( filenm <- system.file( 
    "bintest/output_chat_winCer_GW-C_1kgHa_d298.bin", 
    package = "macroutils2", mustWork = TRUE ) ) 

#   Read the binary file
tmp1 <- macroReadBin( f = filenm ) 

#   Inspect the table
colnames( tmp1 ) 

dim( tmp1 ) 



# ====== Aggregate the results =====

#   Mean by year and month (only top results shown):
head( r1 <- macroAggregateBin( x = tmp1, by = "%Y-%m", FUN = mean ) )

#   Mean by month too, but on one column only
#   (only top results shown):
head( r2 <- macroAggregateBin( 
    x       = tmp1, 
    columns = "CCET", 
    by      = "%Y-%m", 
    FUN     = mean ) ) 


#   Mean by week of year (00 -> 53):
r3 <- macroAggregateBin( x = tmp1, by = "%Y-%W", FUN = mean ) 

#   Inspect the results
head( r3 ) 

tail( r3 ) 

#   Notice the new format of the column 'Date' ("character")
class( r1[,"Date"] )

#   Trick to convert r1$Date to POSIXct date again, by adding a virtual day:
r1[,"Date"] <- as.POSIXct( paste( sep = "", r1[,"Date"], "-15" ), 
    format = "%Y-%m-%d", tz = "GMT" ) 
class( r1[,"Date"] )

#   Plot the results
plot( r1[,2] ~ r1[,"Date"], type = "b", col = "red" ) 



# ====== using the original R aggregate() =====

#   More code, but a bit faster
r1b <- aggregate( 
    x   = tmp1[,-1], 
    by  = list( "Date" = format.POSIXct( tmp1[,"Date"], "%Y-%m" ) ), 
    FUN = mean ) 

head( r1b ) 

identical( r1[,-1], r1b[,-1] )
