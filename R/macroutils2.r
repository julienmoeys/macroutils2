
# +-------------------------------------------------------------+ 
# | Package:    See 'Package' in file ../DESCRIPTION            | 
# | Author:     Julien MOEYS                                    | 
# | Language:   R                                               | 
# | Contact:    See 'Maintainer' in file ../DESCRIPTION         | 
# | License:    See 'License' in file ../DESCRIPTION            | 
# +-------------------------------------------------------------+ 



# +-------------------------------------------------------------+ 
# | Original file: macroutils-package.R                         | 
# +-------------------------------------------------------------+ 

#'muParList
#'
#'
#'
#'@name muParList
#'@docType data
NULL




#' R utility functions for the MACRO (and SOIL) models.
#'
#' R utility functions for the MACRO (and SOIL) models. Reads, 
#'  writes, plot, view and converts MACRO binary files (input or 
#'  output data).
#'
#'@name macroutils2-package
#'
#'@aliases macroutils2-package macroutils
#'
#'@docType package
#'
#'@author 
#'  Julien MOEYS <jules_m78-soiltexture@@yahooDOTfr>, 
#'  Kristian Persson <kristianDOTpersson@@sluDOTse> 
#'
#'  Maintainer: Julien MOEYS <jules_m78-soiltexture@@yahooDOTfr>, 
#'
#'@keywords package
NULL



# +-------------------------------------------------------------+ 
# | Original file: onAttach.R                                   | 
# +-------------------------------------------------------------+ 

#'@importFrom utils packageVersion
NULL

.onAttach <- function(# Internal. Message displayed when loading the package.
 libname, 
 pkgname  
){  
    # muPar( "timeSeriesValid" = isValidTimeSeries ) 
    
    # Welcome message
    if( interactive() ){ 
        gitVersion <- system.file( "GIT_REVISION", package = pkgname ) 
        
        if( gitVersion != "" ){ 
            gitVersion <- readLines( con = gitVersion )[ 1L ] 
            gitVersion <- strsplit( x = gitVersion, split = " ", 
                fixed = TRUE )[[ 1L ]][ 1L ]
            
            gitVersion <- sprintf( "(git revision: %s)", gitVersion ) 
        }else{ 
            gitVersion <- "(git revision: ?)" 
        }   
        
        msg <- sprintf( 
            "%s %s %s. For help type: help(pack='%s')", 
            pkgname, 
            as.character( utils::packageVersion( pkgname ) ), 
            gitVersion, # svnVersion
            pkgname ) 
        
        packageStartupMessage( msg ) 
    }   
}   


# +-------------------------------------------------------------+ 
# | Functions required for the option system (below)            | 
# +-------------------------------------------------------------+ 

# ==================== isValidTimeSeries ===================

# Note: function originally defined in macroutils.R

#' Test that Date or POSIXct date-time are unique, sorted and regular.
#'
#'@description
#'  Test that Date or POSIXct date-time are unique, sorted and 
#'  regular.
#'
#'
#'@param x
#'  A vector of \code{\link{Date}}, or of \code{\link[base:DateTimeClasses]{POSIXct}} 
#'  date-times
#'
#'@param units
#'  Passed to \code{\link[base:numeric]{as.numeric}}-\code{difftime}. Only 
#'  used in case irregularities in the time series are 
#'  detected.
#'
#'@param onError
#'  A valid R function, such as \code{warning} or \code{stop}, 
#'  or \code{message}. Function that will be used to output 
#'  an error message if the time series is not unique, sorted 
#'  and regular.
#'
#'
#'@return 
#'  Returns \code{FALSE} if a problem was detected, and 
#'  \code{TRUE} otherwise (unless \code{onError} is \code{stop}, 
#'  in which case an error is send and the function stops).
#'
#'
#'@example inst/examples/isValidTimeSeries-examples.r
#'
#'@export
#'
isValidTimeSeries <- function( 
    x,      # Date-format or POSIXct-format
    units   = "hours", 
    onError = warning 
){  
    isValid <- TRUE
    
    #   Find if all dates are unique
    if( any( dup <- duplicated( x ) ) ){
        onError( sprintf(
            "Some climate date(s)-time(s) are duplicated. First case: %s. Please check. See also option 'timeSeriesValid' in muPar()", 
            x[ dup ][ 1L ]
        ) ) 
        
        isValid <- FALSE
    };  rm( dup )
    
    #   Find if all dates are sorted
    if( any( sort( x ) != x ) ){
        onError( "Some date(s)-time(s) seems to be unsorted. Please check. See also option 'timeSeriesValid' in muPar()" ) 
        
        isValid <- FALSE
    }   
    
    #   Find if time increment is homogeneous
    # udiff <- unique( diff( x ) )
    udiff <- unique( difftime( x[ -length(x) ], x[ -1 ], units = units ) )
    
    if( length( udiff ) > 1L ){
        udiff <- as.numeric( udiff, units = units ) 
        
        u <- substr( units, 1, 1 )
        
        onError( sprintf( 
            "The time interval between date(s)-time(s) vary. First two time differences: %s %s, %s %s. Please check. See also option 'timeSeriesValid' in muPar()", 
            udiff[ 1L ], u, udiff[ 2L ], u
        ) )  
        
        isValid <- FALSE
    }   
    
    return( isValid ) 
}   



# +-------------------------------------------------------------+ 
# | Original file: muOptionSystem.R                             | 
# +-------------------------------------------------------------+ 

## Package's parameter system
## +------------------------------------------------------------+

## Create two environment that will contain the package's
## parameters.

## - Backup / reference 
.muParList <- new.env() 

## - User visible container
muParList  <- new.env() 



## Set some default parameters: 

# .muParList[[ "rmNonAlphaNum" ]]        <- FALSE 
# .muParList[[ "rmRunID" ]]          <- FALSE 
# .muParList[[ "tz" ]]                  <- "GMT" 
.muParList[[ "alphaNum" ]]            <- c( letters, LETTERS, 0:9, " ", "_", "-" ) 
# .muParList[[ "header" ]]              <- TRUE 
.muParList[[ "lastBinWd" ]]           <- character(0) 
.muParList[[ "timeSeriesValid" ]]     <- isValidTimeSeries 



# ==================== muPar ====================

#' Get or set default parameters for the package.
#'
#' Get or set default parameters for the package. Notice changes done to the
#'  parameter values are reset every time the R session is closed and the package
#'  is reloaded.
#'
#'  The function has 3 possible, non-exclusive behaviours: \itemize{ \item If
#'  \code{reset=TRUE}, resetting the parameters to their initial values, as
#'  defined in this function. \item (Silently) returning the actual value of the
#'  package parameters. If \code{par=NULL}, all the values are returned.  If
#'  \code{par} is a vector of parameter names, their value will be returned.
#'  \item Setting-up the value of some parameters, passing a list of parameter
#'  value to \code{par} OR setting some of the parameters listed above. }
#'
#'  Notice that when \code{reset=TRUE} and some new parameter values are
#'  provided, the parameters are first reset, and then the new parameter values
#'  are set. If \code{par} is a list, parameters are set first according to
#'  values in \code{par}, and then according to values in the parameters listed
#'  below. This combination is not recommended, but nonetheless possible.
#'
#'  The actual value of the parameters is stored in (and can be retrieved from)
#'  the environment \code{rspPars}. The default value of the parameters are
#'  stored in the environment \code{rspPars}. Do not use them directly.
#'
#'
#'@param par 
#'  Three possible cases: \itemize{ \item If \code{par} is \code{NULL}
#'  (default): All the actual value of the parameters will be silently returned.
#'  \item If \code{par} is a vector of character strings representing parameter
#'  names. The value of the parameters named here will be (silently) returned.
#'  \item If \code{par} is a list following the format \code{tag = value}, where
#'  \code{tag} is the name of the parameter to be changed, and \code{value} is
#'  its new value.  Such a list is returned by \code{muPar()}. Notice that
#'  parameters can also be set individually, using the options listed below. }
#'
#'@param reset 
#'  Single logical. If TRUE, all the parameters will be set to their
#'  default value. Values are reset before any change to the parameter values, as
#'  listed below.
#'  
#'@param alphaNum 
#'  Vector of single characters. List of characters allowed in
#'  the column names when \code{rmNonAlphaNum == TRUE}.
#'  
#'@param lastBinWd 
#'  Single character string. Last folder in which some binary files
#'  were fetched.
#'  
#'@param timeSeriesValid 
#'  A valid R function. The first parameter of the function 
#'  must accept a Date or POSIXct time series (as read from 
#'  or exported to a BIN-file). The purpose of the 
#'  function is to check that the time series is "valid". 
#'  The default function 
#'  \code{\link[macroutils2]{isValidTimeSeries}} (set when 
#'  the package is attached) will for example check that 
#'  date-times in the time series are unique, sorted and 
#'  regular(ly increasing). Set to \code{NULL} or 
#'  \code{function(x){TRUE}} to cancel any check.
#' 
#'  
#'@return 
#'  Returns a partial or complete list of (actual) parameter values, as a
#'  named list.
#'  
#'  
#'@seealso \code{\link{getMuPar}}.
#'
#'
#'@export
#'
#'
muPar <- function(
    par     = NULL, 
    reset   = FALSE, 
    #dateMethod, 
    #rmSpaces,
    #rmNonAlphaNum,
    #rmRunID, 
    # tz,
    alphaNum, 
    #header, 
    lastBinWd, 
    timeSeriesValid
){  
    parList <- names( formals(muPar) ) 
    parList <- parList[ !(parList %in% c( "par", "reset" )) ] 
    
    
    ## (1) Reset the parameter values:
    if( reset ){ 
        v  <- as.list( .muParList ) 
        nv <- names( v ) 
        
        lapply( 
            X   = 1:length(v), 
            FUN = function(X){ 
                assign( x = nv[ X ], value = v[[ X ]], envir = muParList ) 
            }   
        )   
        
        rm( nv, v ) 
    }   
    
    
    ## (2) Change the parameter values:
    
    # Get actual parameter values:
    muParValues <- as.list( get( x = "muParList" ) ) 
    
    # Case: par is a list of parameters to be set
    if( is.list( par ) ){
        parNames <- names( par ) 
         
        if( is.null( parNames ) ){ 
            stop( "If 'par' is a list, its item must be named." )
        }   
        
        # Check that all parameters in par exists:
        testpar1 <- !(parNames %in% names(muParValues)) 
        
        if( any( testpar1 ) ){ 
            stop( sprintf( 
                "Some of the parameter names listed in 'par' could not be found: %s.", 
                paste( parNames[ testpar1 ], collapse=", " ) 
            ) ) 
        }  
        
        # Set the values
        for( i in parNames ){ 
            if( is.null( par[[ i ]] ) ){
                muParValues[ i ] <- list( NULL ) # Fixed 2016/01/27
            }else{
                muParValues[[ i ]] <- par[[ i ]] 
            }   
        }   
    }   
    
    # Set all the individual parameters provided as a function's 
    # argument(s)
    for( parLabel in parList ){ 
        testExpr <- substitute( 
            expr = !missing(theLabel), 
            env  = list( theLabel = as.symbol(parLabel) ) 
        )   
        
        if( eval( testExpr ) ){ 
            tmpPar <- get( x = parLabel )  
            
            if( is.null( tmpPar ) ){
                muParValues[ parLabel ] <- list( NULL ) # Fixed 2016/01/27
            }else{
                muParValues[[ parLabel ]] <- tmpPar
            };  rm( tmpPar )
            
        }   
    }   
    
    # Set the parameter values at once 
    nv <- names( muParValues ) 
    lapply( 
        X   = 1:length(muParValues), 
        FUN = function(X){ 
            assign( x = nv[ X ], value = muParValues[[ X ]], envir = muParList ) 
        }   
    )   
    
    
    ## (3) Return the parameter values:
    
    # Case: return the value of some parameters:
    if( is.character(par) & (length(par) != 0) ){ 
        # Test that all demanded parameters exists:    
        testpar <- !(par %in% names(muParValues)) 
        
        if( any( testpar ) ){ 
            stop( sprintf( 
                "Some of the parameter names listed in 'par' could not be found: %s.", 
                paste( par[ testpar ], collapse=", " ) 
            ) ) 
        }  
        
        ret <- muParValues[ par ] 
    
    # Case: return the value of all parameters:
    }else{ 
        ret <- muParValues 
    }   
    
    return( invisible( ret ) ) 
### Returns a partial or complete list of (actual) parameter values, 
### as a named list.
}   




# ==================== muPar ====================

#' Get a single default parameters for the package.
#'
#' Get a single default parameters for the package. Wrapper around
#'  \code{\link{muPar}}.
#'
#'
#'@param par 
#'  See the \code{par} argument in \code{\link{muPar}}. Notice that
#'  if more than one parameter name is provided, only the first one will be
#'  returned.
#'  
#'  
#'@return 
#'  Returns the value of the parameter \code{par}, without the list
#'  container of \code{\link{muPar}}.
#'
#'
#'@export
#'
#'
getMuPar <- function(
    par 
){  
    return( muPar( par = par )[[ 1L ]] ) 
}   



## Test that all parameters in '.muParList' have been included in 
## the function rspParameters() 

# List of parameter names:
parNames <- names( as.list( .muParList ) ) 

# List of argument names
muParF <- names(formals(muPar))
muParF <- muParF[ !(muParF %in% c("par","reset")) ]

# List of parameters handled by muPar(): do they match with 
# the default parameters?
testpar  <- !(parNames %in% muParF)

if( any(testpar) ){ 
    stop( sprintf( 
        "Some parameters in '.muParList' are not in names(formals(muPar)): %s", 
        paste( parNames[ testpar ], collapse = ", " ) 
    ) )  
}   

# Other way round
testpar2 <- !(muParF %in% parNames)

if( any(testpar2) ){ 
    stop( sprintf( 
        "Some parameters in names(formals(muPar)) are not in '.muParList': %s", 
        paste( muParF[ testpar2 ], collapse = ", " ) 
    ) )  
}   

rm( testpar, parNames, testpar2, muParF ) 



## Set the current list of parameters
muParList <- list2env( as.list( .muParList ) ) 



# +-------------------------------------------------------------+ 
# | Original file: macroReadIndump-fun.R                        | 
# +-------------------------------------------------------------+ 

### Converts MACRO internal dates into R POSIXct date-time format
.macroDate2POSIXct <- function( x, tz = "GMT" ){ 
    x <- as.integer( x ) 
    
    date.offsetX <- -48/24 
    
    x <- as.POSIXct( "0001/01/01 00:00:00", 
        tz = tz) + x * 60 + date.offsetX * 
        24 * 60 * 60
    
    x <- as.POSIXct( format( x = x, format = "%Y-%m-%d %H:%M:%S", 
        tz = tz), format = "%Y-%m-%d %H:%M:%S", tz = tz )
    
    return( x ) 
}   
#   .macroDate2POSIXct( c("1035596160","1049270399") )



# macroReadIndump ===============================================

