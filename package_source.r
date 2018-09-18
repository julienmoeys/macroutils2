
rm(list=ls(all=TRUE)) 

pkgName <- "macroutils2"
setwd( file.path( Sys.getenv( x = "rPackagesDir" ), pkgName ) )

#   Source macroutils2
source( "R/macroutils2.r" )
