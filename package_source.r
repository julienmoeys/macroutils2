
rm(list=ls(all=TRUE)) 

#   Project name
prjName <- "macrounchained"

#   Package name (in the project)
pkgName <- "macroutils2"

setwd( file.path( Sys.getenv( x = "rPackagesDir" ), prjName, 
    pkgName ) )

#   Source rmacrolite
source( sprintf( "R/%s.r", pkgName ) )