#' INTERNAL. Import a MACRO indump.tmp file and output it in a human readable format.
#'
#' INTERNAL. Import a MACRO indump.tmp file and output it in a 
#'  human readable format. It reads layered parameters, options, 
#'  crop parameters and irrigation parameters, but not yet output 
#'  parameters. EXPERIMENTAL. USE AT YOUR OWN RISKS.
#'
#'@param f 
#'  Single character string. Name (and if needed, path) of the 
#'  indump.tmp file to be read
#'
#'@param layerLoc
#'  Single integer. Line where the number of numerical layers is 
#'  written
#'
#'@param exportTrash
#'  Single logical value. If TRUE, 'filling' parameter values (i.e. 
#'  values written but not used) are also exported.
#'
#'
#'@return 
#'  Returns a list of \code{\link[base]{data.frame}}s with different 
#'  MACRO parameters
#'
#'
#'@export
#'
#'@keywords internal
#'
#'@importFrom utils read.fwf
#'
macroReadIndump <- function( 
 f, 
 layerLoc = 7, 
 exportTrash = FALSE
){   
    indump <- readLines( con = f ) 
    
    nlayer  <- as.integer( scan( text = indump[ layerLoc ], quiet = TRUE ) ) 
    
    # Find the beginning and end of the 1st variables array
    varLoc1 <- which( substr( indump, 1, 1 ) == "4" ) 
    varLoc1 <- varLoc1[ which( varLoc1 > layerLoc ) ][1]
    varLoc2 <- strsplit( x = indump[ varLoc1 ], split = " " )[[ 1 ]] 
    varLoc2 <- as.integer( varLoc2[ length( varLoc2 ) ] ) 
    varLoc <- (varLoc1+1):(ceiling( varLoc2 / 6 ) + varLoc1)
    rm( varLoc1, varLoc2 ) 
    
    # Read the 1st variable array
    val <- as.numeric(unlist( lapply( 
        X   = indump[ varLoc ], 
        FUN = function(X){ scan( text = X, what = "character", quiet = TRUE ) } ) ) ) 
    
    # Find the beginning and end of the 1st variables index vector
    indexLoc1 <- which( substr( indump, 1, 1 ) == "8" ) 
    indexLoc1 <- indexLoc1[ which( indexLoc1 > max(varLoc) )[1] ] 
    indexLoc2 <- strsplit( x = indump[ indexLoc1 ], split = " " )[[ 1 ]] 
    indexLoc2 <- as.integer( indexLoc2[ length( indexLoc2 ) ] ) 
    indexLoc <- (indexLoc1+1):(ceiling( indexLoc2 / 8 ) + indexLoc1)
    rm( indexLoc1, indexLoc2 ) 
    
    # Read the 1st variables index-array
    ind <- as.integer( unlist( lapply( 
        X   = indump[ indexLoc ], 
        FUN = function(X){ scan( text = X, what = "character", quiet = TRUE ) } ) ) ) 
    
    # Find the beginning and end of the 1st variables column vector
    colLoc1 <- which( substr( indump, 1, 1 ) == "7" ) 
    colLoc1 <- colLoc1[ which( colLoc1 > max(indexLoc) )[1] ] 
    colLoc2 <- strsplit( x = indump[ colLoc1 ], split = " " )[[ 1 ]] 
    colLoc2 <- as.integer( colLoc2[ length( colLoc2 ) ] ) 
    colLoc <- (colLoc1+1):(ceiling( colLoc2 / 8 ) + colLoc1)
    rm( colLoc1, colLoc2 ) 
    
    # Read the 1st variables index-array
    # varIndex <- unlist( lapply( 
        # X   = indump[ colLoc ], 
        # FUN = function(X){ scan( text = X, what = "character", quiet = TRUE ) } ) ) 
    tmp  <- tempfile() 
    writeLines( text = paste( indump[ colLoc ] ), con = tmp ) 
    # library( "utils" )
    varIndex <- utils::read.fwf( file = tmp, widths = rep(9,8), stringsAsFactors = FALSE ) 
    unlink( tmp ); rm( tmp ) 
    varIndex <- unlist( lapply( 
        X   = 1:nrow(varIndex),
        FUN = function(X){
            scan( 
                text  = paste( varIndex[X,], collapse = " " ),
                what  = "character", 
                quiet = TRUE 
            )
        }
    ) ) 
    varIndex <- varIndex[ !is.na( varIndex ) ] 
    
    # Bind the columns and their indexes
    varIndex <- data.frame( 
        "name"   = varIndex, 
        "start"  = ind[ -length( ind ) ], 
        "stop"   = ind[ -length( ind ) ] + diff( ind ) - 1, 
        "length" = diff( ind ), 
        stringsAsFactors = FALSE )
    
    # Empty variable matrix
    mat   <- matrix( data = length(0), nrow = nlayer, ncol = 0 )
    vr    <- numeric(0) 
    trash <- list() 
    
    for( r in 1:nrow( varIndex ) ){ 
        #   Locate the values 
        i <- varIndex[ r, "start" ] 
        j <- varIndex[ r, "stop" ]  
        
        #   Case: layered variable:
        if( varIndex[ r, "length" ] == nlayer ){ 
            #   Read the values into a matrix
            matTmp <- matrix( data = val[ i:j ], nrow = nlayer, 
                ncol = 1, byrow = FALSE ) 
            
            #   Name the column
            colnames( matTmp ) <- varIndex[ r, "name" ] 
            
            #   Bind to the existing data
            mat <- cbind( mat, matTmp ); rm( matTmp ) 
            
        }else{ 
        #   Case: non-layered variable
            varTmp <- val[ i:j ] 
            
            #   Case: not a single value (strange stuff)
            if( varIndex[ r, "length" ] != 1 ){ 
                #   Only keep the last value
                trash[[ varIndex[ r, "name" ] ]] <- varTmp[ -1 ] # -length( varTmp )
                varTmp <- varTmp[ 1 ] # length( varTmp )
            }   
            
            names( varTmp ) <- varIndex[ r, "name" ] 
            vr <- c( vr, varTmp ); rm( varTmp ) 
        }   
    }   
    
    
    
    # === === read the "options" === === 
    
    # Find the beginning and end of the 1st variables array
    varLoc <- which( substr( indump, 1, 17 ) ==  " 5             35" )[1] 
    if( length( varLoc ) == 0 ){ 
        stop( "Could not find the 'options' variables" )
    }   
    varLoc <- varLoc+1
    
    # Read the 1st variable array
    valO <- as.numeric(unlist( lapply( 
        X   = indump[ varLoc ], 
        FUN = function(X){ scan( text = X, what = "character", quiet = TRUE ) } ) ) ) 
    
    # Find the beginning and end of the 1st variables column vector
    colLoc1 <- which( substr( indump, 1, 17 ) ==  " 6             35" )[1] 
    if( length( colLoc1 ) == 0 ){ 
        stop( "Could not find the 'options' header" )
    }   
    colLoc2 <- strsplit( x = indump[ colLoc1 ], split = " " )[[ 1 ]] 
    colLoc2 <- as.integer( colLoc2[ length( colLoc2 ) ] ) 
    colLoc <- (colLoc1+1):(ceiling( colLoc2 / 8 ) + colLoc1)
    rm( colLoc1, colLoc2 ) 
    
    # Read the 1st variables index-array
    tmp  <- tempfile() 
    writeLines( text = paste( indump[ colLoc ] ), con = tmp ) 
    colO <- read.fwf( file = tmp, widths = rep(9,8), stringsAsFactors = FALSE ) 
    unlink( tmp ); rm( tmp ) 
    colO <- unlist( lapply( 
        X   = 1:nrow(colO),
        FUN = function(X){
            scan( 
                text  = paste( colO[X,], collapse = " " ),
                what  = "character", 
                quiet = TRUE 
            )
        }
    ) ) 
    colO <- colO[ !is.na( colO ) ] 
    
    names( valO ) <- colO 
    
    
    
    # === === read the start / stop dates === === 
    
    varLoc <- which( substr( indump, 1, 7 ) ==  "25    0" )[1] 
    if( length( varLoc ) == 0 ){ 
        stop( "Could not find the 'start / stop dates' variables" )
    }   
    varLoc <- varLoc+1
    
    # Read the 1st variable array
    valDates <- as.integer( unlist( lapply( 
        X   = indump[ varLoc ], 
        FUN = function(X){ scan( text = X, what = "character", quiet = TRUE ) } ) ) ) 
    
    valDates <- .macroDate2POSIXct( valDates[1:2] )
    
    
    
    # === === Find time-variable parameters === ===
    
    timePar <- list() 
    
    dateLoc  <- which( substr( indump, 1, 3 ) ==  "23 " ) 
    dateLoc2 <- c( dateLoc, length( indump ) + 1 ) 
    
    if( length( dateLoc ) == 0 ){ 
        warning( "Could not find time-variable parameters" )
    }else{ 
        varLoc2a <- which( substr( indump, 1, 4 ) ==  "101 " ) 
        varLoc2b <- which( substr( indump, 1, 4 ) ==  "102 " ) 
            
        for( timeI in 1:length( dateLoc ) ){ 
            #   Find and convert the date-time
            dateTime <- as.integer( scan( text = indump[ dateLoc[ timeI ]+1 ], 
                what = "character", quiet = TRUE ) ) 
            dateTime <- .macroDate2POSIXct( dateTime )
            
            # #   Locate and read the index and values array
            # if( timeI != length( dateLoc ) ){ 
                # timeIPlusOne <- timeI+1 
            # }else{ 
                # timeIPlusOne <- length( indump ) + 1 
            # }   
            
            testTime <- (varLoc2a > dateLoc[ timeI ]) & 
                (varLoc2a < dateLoc2[ timeI+1 ])
            indexLoc1 <- varLoc2a[ which( testTime )[ 1 ] ]
            indexLoc2 <- strsplit( x = indump[ indexLoc1 ], split = " " )[[ 1 ]] 
            indexLoc2 <- as.integer( indexLoc2[ length( indexLoc2 ) ] ) 
            indexLoc <- (indexLoc1+1):(ceiling( indexLoc2 / 10 ) + indexLoc1)
            rm( indexLoc1, indexLoc2 ) 
            
            # Read the index-array
            ind <- as.integer( unlist( lapply( 
                X   = indump[ indexLoc ], 
                FUN = function(X){ scan( text = X, what = "character", quiet = TRUE ) } ) ) ) 
            
            testTime <- (varLoc2b > dateLoc[ timeI ]) & 
                (varLoc2b < dateLoc2[ timeI+1 ])
            varLoc1   <- varLoc2b[ which( testTime )[ 1 ] ] 
            varLoc3 <- strsplit( x = indump[ varLoc1 ], split = " " )[[ 1 ]] 
            varLoc3 <- as.integer( varLoc3[ length( varLoc3 ) ] ) 
            varLoc <- (varLoc1+1):(ceiling( varLoc3 / 10 ) + varLoc1)
            rm( varLoc1, varLoc3 ) 
            
            # Read the variable array
            valDate <- as.numeric( unlist( lapply( 
                X   = indump[ varLoc ], 
                FUN = function(X){ scan( text = X, what = "character", quiet = TRUE ) } ) ) ) 
            
            
            varIndex2 <- lapply( 
                X   = ind, 
                FUN = function(X){ 
                    testCol <- (varIndex[,"start"] <= X) & 
                        (varIndex[,"stop" ] >= X) 
                    testCol <- which( testCol ) 
                    
                    if( length(testCol) == 0 ){ 
                        stop( "Can't find index of time-variable parameter" )
                    }   
                    
                    return( varIndex[ testCol[1], ] ) 
                }   
            )   
            varIndex2 <- unique( do.call( "rbind", varIndex2 ) ) 
            
            # testCol <- which( varIndex[,"start"] %in% ind )
            # varIndex2 <- data.frame( 
                # "name"   = varIndex[ testCol, "name" ], 
                # "start"  = ind, 
                # "length" = varIndex[ testCol, "length" ], 
                # stringsAsFactors = FALSE 
            # )   
            
            #   Prepare reading the new values:
            mat2   <- matrix( data = length(0), nrow = nlayer, ncol = 0 )
            vr2    <- numeric(0) 
            trash2 <- list() 
            j <- 0 
            
            # if( timeI == 2 ){ browser() }
            
            #   Read the new values
            for( r in 1:nrow( varIndex2 ) ){ 
                # Locate the values 
                # i <- varIndex2[ r, "start" ] 
                i <- j+1
                j <- i + varIndex2[ r, "length" ] - 1 
                
                #   Case: layered variable:
                if( varIndex2[ r, "length" ] == nlayer ){ 
                    #   Read the values into a matrix
                    matTmp <- matrix( data = valDate[ i:j ], nrow = nlayer, 
                        ncol = 1, byrow = FALSE ) 
                    
                    #   Name the column
                    colnames( matTmp ) <- varIndex2[ r, "name" ] 
                    
                    #   Bind to the existing data
                    mat2 <- cbind( mat2, matTmp ); rm( matTmp ) 
                    
                }else{ 
                #   Case: non-layered variable
                    varTmp <- valDate[ i:j ] 
                    
                    #   Case: not a single value (strange stuff)
                    if( varIndex2[ r, "length" ] != 1 ){ 
                        #   Only keep the last value
                        trash2[[ varIndex2[ r, "name" ] ]] <- varTmp[ -1 ] 
                        varTmp <- varTmp[ 1 ] 
                    }   
                    
                    names( varTmp ) <- varIndex2[ r, "name" ] 
                    vr2 <- c( vr2, varTmp ); rm( varTmp ) 
                }   
            }   
            
            if( ncol(mat2) == 0 ){ mat2 <- NULL } 
            
            if( !exportTrash ){ trash2 <- list() } 
            
            timePar[[ length(timePar)+1 ]] <- list( 
                "date"    = dateTime, 
                "trash"   = trash2, 
                "mat"     = mat2, 
                "var"     = vr2 
            )   
            
        }   
        
    }   
    
    
    
    # === === Tag time variable parameters === === 
    
    cropCol <- c( "ROOTINIT", "ROOTMAX", "ROOTDEP", "CFORM", 
        "RPIN", "WATEN", "CRITAIR", "BETA", "CANCAP", "ZALP", 
        "IDSTART", "IDMAX", "IHARV", "ZHMIN", "LAIMIN", "LAIMAX", 
        "ZDATEMIN", "DFORM", "LAIHAR", "HMAX", "RSMIN", "ATTEN" ) 
    
    irrCol <- c( "IRRDAY", "AMIR", "IRRSTART", "IRREND", "ZFINT", 
        "CONCI", "NIRR" )
    
    type <- unlist( lapply( 
        X   = timePar, 
        FUN = function(X){ 
            type <- "other" 
            nm   <- names( X[["var"]] ) 
            
            #   Test if crops
            selCol <- cropCol[ cropCol %in% nm ]
            
            if( length(selCol) != 0 ){ 
                typeCrop <- TRUE 
            }else{ typeCrop <- FALSE }
            
            #   Test if irrigation
            selCol <- irrCol[ irrCol %in% nm ]
            
            if( length(selCol) != 0 ){ 
                typeIrr <- TRUE 
            }else{ typeIrr <- FALSE }
            
            if( typeCrop & typeIrr ){ 
                warning( "Both irrigation and crop parameters mixed in time-variable parameters" ) }
            
            if( typeCrop ){ type <- "crop" } 
            if( typeIrr){ type <- "irr" } 
            
            return( type ) 
        }   
    ) ) 
    
    
    # === === Prepare crop parameters === === 
    
    #   Separate the crop parameters from the rest
    
    crop    <- vr[ cropCol ] 
    crop    <- t( as.matrix( crop ) ) 
    colnames(crop) <- cropCol  
    
    vr      <- vr[ !(names(vr) %in% cropCol) ] 
    
    #   Add a date column
    crop    <- data.frame( 
        "DATE"  = valDates[1], 
        "DOY"   = as.integer( format( valDates[1], format = "%j" ) ), 
        crop 
    )   
    
    cropLater <- matrix( data = NA_real_, nrow = 1, 
        ncol = length(cropCol) ) 
    colnames( cropLater ) <- cropCol 
    cropLater <- data.frame( 
        "DATE"  = as.POSIXct( NA ), 
        "DOY"   = as.integer( NA ), 
        cropLater 
    )   
    
    testTimeCrop <- which( type == "crop" ) 
    
    if( length(testTimeCrop) != 0 ){ 
        cropLater <- lapply( 
            X   = timePar[ testTimeCrop ], 
            FUN = function(X){ 
                selCol <- cropCol[ cropCol %in% names( X[["var"]] ) ]
                
                if( length(selCol) != 0 ){ 
                    cropLater[ 1, selCol ] <- X[["var"]][ selCol ] 
                    
                    if( length(selCol) != length( cropCol ) ){ 
                        warning( "Some time variable crop parameters not found in initial parameters" ) 
                    }   
                    
                    cropLater[, "DATE" ] <- X[["date"]] 
                    cropLater[, "DOY" ]  <- as.integer( format( X[["date"]], format = "%j" ) ) 
                }else{ 
                    #   Return an empty data.frame
                    cropLater <- cropLater[ logical(0), ] 
                }   
                
                return( cropLater ) 
            }   
        )   
        cropLater <- do.call( "rbind", cropLater )
        
        crop <- rbind( crop, cropLater ); rm( cropLater ) 
    }   
    
    # === === Prepare Irrigation parameters === === 
    
    #   Separate the irrigation parameters from the rest
    
    irr    <- vr[ irrCol ] 
    irr    <- t( as.matrix( irr ) ) 
    colnames(irr) <- irrCol  
    
    vr      <- vr[ !(names(vr) %in% irrCol) ] 
    
    #   Add a date column
    irr    <- data.frame( 
        "DATE"  = valDates[1], 
        "DOY"   = as.integer( format( valDates[1], format = "%j" ) ), 
        irr 
    )   
    
    irrLater <- matrix( data = NA_real_, nrow = 1, 
        ncol = length(irrCol) ) 
    colnames( irrLater ) <- irrCol 
    irrLater <- data.frame( 
        "DATE"  = as.POSIXct( NA ), 
        "DOY"   = as.integer( NA ), 
        irrLater 
    )   
    
    testTimeIrr <- which( type == "irr" ) 
    
    if( length(testTimeIrr) != 0 ){ 
        irrLater <- lapply( 
            X   = timePar[ testTimeIrr ], 
            FUN = function(X){ 
                selCol <- irrCol[ irrCol %in% names( X[["var"]] ) ]
                
                if( length(selCol) != 0 ){ 
                    irrLater[ 1, selCol ] <- X[["var"]][ selCol ] 
                    
                    if( length(selCol) != length( irrCol ) ){ 
                        warning( "Some time variable irrigation parameters not found in initial parameters" ) 
                    }   
                    
                    irrLater[, "DATE" ] <- X[["date"]] 
                    irrLater[, "DOY" ]  <- as.integer( format( X[["date"]], format = "%j" ) ) 
                }else{ 
                    #   Return an empty data.frame
                    irrLater <- irrLater[ logical(0), ] 
                }   
                
                return( irrLater ) 
            }   
        )   
        irrLater <- do.call( "rbind", irrLater )
        
        irr <- rbind( irr, irrLater ); rm( irrLater ) 
    }   
    
    # === === Prepare the index of variables
    
    varIndex[, "isCrop" ] <- varIndex[, "name" ] %in% cropCol 
    varIndex[, "isIrr" ]  <- varIndex[, "name" ]  %in% irrCol 
    
    
    
    # === === Final export === === 
    
    #   Keep only non crop and non irrigation parameters in 
    #   list of time variable parameters
    timePar <- timePar[ which( !(type %in% c("crop","irr")) ) ] 
    
    if( !exportTrash ){ trash <- list() } 
    
    out <- list( 
        "trash"     = trash, 
        "mat"       = mat, 
        "var"       = vr, 
        "options"   = valO, 
        "crop"      = crop, 
        "irrig"     = irr, 
        "dateRange" = valDates, 
        "timePar"   = timePar, 
        "varIndex"  = varIndex ) 
    
    return( out )
}   



# +-------------------------------------------------------------+ 
# | Original file: splitPath.R                                  | 
# +-------------------------------------------------------------+ 

.pathSplit <- function(# Split paths into single items, folder(s) or file name(s)
### Split paths into single items, folder(s) or file name(s)
 
 p, 
### Vector of character strings. Paths.
 
 fsep = NULL  
### Vector of character strings. File separators accounted for. 

){  
    if( is.null(fsep) ){ fsep <- c("/","\\") } 
    
    # Strip the file path 
    p <- lapply( X  = p, FUN = function(X){ 
        for( fs in fsep ){ 
            X <- unlist( strsplit(
                x     = X, 
                split = fs, 
                fixed = TRUE
            ) ) 
        }   
        
        return( X[ nchar(X) != 0 ] ) 
    } ) 
    
    return( p ) 
### Returns a list of vector of character strings, of the same 
### length as \code{p}  
}   



.pathLastItem <- function(# Returns the last item in a path
### Returns the last item in a path
 
 p, 
### Vector of character strings. Paths.
 
 fsep = NULL, 
### Vector of character strings. File separators accounted for. 

 noExt=NULL
### Single character string. Extension to be removed from the 
### last item. For example \code{noExt = ".txt"} 
 
){  
    # Strip the file path 
    p <- .pathSplit( p, fsep = fsep )
    
    # Remove the last bit (presumably the file name) 
    p <- lapply( X = p, FUN = function(X){ X[ length(X) ] } ) 
    
    # Remove the file extension
    if( !is.null( noExt ) ){ 
        p <- lapply( X   = p, FUN = function(X){ 
            for( noE in noExt ){ 
                X <- unlist( strsplit(
                    x     = X, 
                    split = noE, 
                    fixed = TRUE
                ) ) 
            }   
            
            return( X ) 
        } )   
    }   
    
    return( unlist( p ) ) 
### Returns path without the file name at the end.
}   




.pathNoLastItem <- function(# Returns a path without its last item
### Returns the last item in a path
 
 p, 
### Vector of character strings. Paths.
 
 fsep = NULL, 
### Vector of character strings. File separators accounted for. 
 
 collapse=.Platform$file.sep, 
### Final file separator to be used
 
 normalise=TRUE, 
### Single logical value. If \code{TRUE}, \code{\link[base]{normalizePath}} 
### is ran on the paths.
 
 mustWork = FALSE
### See \code{\link[base]{normalizePath}}.
 
){  
    # Strip the file path 
    p <- .pathSplit( p, fsep = fsep )
    
    # Remove the last bit (presumably the file name) 
    p <- lapply( X = p, FUN = function(X){ 
        X <- X[ -length(X) ] 
        
        # Concatenate again the file path
        X <- paste( X, collapse = collapse ) 
        
        return( X )
    } ) 
    
    
    # Normalise the paths: 
    if( normalise ){ p <- normalizePath( unlist( p ), mustWork = mustWork ) } 
    
    
    return( p ) 
### Returns path without the file name at the end.
}   



# +-------------------------------------------------------------+ 
# | Original file: macroutils.R                                 | 
# +-------------------------------------------------------------+ 

## # Trim non-alphanumeric suffixes in column 
## # names. Because spaces are occasionally present in 
## # the columns non-alphanumeric suffixes, some non-relevant 
## # characters may be left.
.removeNonAlphaNumSuffix <- function( x ){
    # xIsDate <- x == "Date"
    
    n <- length( x )
    
    split_text <- strsplit( x = x, split = " " )
    
    nbParts <- unlist( lapply( X = split_text, FUN = length ) )
    
    suffixes <- unlist( lapply( 
        X   = split_text, 
        FUN = function(y){ 
            y[ length( y ) ]
        } ) ) 
    
    suffixes[ nbParts == 1L ] <- ""
    
    alphaNum <- getMuPar( "alphaNum" )
    
    suffixIsAlphaNumOnly <- strsplit( x = suffixes, 
        split = "" ) 
    
    suffixIsAlphaNumOnly <- unlist( lapply(
        X   = 1:n, 
        FUN = function(i){
            return( all( suffixIsAlphaNumOnly[[i]] %in% c( alphaNum, "" ) ) )
        } ) ) 
    
    # nonSuffixes <- unlist( lapply( X = split_text, 
        # FUN = function(x){ 
            # x <- x[ -length( x ) ] 
            # x[ x == "" ] <- " "
            # return( paste( x, collapse = " " ) )
        # } ) ) 
    
    nchar_x        <- nchar( x )
    nchar_suffixes <- nchar( suffixes )
    
    nonSuffixes <- unlist( lapply( X = 1:n, 
        FUN = function(i){ 
            return( substr( x = x[ i ], start = 1L, 
                stop = nchar_x[ i ] - nchar_suffixes[ i ] ) )
        } ) ) 
    
    # browser()
    
    # nonSuffixes[ suffixIsAlphaNumOnly & (nbParts != 1L) ] <- 
        # suffixes[ suffixIsAlphaNumOnly & (nbParts != 1L) ]
    
    # suffixes[ suffixIsAlphaNumOnly & (nbParts != 1L) ] <- 
        # rep( "", sum(suffixIsAlphaNumOnly & (nbParts != 1L)) )
    
    suffixesKept <- rep( x = integer(), times = n )
    
    charWasNonAlphaNum <- rep( x = FALSE, times = n )
    
    for( i in 1:3 ){
        suppressWarnings( char_i <- as.integer( substr( 
            x = suffixes, start = i, stop = i ) ) )
        
        char_i <- as.character( char_i )
        
        charWasNonAlphaNum <- charWasNonAlphaNum | is.na( char_i ) 
        
        char_i[ charWasNonAlphaNum ] <- ""
        
        suffixesKept <- paste( suffixesKept, char_i, 
                sep = "" ) 
    }   
    
    out <- paste( nonSuffixes, suffixesKept, sep = " " )
    
    #   Trim trailing white spaces and export
    return( trimws( x = out, which = "right" ) )
}   



# ==================== .macroReadBin ====================

