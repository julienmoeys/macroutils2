
# +--------------------------------------------------------+
# | Generate package documentation pages from inline       |
# | documentation. Build, check and install package        |
# +--------------------------------------------------------+

rm(list=ls(all=TRUE)) 

prjName  <- "macrounchained" 
pkgName  <- "macroutils2" 
pkgDir   <- Sys.getenv( x = "rPackagesDir", unset = NA_character_ ) 
if( is.na( pkgDir ) ){ 
    stop( "Variable 'rPackagesDir' not defined." ) 
}else{ pkgDir <- file.path( pkgDir, prjName ) }
buildDir <- file.path( pkgDir, pkgName, "_package_binaries" )
local_repos <- Sys.getenv( x = "rPackagesLocalRepos", 
    unset = NA_character_ ) 
if( is.na( local_repos ) ){ 
    stop( "Variable 'rPackagesLocalRepos' not defined." ) 
}else{ local_repos <- file.path( local_repos, prjName ) }

setwd( pkgDir )

# Source some utility functions (prefix: pdu_)
source( file.path( pkgName, "pkg_dev_utilities.fun.r" ) ) 

pdu_detach( pkgName = pkgName )



# +--------------------------------------------------------+
# | Generate package documentation pages from inline       |
# | documentation.                                         |
# +--------------------------------------------------------+

# Change the description file:
pdu_pkgDescription( 
    pkgName     = pkgName, 
    pkgDir      = pkgDir, 
    pkgVersion  = "2.2.0", 
    pkgDepends  = "utils", # Must be in "Depends" as choose.files not available on Unix
    pkgImports  = c( "tcltk", "graphics", "grDevices", "stats" ), # "tools", 
    pkgSuggests = c( "RODBC" ), 
    RVersion    = NULL 
)   



library( "roxygen2" )

roxygen2::roxygenize( 
    package.dir   = file.path( pkgDir, pkgName ), 
    # unlink.target = TRUE, 
    roclets       = c( "namespace", "rd" ) # "collate" 
)   


# pdu_pkgRemove( pkgName = pkgName ) 



# +--------------------------------------------------------+
# | Run R CMD build (build tar.gz source binary)           |
# | Run R CMD check (check package)                        |
# | Run R CMD INSTALL (build Windows binary and install)   |
# +--------------------------------------------------------+

# # Source some utility functions (prefix: pdu_)
# source( file.path( pkgName, "pkg_dev_utilities.fun.r" ) ) 

pdu_rcmdbuild( pkgName = pkgName, pkgDir = pkgDir, 
    buildDir = buildDir, gitRevison = TRUE, 
    noVignettes = FALSE, compactVignettes = "gs+qpdf", 
    md5 = TRUE )

pdu_rcmdinstall( pkgName = pkgName, pkgDir = pkgDir, 
    buildDir = buildDir, build = TRUE, 
    compactDocs = TRUE, byteCompile = TRUE )

pdu_rcmdcheck( pkgName = pkgName, pkgDir = pkgDir, 
    buildDir = buildDir, noExamples = FALSE, 
    noTests = FALSE, noVignettes = FALSE )
#   1 NOTE because of package size cannot be mitigated

#   Remove .Rcheck folder
pdu_rm_Rcheck( pkgName = pkgName, pkgDir = pkgDir, 
    buildDir = buildDir )

#   Load and unload the package:
library( pkgName, character.only = TRUE )
pdu_detach( pkgName = pkgName )



# +--------------------------------------------------------+
# | Rebuild vignette (optional)                            |
# +--------------------------------------------------------+

# # Source some utility functions (prefix: pdu_)
# source( file.path( pkgName, "pkg_dev_utilities.fun.r" ) ) 

# pdu_build_vignette( RnwFile = "macroutils2_vignette.Rnw", 
    # pkgName = pkgName, pkgDir = pkgDir, buildDir = buildDir, 
    # pdf = TRUE, quiet = TRUE )   



# +--------------------------------------------------------+
# | Build PDF-version of the manual (help pages)           |
# +--------------------------------------------------------+

# # Source some utility functions (prefix: pdu_)
# source( file.path( pkgName, "pkg_dev_utilities.fun.r" ) ) 

pdu_rd2pdf( pkgName = pkgName, pkgDir = pkgDir, 
    buildDir = buildDir )



# +--------------------------------------------------------+
# | Copy source and zip binaries to local repos            |
# +--------------------------------------------------------+

pdu_copy_to_repos( pkgName = pkgName, pkgDir = pkgDir, 
    buildDir = buildDir, local_repos = local_repos )