## # Read bin file from the Soil and MACRO models.
## #
## # Read bin file from the Soil and MACRO models. Adapted from 
## #  an "anonymous" SLU original code by Kristian Persson. R code 
## #  vectorisation by Julien Moeys.
## #  
## #  Many global arguments can be set-up and retrieved via 
## #  \code{\link{muPar}} and \code{\link{getMuPar}}. 
## #  Please check the help page of these functions if you need to 
## #  tune \code{macroReadBin}.
## #
## #
## #@seealso \code{\link[base]{readBin}}.
## #
## #
## #@param f 
## #  Single character string or connection to a binary file. If 
## #  a character string, it should be the name of the binary file 
## #  which the data are to be read from. The path of the file may 
## #  be provided as well, if f is not in the working directory.
## #
## #@param \dots 
## #  Additional options passed to \code{\link[base]{readBin}}.
## #
## #
## #@return 
## #  Returns a data.frame with the content of the bin file. Columns 
## #  names found in the bin file are returned as well. The "Date" 
## #  column in the bin file is converted from "Julian Date" into 
## #  POSIXct date format.
## #
## #
.macroReadBin <- function(
    f,
    header, 
    rmSuffixes, 
    trimLength, 
    rmNonAlphaNum, 
    rmSpaces, 
    rmRunID, 
    dateMethod, 
    tz, 
    ...
){  # Reads an integer (4 byte) containting the numner of records 
    # and the length of each record
    record.number <- readBin( 
        con  = f, 
        what = "int",
        n    = 2L, 
        size = 4L, 
        ... 
    )   
    
    record.length <- record.number[ 2L ] # Width of a row in bytes
    record.number <- record.number[ 1L ] # Number of rows
    
    # Number of variables in the file
    variables.number <- record.length / 4L # - 1
    
    if( header ){ 
        colLength <- (variables.number-1L) * ( 52L + 4L + 4L ) 
    }else{ 
        colLength <- 0 
    }   
    
    # Read all the bin file at once:
    # - Calculate its total length 
    total.length <- 
        record.length +                       # File 'info' record
        record.number * record.length +       # Table of data 
        colLength                             # Column names (excl. date)
    
    # - Read the file
    binData <- readBin( 
        con  = f, 
        what = "raw",
        n    = total.length, 
        #size=NA, 
        ... 
    )   
    
    
    # Create a matrix to store the data
    data.values <- matrix( 
        nrow = record.number, 
        ncol = variables.number
    )   #
    
    sel.vec.lst <- mapply( 
        FUN  = seq, 
        from = record.length * (1L:record.number) + 1L, # +1 is to skip the 1st info slot
        to   = record.length * (2L:(record.number + 1L)), 
        SIMPLIFY = FALSE 
    )   
    
    data.values <- do.call( 
        "what" = rbind, 
        args   = lapply( 
            X   = sel.vec.lst, # X is row.nr 
            FUN = function(X){ 
                c( 
                    as.double( 
                        readBin( 
                            con  = binData[ X[1L:4L] ], 
                            what = "int", 
                            size = 4L, 
                            n    = 1L 
                        )   
                    ),  
                    readBin( 
                        con  = binData[ X[5:length(X)] ], 
                        what = "double", 
                        size = 4L, 
                        n    = variables.number - 1L 
                    )   
                )   
            }   
        )   
    )   
    
    # Read in column names
    if( header ){ 
        col.Names <- rep( x = as.character(NA), times = variables.number ) 
        
        col.Names[1L] <- "Date" 
        
        sel.vec.lst2 <- mapply( 
            FUN  = seq, 
            from = record.length * (record.number+1L) + 1L + (0L:(variables.number-2L))*60L, 
            to   = record.length * (record.number+1L) + (1L:(variables.number-1L))*60L, 
            SIMPLIFY = FALSE 
        )   #
        
        col.Names[ 2L:variables.number ] <- unlist( lapply( 
            X   = 1L:length(sel.vec.lst2), 
            FUN = function(X){ 
                #   New code, also handling metabolite intermediate 
                #   file
                readChar( 
                    con = binData[ sel.vec.lst2[[ X ]] ][ 
                        binData[ sel.vec.lst2[[ X ]] ] != as.raw(0x00) ], 
                    nchars = length( sel.vec.lst2[[ X ]] ) ) #   
                
                # readChar( 
                    # con    = binData[ sel.vec.lst2[[ X ]] ], 
                    # nchars = 52  
                # )   
            }   
        ) ) 
        
        # Remove trailing blanks
        col.Names <- sub( 
            pattern     = "[ ]*$", 
            replacement = "", 
            x           = col.Names  
        )   
        
        if( rmSuffixes ){
            #   Attempt to automatically remove non-alphanumeric
            #   suffixes from column names
            col.Names <- .removeNonAlphaNumSuffix( x = col.Names )
        }   
        
        if( (length(trimLength) != 0) & is.integer(trimLength) ){
            #   Trim the column names to a certain number of 
            #   characters
            .nchar <- nchar( col.Names )
            
            col.Names <- substring( 
                text  = col.Names, 
                first = 1L, 
                last  = pmin( trimLength, .nchar ) )
            
            rm( .nchar )
        }      
        
        if( rmSpaces ){   
            # col.Names <- gsub( pattern = "-", replacement = " ", x = col.Names ) 
            
            col.Names  <- strsplit(
                x        = col.Names, 
                split    = " ", 
                fixed    = FALSE, 
                perl     = FALSE
            )   
            
            col.Names  <- unlist( lapply( 
                    X   = col.Names, 
                    FUN = function(X){ 
                        paste( X[ X != "" ], collapse = "_" ) 
                    }   
            )   )   
        }   
        
        if( rmNonAlphaNum ){   
            col.Names <- strsplit( x = col.Names, split = "" ) 
            
            col.Names <- unlist( lapply( 
                X   = col.Names, 
                FUN = function(X){ 
                    sel <- X %in% getMuPar( "alphaNum" ) 
                    
                    return( paste( X[ sel ], collapse = "" ) ) 
                }   
            ) ) 
        }   
        
        colnames( data.values ) <- col.Names 
        
        data.values <- as.data.frame( data.values ) 
        
        if( rmRunID & rmSpaces ){ 
            colnames( data.values ) <- macroStripRunID( 
                x         = colnames( data.values ), 
                splitChar = "_"
            )   
        }   
    }else{ 
        data.values <- as.data.frame( data.values ) 
        
        colnames( data.values )[ 1 ] <- "Date" 
    }   
    
    
    if( dateMethod == 1L ){   
        date.offsetX <- -48L/24L
        tz           <- tz 
        
        # Method 1: Add the date converted in seconds + an offset 
        # of -2 days 
        data.values[,"Date"] <- as.POSIXct( 
            "0001/01/01 00:00:00",
            tz = tz 
        ) + data.values[,"Date"]*60L + date.offsetX*24L*60L*60L  # Add the date
        
        data.values[,"Date"] <- as.POSIXct( 
            format( 
                x      = data.values[, "Date" ], 
                format = "%Y-%m-%d %H:%M:%S", 
                tz     = tz 
            ),  #
            format = "%Y-%m-%d %H:%M:%S", 
            tz = tz 
        )   #
        
        # cat( "1. class(Date2): ", class(Date2), "\n" ) 
        
        # data.values[,"Date"] <- Date2 
    }   
    #
    if( dateMethod == 2L ){ 
        data.values[,"Date"] <- unlist( lapply( 
            X   = 1:record.number, 
            FUN = function(X){ 
                jul<-data.values[X,"Date"]    # minutes
                mi <- jul %% (60 * 24)          # residual minutes
                ho <- mi / 60                   # hours 
                mi <- mi - ho * 60  # This bit is weird mi = 0
                jul <- (jul - mi - ho * 60) / 60 / 24 + 1721424
                ja <- jul
                if(jul >= 2299161)
                {
                    jalpha <- ((jul - 1867216) - 0.25) / 36524.25
                    jalpha <- floor(jalpha)
                    ja = jul + 1 + jalpha - floor(jalpha * 0.25)
                }
                jb <- ja + 1524
                jc <- floor(6680.0 + ((jb - 2439870) - 122.1) / 365.25)
                jd <- 365 * jc + floor(0.25 * jc)
                je <- floor((jb - jd) / 30.6001)
                da <- jb - jd - floor(30.6001 * je)
                mon <- je - 1
                if (mon > 12) 
                {
                    mon <- mon - 12
                }
                yea <- jc - 4715
                if (mon > 2)
                {
                    yea = yea - 1
                }
                if (yea <= 0)
                {
                     yea = yea - 1
                }
                dateStr <- paste(yea,"-",mon,"-", da, " ", ho, ":" , mi, sep="") #make a date string
                #
                return( dateStr ) 
            }   #
        ) ) #
         
        #Transform text format date to POSIXct
        data.values[,"Date"] <- as.POSIXct( 
            data.values[,"Date"],      #vektor att transformera
            format = "%Y-%m-%d %H:%M", #Description of current date string to convert
            tz     = tz )   
        
        # cat( "1. class(Date2): ", class(Date2), "\n" )  
        
        # data.values[,"Date"] <- Date2 
    }       
    
    #   Control that the date-time series is valid
    .isValidTimeSeries <- getMuPar( "timeSeriesValid" ) 
    
    if( !is.null( .isValidTimeSeries ) ){
        .isValidTimeSeries( data.values[,"Date"] ) 
    }   
    
    #Return the data.frame
    return( data.values )
}   



# ==================== .chooseBinFiles ====================

#'@importFrom tcltk tk_choose.files

## # Pop-up a menu to choose bin file from the file system.
## # 
## # Pop-up a menu to choose bin file from the file system.
## #
## #
## #@param caption
## #   See \code{\link[utils]{choose.files}} or 
## #   \code{\link[tcltk]{tk_choose.files}}.
## # 
## #@param multi
## #   See \code{\link[utils]{choose.files}} or 
## #   \code{\link[tcltk]{tk_choose.files}}.
## # 
## # 
.chooseBinFiles <- function(
    caption = "Select one or several binary file(s)", 
    multi   = TRUE
){  
    if( !interactive() ){ 
        stop( "'.chooseBinFiles' can only be used in interactive mode" )
    }   
    
    
    ## Set the folder working directory
    lastBinWd <- getMuPar( "lastBinWd" ) 
    
    if( length(lastBinWd) == 0 ){ 
        lastBinWd <- getwd() 
    }else{ 
        if( lastBinWd == "" ){ 
            lastBinWd <- getwd() 
        }else{ 
            lastBinWd <- file.path( lastBinWd, "*.*" )
        }   
    }   
    
    
    ## Create a template of file extension to be read:
    filterz <- matrix( 
        data  = c( 
            "Binary files (*.bin)", "*.bin", 
            "All",                  "*" ), 
        nrow  = 2, 
        ncol  = 2, 
        byrow = TRUE  
    )   
    rownames( filterz ) <- c( "bin", "all" ) 
    
    ## Pop-up a menu to choose the bin file to be 
    ## imported
    if( exists(x = "choose.files", where = "package:utils" ) ){ 
        # fun <- get( "choose.files" ) 
        
        f <- utils::choose.files(
            default = lastBinWd, # , "*.bin"
            caption = caption, 
            multi   = multi, 
            filters = filterz 
        )   
        
    }else{ 
        # library( "tcltk" ) 
        
        # fun <- get( "tk_choose.files" ) 
        
        f <-tcltk::tk_choose.files(
            default = lastBinWd, # , "*.bin"
            caption = caption, 
            multi   = multi, 
            filters = filterz 
        )   
    }       
    
    ## Set the last folder where binary files were found:
    lastBinWd <- .pathNoLastItem( p = f[1] ) 
    
    muPar( "lastBinWd" = lastBinWd ) 
    
    return( f ) 
}   




# ==================== .macroMenu ====================

## # Wrapper around 'menu' with error handling
## #
## # Wrapper around 'menu' with error handling
## #
## #
## #@param title
## #    See \code{\link[utils]{select.list}}
## # 
## #@param choices
## #    See \code{\link[utils]{select.list}}
## # 
## #@param graphics
## #    See \code{\link[utils]{select.list}}
## # 
## #@param preselect
## #    See \code{\link[utils]{select.list}}
## # 
## #@param error
## #    Single character string. Error message to be displayed if 
## #    the user does not chose any item (code 0).
## # 
## #@param multi
## #    Single logical. If \code{TRUE}, then multiple choices are 
## #    allowed.
## # 
## # 
## #@return
## #    The user's choice.
## #
## #
#'@importFrom utils select.list
.macroMenu <- function(
    title = NULL, 
    choices, 
    graphics = FALSE, 
    preselect = NULL, 
    error = "You haven't chosen anything :o(", 
    multi = FALSE
){  ## Ask the user some choice
    # mRes <- menu( 
    #     choices  = choices, 
    #     graphics = graphics, 
    #     title    = title
    # )   
    
    choicesNum <- 1:length(choices) 
    names( choicesNum ) <- choices 
    
    mRes <- utils::select.list( 
        title       = title,
        choices     = choices, 
        preselect   = preselect, 
        multiple    = multi, 
        graphics    = graphics 
    )   
    
    ## Error handling:
    if( length(mRes) == 0 ){ 
        stop( error ) 
    }   
    
    mRes <- choicesNum[ mRes ] 
    names( mRes ) <- NULL 
    
    if( any( is.na( mRes ) ) ){ 
        stop( "Wrong value(s) chosen" )
    }   
    
    return( mRes ) 
}   




# ==================== macroReadBin ====================

#' Read bin file from the Soil and MACRO models.
#'
#' Read bin file from the Soil and MACRO models, including 
#'  MACRO intermediate-files for metabolite. Adapted by 
#'  Kristian Persson from an "anonymous" SLU original code . 
#'  R code vectorisation by Julien Moeys.
#'
#' Some global arguments can be set-up and retrieved via \code{\link{muPar}}
#'  and \code{\link{getMuPar}}.  Please check the help page of these functions
#'  if you need to tune \code{\link[macroutils2:macroReadBin-methods]{macroReadBin}}.
#'
#'@param f 
#'  Vector of character strings or a single \code{\link{connection}}
#'  to a binary file. If a vector character strings, it should be the name(s) of
#'  the binary file(s) which the data are to be read from. The path of the
#'  file(s) may be provided as well, if the file(s) is (are) 
#'  not in the working directory.
#'
#'@param \dots Additional options passed to specific 
#'  methods and to \code{\link[base]{readBin}}
#'
#'
#'@return 
#'  Returns a \code{data.frame} with the content of the bin file. 
#'  If \code{length(f) > 1}, then a \code{list} of \code{data.frame} 
#'  is returned instead. The \code{Date} column in the bin file is 
#'  converted from "Julian Date" into \code{\link[base:DateTimeClasses]{POSIXct}} 
#'  date format.
#'
#'
#'@seealso \code{\link[base]{readBin}}.
#'
#'
#'@example inst/examples/macroReadBin-example.r
#'
#'@rdname macroReadBin-methods
#'
#'@export
#'
#'
macroReadBin <- function(
    f, 
    ...
){  
    if( missing( f ) ){ 
        UseMethod( "macroReadBin", object = character(0) )
    }else{ 
        UseMethod( "macroReadBin" )
    }   
}   



#'@param header 
#'  Single logical. If \code{TRUE} the header is present in the bin file,
#'  if \code{FALSE} it is not present.
#'
#'@param rmSuffixes
#'  If \code{TRUE}, the code automatically tries to identify 
#'  non alpha-numeric trailing characters following the column 
#'  name. Contrary to \code{trimLength} (see below), this is 
#'  a generic method independent of the type of bin-files (input, 
#'  output of parent substances, output of metabolites), but 
#'  is does not work 100 percent correct.
#'
#'@param trimLength
#'  Single integer value. Number of characters expected for 
#'  column names. All characters beyond \code{trimLength} are 
#'  trimmed. Default to \code{trimLength = integer(0)}, meaning 
#'  that the column names is not trimmed to a fixed length. 
#'  The appropriate length depend on the type of bin-file.
#'  
#'@param rmNonAlphaNum 
#'  Single logical. If TRUE remove all non alpha-numeric
#'  characters from the column names (and replace them by underscores). See also
#'  the \code{alphaNum} parameter. Use this option to obtain database compatible
#'  column names. If \code{gui} is \code{TRUE}, \code{rmNonAlphaNum} is ignored,
#'  and a menu will ask you what to do.
#'
#'@param rmSpaces 
#'  Single logical. If TRUE remove extra spaces and minus
#'  signs in column names and replace them by underscores _. 
#'  Multiple spaces are grouped. Trailing (end) space(s) are 
#'  always removed (whatever is the value of \code{rmSpaces}). 
#'  If \code{gui} is \code{TRUE}, \code{rmSpaces} is
#'  ignored, and a menu will ask you what to do.
#'  
#'@param rmRunID 
#'  Single logical. If TRUE remove the simulation ID at the end
#'  of each column name. \code{rmSpaces} must be \code{TRUE} for using this
#'  option (otherwise ignored). If \code{gui} is \code{TRUE}, \code{rmRunID}
#'  is ignored, and a menu will ask you what to do.
#'  
#'@param dateMethod 
#'  Single integer. If 1 uses a new (shorter) method for
#'  converting dates (from the weird bin file format to POSIXct), if 2 uses the
#'  old / slower method implemented for the SOIL model (and MACRO?) and if 0 (or
#'  any other value than 1 or 2) returns the original date in minutes since 2
#'  days before the 1st of January of year 0001 at 00:00. For 1 and 2 the date
#'  returned is POSIXct with time-zone \code{tz}, and for 0 it is integers.
#'
#'@param tz 
#'  Single character string. "A timezone specification to be used for
#'  the conversion. System-specific (see \code{\link{as.POSIXlt}}), but "" is the
#'  current time zone, and "GMT" is UTC".
#'  
#'@rdname macroReadBin-methods
#'
#'@method macroReadBin character
#'@export 
macroReadBin.character <- function(
    f, 
    header = TRUE, 
    rmSuffixes = TRUE, 
    trimLength = integer(), 
    rmNonAlphaNum = TRUE, 
    rmSpaces = TRUE, 
    rmRunID = TRUE, 
    dateMethod = 1L, 
    tz = "GMT", 
    ...
){  ## If no file name is provided
    if( missing( f ) ){ 
        if( interactive() ){ 
            ## Pop-up a menu to choose the bin file to be 
            ## imported
            f <- .chooseBinFiles(
                caption = "Select one or several binary file(s)", 
                multi   = TRUE  
            )   
            
            if( length(f) == 0 ){ 
                stop( "You haven't choosen any binary file to read :o(" )
            }   
            
            f <- sort( f ) 
        }else{ 
            stop( "'f' can not be missing when R is not being used interactively" ) 
        }   
    }   
    
    
    bin <- lapply( 
        X   = 1:length( f ), 
        FUN = function(i){ 
            bin <- .macroReadBin( 
                f             = f[ i ], 
                dateMethod    = dateMethod, 
                rmSuffixes    = rmSuffixes, 
                trimLength    = trimLength, 
                rmNonAlphaNum = rmNonAlphaNum, 
                rmSpaces       = rmSpaces, 
                rmRunID       = rmRunID, 
                tz            = tz, 
                header        = header, 
                ... ) 
                
            class( bin ) <- c( "macroTimeSeries", "data.frame" )
            
            attr( x = bin, which = "file" ) <- f[ i ] 
            
            return( bin ) 
        }   
    )   
    
    ## Add the file name to each table:
    if( length( bin ) > 1 ){ 
        class( bin ) <- c( "macroTimeSeriesList", "list" ) 
        
    }else{ 
        bin <- bin[[ 1 ]] 
    }   
    
    
    f <- .pathLastItem( p = f, noExt = TRUE )
    attr( x = bin, which = "file" ) <- f 
    
    
    return( bin )
}   



# ==================== macroWriteBin ====================

#' Write bin file for the SOIL and MACRO models.
#'
#' Write bin file for the SOIL and MACRO models. Original code by 
#'  Kristian Persson. R code vectorisation by Julien Moeys.
#'
#'
#'@param x 
#'  A \code{\link[base]{data.frame}}. 
#'  Table of data to be written in \code{file}. The table must contain one column named "Date" containing POSIXct dates, and
#'  thus must have column names. All columns but "Date" must be of type numerical
#'  (integer or double), and will be written as double. The "Date" will be
#'  converted into integers, representing minutes since 2 days before the 1st of
#'  Januray of year 0001 at 00:00. Missing values are not allowed.
#'  
#'@param f 
#'  Single character string or connection to a binary file. If a
#'  character string, it should be the name of the binary file which the data are
#'  to be written from. The path of the file may be provided as well, if \code{f} is
#'  not in the working directory.
#'  
#'@param \dots 
#'  Additional options passed to \code{\link[base:readBin]{writeBin}}
#'  
#'  
#'@example inst/examples/macroWriteBin-example.r
#'
#'@rdname macroWriteBin-methods
#'
#'@export
#'
#'
macroWriteBin <- function(
 x, 
 ...
){  
    UseMethod( "macroWriteBin" )
}   



#'@rdname macroWriteBin-methods
#'
#'@method macroWriteBin macroTimeSeries
#'@export 
macroWriteBin.macroTimeSeries <- function(
 x, 
 ...
){ 
    NextMethod( "macroWriteBin" ) 
}   



#'@rdname macroWriteBin-methods
#'
#'@method macroWriteBin macroTimeSeriesList
#'@export 
macroWriteBin.macroTimeSeriesList <- function(
 x, 
 f, 
 ...
){  
    if( is.data.frame( x ) ){ 
        if( !"index" %in% colnames( x ) ){ 
            stop( "If 'x' is a 'macroTimeSeriesList', it must have a column 'index'" ) 
        }   
        
        n <- length( unique( x[, 'index' ] ) ) 
        
        if( n != length( f ) ){ 
            stop( sprintf( 
                "length(unique(x[,'index'])) and length(f) must be identical (now %s and %s)", 
                n, length( f ) 
            ) ) 
        }   
        
        x <- split( x = x, f = x[, 'index' ] ) 
        
    }else if( is.list( x ) ){ 
        n <- length( x ) 
        
        if( n != length( f ) ){ 
            stop( sprintf( 
                "length(x) and length(f) must be identical (now %s and %s)", 
                n, length( f ) 
            ) ) 
        }   
    }else{ 
        stop( "If 'x' is a 'macroTimeSeriesList', it must be a list or a data.frame"  )
    }   
    
    
    out <- lapply( 
        X   = 1:n, 
        FUN = function(i){ 
            macroWriteBin.data.frame( x = x[[ i ]], f = f[ i ], ... )
        }   
    )   
    
    
    return( invisible( out ) ) 
}   



#'@rdname macroWriteBin-methods
#'
#'@method macroWriteBin list
#'@export 
macroWriteBin.list <- function(
 x, 
 f, 
 ...
){  
    n <- length(x)
    
    if( n != length( f ) ){ 
        stop( sprintf( 
            "length(x) and length(f) must be identical (now %s and %s)", 
            n, length( f ) 
        ) ) 
    }   
    
    isMacroTimeSeries <- unlist( lapply( 
        X   = x, 
        FUN = function(X){ 
            test <- c( "macroTimeSeries", "data.frame" ) %in% 
                class( X ) 
            
            return( any( test ) )
        } 
    ) ) 
    
    if( !all( isMacroTimeSeries ) ){ 
        stop( "Some items in x are not 'macroTimeSeries'-class or 'data.frame'-class" )
    }   
    
    out <- lapply( 
        X   = 1:n, 
        FUN = function(i){ 
            macroWriteBin.data.frame( x = x[[ i ]], f = f[ i ], ... )
        }   
    )   
    
    return( invisible( out ) ) 
}   



#'@param header 
#'  If code{TRUE}, the column header is written in the bin-file.
#'
#'@param dateMethod 
#'  See help page for \code{\link[macroutils2:macroReadBin-methods]{macroReadBin}}.
#'
#'@param tz 
#'  See help page for \code{\link[macroutils2:macroReadBin-methods]{macroReadBin}}.
#'
#'@rdname macroWriteBin-methods
#'
#'@method macroWriteBin data.frame
#'@export 
macroWriteBin.data.frame <- function(
    x,
    f,
    header = TRUE, 
    dateMethod = 1L, 
    tz = "GMT", 
    ...
){  
    if( !("Date" %in% colnames(x)) ){
        stop( "The table 'x' must contain a column 'Date'" ) 
    }   
    
    if( !("POSIXct" %in% class( x[,"Date"] )) ){   
        stop( "The class of column 'Date' in 'x' must be 'POSIXct'" ) 
    }   
    
    test.na <- apply( 
        X      = x, 
        MARGIN = 1, 
        FUN    = function(X){any(is.na(X) | is.nan(X))} 
    )   
    
    if( any( test.na ) ){
        stop( paste( sum( test.na ), " rows in 'x' were found with NA or NaN values." ) )
    }   
    
    
    #   Control that the date-time series is valid
    .isValidTimeSeries <- getMuPar( "timeSeriesValid" ) 
    
    if( !is.null( .isValidTimeSeries ) ){
        .isValidTimeSeries( x[, "Date" ] ) 
    }   
    
    
    #Version 1.0
    #Writes the contest of a dataframe to a bin file
    #
    # opens binary file for writing
    # con = file(file, open="wb")    
    # 
    #get size of data
    record.number   <- nrow(x) 
    variables.number <- ncol(x) 
    PostSize        <- 4
    
    #Size of a record in bytes
    record.length <- variables.number * PostSize
    #
    if( header ){ 
        colLength <- (variables.number-1) * ( 52 + 4 + 4 ) 
    }else{ 
        colLength <- 0 
    }   #
    #
    # Write all the (empty) bin string at once:
    # - Calculate its total length 
    total.length <- 
        record.length +                       # File 'info' record
        record.number * record.length +       # Table of data 
        colLength                             # Column names (excl. date)
    #
    # - Read the file
    binData <- raw( length = total.length )
    #
    #Number of records
    rec_ant <- record.number
    #
    #Write first record containg the number of records and the size of the records
    binData[ 1:4 ] <- writeBin( 
        object = as.integer( record.number ), 
        con    = raw(), 
        size   = 4
    )   #
    #
    binData[ 5:8 ] <- writeBin( 
        object = as.integer( record.length ), 
        con    = raw(), 
        size   = 4
    )   #
    #
    #Save the data in the dataframe
    #
    if( dateMethod == 1L ){ 
        date.offsetX=-48/24
        #
        # Extract the time zone (summer / winter & time zone)
        x.tz <- format.POSIXct( x = x[1,"Date"], format = "-", usetz = T )
        x.tz <- substr( x = x.tz, start = 3, stop = nchar( x.tz ) ) 
        #
        # "Neutralize" the time zone
        x[,"Date"] <- as.POSIXct( 
            format( 
                x      = x[,"Date"], 
                format = "%Y-%m-%d %H:%M:%S", 
                tz     = x.tz 
            ),  #
            format = "%Y-%m-%d %H:%M:%S", 
            tz = tz ) 
        #
        # Set the origin date
        originDate <- as.POSIXct( 
            x      = "0001-01-01 00:00:00", 
            format = "%Y-%m-%d %H:%M:%S", 
            tz     = tz ) + date.offsetX*24*60*60
        #
        x[,"Date"] <- as.integer( 
            difftime( 
                time1 = x[,"Date"], 
                time2 = originDate, 
                units = "mins" 
            )   #
        )   #
    }else if( dateMethod == 2L ){   #
        #Create a vector to hold dates in julian format
        # data.julian <- rep( as.integer(NA), times = record.number ) 
        #Convert date in POSIXct to julian format
        data.julian <- unlist( lapply( 
            X   = 1:record.number, 
            FUN = function(X){ 
                #print (x[row.nr,1])
                da  <- as.POSIXlt(x[ X, 1 ])$mday
                mon <- as.POSIXlt(x[ X, 1 ])$mon + 1
                yea <- as.POSIXlt(x[ X, 1 ])$year + 1900
                #
                ho = 12
                mi = 0
                if( yea < 0 )
                {   #
                    yea <- yea + 1
                }   #
                if( mon > 2 )
                {   #
                    jy <- yea
                    jm <- mon + 1
                }else{
                    jy <- yea - 1
                    jm <- mon + 13
                }   #
                #
                jd <- floor(365.25 * jy) + floor(30.6001 * jm) + da + 1720995
                tl <- da + 31 * (mon + 12 * yea)
                if( tl > 588829 ) 
                {   #
                    ja <- round(0.01 * jy)
                    jd <- jd + 2 - ja + floor(0.25 * ja)
                }   #
                jd <- jd - 1721424
                jd <- jd * 24 * 60 + ho * 60 + mi
                #
                # data.julian[ row.nr ] <- jd
                return( jd ) 
            }   #
        ) ) #
    }else{
        stop( sprintf( 
            "Unkown value for argument 'dateMethod': %s. Should be 1 or 2", 
            dateMethod ) )
    }   
    #
    sel.vec <- (record.length + 1):(record.length * (record.number+1)) 
    #
    sel.colz <- colnames(x) != "Date" 
    #
    binData[ sel.vec ] <- unlist( 
        lapply( 
            X   = 1:nrow(x), # X is row.nr 
            FUN = function(X){ 
                x <- x[ X, ] 
                #
                b1 <- writeBin( 
                    con    = raw(), 
                    object = x[, "Date" ], 
                    size   = 4  
                )   #
                #
                b2 <- writeBin( 
                    con    = raw(), 
                    object = as.double( x[, sel.colz ] ), 
                    size   = 4  
                )   #
                #
                return( c(b1,b2) ) 
            }   #
        )   #
    )   #
    #
    if( header ){ 
        sel.vec2 <- (record.length * (record.number+1) + 1):(record.length * (record.number+1) + colLength)
        # 
        sel.colz2 <- colnames(x)[ sel.colz ] 
        # 
        sel.colz3 <- substr( x = sel.colz2, start = 1, stop = 52 ) 
        sel.colz3 <- sprintf( fmt = "%-52s", sel.colz3 ) 
        # 
        # cat( "length( binData[ sel.vec2 ] ): ", binData[ sel.vec2 ], "\n" ) 
        # 
        binData[ sel.vec2 ] <- unlist( 
            lapply( 
                X   = 1:length(sel.colz3), # X is row.nr 
                FUN = function(X){ 
                    nm <- writeChar( 
                        con    = raw(), 
                        object = sel.colz3[ X ], 
                        eos    = NULL 
                    )   #
                    #
                    # cat( "length(nm): ", length(nm), "\n" ) 
                    #
                    minMax <- writeBin( 
                        con    = raw(), 
                        object = as.double( range( x[, sel.colz2[ X ] ] ) ), 
                        size   = 4  
                    )   #
                    #
                    # res <- c(nm,minMax) 
                    #
                    # cat( "length(res): ", length(res), "\n" ) 
                    # 
                    return( c(nm,minMax) ) 
                }   #
            )   #
        )   #
    }   #
    #
    writeBin( 
        con    = f, 
        object = binData,
        size   = NA, 
        ... 
    )   #
}   #




# macroPlot =====================================================

#' Plot time series from SOIL or MACRO simulation data (input or output).
#'
#' Plot time series from SOIL or MACRO simulation data (input or output). When
#'  \code{x} is missing and/or \code{gui} is \code{FALSE}, the function pops-up
#'  menu asking the user which file(s) and which variable(s) to plot, and how.
#'
#'
#'@param x 
#'  A single \code{\link[base]{data.frame}}, or a
#'  \code{\link[base]{list}} of \code{data.frame} containing the data to be
#'  plotted. Each \code{data.frame} must have at least two columns: one column
#'  \code{Date} containing dates in \code{\link[base:DateTimeClasses]{POSIXct}} format (see
#'  \code{\link[base]{DateTimeClasses}}), and one or more named columns of data
#'  in some numerical formats. Such \code{data.frame} will presumably be
#'  imported from \code{bin} files, with \code{\link[macroutils2:macroReadBin-methods]{macroReadBin}}. If missing,
#'  a pop-up menu will ask you the binary files to be read and that contains the
#'  variables to be plotted.
#'
#'@param gui 
#'  Single logical. Set to \code{TRUE} if you want to choose only some
#'  of the columns in the table passed to \code{x}. Will be ignored if
#'  \code{\link[base]{interactive}} is \code{FALSE} (i.e.  if ran outside R GUI
#'  for Windows).
#'
#'@param z 
#'  Vector of character strings. Name of the variables to include 
#'  in the graph. If \code{NULL}, all variables in 'x' are included, 
#'  and if \code{gui} is \code{TRUE}, the user is asked with variable 
#'  should be included.
#'
#'@param subPlots 
#'  Single logical. If \code{TRUE} (default), all the variables
#'  in \code{x} will be plotted in separated sub-plots, with sub-plots on top of
#'  each others. If \code{FALSE}, all the variables in \code{x} will be plotted
#'  in the same plot, on top of each other, with the same Y axis. If \code{gui}
#'  is \code{TRUE}, \code{subPlots} is ignored, and a menu will ask you what to
#'  do.
#'
#'@param verbose 
#'  Single logical. If \code{TRUE}, some text message will be
#'  displayed on the console to explain what is going on.
#'
#'@param xlab 
#'  See \code{\link[graphics]{plot.default}}. A single character
#'  string.  Label of the 'x' axis.
#'
#'@param ylab 
#'  See \code{\link[graphics]{plot.default}}. A vector of character
#'  strings of length one or of the same length as the variables in (or chosen
#'  from) \code{x}.
#'
#'@param ylim 
#'  See \code{\link[graphics]{plot.default}}.
#'
#'@param xlim 
#'  See \code{\link[graphics]{plot.default}}.
#'
#'@param col 
#'  See \code{\link[graphics]{plot.default}} or
#'  \code{\link[graphics]{lines}}. Vector of character strings, line colors.
#'
#'@param sub 
#'  See \code{\link[graphics]{plot}} or \code{\link[graphics]{title}}.
#'  Vector of character strings, sub-titles of each plot.
#'
#'@param lwd 
#'  See \code{\link[graphics]{plot.default}} or
#'  \code{\link[graphics]{lines}}. Vector of integers, line widths (thicknesses).
#'
#'@param lty 
#'  See \code{\link[graphics]{plot.default}}. a vector of line types.
#'
#'@param main 
#'  See \code{\link[graphics]{plot.default}}. Plot title(s).
#'
#'@param cex.main 
#'  See \code{\link[graphics]{par}}. Title(s) expansion factor.
#'
#'@param panel.first 
#'  See \code{\link[graphics]{plot.default}}.
#'
#'@param dLegend 
#'  Single logical value. If \code{TRUE} and \code{subPlots=FALSE}
#'  and more than one variable is plotted, a legend is drawn above the plot (with
#'  distinct colors for each variables).
#'
#'@param las 
#'  See \code{\link[graphics]{par}}.
#'
#'@param bty 
#'  See \code{\link[graphics]{par}}.
#'
#'@param \dots 
#'  Additional arguments passed to \code{\link[graphics]{plot}} and
#'  to \code{\link[graphics]{lines}} (when \code{subPlots} is \code{FALSE}).  See
#'  also \code{\link[graphics]{plot.default}}.
#'
#'@return 
#'  Invisibly returns 'x', or the content of the files selected.
#'
#'
#'@example inst/examples/macroPlot-example.r
#'
#'@rdname macroPlot-methods
#'
#'@export
#'
#'
macroPlot <- function(
 x, 
 ...
){  
    if( missing( x ) & interactive() ){ 
        UseMethod( "macroPlot", object = data.frame() ) 
    }else{ 
        UseMethod( "macroPlot" ) 
    }   
}   



#'@rdname macroPlot-methods
#'
#'@method macroPlot macroTimeSeries
#'@export 
macroPlot.macroTimeSeries <- function(
 x, 
 ... 
){ 
    macroPlot.default( x = x, ... ) 
}   



#'@rdname macroPlot-methods
#'
#'@method macroPlot macroTimeSeriesList
#'@export 
macroPlot.macroTimeSeriesList <- function(
 x, 
 ... 
){ 
    macroPlot.default( x = x, ... ) 
}   



#'@rdname macroPlot-methods
#'
#'@method macroPlot data.frame
#'@export 
macroPlot.data.frame <- function(
 x, 
 ...
){ 
    macroPlot.default( x = x, ... ) 
}   


#'@importFrom grDevices gray
#'@importFrom graphics par
#'@importFrom graphics rect
#'@importFrom graphics axis.POSIXct
#'@importFrom graphics axTicks
#'@importFrom graphics abline
#'@importFrom graphics axis
NULL 

.paf <- function( 
 bg        = gray( .95 ), 
 col       = "white", 
 col0      = gray( .80 ), 
 col.ticks = gray( .50 ), 
 border    = NA, 
 axes      = TRUE, 
 ... 
){  
    #   Fetch plot boundaries
    usr <- graphics::par( "usr" ) 
    
    
    #   Background color
    graphics::rect( xleft = usr[1], ybottom = usr[3], xright = usr[2], 
        ytop = usr[4], col = bg, border = border, ... ) 
    
    
    #   Compute grid positions (x-axis being a POSIXct time)
    usrPOSIXct <- as.POSIXct( usr[1:2], origin = "1970-01-01 00:00:00", 
        tz = "GMT" ) 
    
    
    #   At-points for big and small ticks
    xAt  <- graphics::axis.POSIXct( side = 1, x = usrPOSIXct, labels = FALSE, 
        col = NA ) 
    if( length( xAt ) == 1 ){ 
        dxAt <- max( diff( c( usrPOSIXct[1], xAt, usrPOSIXct[2] ) ) )/2 
    }else{ 
        dxAt <- max( diff(xAt) )/2 
    }   
    xAt2 <- c( xAt[1] - dxAt, xAt + dxAt ); rm( dxAt ) 
    
    yAt  <- graphics::axTicks( side = 2 ) 
    
    if( length( yAt ) == 1 ){ 
        dyAt <- max( diff( c( usr[3], yAt, usr[4] ) ) )/2 
    }else{ 
        dyAt <- max( diff(yAt) )/2 
    }   
    yAt2 <- c( yAt[1] - dyAt, yAt + dyAt ); rm( dyAt ) 
    
    
    #   Get the "official" line width
    lwd <- graphics::par( "lwd" ) 
    
    
    #   Plot the grid
    graphics::abline( h = yAt,  col = col, lwd = lwd )
    graphics::abline( h = yAt2, col = col, lwd = lwd/2 )
    graphics::abline( v = xAt,  col = col, lwd = lwd )
    graphics::abline( v = xAt2, col = col, lwd = lwd/2 )
    
    #   Special line for the Y0
    if( usr[3] <= 0 & usr[4] >= 0 ){ 
        graphics::abline( h = 0,  col = col0, lwd = lwd ) 
    }   
    
    if( axes ){ 
        #   Y and right axes 
        for( i in c(2,4) ){ 
            
            
            graphics::axis( side = i, labels = ifelse( i == 2, TRUE, FALSE ), 
                lwd = 0, lwd.ticks = lwd, col.ticks = col.ticks ) 
            
            graphics::axis( side = i, at = yAt2, 
                labels = FALSE, tcl = -.25, lwd = 0, 
                lwd.ticks = lwd/2, col.ticks = col.ticks )
        }   
        
        #   X and top axes
        for( i in c(1,3) ){             
            
            
            #   X axis labels
            if( i == 1 ){ 
               graphics::axis.POSIXct( side = i, x = usrPOSIXct, at = xAt, 
                    labels = TRUE, col = NA ) 
            }   
            
            graphics::axis( side = i, at = xAt, labels = FALSE, lwd = 0, 
                lwd.ticks = lwd, col.ticks = col.ticks ) 
            
            graphics::axis( side = i, at = xAt2, labels = FALSE, tcl = -.25, 
                lwd = 0, lwd.ticks = lwd/2, col.ticks = col.ticks )
        }   
    }   
}   

    # x <- as.POSIXct( as.Date( 0:10, origin = "1999-01-01" ) )
    # y <- rnorm( length( y ) ) 

    # # par( "las" = 1 )
    # plot( x = x, y = y, axes = FALSE, panel.first = .paf(), 
        # las = 1 ) 



#'@rdname macroPlot-methods
#'
#'@method macroPlot default
#'@export 
#'
#'@importFrom utils flush.console
#'@importFrom graphics locator
#'@importFrom graphics abline
#'@importFrom graphics par 
#'@importFrom graphics layout 
#'@importFrom graphics plot 
#'@importFrom graphics rect 
#'@importFrom graphics legend 
#'@importFrom graphics lines  
#'@importFrom grDevices hcl
#'@importFrom grDevices gray 
macroPlot.default <- function(
    x, 
    gui         = TRUE, 
    z           = NULL, 
    subPlots    = TRUE, 
    verbose     = TRUE, 
    xlab        = "Date", 
    ylab        = NULL, 
    ylim        = NULL, 
    xlim        = NULL, 
    col         = NULL,  
    sub         = NULL, 
    lwd         = 2L, 
    lty         = NULL, 
    main        = NULL, 
    cex.main    = NULL, 
    panel.first = .paf(), 
    dLegend     = TRUE, 
    las         = 1L, 
    bty         = "n", 
    ...
){  
    panel.first <- substitute( panel.first )
    
    xDep <- deparse( substitute( x ) ) 
    
    ## Check that the class of x is (a list of) data.frame
    if( missing( x ) ){     # ifelse( is.data.frame( x ), nrow(x) == 0, FALSE )
        if( interactive() ){ 
            # Pop-up a menu to choose the bin file to be 
            #   imported
            if( verbose ){ message( 
                "'x' is missing. You will be asked which binary files you want to plot (pop-up menu)\n" 
            ) }    
            
            file <- .chooseBinFiles(
                caption = "Select one or several binary file(s) to plot", 
                multi   = TRUE  
            )   
            
            if( length(file) == 0 ){ 
                stop( "You haven't chosen any binary file to read :o(" )
            }   
            
            file <- sort( file ) 
            
            if( verbose ){ message( 
                sprintf( "Now importing files: %s\n", paste( file, collapse = ", " ) )    
            ) }    
            
            # Import the files
            x <- macroReadBin( file = file ) 
            
            if( length( file ) == 1 ){ 
                x <- list( x ) 
                
                attr( x = x, which = "file" ) <- .pathLastItem( p = file, noExt = TRUE ) 
                
                names( x ) <- .pathLastItem( p = file, noExt = TRUE ) 
            }   
            
            # if( length( file ) > 1 ){ 
                # tmp <- attr( x = x, which = "file" ) 
                
                # x <- split( x = x, f = x[, "index" ] ) 
                
                # attr( x = x, which = "file" ) <- tmp; rm( tmp )
            # }   
            
            # names( x ) <- .pathLastItem( p = file ) 
            
            test.class <- TRUE 
        }else{ 
            stop( "'x' can not be missing when R running in a non-interactive mode" )
        }   
    }else if( is.data.frame( x ) ){ 
        
        # test.class <- any( c("data.frame","macroTimeSeries","macroTimeSeriesList") %in% class( x ) ) 
        
        if( ("index" %in% colnames( x )) & is.null( attr( x = x, which = "file" ) ) ){ 
            tmp <- sprintf( "index(%s)", unique( x[, "index" ] ) )
            
            x <- split( x = x, f = x[, "index" ] ) 
            
            attr( x = x, which = "file" ) <- tmp; rm( tmp )
        }else{ 
            if( is.null( attr( x = x, which = "file" ) ) ){ 
                attr( x = x, which = "file" ) <- xDep
            }   
            
            tmp <- attr( x = x, which = "file" )
            x   <- list( x ) 
            attr( x = x, which = "file" ) <- tmp; rm( tmp )
        }   
        
        test.class <- TRUE 
        
    }else if( ("macroTimeSeriesList" %in% class( x )) | is.list( x ) ){ 
        
        if( is.list( x ) ){ 
            test.class <- unlist( lapply( 
                X   = x, 
                FUN = function(X){ 
                    return( "data.frame" %in% class( X ) ) 
                }   
            ) ) 
            
            if( is.null( attr( x = x, which = "file" ) ) ){ 
                if( !is.null( names( x ) ) ){ 
                    attr( x = x, which = "file" ) <- names( x ) 
                    
                }else{ 
                    attr( x = x, which = "file" ) <- 
                        sprintf( "item(%s)", 1:length(x) )
                    
                }   
            }   
            
            # if( all( test.class ) ){
                # x <- do.call( what = "rbind", args = x )
            # }   
            
            # if( !"index" %in% colnames( x ) ){ 
                # stop( "If 'x' is a 'macroTimeSeriesList' and list its data.frame must contain a column 'index'" )
            # }   
            
        }else if( is.data.frame( x ) ){ 
            test.class <- TRUE 
            
            if( "index" %in% colnames( x ) ){ 
                tmp <- sprintf( "index(%s)", unique( x[, "index" ] ) )
                
                x <- split( x = x, f = x[, "index" ] ) 
                
                attr( x = x, which = "file" ) <- tmp; rm( tmp )
            }else{ 
                if( is.null( attr( x = x, which = "file" ) ) ){ 
                    attr( x = x, which = "file" ) <- xDep
                }   
            }   
            
            # if( !"index" %in% colnames( x ) ){ 
                # stop( "If 'x' is a 'macroTimeSeriesList' and data.frame it must contain a column 'index'" )
            # }   
            
        }else{ 
            test.class <- FALSE 
        }   
        
    }else{ 
        test.class <- FALSE 
    }   
    
    if( any( !test.class ) ){ 
        stop( "'x' must be a (list of) data.frame" ) 
    }   
    
    
    file <- attr( x = x, which = "file" ) 
    if( is.null( file ) ){ 
        warning( "'x' is missing an attribute 'file'. Something went wrong" )
        
        file <- sprintf( "item(%s)", 1:length(x) )
    }   
    
    
    ## List column names:
    Y.name <- lapply( 
        X   = x, 
        FUN = function(X){ 
            colnames(X) 
        }   #
    )   #
    
    
    ## Check that there is a Date format
    test.Date <- unlist( lapply( 
        X   = Y.name, 
        FUN = function(X){ 
            ("Date" %in% X) & (length(X) >= 2)
        }   
    ) ) 
    
    if( any( !test.Date ) ){
         stop( "data.frame(s) in 'x' must have a 'Date' column and at least another column" ) 
    }   
    
    Y.name <- lapply( 
        X   = Y.name, 
        FUN = function(X){ 
            X[ X != "Date" ] 
        }   
    )   
    
    
    if( !is.null( z ) ){ 
        if( "Date" %in% z ){ 
            warning( "'z' should not include 'Date'" ) 
            
            z <- z[ z != "Date" ] 
        }   
        
        Y.name <- lapply( 
            X   = Y.name, 
            FUN = function(X){ 
                testZ <- z %in% X 
                
                if( !all( testZ ) ){ 
                    stop( sprintf( 
                        "Some columns in 'z' are missing in 'x': %s", 
                        paste( z[ !testZ ], collapse = "; " )
                    ) ) 
                }   
                
                return( z ) 
            }   
        )   
    }   
    
    
    
    # +---------------------------------------------------------+
    # | Loop over the main menu                                 |
    # +---------------------------------------------------------+
    loopCount <- 1L 
    zoomSet   <- FALSE 
    n         <- 1L 
    
    repeat{ 
        
        # +---------------------------+
        # | Main menu                 |
        # +---------------------------+
        if( (loopCount > 1) & gui & interactive() ){ 
            mainMenuItem <- c( 
                "1" = "Change the variable(s)", 
                "2" = "Change the type of plot",  
                "3" = "Zoom in", 
                "4" = "Reset the zoom",  
                "5" = "Exit the function" 
            )   
            
            if( !zoomSet ){ mainMenuItem <- 
                mainMenuItem[ names(mainMenuItem) != "4" ] } 
            if( n == 1L ){  mainMenuItem <- 
                mainMenuItem[ names(mainMenuItem) != "2" ] } 
            
            mainMenu <- .macroMenu(
                choices  = mainMenuItem,  
                graphics = FALSE, 
                title    = "Main plot menu. Do you want to:", 
                error    = "You have not chosen any action!", 
                multi    = TRUE 
            )   
            
            mainMenu <- mainMenuItem[ mainMenu ] 
            mainMenu <- as.integer( names( mainMenu ) ) 
            
            
            ## Reset the loop count if the variables are changed:
            loopCount <- ifelse( mainMenu == 1L, 1L, loopCount ) 
            
            ## Reset the zoom "indicator"
            zoomSet   <- ifelse( mainMenu == 1L, FALSE, zoomSet ) 
        }else{ 
            mainMenu <- 0L 
        }   
        
        
        
        # +---------------------------+ 
        # | Case: exit                | 
        # +---------------------------+ 
        
        if( mainMenu == 5L ){ 
            message( "Plot operations finished (interrupted by the user)" ) 
            
            break 
        }   
        
        
        
        # +---------------------------+
        # | Choose the variables      |
        # +---------------------------+
        if( gui & interactive() & ((loopCount == 1L) | mainMenu == 1L) ){ 
            # if( verbose ){ message( 
            #     "'gui' is TRUE. You will be asked which variable you want to plot, and how you want to plot them (pop-up menu)\n" 
            # ) } 
            
            Y.name0 <- lapply( 
                X   = 1:length(Y.name), 
                FUN = function(X){ 
                    Y.name <- Y.name[[ X ]] 
                    
                    mRes <- .macroMenu(
                        choices  = Y.name, 
                        graphics = FALSE, 
                        title    = sprintf( 
                            "Choose one or several variables to plot from table %s", 
                            file[ X ] ), 
                        error    = sprintf( 
                            "You have not chosen any variables from table %s", 
                            X ), 
                        multi    = TRUE 
                    )   
                    
                    return( Y.name[ mRes ] )  
                }   
            )   
            
            
            # How many variables?
            n <- unlist( lapply( 
                X   = Y.name0, 
                FUN = function(X){ 
                    length( X ) 
                }   
            ) ) 
            n <- sum(n)
            
            if( verbose ){ message( 
                sprintf( "You have chosen %s variables\n", n ) 
            ) } 
        
        }else if( gui & !interactive() ){ 
            stop( "'gui' can not be TRUE when R is not running in interactive mode" )
        }else if( !gui ){ 
            Y.name0 <- Y.name 
            
            # How many variables?
            n <- unlist( lapply( 
                X   = Y.name0, 
                FUN = function(X){ 
                    length( X ) 
                }   
            ) ) 
            n <- sum(n)
        }   
        
        
        # +---------------------------+ 
        # | Zoom & xlim               | 
        # +---------------------------+ 
        
        ## Case 1: zoom
        if( gui & interactive() & (loopCount != 1L) & (mainMenu == 3L) ){ 
            
            message( "Zoom selection. NOTE: USE THE LAST PLOT (MOST BOTTOM RIGHT)" ) 
            
            
            message( "Select date-time boundary 1 (lower or higher), on the plot area" ) 
            
            utils::flush.console() 
            
            ## Select date boundary 1:
            l1 <- l1a <- graphics::locator( n = 1, type = "n" )$"x" 
            
            ## Convert it to a Date (was integer)
            l1 <- as.POSIXct( l1, origin = "1970-01-01 00:00:00", tz = "GMT" ) 
            l1 <- format.POSIXct( l1, tz = getMuPar( "tz" ) ) 
            l1 <- as.POSIXct( l1, , tz = getMuPar( "tz" ) ) 
            
            ## Display a line at that date-time
            abline( v = l1a, col = "pink" ) 
            
            
            message( "Select date-time boundary 2 (lower or higher), on the plot area" ) 
            
            utils::flush.console() 
            
            ## Select date boundary 1:
            l2 <- graphics::locator( n = 1, type = "n" )$"x" 
            
            ## Convert it to a Date (was integer)
            l2 <- as.POSIXct( l2, origin = "1970-01-01 00:00:00", tz = "GMT" ) 
            l2 <- format.POSIXct( l2, tz = getMuPar( "tz" ) ) 
            l2 <- as.POSIXct( l2, , tz = getMuPar( "tz" ) ) 
            
            ## Display a line at that date-time
            graphics::abline( v = l2, col = "pink" ) 
            
            
            ## Convert that into ylim 
            xlim0 <- c( l1, l2 ) 
            xlim0 <- c( min(xlim0), max(xlim0) ) 
            
            message( sprintf( "Date-time range chosen: %s to %s\n", xlim0[1], xlim0[2] ) ) 
            
            
            ## Set the zoom indicator
            zoomSet <- TRUE 
        
        ## Case 2: set or re-set the zoom
        }else if( (loopCount == 1L) | (mainMenu == 4L) | !gui ){ 
            if( is.null( xlim ) ){ 
                xlim0 <- lapply( 
                    X   = 1:length(Y.name0), 
                    FUN = function(X){ 
                        ## Select the table:
                        x <- x[[ X ]]
                        
                        ## Select the columns:
                        x <- x[, "Date" ] 
                        
                        x <- data.frame( "min" = min( x ), "max" = max( x ) ) 
                        
                        ## Get the max value
                        return( x ) 
                    }   
                )   
                
                xlim0 <- do.call( what = "rbind", args = xlim0 )
                
                xlim0 <- c( min( xlim0[,"min"] ), max( xlim0[,"max"] ) ) 
            }else{ 
                xlim0 <- xlim 
            }   
        }   
        
        
        # +---------------------------+ 
        # | Single plot or multiple   | 
        # | sub-plots                 | 
        # +---------------------------+ 
        
        ## subPlots variables in sub-plots?
        if( gui & interactive() & ((loopCount == 1L) | mainMenu == 2L) ){
            if( n > 1 ){ 
                mRes <- .macroMenu(
                    title    = sprintf( "Should all %s variables be plotted:", n ), 
                    choices  = c( "In a single plot", "In stacked sub-plots"), 
                    graphics = FALSE, 
                    error    = "You have not chosen how the variables should de plotted :o(", 
                    multi    = FALSE 
                )   
                
                if( verbose & (mRes == 1) ){ message( 
                    "You have chosen a single plot. You can use 'subPlots = FALSE' to do that when 'gui = FALSE'\n"  
                ) } 
                
                if( verbose & (mRes == 2) ){ message( 
                    "You have chosen sub-plots. You can use 'subPlots = TRUE' to do that when 'gui = FALSE'\n"  
                ) } 
                
                subPlots <- ifelse( mRes == 1, FALSE, TRUE )
            }else{ 
                subPlots <- TRUE 
            }   
        }   
        
        
        
        # +---------------------------+ 
        # | Settings                  | 
        # +---------------------------+ 
        
        # +---------------------------+ 
        # | ylab: Y-axis labels
        if( is.null(ylab) ){  
            ylab0 <- unlist( lapply( 
                X   = 1:length(Y.name0), 
                FUN = function(X){  
                    # paste( nm.x[ X ], Y.name0[[ X ]], sep = ":" ) 
                    return( Y.name0[[ X ]] )
                }   
            ) ) 
            
        }else if( (length(ylab) != 1) & (length(ylab) != n) ){ 
            if( !subPlots ){ 
                stop( "When 'subPlots' is 'FALSE' 'ylab' must be 'NULL' or length 1" ) 
            }   
            
            stop( "'ylab' must be 'NULL', or length 1, or the same length as the variables (chosen) in 'x'" ) 
        }else{ 
            ylab0 <- ylab 
        }   
        
        if( length( ylab0 ) == 1 ){ ylab0 <- rep(ylab0,n) } 
        
        
        # # +---------------------------+ 
        # # | panel.first & grid() 
        # if( is.null(panel.first) ){ 
            # panel.first <- call( "grid" ) 
        # }   
        
        
        # +---------------------------+ 
        # | col: line colors
        if( is.null( col ) ){ 
            col0 <- grDevices::hcl( 
                h = seq( from = 15, to = 360+15, length.out = n+1 ), 
                c = 100, 
                l = 50 )[ -(n+1) ] 
            
        }else{ 
            col0 <- col 
        }   
        
        if( length( col0 ) == 1 ){ col0 <- rep(col0,n) } 
        
        
        # +---------------------------+ 
        # | lwd: line(s) width(s)
        if( length( lwd ) == 1 ){ 
            lwd0 <- rep( lwd, n ) 
            oldParLwd <- graphics::par( "lwd" = lwd )$"lwd" 
        }else{ 
            lwd0 <- lwd 
        }   
        
        
        # +---------------------------+ 
        # | lwd: line(s) type(s)
        if( is.null( lty ) & !subPlots ){ 
            lty0 <- rep( 1:4, length.out = n ) 
        }else{ 
            lty0 <- lty 
        }   
        
        
        # +---------------------------+ 
        # | sub: subtitles
        fileNames <- unlist( lapply( 
            X   = 1:length(file), 
            FUN = function(X){ 
                rep( file[ X ], length( Y.name0[[ X ]] ) ) 
            }   
        ) ) 
        
        if( is.null( sub ) & subPlots ){ 
            sub0 <- paste0( "File: ", fileNames ) 
        }else{ 
            sub0 <- sub 
        }   
        
        if( length( sub0 ) == 1 ){ sub0 <- rep( sub0, n ) } 
        
        
        # +---------------------------+ 
        # | main: main title
        if( is.null( main ) & subPlots ){ 
            main0 <- ylab0 
        }else{ 
            main0 <- main 
        }   
        
        if( length( main0 ) == 1 ){ main0 <- rep(main0,n) } 
        
        
        # +---------------------------+ 
        # | cex.main: main title 'expansion'
        if( is.null( cex.main ) & subPlots ){ 
            cex.main0 <- 0.8 
        }else{ 
            cex.main0 <- cex.main 
        }   
        
        if( length( lty0 ) == 1 ){ lty0 <- rep(lty0,n) } 
        
        
        # +---------------------------+ 
        # | Plot layout (and ylim)    |
        # +---------------------------+ 
        
        #   Set axis label style
        oldParLas <- graphics::par( "las" = las )$"las"
        
        ## If more than one variable, create sub-plots
        if( (n > 1) & (!subPlots) ){ 
            
            # +---------------------------+ 
            # | Plot layout (no subplots) 
            mx <- ifelse( dLegend, 2L, 1L ) 
            
            mat <- matrix( 
                data = 1:mx, 
                nrow = mx, 
                ncol = 1 )
            
            graphics::layout( mat = mat, heights = c(1,2)[ 1:mx ] ) 
            
            if( n > 1 ){ 
                ylab2 <- "(see legend)" # expression( italic( "(see the legend)" ) ) 
            }else{ 
                ylab2 <- ylab0 
            }   
            
            # +---------------------------+ 
            # | ylim: variable range        
            if( is.null( ylim ) ){ 
                ylim0 <- range( unlist( lapply( 
                    X   = 1:length(Y.name0), 
                    FUN = function(X){ 
                        ## Select the table:
                        x <- x[[ X ]]
                        
                        ## Select the columns:
                        x <- x[, Y.name0[[ X ]] ] 
                        
                        ## Get the max value
                        return( range(x) ) 
                    }   
                ) ) ) 
            }else{ 
                ylim0 <- ylim 
            }   
            
            
            # +---------------------------+ 
            # | Add a legend              |
            # +---------------------------+ 
            
            # oldParMar <- par( c("mar","bg") ) 
            if( dLegend ){ 
                oldParMar <- graphics::par( "mar" = c(0,0,0,0) )$"mar" 
                # par( "bg" = grDevices::gray( .9 ) ) 
                
                graphics::plot( x = 1, y = 1, xlab = "", ylab = "", bty = "n", 
                    xaxt = "n", yaxt = "n", type = "n" ) 
                
                # Draw a gray background rectangle:
                usr <- graphics::par( "usr" ) 
                graphics::rect(
                    xleft   = usr[1], 
                    ybottom = usr[3], 
                    xright  = usr[2], 
                    ytop    = usr[4], 
                    col     = NA, 
                    border  = grDevices::gray( .5 ) 
                )   
                
                ## Add the general legend:
                graphics::legend( 
                    x       = "center", 
                    title   = "File(s) and Variable(s):", 
                    legend  = paste0( fileNames, ", ", ylab0 ), 
                    lwd     = lwd0, 
                    col     = col0, 
                    lty     = lty0, 
                    bty     = "n"
                )   
                
                graphics::par( "mar" = oldParMar ) 
            }   
            
            # +---------------------------+ 
            # | Empty plot on which lines 
            # | will be plotted
            
            graphics::plot( 
                x           = xlim0, 
                y           = ylim0, 
                xlab        = xlab, 
                ylab        = ylab2, 
                xlim        = xlim0, 
                type        = "n", 
                sub         = sub0, 
                panel.first = eval( panel.first ), 
                #las         = las, 
                bty         = bty, 
                axes        = FALSE, 
                ... 
            )   
        }else{ 
            
            # +---------------------------+ 
            # | Plot layout (with subplots) 
            if( n > 2 ){ 
                #n <- 3 
                nrowz <- ceiling( sqrt( n ) ) 
                ncolz <- ceiling( n / nrowz ) 
                #nrowz; ncolz 
                
                mat <- matrix( 
                    data = 1:(nrowz*ncolz), 
                    nrow = nrowz, 
                    ncol = ncolz ) 
            }else{ 
                mat <- matrix( 
                    data = 1:n, 
                    nrow = n, 
                    ncol = 1 ) 
            }   
            
            # if( n != 1 ){ layout( mat = mat ) } 
            graphics::layout( mat = mat ) 
        }   
        
        
        # +---------------------------+ 
        # | Generate the plot         |
        # +---------------------------+ 
        
        # +---------------------------+ 
        # | Plot variables: table by table 
        plotCount <- 0 
        
        for( subTbl in 1:length(Y.name0) ){ 
            subTbl.name <- Y.name0[[ subTbl ]] 
            
            # +---------------------------+ 
            # | Plot variables: variables by variables 
            # | in a given table
            for( varNb in 1:length(subTbl.name) ){ 
                plotCount <- plotCount + 1 
                
                plotVar <- subTbl.name[ varNb ] 
                
                if( subPlots ){ 
                    graphics::plot( 
                        x           = x[[ subTbl ]][, "Date" ], 
                        y           = x[[ subTbl ]][, plotVar ], 
                        xlab        = xlab, 
                        ylab        = "(see title)", # expression( italic( "(see the title)" ) ), 
                        type        = "l", 
                        xlim        = xlim0, 
                        col         = col0[ plotCount ], 
                        main        = main0[ plotCount ], 
                        cex.main    = cex.main0, 
                        sub         = sub0[ plotCount ], 
                        lwd         = lwd0[ plotCount ], 
                        lty         = lty0[ plotCount ], 
                        panel.first = eval( panel.first ), 
                        #las         = las, 
                        bty         = bty, 
                        axes        = FALSE, 
                        ... 
                    )   
                }else{ 
                    graphics::lines( 
                        x    = x[[ subTbl ]][, "Date" ], 
                        y    = x[[ subTbl ]][, plotVar ], 
                        col  = col0[ plotCount ], 
                        lwd  = lwd0[ plotCount ], 
                        lty  = lty0[ plotCount ], 
                        ...  
                    )  
                }   
            }   
        }   
        
        
        # +---------------------------+ 
        # | Case: exit (no gui case)  | 
        # +---------------------------+ 
        
        if( !gui ){ 
            break 
        }else{ 
            message( "Plot created\n" )
        }   
        
        
        ## Increment the loop counter
        loopCount <- loopCount + 1L 
        
    }   ## End of the repeat loop over menus
    
    
    #   Reset par(lwd,las)
    graphics::par( "lwd" = oldParLwd, "las" = oldParLas )
    
    
    return( invisible( x ) ) 
}   




# ==================== macroAggregateBin ====================

#' Aggregate simulation results by some date subsets, using various functions
#'
#' Aggregate simulation results by some date subsets, using various functions.
#'  macroAggregateBin can be used on a data.frame containing simulation results (or
#'  weather data or any time series data) to compute some aggregation function
#'  (FUN = sum, mean, median, ...) over subsets of dates (aggregate by day, week,
#'  month, ...).
#'
#'
#'@param x 
#'  A data.frame, with a date column named after 'dateCol' (default
#'  "Date") and one or several variables to be aggregated on a certain time
#'  interval (defined in 'by'). The column 'dateCol' must be in POSIXct format.
#'  
#'@param columns 
#'  A vector of character strings. Name of the columns to be
#'  selected and aggregated. 'dateCol' does not need to be specified here, but
#'  can be included.
#'  
#'@param by 
#'  A character string representing a POSIXct format (see
#'  ?format.POSIXct). "\%Y-\%m-\%d" (the default) will aggregate the data by days
#'  and "\%Y-\%m-\%d \%H", "\%Y-\%W", "\%Y-\%m" will aggregate the data by hour,
#'  week of the year or month, respectively. Other combinations are possible.
#'  
#'@param FUN 
#'  A function to be applied to aggregate the data on each element of
#'  'by'. Can be 'sum', 'mean', 'median', etc. For removing missing values,
#'  choose something like 'function(x)sum(x,na.rm=TRUE)'.  Another possibility
#'  would be 'function(x)quantile(x,probs=.75)'.  The same function is applied
#'  for all columns, so consider applying different macroAggregateBin() on different
#'  data types if needed.
#'
#'@param dateCol 
#'  Name of the column containing the POSIXct date values. Default
#'  is 'Date'.
#'  
#'  
#'@return 
#'  Returns a data.frame with the values in columns aggregated by 'by'
#'  with the function 'FUN'. Notice that the format of 'dateCol' is then
#'  "character", and not any more POSIXct (because no uniform date format are
#'  possible for exporting back the dates).
#'  
#'  
#'@example inst/examples/macroAggregateBin-example.r
#'
#'
#'@export
#'
#'
#'@importFrom stats aggregate
macroAggregateBin <- function(
    x, 
    columns = colnames(x), 
    by      = "%Y-%m-%d", 
    FUN     = sum, 
    dateCol = "Date" 
){  #
    if( !dateCol %in% columns ){ columns <- c(dateCol,columns) } 
    #
    testColumns <- columns %in% colnames( x ) 
    #
    if( any( !testColumns ) )
    {   #
        stop( paste( 
            sep = "", 
            "Some column(s) was/were not found in x:", 
            paste( columns[ !testColumns ], collapse = ", " ), 
            "." 
        ) ) #
    }   #
    #
    x <- x[, columns ] 
    columns2 <- colnames(x) != dateCol 
    columns2 <- columns[ columns2 ] 
    x <- x[, c(dateCol,columns2) ] 
    #
    if( !("POSIXct" %in% class( x[,dateCol] ) ) ){ stop("'dateCol' must be of class POSIXct") } 
    #
    byIndex  <- format.POSIXct( x = x[,dateCol], format = by ) 
    # byIndex2 <- as.integer( as.factor( byIndex ) ) 
    #
    FUN2 <- FUN; rm( FUN ) 
    
    
    x <- stats::aggregate( 
        x        = x[, -1, drop = FALSE ], 
        by       = list( "Date" = byIndex ), 
        FUN      = FUN2, 
        simplify = TRUE 
    )   #
    #
    colnames( x )[ -1 ] <- columns2 
    #
    # x <- data.frame( 
    #     "Date" = unique( byIndex ), 
    #     x, 
    #     stringsAsFactors = FALSE 
    # )   #
    #
    colnames(x)[1] <- dateCol 
    #
    x <- x[, columns ] 
    #
    return( x ) 
}   




# ==================== macroStripRunID ====================

## # Remove the Run ID from the column names of a MACRO simulation 
## #    result.
## #
## # Remove the Run ID from the column names of a MACRO simulation 
## #    result.
## #
## #
## #@param x
## #    A vector of character strings. Column names of a MACRO input 
## #    result table.
## # 
## #@param splitChar 
## #    Single character string. Character that separates the different 
## #    parts of the columns names.
## #    
## # 
## #@return
## #    Returns a data.frame, with 'clean' column names.
## #
## #
macroStripRunID <- function(
    x, 
    splitChar = "_"
){  
    split.colz <- strsplit( 
        x     = x, 
        split = splitChar, 
        fixed = TRUE  
    )   #
    
    # Remove the RUNID from columns names
    split.colz <- lapply( 
        X   = split.colz, 
        FUN = function(X){ 
            l <- length( X ) 
            
            if( l > 1 ){ 
                # Extract the last item
                last <- suppressWarnings( as.integer( X[ l ] ) ) 
                
                # Extract the 2nd last item
                secondLast <- suppressWarnings( as.integer( X[ l-1 ] ) ) 
                
                # Set the ID to ""
                if( !is.na( last ) ){ 
                    if( !is.na( secondLast ) ){ 
                        
                        # ID is 2nd last
                        X[ l-1 ] <- "" 
                    }else{ 
                        
                        # ID is last
                        X[ l ] <- ""
                    }   
                }   
            }   
            
            return( X )
        }   
    )   
         
    x <- unlist( lapply( 
            X   = split.colz, 
            FUN = function(X){ 
                paste( 
                    X[ X != "" ], 
                    collapse = splitChar 
                )   
            }   
    )   )   
    
    return( x ) 
}   #




# ==================== macroConvertBin ====================

#' Converts MACRO/SOIL binary files into CSV or TXT text files
#'
#' Converts MACRO/SOIL binary files into CSV or TXT text files. 
#'  The function is a wrapper around \code{\link[macroutils2:macroReadBin-methods]{macroReadBin}} 
#'  and \code{\link[utils]{write.table}}. It is possible to choose 
#'  the field delimiter and the decimal mark.
#'
#'
#'@param f 
#'  Vector of character strings or a single \code{\link{connection}}
#'  to a binary file. If a vector character strings, it should be the name(s) of
#'  the binary file(s) which the data are to be read from. The path of the
#'  file(s) may be provided as well, if the file(s) is (are) not in the working
#'  directory.
#'  
#'@param gui 
#'  Single logical. Set to \code{TRUE} if you want to choose only some
#'  of the columns in the table passed to \code{x}. Will be ignored if
#'  \code{\link[base]{interactive}} is \code{FALSE} (i.e.  if ran outside R GUI
#'  for Windows).
#'  
#'@param sep 
#'  Single character. Columns / field separator. Ignored if
#'  \code{gui=TRUE}. Choose \code{','} for comma, \code{';'} for semi-colon,
#'  \code{'\t'} for tabulation and \code{' '} for space.
#'  
#'@param dec 
#'  Single character. Decimal mark. Ignored if \code{gui=TRUE}.
#'  
#'@param fileOut 
#'  Vector of character strings or a single
#'  \code{\link{connection}} to a text. If a vector character strings, it should
#'  be the name(s) of the text file(s) where the data are to be written to. The
#'  path of the file(s) may be provided as well, if these file(s) is (are) not in
#'  the working directory. If \code{NULL}, file names will be generated
#'  automatically.
#'  
#'@param writeArgs 
#'  List of additional arguments passed to \code{\link[utils]{write.table}}
#'  
#'@param overwrite 
#'  Single logical value. If \code{TRUE} (not the default), 
#'  Existing output files are overwritten without warning.
#'  
#'@param \dots 
#'  More arguments passed to \code{\link[macroutils2:macroReadBin-methods]{macroReadBin}}.
#'
#'
#'@export
#'
#' 
macroConvertBin <- function(# Converts MACRO/SOIL binary files into CSV or TXT text files
    f, 
    gui       = TRUE, 
    sep       = ",", 
    dec       = ".", 
    fileOut   = NULL, 
    writeArgs = list( "row.names" = FALSE ), 
    overwrite = FALSE, 
    ...
){  ## If no file name is provided
    if( missing( f ) ){ 
        if( interactive() ){ 
            ## Pop-up a menu to choose the bin file to be 
            ## imported
            f <- .chooseBinFiles(
                caption = "Select one or several binary file(s)", 
                multi   = TRUE  
            )   
            
            if( length(f) == 0 ){ 
                stop( "You haven't choosen any binary file to read :o(" )
            }   
            
            f <- sort( f ) 
        }else{ 
            stop( "'f' can not be missing when R is not being used interactively" ) 
        }   
    }   
    
    
    ## Read the files:
    x <- macroReadBin( f = f, ... ) 
    
    
    if( gui ){ 
        sep <- .macroMenu( 
            title       = "Choose the field separator:", 
            choices     = c( 
                "Comma              (',').  Extension: .csv", # 1 
                "Semicolon          (';').  Extension: .csv", # 2 
                "Tabulation         ('\t'). Extension: .txt", # 3 
                "Single-space       (' ').  Extension: .txt"  # 4 
                #"Space, fixed-width ('').   Extension: .txt"  # 5 
            ),  
            graphics    = FALSE, 
            preselect   = ",", 
            error       = "You haven't chosen anything :o(", 
            multi       = FALSE 
        )   
        
        
        sep <- if( sep == 1 ){ 
            sep <- ","  
        }else if( sep == 2 ){ 
            sep <- ";"  
        }else if( sep == 3 ){ 
            sep <- "\t" 
        }else if( sep == 4 ){ 
            sep <- " " 
        }   
        # else if( sep == 5 ){ 
        #     sep <- "" 
        # }   
        
        
        dec <- .macroMenu( 
            title       = "Choose the decimal mark:", 
            choices     = c( ".", "," ), 
            graphics    = FALSE, 
            preselect   = ".", 
            error       = "You haven't chosen anything :o(", 
            multi       = FALSE 
        )   
        dec <- ifelse( dec == 1, ".", "," )  
    }   
    
    if( sep == dec ){ 
        stop( "'sep' and 'dec' are identical" )
    }   
    
    if( is.data.frame(x) ){ 
        x <- list( x ) 
    }   
    
    
    ## Create new file names (if needed):
    if( is.null( fileOut ) ){ 
        fileOut <- paste0( 
            f, 
            ifelse( sep %in% c("\t"," ",""), ".txt", ".csv" )
        )   
    }else{ 
        if( length( fileOut ) != length( f ) ){ 
            stop( "'f' and 'fileOut' must be of the same length" )
        }   
    }   
    
    
    ## Test if the file exists:
    testFile <- file.exists( fileOut ) 
    
    if( any( testFile ) ){ 
        #   Select only the 1st files
        testFile  <- which( testFile ) 
        moreFiles <- ifelse( max( testFile ) > 3, "...", 
            character(0) )
        testFile  <- testFile[ testFile <= 3 ]
        
        if( gui & (!overwrite) ){
            message( sprintf( 
                "Some output file(s) already exist(s) (%s)", 
                paste( c( fileOut[ testFile ], moreFiles ), collapse = ", " )  
            ) ) 
            
            overwrite2 <- .macroMenu( 
                title       = "Do you want to overwrite these files?", 
                choices     = c( "No", "Yes" ), 
                graphics    = FALSE, 
                preselect   = "No", 
                error       = "You haven't chosen anything :o(", 
                multi       = FALSE 
            )   
            overwrite2 <- ifelse( overwrite2 == 1, FALSE, TRUE ) 
            
            message( "Note: Set 'overwrite' to TRUE to avoid the question above." )
            
            if( !overwrite2 ){ 
                stop( "Operation aborded by the user" )
            }   
        }else if( !overwrite ){
            stop( sprintf( 
                "Some output file(s) already exist(s) (%s). Set 'overwrite' to TRUE to ignore existing files.", 
                paste( c( fileOut[ testFile ], moreFiles ), collapse = ", " )  
            ) ) 
        }   
    }     
    
    
    
    for( f in 1:length(f) ){ 
        x0 <- x[[f]] 
        class(x0) <- "data.frame"
        
        writeArgs0 <- c( list( 
            "x"     = x0, 
            "file"  = fileOut[f], 
            "sep"   = sep, 
            "dec"   = dec  
        ), writeArgs ) 
        
        do.call( what = "write.table", args = writeArgs0 ) 
    }   
    
    
    return( invisible( x ) ) 
}   




# ==================== macroViewBin ====================

#' Reads a MACRO/SOIL binary file and view it as a table.
#'
#' Reads a MACRO/SOIL binary file and view it as a table.
#'
#'
#'@param f 
#'  Single character strings or a single \code{\link{connection}} to
#'  a binary file. If a vector character strings, it should be the name of the
#'  binary file which the data are to be read from. The path of the file may be
#'  provided as well, if \code{f} is not in the working directory.
#'  
#'@param \dots 
#'  More arguments passed to \code{\link[macroutils2:macroReadBin-methods]{macroReadBin}}.
#'
#'
#'@export
#'
#'
#'@importFrom utils View
macroViewBin <- function(
    f, 
    ...
){  ## If no file name is provided
    if( missing( f ) ){ 
        if( interactive() ){ 
            ## Pop-up a menu to choose the bin file to be 
            ## imported
            f <- .chooseBinFiles(
                caption = "Select one or several binary file(s)", 
                multi   = FALSE   
            )   
            
            if( length(f) == 0 ){ 
                stop( "You haven't choosen any binary file to read :o(" )
            }   
            
            f <- sort( f ) 
        }else{ 
            stop( "'f' can not be missing when R is not being used interactively" ) 
        }   
    }   
    
    
    ## Read the files:
    x <- macroReadBin( f = f[1], ... ) 
    
    
    ## View the file     
    utils::View( x, title = f[1] )  
    
    return( invisible( x ) ) 
}   



# +-------------------------------------------------------------+ 
# | Original file: bugFixes.R                                   | 
# +-------------------------------------------------------------+ 

# .chooseAccessFiles ============================================

#'@importFrom tcltk tk_choose.files

## # Pop-up a menu to choose MS Access file from the file system.
## # 
## # Pop-up a menu to choose MS Access file from the file system.
## #
## #
## #@param caption
## #   See \code{\link[utils]{choose.files}} or 
## #   \code{\link[tcltk]{tk_choose.files}}.
## # 
## #@param multi
## #   See \code{\link[utils]{choose.files}} or 
## #   \code{\link[tcltk]{tk_choose.files}}.
## # 
## # 
.chooseAccessFiles <- function(
    caption = "Select one or several MACRO parameter database(s) (MS Access)", 
    multi   = TRUE
){  
    if( !interactive() ){ 
        stop( "'.chooseAccessFiles' can only be used in interactive mode" )
    }   
    
    
    ## Set the folder working directory
    lastBinWd <- getMuPar( "lastBinWd" ) 
    
    if( length(lastBinWd) == 0 ){ 
        lastBinWd <- getwd() 
    }else{ 
        if( lastBinWd == "" ){ 
            lastBinWd <- getwd() 
        }else{ 
            lastBinWd <- file.path( lastBinWd, "*.*" )
        }   
    }   
    
    
    ## Create a template of file extension to be read:
    filterz <- matrix( 
        data  = c( 
            "Access files (*.mdb)", "*.mdb", 
            "All",                  "*" ), 
        nrow  = 2, 
        ncol  = 2, 
        byrow = TRUE  
    )   
    rownames( filterz ) <- c( "mdb", "all" ) 
    
    ## Pop-up a menu to choose the bin file to be 
    ## imported
    if( exists(x = "choose.files", where = "package:utils" ) ){ 
        # fun <- get( "choose.files" ) 
        
        f <- utils::choose.files(
            default = lastBinWd, # , "*.bin"
            caption = caption, 
            multi   = multi, 
            filters = filterz 
        )   
        
    }else{ 
        # library( "tcltk" ) 
        
        # fun <- get( "tk_choose.files" ) 
        
        f <- tcltk::tk_choose.files(
            default = lastBinWd, # , "*.bin"
            caption = caption, 
            multi   = multi, 
            filters = filterz 
        )   
    }   
    
    
    # browser()
    
    
    ## Set the last folder where binary files were found:
    lastBinWd <- .pathNoLastItem( p = f[1] ) 
    
    muPar( "lastBinWd" = lastBinWd ) 
    
    return( f ) 
}   



# macroBugFixCleanDb ============================================

#' Clean-up MACRO 5.2 parameter databases. Fixes 4 known bugs (orphan, incomplete or unnecessary values)
#'
#' Clean-up MACRO 5.2 parameter databases. Fixes 4 known bugs 
#'  (orphan, incomplete or unnecessary values). It is very 
#'  highly recommended to make a backup-copy of MACRO 5.2 
#'  parameter databases before you try this utility. The 
#'  R \bold{\code{\link[RODBC]{RODBC-package}}} is required to run 
#'  this function, and you also need to run a \bold{32 bit 
#'  (i386)} version of R (maybe located in 
#'  \code{\{R installation directory\}bin/i386/Rgui.exe}, 
#'  if it has been installed).
#'
#'
#'@param f 
#'  Vector of character strings or a single \code{\link{connection}}
#'  to a MACRO GUI MS Access parameter database. If a vector of 
#'  character strings, it should be the name(s) of
#'  the Access database(s) containing MACRO parameters. The path 
#'  of the file(s) may be provided as well, if the file(s) 
#'  is (are) not in the working directory.
#'
#'@param paranoia 
#'  Single logical value. If \code{TRUE}, the user is asked 
#'  if he made a backup copy of the parameter database.
#'
#'@param \dots Additional options passed to specific 
#'  methods.
#'
#'
#'@return 
#'  Do not return anything. Used for it side effect on a MACRO 
#'  parameter database.
#'
#'
#'@rdname macroBugFixCleanDb
#'
#'@export
#'
#'
#'@importFrom utils sessionInfo
#'@importFrom utils select.list
#'@importFrom utils installed.packages
macroBugFixCleanDb <- function(
    f, 
    paranoia = TRUE, 
    ...
){      
    testRODBC <- "RODBC" %in% rownames( utils::installed.packages() )
    
    if( !testRODBC ){ 
        stop( "'RODBC' package not available. Please install RODBC first: install.package('RODBC')" )
    }else{ 
        arch <- utils::sessionInfo()[[ "R.version" ]][[ "arch" ]]
        
        if( arch != "i386" ){
            warning( sprintf( 
                "'RODBC' MS Access interface requires a 32 bit version of R (i386) (now: %s). Consider running R i386 instead ({R install dir}/i386/Rgui.exe)", 
                arch
            ) ) 
        }   
    }   
    
    
    ## If no file name is provided
    if( missing( f ) ){ 
        if( interactive() ){ 
            ## Pop-up a menu to choose the bin file to be 
            ## imported
            f <- .chooseAccessFiles(
                caption = "Select one or several MACRO parameter database(s) (MS Access)", 
                multi   = TRUE  
            )   
            
            if( length(f) == 0 ){ 
                stop( "You haven't choosen any binary file to read :o(" )
            }   
            
            f <- sort( f ) 
        }else{ 
            stop( "'f' can not be missing when R is not being used interactively" ) 
        }   
    }   
    
    
    if( interactive() & paranoia ){ 
        cp <- utils::select.list( 
            title       = "Did you made a backup-copy of your parameter database?",
            choices     = c( "Yes", "No" ), 
            preselect   = NULL, 
            multiple    = FALSE, 
            graphics    = FALSE 
        )   
        
        if( cp == "No" ){ 
            stop( "Then make a backup-copy of your parameter database" )
        }   
    }   
    
    
    silent <- lapply( 
        X   = f, 
        FUN = function(.f){ 
            # f <- f[1]
            
            message( sprintf( "Starts processing database: '%s'.", .f ) )
            
            channel <- RODBC::odbcConnectAccess( access.file = .f ) 
            
            on.exit( try( RODBC::odbcClose( channel = channel ) ) )
            
            tablesList <- RODBC::sqlTables( channel = channel )
            
            .tables <- c( "Output()", "Run_ID", "OutputLayers" ) 
            testTables <- .tables %in% 
                tablesList[, "TABLE_NAME" ]
            
            if( !all(testTables) ){ 
                stop( sprintf( 
                    "The table(s) %s cannot be found in the database (%s)", 
                    paste( .tables[ !testTables ], collapse = "; " ), 
                    .f 
                ) ) 
            };  rm( .tables, testTables ) 
            
            output <- RODBC::sqlFetch( channel = channel, sqtable = "Output()" )
            
            runIdTbl <- RODBC::sqlFetch( channel = channel, sqtable = "Run_ID" )
            
            outputLayers <- RODBC::sqlFetch( channel = channel, sqtable = "OutputLayers" )
            
            # runIds <- runIdTbl[, "R_ID" ]
            
            
            
            # 1 - ORPHAN `R_ID` IN `Output()` (NOT ANY MORE 
            #     IN `Run_ID`)
            # ----------------------------------------------
            
            #   ID in "Output()" but not in "Run_ID"
            missId <- unique( missId0 <- output[ 
                !(output[, "R_ID" ] %in% runIdTbl[, "R_ID" ]), 
                "R_ID" ] ) 
            
            #   Delete IDs in Output() that are 'orphan'
            if( length( missId ) > 0 ){ 
                message( sprintf( 
                    "Found %s orphan values in `Output()` for RUNID(s) %s", 
                    length( missId0 ), 
                    paste( missId, collapse = "; " )
                ) ) 
                
                rm( missId0 )
                
                for( id in missId ){ 
                    RODBC::sqlQuery( 
                        channel = channel, 
                        query   = sprintf( "DELETE * FROM `Output()` WHERE `R_ID` = %s", id ), 
                    )   
                }   
                
                message( "Orphan values deleted in `Output()`" )
            }else{
                message( "Found no orphan values in `Output()` (fine!)" )
            }   
            
            rm( missId )
            
            #   Re-fetch Output()
            output <- RODBC::sqlFetch( channel = channel, sqtable = "Output()" ) 
            
            
            
            # 2 - DUPLICATED `R_ID`-`Var` IN `Output()`
            # ----------------------------------------------
            
            #   Find RUNID with duplicated export parameters
            uOutput   <- output[, c( "R_ID", "Var" ) ] 
            selDuplic <- duplicated( uOutput ) 
            
            duplicId  <- unique( uOutput[ selDuplic, "R_ID" ] ) 
            rm( uOutput, selDuplic )
            
            if( length( duplicId ) > 0 ){ 
                message( sprintf( 
                    "Found %s duplicated values in `Output()` for RUNID(s) %s", 
                    length( selDuplic ), 
                    paste( duplicId, collapse = "; " ) 
                ) ) 
                
                for( id in duplicId ){ 
                    # id <- duplicId[ 1 ]
                    
                    sOutput <- subset( 
                        x      = output, 
                        subset = eval( quote( R_ID == id ) ) )
                    
                    #   Order the table
                    sOutput <- sOutput[ 
                        order( sOutput[, "Var" ], sOutput[, "Output()ID" ] ), ]
                    
                    #   Unique list of variables
                    uVar <- unique( sOutput[, "Var" ] ) 
                    
                    nrow( sOutput ) # 98
                    
                    for( v in uVar ){ 
                        # v <- uVar[ 1 ]
                        
                        outputId <- sOutput[ 
                            sOutput[,"Var"] == v, 
                            "Output()ID" ] 
                        
                        if( length( outputId ) > 1 ){ 
                            RODBC::sqlQuery( 
                                channel = channel, 
                                query   = sprintf( "DELETE * FROM `Output()` WHERE `Output()ID` = %s", min( outputId ) ), 
                            )   
                        }   
                        
                        rm( outputId )
                        
                    }   
                    
                    # nrow( sOutput ) # 98
                    
                    rm( sOutput, uVar, v )
                }   
                
                message( "Duplicated values deleted in `Output()`" )
            }else{
                message( "Found no duplicated values in `Output()` (fine!)" )
            }   
            
            rm( duplicId )
            
            
            
            # 3 - EXPORT PARAMS IN `Output()` NOT SELECTED 
            #     BUT STILL PRESENT IN `OutputLayers`
            # ----------------------------------------------
            
            #   Find outputs that are not selected in `Output()`
            #   but nonetheless present in `OutputLayers`
            uOutput2 <- unique( output[, c( "R_ID", "Var", "Output()ID", "selected" ) ] )
            
            #   Only keep those that are not selected 
            #   as layered output
            uOutput2 <- subset( x = uOutput2, subset = eval( quote( selected != 1 ) ) )
            
            #   Find the one that should not be there
            testOutLay <- outputLayers[, "Output()ID" ] %in% 
                uOutput2[, "Output()ID" ]
            
            if( any( testOutLay ) ){
                #   Reverse selection: entries in `Output()`
                #   that have unnecessary layers parameters in 
                #   `OutputLayers`
                testOut <- uOutput2[, "Output()ID" ] %in% 
                    outputLayers[ testOutLay, "Output()ID" ] 
                
                message( sprintf( 
                    "Found %s unnecessary entries in `OutputLayers` for RUNID(s) %s", 
                    length( testOutLay ),
                    paste( unique( uOutput2[ testOut, "R_ID" ] ), collapse = "; " ) 
                ) ) 
                
                rm( testOut )
                
                #   Find the OutputLayerID to be removed
                idOut <- outputLayers[ testOutLay, "OutputLayerID" ]
                
                RODBC::sqlQuery( 
                    channel = channel, 
                    query   = sprintf( 
                        "DELETE * FROM `OutputLayers` WHERE `OutputLayerID` IN (%s)", 
                        paste( as.character( idOut ), collapse = ", " ) 
                    ),  
                )   
                
                message( sprintf( 
                    "Deleted %s unnecessary entries in `OutputLayers`", 
                    length( idOut ) 
                ) ) 
                
                rm( idOut )
            }else{
                message( "Found no unnecessary entries in `OutputLayers` (fine!)" )
            }   
            
            rm( uOutput2, testOutLay )
            
            
            
            # 4 - EXPORT PARAMS IN `OutputLayers` WHERE THE 
            #     COLUMN `Selected` IS NOT SET (neither 0 nor 
            #     1), presumably after more layers were 
            #     added
            # ----------------------------------------------
            
            uOutput2 <- unique( output[, c( "R_ID", "Var", "Output()ID", "selected" ) ] )
            
            #   Find the one that should not be there
            selFixSelCol <- is.na( outputLayers[, "Selected" ] )
            
            if( any( selFixSelCol ) ){
                #   Reverse selection: entries in `Output()`
                #   that have unnecessary layers parameters in 
                #   `OutputLayers`
                testOut <- uOutput2[, "Output()ID" ] %in% 
                    outputLayers[ selFixSelCol, "Output()ID" ] 
                
                message( sprintf( 
                    "Found %s entries in `OutputLayers` where selected is not set, for RUNID(s) %s", 
                    sum( selFixSelCol ), 
                    paste( unique( uOutput2[ testOut, "R_ID" ] ), collapse = "; " ) 
                ) ) 
                
                rm( testOut )
                
                #   Find the OutputLayerID to be removed
                idOut <- outputLayers[ selFixSelCol, "OutputLayerID" ]
                
                RODBC::sqlQuery( 
                    channel = channel, 
                    query   = sprintf( 
                        "UPDATE `OutputLayers` SET `Selected`=0 WHERE `OutputLayerID` IN (%s)", 
                        paste( as.character( idOut ), collapse = ", " ) 
                    ),  
                )   
                
                message( sprintf( 
                    "Set %s entries in `OutputLayers` (`Selected` set to 0)", 
                    length( idOut ) 
                ) ) 
                
                rm( idOut )
            }else{
                message( "Found no entries with `Selected` not set in `OutputLayers` (fine!)" )
            }   
            
            rm( selFixSelCol )
            
            
            
            # Close and exit
            # ----------------------------------------------
            
            RODBC::odbcClose( channel = channel ) 
            
            on.exit() 
        }   
    )   
    
    message( "Database cleaned" ) 
}   



# +-------------------------------------------------------------+ 
# | Original file: macroutilsFocusGWConc.r                         | 
# +-------------------------------------------------------------+ 

#' INTERNAL/NON-OFFICIAL: Calculate the yearly and Xth percentile groundwater concentration from a MACROInFOCUS output.
#'
#' INTERNAL & NON-OFFICIAL: Calculate the yearly and Xth percentile 
#'  groundwater concentration from a MACROInFOCUS output. 
#'  \bold{WARNING} This function is \bold{not} part 
#'  of the official MACROInFOCUS program. It is provided 
#'  for test-purpose, without any guarantee or support from 
#'  the authors, CKB, SLU or KEMI. You are strongly recommended to 
#'  benchmark the function against a range of (official) 
#'  MACROInFOCUS simulation results, before you use the 
#'  function. You are also strongly recommended to inspect 
#'  the code of these functions before you use them. To 
#'  inspect the content of these functions, simply type 
#'  \code{body( macroutils2:::macroutilsFocusGWConc.data.frame )} 
#'  after you have loaded the package \code{macroutils2}.
#'
#'
#'@references 
#'  European Commission (2014) "Assessing Potential for 
#'  Movement of Active Substances and their Metabolites to 
#'  Ground Water in the EU Report of the FOCUS Ground Water 
#'  Work Group, EC Document Reference Sanco/13144/2010 
#'  version 3, 613 pp. \url{http://focus.jrc.ec.europa.eu/gw/docs/NewDocs/focusGWReportOct2014.pdf}
#'  See in particular the last sentence page 475. 
#'
#'
#'@author 
#'  Julien Moeys \email{jules_m78-soiltexture@@yahooDOTfr}, 
#'  contributions from Stefan Reichenberger 
#'  \email{SReichenberger@@knoellDOTcom}.
#'
#'
#'@param x
#'  Either a vector of character strings, a 
#'  \code{\link[base]{data.frame}}, or a list of 
#'  \code{\link[base]{data.frame}}s. If a vector of character 
#'  strings, names (and possibly paths to) a \code{.bin} file 
#'  output by MACROInFOCUS. The argument is passed internally 
#'  to \code{\link[macroutils2:macroReadBin-methods]{macroReadBin}} (its 
#'  \code{file}-argument). If a (list of) 
#'  \code{\link[base]{data.frame}}(s), it should be imported from 
#'  a \code{.bin} file output by MACROInFOCUS (for example 
#'  with \code{\link[macroutils2:macroReadBin-methods]{macroReadBin}}).
#'
#'@param nbYrsWarmUp
#'  Single integer values: Number of warm-up years that 
#'  should be removed from the beginning of the model output.
#'  A default of 6 years of warn-up are used in FOCUS.
#'
#'@param yearsAvg
#'  Single integer values: Number of simulation years to 
#'  "aggregate" when calculating yearly- or biennial- or 
#'  triennial- (etc.) average concentrations. 
#'  If \code{yearsAvg=1L}, the function calculates yearly-
#'  average concentrations before calculating the Xth 
#'  worst-case percentile. If \code{yearsAvg=2L}, the function 
#'  calculates biennial-average concentrations. If 
#'  \code{yearsAvg=3L}, the function calculates 
#'  triennial-average concentrations (etc.). The default in 
#'  FOCUS is to calculate yearly avegares when the pesticide 
#'  is applied yearly, biennial-averages when the pesticide 
#'  is applied every two years and triennial averages when 
#'  the pesticide is applied every three years. When 
#'  \code{yearsAvg} is \code{NULL} (the default), the function 
#'  tries to automatically sets and control this parameter.
#'
#'@param prob
#'  Single numeric value, between 0 and 1. Probability 
#'  (percentile/100) of the worst case concentration 
#'  that shall be calculated. In FOCUS, the yearly results 
#'  are ordered by increasing yearly average concentrations 
#'  before the percentile is calculated, as the average 
#'  concentration of the two years closest to the Xth percentile 
#'  (X always being 80, in FOCUS). Here, in practice, the 
#'  index of the 1st and 2nd year used for calculating the 
#'  average are selected as follow: 
#'  \code{min_index = floor(prob *(number of sim years used))} and 
#'  \code{max_index = ceiling(prob *(number of sim years used))},
#'  but in cases \code{min_index} is identical to \code{max_index}, 
#'  then \code{max_index} is defined as \code{min_index + 1}, 
#'  unless \code{prob} is 0 or 1 (to get the minimum 
#'  or the maximum yearly concentrations, respectively). 
#'  The number of simulation years used is equal to the total 
#'  number of simulation years in \code{x} minus 
#'  \code{nbYrsWarmUp}. In practice, what is calculated 
#'  "a la FOCUS", when \code{prob = 0.8}, is an average 
#'  between the 80th and the 85th percentile yearly 
#'  concentrations. See FOCUS Groundwater main report p 475 
#'  (reference above). Notice that the algorithm also calculates 
#'  a Xth percentile concentration (\code{x = prob * 100}) 
#'  using R function \code{\link[stats]{quantile}}, with 
#'  its default parametrisation and quantile-calculation 
#'  method (Note: see the help page of the function if you 
#'  are interested to see how that percentile is obtained).
#'
#'@param method
#'  Single character string. If \code{method = "focus"} (the default), 
#'  the percentile is calculated with the default FOCUS method, 
#'  that is the concentration derived from the cumulated 
#'  yearly (or biennial or triennial) water and solute flow 
#'  from the two years closest to the Xth percentile 
#'  concentration (where \code{X = prob * 100}). If 
#'  \code{method = "R"}, the concentration is calculated using 
#'  \code{R} function \code{\link[stats]{quantile}}, calculated 
#'  directly on the yearly (or biennial or triennial) 
#'  concentrations. If \code{method = "test"}, it is expected 
#'  that the simulation is a "short test" simulation, for example 
#'  one year long, and a simple average concentration may be 
#'  returned when a PEC-groundwater cannot be calculated. 
#'  Only meant to be used when performing functional tests.
#'
#'@param negToZero
#'  Single logical value. If \code{TRUE} (not the default) 
#'  negative concentrations will be set to 0 (presumably like 
#'  in MACROInFOCUS). If \code{FALSE}, they will not be set 
#'  to 0, but if some of the concentrations used to calculate 
#'  the Xth percentile (see \code{yearsXth}) are negative, 
#'  a warning will be issued (so that the user knows that 
#'  concentrations may differ from those in MACROInFOCUS).
#'
#'@param quiet
#'  Single logical value. Set to \code{TRUE} to suppress the 
#'  warning message. Default value to \code{FALSE}.
#'
#'@param type
#'  Single integer value. Only used when \code{method = "R"} 
#'  (see above). See \code{\link[stats]{quantile}}.
#'
#'@param massunits
#'  Single integer value. Code for the mass unit of the simulation 
#'  result in \code{x}. \code{1} is micro-grams, \code{2}is 
#'  milligrams (the default in MACRO In FOCUS and thus in this 
#'  function), \code{2} is grams and \code{4} is kilograms. 
#'  Corresponds to the parameter \code{MASSUNITS} in MACRO.
#'
#'@param \dots
#'  Additional parameters passed to 
#'  \code{\link[macroutils2:macroReadBin-methods]{macroReadBin}}, when \code{x} is 
#'  a character string naming one or several files to be 
#'  imported. Not used otherwise.
#'
#'
#'@return 
#'  Returns a \code{\link[base]{list}} with the following items:
#'  \itemize{
#'    \item{"info\_general"}{
#'      A \code{\link[base]{data.frame}} with the following columns:
#'      \itemize{
#'        \item{"conc\_percentile"}{The percentile used to 
#'          calculate the Predicted Environmental Concentration 
#'          (columns \code{ug\_per\_L} in items 
#'          \code{conc\_target\_layer} and \code{conc\_perc}, 
#'          below), in [\%].}
#'        \item{"rank\_period1"}{The rank of the first 
#'          simulation period used to calculate \code{ug\_per\_L},
#'          when ordered by increasing average concentration.}
#'        \item{"rank\_period2"}{The rank of the second 
#'          simulation period used to calculate \code{ug\_per\_L},
#'          when ordered by increasing average concentration.}
#'        \item{"method"}{See argument \code{method} above.}
#'        \item{"nb\_sim\_yrs\_used"}{Number of simulation years 
#'          used for the calculation, after discarding the warm-up 
#'          period.}
#'        \item{"nb\_yrs\_per\_period"}{Number of simulation years 
#'          aggregated to calculate the average concentration of 
#'          each "period". 1, 2 or 3 in cases of yearly, biennial 
#'          or triennial pesticide application frequency.}
#'        \item{"nb\_yrs\_warmup"}{Number of simulation 
#'          years discarded as a warm-up period.}
#'        \item{"neg\_conc\_set\_to\_0"}{See \code{negToZero} 
#'          above.}
#'      }  
#'    }  
#'    \item{"info\_period"}{
#'      A \code{\link[base]{data.frame}} with the following columns:
#'      \itemize{
#'        \item{"period\_index"}{Index of the simulation 
#'          period when periods are sorted in chronological 
#'          order (i.e. \code{1} is the first or earliest 
#'          period).}
#'        \item{"from\_year"}{First year included in the period.}
#'        \item{"to\_year"}{Last year included in the period.}
#'      }  
#'    } 
#'    \item{"water\_target\_layer\_by\_period"}{
#'      A \code{\link[base]{data.frame}} with the following columns:
#'      \itemize{
#'        \item{"period\_index"}{See above.}
#'        \item{"mm\_mic"}{Accumulated amount of water 
#'          passed through the micropores in target layer 
#'          over the period, downward (positive) or upward 
#'          (negative), in [mm] of water.}
#'        \item{"mm\_mac"}{Accumulated amount of water 
#'          passed through the macropores in target layer 
#'          over the period, downward (positive) or upward 
#'          (negative), in [mm] of water.}
#'        \item{"mm\_tot"}{Accumulated amount of water 
#'          passed through the target layer 
#'          over the period, downward (positive) or upward 
#'          (negative), in [mm] of water.}
#'      }  
#'    } 
#'    \item{"solute\_target\_layer\_by\_period"}{
#'      A \code{\link[base]{data.frame}} with the following columns:
#'      \itemize{
#'        \item{"period\_index"}{See above.}
#'        \item{"mg\_per\_m2\_mic"}{Accumulated mass of 
#'          solute passed through the micropores, per square 
#'          meter, in target layer, over the period, 
#'          downward (positive) or upward (negative), in 
#'          [mg/ m2].}
#'        \item{"mg\_per\_m2\_mac"}{Accumulated mass of 
#'          solute passed through the macropores, per square 
#'          meter, in target layer, over the period, 
#'          downward (positive) or upward (negative), in 
#'          [mg/ m2].}
#'        \item{"mg\_per\_m2\_tot"}{Accumulated mass of 
#'          solute passed through the target layer, per square 
#'          meter, over the period, downward (positive) or 
#'          upward (negative), in [mg/ m2].}
#'        \item{"ug\_per\_L"}{Water-flow-weighted average 
#'          solute concentration over the period, in 
#'          [micro-grams/L] or [mg/m3]. In practice equal 
#'          to the accumulated solute mass divided by the 
#'          accumulated water flow, with appropriate unit 
#'          conversion.}
#'      }  
#'    } 
#'    \item{"water\_perc\_by\_period"}{
#'      A \code{\link[base]{data.frame}} with the following columns:
#'      \itemize{
#'        \item{"period\_index"}{See above.}
#'        \item{"mm"}{Accumulated amount of water 
#'          passed through the bottom layer of the soil profile 
#'          over the period, downward (positive) or upward 
#'          (negative), in [mm] of water.}
#'      }  
#'    } 
#'    \item{"solute\_perc\_by\_period"}{
#'      A \code{\link[base]{data.frame}} with the following columns:
#'      \itemize{
#'        \item{"period\_index"}{See above.}
#'        \item{"mg\_per\_m2"}{Accumulated mass of 
#'          solute passed through the bottom layer of the soil 
#'          profile , per square meter, over the period, 
#'          downward (positive) or upward (negative), in 
#'          [mg/ m2].}
#'        \item{"ug\_per\_L"}{Water-flow-weighted average 
#'          solute concentration over the period, in 
#'          [micro-grams/L] or [mg/m3]. In practice equal 
#'          to the accumulated solute mass divided by the 
#'          accumulated water flow, with appropriate unit 
#'          conversion.}
#'      }  
#'    } 
#'    \item{"conc\_target\_layer"}{
#'      A \code{\link[base]{data.frame}} with the following columns:
#'      \itemize{
#'        \item{"ug\_per\_L"}{Xth percentile of the period-
#'          averaged solute concentrations in the target 
#'          layer, where X is equal to \code{conc\_percentile} 
#'          (See above).}
#'        \item{"ug\_per\_L\_rnd"}{Same as above, except that 
#'          the concentration is rounded to 2 digits after the 
#'          decimal mark, in scientific mode, in an attempt to 
#'          obtain the same value as MACRO In FOCUS graphical 
#'          interface.}
#'        \item{"index\_period1"}{Index of the first simulation 
#'          period used to calculate the Xth percentile of 
#'          the period-averaged solute concentrations. 
#'          Corresponds to the column \code{period\_index} in 
#'          the tables above.}
#'        \item{"index\_period2"}{Index of the second simulation 
#'          period used to calculate the Xth percentile of 
#'          the period-averaged solute concentrations. 
#'          Corresponds to the column \code{period\_index} in 
#'          the tables above.}
#'        \item{"f\_solute\_mac"}{Average fraction of solute 
#'          in the macropores corresponding to 
#'          \code{ug\_per\_L}, 0 meaning 0\% of the solute in 
#'          the macropres and 1 meaning 100\% of the solute 
#'          in the macropores.}
#'        \item{"f\_solute\_mic"}{Average fraction of solute 
#'          in the micropores corresponding to 
#'          \code{ug\_per\_L}, 0 meaning 0\% of the solute in 
#'          the micropres and 1 meaning 100\% of the solute 
#'          in the micropores.}
#'      }  
#'    } 
#'    \item{"conc\_perc"}{
#'      A \code{\link[base]{data.frame}} with the following columns:
#'      \itemize{
#'        \item{"ug\_per\_L"}{Xth percentile of the period-
#'          averaged solute concentrations percolated at the 
#'          bottom boundary of the soil profile, where X is 
#'          equal to \code{conc\_percentile} (See above).}
#'        \item{"ug\_per\_L\_rnd"}{Same as above, except that 
#'          the concentration is rounded to 2 digits after the 
#'          decimal mark, in scientific mode, in an attempt to 
#'          obtain the same value as MACRO In FOCUS graphical 
#'          interface.}
#'        \item{"index\_period1"}{Index of the first simulation 
#'          period used to calculate the Xth percentile of 
#'          the period-averaged solute concentrations. 
#'          Corresponds to the column \code{period\_index} in 
#'          the tables above.}
#'        \item{"index\_period2"}{Index of the second simulation 
#'          period used to calculate the Xth percentile of 
#'          the period-averaged solute concentrations. 
#'          Corresponds to the column \code{period\_index} in 
#'          the tables above.}
#'      }  
#'    } 
#'  }   
#'
#'
#'@example inst/examples/macroutilsFocusGWConc-examples.r
#'
#'@rdname macroutilsFocusGWConc-methods
#'
#'@export
#'
#'@importFrom stats quantile
macroutilsFocusGWConc <- function( 
    x, 
    nbYrsWarmUp = 6L, 
    yearsAvg = NULL, 
    prob = 0.8, 
    method = c("focus","R","test")[1L], 
    negToZero = TRUE, 
    type = 7L, 
    quiet = FALSE, 
    massunits = 2L, 
    ...
){  
    UseMethod( "macroutilsFocusGWConc" )
}  



#'@rdname macroutilsFocusGWConc-methods
#'
#'@method macroutilsFocusGWConc character
#'
#'@export 
#'
macroutilsFocusGWConc.character <- function( 
    x, 
    nbYrsWarmUp = 6L, 
    yearsAvg = NULL,  
    prob = 0.8, 
    method = c("focus","R","test")[1L], 
    negToZero = TRUE, 
    type = 7L, 
    quiet = FALSE, 
    massunits = 2L, 
    ...
){  
    # if( length( x ) > 1L ){ 
        # stop( "length( x ) > 1L. One file at a time" ) 
    # }   
    
    out <- macroReadBin( f = x, ... ) 
    
    #   Add the file name to the table, as a column
    #   so it can be used later to identify the simulation
    if( length(x) > 1L ){
        out <- lapply(
            X   = 1:length(x), 
            FUN = function( i ){
                out_i <- out[[ i ]]
                
                attr( out_i, which = "file" ) <- x[ i ]
                # out_i[, "file" ] <- x[ i ]
                
                return( out_i )
            }   
        )   
    }else{
        # out[, "file" ] <- x
        attr( out, which = "file" ) <- x
    }   
    
    return( macroutilsFocusGWConc( x = out, nbYrsWarmUp = nbYrsWarmUp, 
        yearsAvg = yearsAvg, prob = prob, method = method, 
        negToZero = negToZero, quiet = quiet, type = type, 
        massunits = massunits, ... ) ) 
}   



#'@rdname macroutilsFocusGWConc-methods
#'
#'@method macroutilsFocusGWConc list
#'
#'@export 
#'
macroutilsFocusGWConc.list <- function( 
    x, 
    nbYrsWarmUp = 6L, 
    yearsAvg = NULL,  
    prob = 0.8, 
    method = c("focus","R","test")[1L], 
    negToZero = TRUE, 
    type = 7L, 
    quiet = FALSE, 
    massunits = 2L, 
    ...
){  
    # #   Add the column 'file' if it is not in there yet
    # x <- lapply(
        # X   = 1:length( x ), 
        # FUN = function( i ){
            # xSubset <- x[[ i ]] 
            
            # if( !("file" %in% colnames( xSubset )) ){
                # xSubset[, "file" ] <- as.character( i ) 
            # }   
            
            # return( xSubset ) 
        # }   
    # )   
    
    #   Process each table one by one
    out <- lapply(
        X   = x, 
        FUN = function( xSubset ){
            return( macroutilsFocusGWConc( x = xSubset, 
                nbYrsWarmUp = nbYrsWarmUp, yearsAvg = yearsAvg, 
                prob = prob, method = method, 
                negToZero = negToZero, quiet = quiet, 
                type = type, massunits = massunits, ... ) )
        }   
    )   
    
    # #   Recover and bind the additional attribute into 
    # #   a big table
    # more <- lapply(
        # X   = out, 
        # FUN = function(o){
            # return( attr( x = o, which = "more" ) ) 
        # }   
    # )   
    # more <- do.call( what = "rbind", args = more )
    
    # #   Extract other attributes
    # nbYrsWarmUp <- attr( x = out[[ 1L ]], which = "nbYrsWarmUp" ) 
    # yearsXth   <- attr( x = out[[ 1L ]], which = "yearsXth" ) 
    # negToZero   <- attr( x = out[[ 1L ]], which = "negToZero" ) 
    
    # #   Bind the main output into a table too
    # out <- do.call( what = "rbind", args = out )
    
    # #   Add an attribute to the final table
    # attr( x = out, which = "more" )        <- more 
    # attr( x = out, which = "nbYrsWarmUp" ) <- nbYrsWarmUp
    # attr( x = out, which = "yearsXth" )    <- yearsXth
    # attr( x = out, which = "negToZero" )   <- negToZero

    return( out ) 
}   

#'@rdname macroutilsFocusGWConc-methods
#'
#'@method macroutilsFocusGWConc data.frame
#'
#'@export 
#'
#'@importFrom stats aggregate
macroutilsFocusGWConc.data.frame <- function( 
    x, 
    nbYrsWarmUp = 6L, 
    yearsAvg = NULL,  # 1 = 1 year averaging, 2 = 2 year averaging, etc. 
    prob = 0.8, 
    method = c("focus","R","test")[1L], 
    negToZero = TRUE, 
    type = 7L, 
    quiet = FALSE, 
    massunits = 2L, 
    ...
){  
    if( !quiet ){
        message( "WARNING: Not part of the official MACROInFOCUS program" )
        message( "  Provided only for test purpose. See help page for more information." )
        message( "  Set 'quiet' to TRUE to suppress these messages" )
    }   
    
    #   Coefficient to convert to g active substance per ha
    if( massunits == 1L ){          #   micro-grams
        mg_per_massunit <- 1/1000
        
    }else if( massunits == 2L ){    #   milligrams
        mg_per_massunit <- 1 
        
    }else if( massunits == 3L ){    #   grams
        mg_per_massunit <- 1000
        
    }else if( massunits == 4L ){    #   kilograms
        mg_per_massunit <- 1000000
        
    }else{
        stop( sprintf( 
            "Unknown value for MASSUNITS (%s) in the par file. Expects 1, 2, 3 or 4.", 
            massunits
        ) ) 
    }   
    
    #   Find out the relevant column names (independently of 
    #   the layer-suffix)
    #   SR20151006: try to get rid of the arguments after 
    #   WOUT etc.
    wOutCol     <- colnames( x )[ substr( x = colnames( x ), 1, 5 ) == "WOUT_" ]
    wFlowOutCol <- colnames( x )[ substr( x = colnames( x ), 1, 9 ) == "WFLOWOUT_" ]
    sFlowCol    <- colnames( x )[ substr( x = colnames( x ), 1, 6 ) == "SFLOW_" ]
    sFlowOutCol <- colnames( x )[ substr( x = colnames( x ), 1, 9 ) == "SFLOWOUT_" ]
    
    if( length( wOutCol ) != 1L ){
        stop( "No or more than one column matching 'WOUT_'" )
    }   
    
    if( length( wFlowOutCol ) != 1L ){
        stop( "No or more than one column matching 'WFLOWOUT_'" )
    }   
    
    if( length( sFlowCol ) != 1L ){
        stop( "No or more than one column matching 'SFLOW_'" )
    }   
    
    if( length( sFlowOutCol ) != 1L ){
        stop( "No or more than one column matching 'SFLOWOUT_'" )
    }   
    
    # if( !("file" %in% colnames( x )) ){
        # x[, "file" ] <- as.character( NA )
    # }   
    
    #   Check that expected columns are present
    expectCols <- c( "Date", wOutCol, 
       wFlowOutCol, sFlowCol, 
       sFlowOutCol, "TFLOWOUT", "TSOUT" ) # , "file"
    
    testCols <- expectCols %in% colnames( x )   
    
    if( !all( testCols ) ){
        stop( sprintf( 
            "Some expected columns are missing: %s", 
            paste( expectCols[ !testCols ], collapse = "; " ) 
        ) ) 
    }   
    
    #   De-aggregate TSOUT and TFLOWOUT
    x[, "TSOUT" ] <- x[, "TSOUT" ] * mg_per_massunit # Unit conversion (to mg)
    
    x[, "dTSOUT" ]    <- NA_real_ 
    x[ 1L, "dTSOUT" ] <- x[ 1L, "TSOUT" ]
    x[ 2L:nrow(x), "dTSOUT" ] <- 
        x[ 2L:nrow(x), "TSOUT" ] - x[ 1L:(nrow(x)-1L), "TSOUT" ]
    
    x[, "dTFLOWOUT" ]    <- NA_real_ 
    x[ 1L, "dTFLOWOUT" ] <- x[ 1L, "TFLOWOUT" ]
    x[ 2L:nrow(x), "dTFLOWOUT" ] <- 
        x[ 2L:nrow(x), "TFLOWOUT" ] - x[ 1L:(nrow(x)-1L), "TFLOWOUT" ]
    
    #   Convert flow rates from hourly to daily
    #   Note: no quotes around sFlowCol, as it is a variable 
    #   containing the column name (and not a column  name)
    x[, sFlowCol ] <- x[, sFlowCol ] * mg_per_massunit # Unit conversion (to mg)
    x[, sFlowOutCol ] <- x[, sFlowOutCol ] * mg_per_massunit # Unit conversion (to mg)
    
    x[, "SFLOW_DAILY" ]    <- x[, sFlowCol ]    * 24
    x[, "SFLOWOUT_DAILY" ] <- x[, sFlowOutCol ] * 24
    x[, "WOUT_DAILY" ]     <- x[, wOutCol ]     * 24
    x[, "WFLOWOUT_DAILY" ] <- x[, wFlowOutCol ] * 24
    
    x[, "SFLOWTOT_DAILY"]  <- (x[, sFlowCol] + x[, sFlowOutCol]) * 24
    x[, "WFLOWTOT_DAILY"]  <- (x[, wOutCol]  + x[, wFlowOutCol]) * 24
    
    # #   Version of solute flow without negative upward flow
    # x[, "SFLOW_DAILY2b" ] <- x[, "SFLOW_DAILY" ]
    # x[ x[, "SFLOW_DAILY2b" ] < 0, "SFLOW_DAILY2b" ] <- 0
    
    # x[, "SFLOWOUT_DAILY2b" ] <- x[, "SFLOWOUT_DAILY" ]
    # x[ x[, "SFLOWOUT_DAILY2b" ] < 0, "SFLOWOUT_DAILY2b" ] <- 0
        
    #   Extract the year
    years <- format.POSIXct( x = x[, "Date" ], format = "%Y" ) 
    years <- as.integer( years ) 
    
    if( nbYrsWarmUp > 0 ){ 
        yearsOut <- sort( unique( years ) )[ 1:nbYrsWarmUp ]    
    }else{
        yearsOut <- integer(0)
    }   
    
    #   Remove the warm-up years
    xOriginal <- x 
    x     <- x[ !(years %in% yearsOut), ]
    years0 <- years 
    years  <- years[ !(years %in% yearsOut) ]
    
    #   Check that there are indeed 20 years left
    nbYears <- length( unique( years ) )
    
    # message( sprintf( "nbYears: %s",nbYears ) )
    
    if( nbYears == 0L ){
        stop( sprintf( 
            "No simulation-year left after removing warmup years (total nb years: %s; argument 'nbYrsWarmUp': %s)", 
            years0, nbYrsWarmUp
        ) ) 
    }   
    
    #   Determine the appropriate number of years on which 
    #   averages are calculated (yearly, biennial, triennial, 
    #   etc.)
    if( is.null( yearsAvg ) ){
        if( nbYears == 20L ){
            #   Yearly application
            yearsAvg <- 1L
            
        }else if( nbYears == 40L ){
            #   Biennial application
            yearsAvg <- 2L
            
        }else if( nbYears == 60L ){
            #   Triennial application
            yearsAvg <- 3L
            
        }else if( method == "test" ){
            yearsAvg <- 1L
            
        }else{
            yearsAvg <- nbYears %/% 20L
            
            if( nbYears != (20L * yearsAvg) ){
                stop( sprintf( 
                    "The number of used simulation years (Number of years - nbYrsWarmUp; %s - %s) is not a multiple of 20.", 
                    nbYears, nbYrsWarmUp ) )
            }
        }   
    }   
    
    #   Check that 'yearsAvg' is correct:
    if( (yearsAvg != (yearsAvg %/% 1)) | (yearsAvg < 1) ){
        stop( sprintf( "'yearsAvg' must be an integer and >= 1, now: %s", yearsAvg ) )
    }   
    
    #   Calculate how many averaging periods there will be:
    nbAvgPer <- nbYears / yearsAvg
    
    #   Check that 'yearsAvg' is correct:
    if( (nbAvgPer != (nbAvgPer %/% 1)) ){
        stop( sprintf( 
            "'yearsAvg' (%s) must be a multiple of the total number of simulation year (%s) minus the number of warmup years (%s).", 
            yearsAvg, nbYears + length( yearsOut ), nbYrsWarmUp ) )
    }   
    
    # #   Check that 'yearsAvg' is correct:
    # if( (nbAvgPer != (nbAvgPer %/% 1)) ){
        # warning( sprintf( 
            # "Number of simulation years (%s) divided by 'yearsAvg' (%s) is not an integer (%s)", 
            # nbYears, 
            # yearsAvg, 
            # nbAvgPer ) )
    # }   
    
    #   Averaging periods (vector):
    avgPer <- rep( 1:nbAvgPer, each = ceiling( yearsAvg ) )
    avgPer <- avgPer[ 1:nbYears ]
    
    yearToAvgPer <- data.frame(
        "year"   = unique( years ),
        "avgPer" = avgPer
    )   
    rownames( yearToAvgPer ) <- as.character( unique( years ) )
    
    x[, "year" ]   <- years 
    x[, "avgPer" ] <- yearToAvgPer[ 
        as.character( x[, "year" ] ), 
        "avgPer" ]
    
    rm( years, yearToAvgPer, avgPer )
    
    #   Conversion table from averaging period to text 
    #   (year from - year to)
    outAvgPer <- data.frame( 
        "avgPer"   = NA_integer_, 
        "yearFrom" = NA_integer_, 
        "yearTo"   = NA_integer_ ) 
    
    avgPer2Range <- lapply(
        X   = split( x = x, f = x[, "avgPer" ] ), 
        FUN = function(sx){
            outAvgPer0 <- outAvgPer
            outAvgPer0[, "yearFrom" ] <- min( sx[, "year" ] ) 
            outAvgPer0[, "yearTo" ]   <- max( sx[, "year" ] ) 
            return( outAvgPer0 )
        }   
    )   
    
    avgPer2Range <- do.call( what = "rbind", args = avgPer2Range  ) 
    
    avgPer2Range[, "avgPer" ] <- unique( x[, "avgPer" ] ) 
    # rownames( avgPer2Range )  <- as.character( avgPer2Range[, "avgPer" ] )
    
    #   Aggregate water and solute flow for each averaging period
    #   (This will accumulate all flow, for each averaging period)
    xPeriod <- stats::aggregate(
        x   = x[, c( "dTSOUT", "dTFLOWOUT", "SFLOW_DAILY", 
            "SFLOWOUT_DAILY", "WOUT_DAILY", 
            "WFLOWOUT_DAILY", "WFLOWTOT_DAILY", "SFLOWTOT_DAILY") ], 
            # , "SFLOW_DAILY2b", "SFLOWOUT_DAILY2b"
        by  = list( "avgPer" = x[, "avgPer" ] ), 
        FUN = sum 
    )   
    
    #   Add the prefix acc_ to all other columns
    colnames( xPeriod )[ -1L ] <- paste( "acc", 
        colnames( xPeriod )[ -1L ], sep = "_" )
    
    #   Rename the columns dTSOUT and dTFLOWOUT, as they 
    #   are now re-accumulated (per averaging period)
    colnames( xPeriod )[ colnames( xPeriod ) == "acc_dTSOUT" ]    <- "TSOUT"
    colnames( xPeriod )[ colnames( xPeriod ) == "acc_dTFLOWOUT" ] <- "TFLOWOUT"
    
    #   Suppress the daily prefix, as variables are now 
    #   accumulated 
    colnames( xPeriod ) <- gsub( x = colnames( xPeriod ), 
        pattern = "_DAILY", replacement = "", fixed = TRUE )
    
    #   Add the year range (min -  max) to the table
    xPeriod <- merge(
        x     = xPeriod, 
        y     = avgPer2Range, 
        by    = "avgPer", 
        all.x = TRUE 
    )   
    rm( avgPer2Range )
    
    #   Calculate the concentrations
    xPeriod[, "CONC_PERC" ] <- (xPeriod[, "TSOUT" ] / (xPeriod[, "TFLOWOUT" ] / 1000))
    
    xPeriod[, "CONC_TLAYER" ] <- 
        (xPeriod[, "acc_SFLOW" ] + xPeriod[, "acc_SFLOWOUT" ]) / 
        ((xPeriod[, "acc_WOUT" ] + xPeriod[, "acc_WFLOWOUT" ]) / 1000)
    
    xPeriod[, "F_SOL_LAYER_MIC" ] <- 
        xPeriod[, "acc_SFLOW" ] / 
        (xPeriod[, "acc_SFLOW" ] + xPeriod[, "acc_SFLOWOUT" ]) 
    
    xPeriod[ (xPeriod[, "acc_SFLOW" ] + xPeriod[, "acc_SFLOWOUT" ]) == 0, "F_SOL_LAYER_MIC" ] <- 0 
    
    xPeriod[, "F_SOL_LAYER_MAC" ] <- 
        xPeriod[, "acc_SFLOWOUT" ] / 
        (xPeriod[, "acc_SFLOW" ] + xPeriod[, "acc_SFLOWOUT" ]) 
    
    xPeriod[ (xPeriod[, "acc_SFLOW" ] + xPeriod[, "acc_SFLOWOUT" ]) == 0, "F_SOL_LAYER_MAC" ] <- 0 
    
    # #   Add the file name to the table:
    # xPeriod[, "file" ] <- x[ 1L, "file" ]
    
    #   Define the two years for the percentile calculation
    if( (prob < 0) | (prob > 1) ){
        stop( sprintf( "'prob' (%s) should be a number >= 0 and <= 1", prob ) )
    }   
    
    #   prob <- 0.8; nbAvgPer <- 1L
    
    yearsXth <- prob * nbAvgPer
    yearsXth <- c( floor(yearsXth), ceiling(yearsXth) )
    if( yearsXth[ 1L ] == yearsXth[ 2L ] ){ 
        if( (prob != 0) & (prob != 1) ){
            yearsXth[ 2L ] <- yearsXth[ 1L ] + 1L 
        }   
    }   
    
    if( (method == "test") & all( yearsXth == 0:1 ) ){
        yearsXth <- c( 1L, 1L ) 
    }   
    
    #   Handle possible negative values in the concentrations
    if( negToZero ){
        xPeriod[ xPeriod[, "CONC_PERC"  ] < 0, "CONC_PERC"  ] <- 0
        xPeriod[ xPeriod[, "CONC_TLAYER" ] < 0, "CONC_TLAYER" ] <- 0
        
    }else{
        testNegPerc <- 
            any( xPeriod[ order( xPeriod[, "CONC_PERC" ] ),  ][ yearsXth, "CONC_PERC"  ] < 0 ) 
        
        testNegLayer <- 
            any( xPeriod[ order( xPeriod[, "CONC_TLAYER" ] ), ][ yearsXth, "CONC_TLAYER" ] < 0 ) 
        
        if( testNegPerc ){
            warning( paste(
                sprintf( "Some of the concentrations used for calculating the %sth percentile are < 0", prob * 100 ), 
                "(at bottom boundary).", 
                sprintf( "Estimated %sth percentiles may differ from MACROInFOCUS GUI", prob * 100 ), 
                "Consider setting 'negToZero'-argument to TRUE"
            ) )  
        }   
        
        if( testNegLayer ){
            warning( paste(
                sprintf( "Some of the concentrations used for calculating the %sth percentile are < 0", prob * 100 ), 
                "(at target depth).", 
                sprintf( "Estimated %sth percentiles may differ from MACROInFOCUS GUI", prob * 100 ), 
                "Consider setting 'negToZero'-argument to TRUE"
            ) ) 
        }   
    }   
    
    #   Calculate the percentile-concentrations (different 
    #   methods)
    
    CONC_PERC_XTH_name <- sprintf( "concPerc%sth", 
        prob * 100 )
    
    CONC_TLAYER_XTH_name <- sprintf( "concTLayer%sth", 
        prob * 100 )
    
    if( method == "focus" ){
        assign(
            x     = CONC_PERC_XTH_name, 
            value = mean( xPeriod[ order( xPeriod[, "CONC_PERC" ] ), ][ yearsXth, "CONC_PERC" ] ) )
        
        assign(
            x     = CONC_TLAYER_XTH_name, 
            value = mean( xPeriod[ order( xPeriod[, "CONC_TLAYER" ] ), ][ yearsXth, "CONC_TLAYER" ] ) )
        
        # CONC_PERC_XTH1  <- mean( xPeriod[ order( xPeriod[, "CONC_PERC" ] ), ][ yearsXth, "CONC_PERC" ] )
        # concTLayerXth <- mean( xPeriod[ order( xPeriod[, "CONC_TLAYER" ] ), ][ yearsXth, "CONC_TLAYER" ] ) 
        
    }else if( method %in% c( "R", "test" ) ){
        assign(
            x     = CONC_PERC_XTH_name, 
            value = as.numeric( quantile( xPeriod[, "CONC_PERC" ],  probs = prob ) ) )
        
        assign(
            x     = CONC_TLAYER_XTH_name, 
            value = as.numeric( quantile( xPeriod[, "CONC_TLAYER" ], probs = prob ) ) )
        
        # CONC_PERC_XTH2  <- as.numeric( quantile( xPeriod[, "CONC_PERC" ],  probs = prob ) )
        # CONC_TLAYER_XTH2 <- as.numeric( quantile( xPeriod[, "CONC_TLAYER" ], probs = prob ) )
        
    }else{
        stop( sprintf( 
            "Argument 'method' should be 'focus', 'R' or 'test'. Now '%s'.",
            method ) )
    }   
    
    F_SOL_LAYER_MAC_XTH_name <- sprintf( "fSolYLayerMac%sth", 
        prob * 100 )
    
    F_SOL_LAYER_MIC_XTH_name <- sprintf( "fSolTLayerMic%sth", 
        prob * 100 )
    
    assign(
        x     = F_SOL_LAYER_MAC_XTH_name, 
        value = mean( xPeriod[ order( xPeriod[, "CONC_TLAYER" ] ), ][ yearsXth, "F_SOL_LAYER_MAC" ] ) )
    
    assign(
        x     = F_SOL_LAYER_MIC_XTH_name, 
        value = mean( xPeriod[ order( xPeriod[, "CONC_TLAYER" ] ), ][ yearsXth, "F_SOL_LAYER_MIC" ] ) )
    
    # F_SOL_LAYER_MAC_XTH1 <- mean( xPeriod[ order( xPeriod[, "CONC_TLAYER" ] ), ][ yearsXth, "F_SOL_LAYER_MAC" ] ) 
    # F_SOL_LAYER_MIC_XTH1 <- mean( xPeriod[ order( xPeriod[, "CONC_TLAYER" ] ), ][ yearsXth, "F_SOL_LAYER_MIC" ] ) 
    
    #   Create a list of named values that will 
    #   contain all the percentiles calculated
    out <- list( 
        "info_general" = data.frame(
            "conc_percentile"   = prob * 100,         # percentile    -> conc_percentile
            "rank_period1"      = min( yearsXth ),    # avgIndexFrom  -> rank_period1
            "rank_period2"      = max( yearsXth ),    # avgIndexTo    -> rank_period2
            "method"            = method,             # 
            "nb_sim_yrs_used"   = nbYears,            # nbSimYrsUsed   -> nb_sim_yrs_used
            "nb_yrs_per_period" = yearsAvg,           # nbYrsAvgPeriod -> nb_yrs_per_period
            "nb_yrs_warmup"     = nbYrsWarmUp,        # nbYrsWarmUp    -> nb_yrs_warmup
            "neg_conc_set_to_0" = negToZero,          # negToZero      -> neg_conc_set_to_0
            # "file"              = x[ 1L, "file" ],    #  
            stringsAsFactors    = FALSE ), 
        
        "info_period" = data.frame(
            "period_index" = xPeriod[, "avgPer" ], 
            "from_year"    = xPeriod[, "yearFrom" ], 
            "to_year"      = xPeriod[, "yearTo" ]  
        ),  
        
        "water_target_layer_by_period"  = data.frame(
            "period_index" = xPeriod[, "avgPer" ], 
            "mm_mic"       = xPeriod[, "acc_WOUT" ], 
            "mm_mac"       = xPeriod[, "acc_WFLOWOUT" ], 
            "mm_tot"       = xPeriod[, "acc_WFLOWTOT" ]
        ),  
        
        "solute_target_layer_by_period" = data.frame(
            "period_index"      = xPeriod[, "avgPer" ], 
            "mg_per_m2_mic" = xPeriod[, "acc_SFLOW" ], 
            "mg_per_m2_mac" = xPeriod[, "acc_SFLOWOUT" ], 
            "mg_per_m2_tot" = xPeriod[, "acc_SFLOWTOT" ], 
            "ug_per_L"      = xPeriod[, "CONC_TLAYER" ] 
        ),  
        
        "water_perc_by_period"  = data.frame(
            "period_index" = xPeriod[, "avgPer" ], 
            "mm"           = xPeriod[, "TFLOWOUT" ]
        ),  
        
        "solute_perc_by_period" = data.frame(
            "period_index"  = xPeriod[, "avgPer" ], 
            "mg_per_m2"     = xPeriod[, "TSOUT" ], 
            "ug_per_L"      = xPeriod[, "CONC_PERC" ] 
        ),  
        
        "conc_target_layer" = data.frame( 
            "ug_per_L"       = get( CONC_TLAYER_XTH_name ), # CONC_PERC_XTH -> ug_per_L
            # "ug_per_L_rnd"   = as.numeric( formatC(get( CONC_TLAYER_XTH_name ),format="e",digits=2L) ), # CONC_PERC_XTH -> ug_per_L
            "ug_per_L_rnd"   = signif( x = get( CONC_TLAYER_XTH_name ), digits = 3L ), # CONC_PERC_XTH -> ug_per_L
            "index_period1"  = xPeriod[ order( xPeriod[, "CONC_TLAYER" ] ), ][ min( yearsXth ), "avgPer" ],    # tLayerAvgPerFrom -> 
            "index_period2"  = xPeriod[ order( xPeriod[, "CONC_TLAYER" ] ), ][ max( yearsXth ), "avgPer" ],    # tLayerAvgPerTo -> 
            "f_solute_mac"   = get( F_SOL_LAYER_MAC_XTH_name ),      # F_SOL_LAYER_MAC_XTH -> 
            "f_solute_mic"   = get( F_SOL_LAYER_MIC_XTH_name ) ),    # F_SOL_LAYER_MIC_XTH -> 
            
        "conc_perc" = data.frame( 
            "ug_per_L"      = get( CONC_PERC_XTH_name ), # CONC_PERC_XTH -> ug_per_L
            # "ug_per_L_rnd"  = as.numeric( formatC(get( CONC_PERC_XTH_name ),format="e",digits=2L) ), # CONC_PERC_XTH -> ug_per_L
            "ug_per_L_rnd"  = signif( get( CONC_PERC_XTH_name ), digits = 3L ),
            "index_period1" = xPeriod[ order( xPeriod[, "CONC_PERC" ] ), ][ min( yearsXth ), "avgPer" ],    # percAvgPerFrom -> 
            "index_period2" = xPeriod[ order( xPeriod[, "CONC_PERC" ] ), ][ max( yearsXth ), "avgPer" ] )   # percAvgPerTo -> 
    )   
    
    if( method == "R" ){
        out[[ "info_general" ]][, "quantile_type" ] <- type
    }   
    
    return( out ) 
}   


