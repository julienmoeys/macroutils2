
# macroutils2 2.3.1
    
*   2024/02/24 
    *   Package compiled and checked with R 4.3.2
    
    *   Fix a bug in causing .macroReadBin() to fail 
        when non-UTF-8 characters are present in column 
        names (error arrising with sub()). WARNING 
        column names may changes after this update.
    
# macroutils2 2.3.0

*   2022/06/29  Package compiled for R 4.2.0
    Fixed an "invalid UTF-8 input in readChar()" error 
    in macroReadBin that occured when running R CMD CHECK 
    on the example in the function's documentation.

# macroutils2 2.2.3
    
*   2019/04/17  Decreased the min R version supported by 
    the package to R 3.1.0. The package was nonetheless 
    not tested on this version.
    
# macroutils2 2.2.2
    
*   2019/03/26  macroutilsFocusGWConc() argument "output_lower_bound"
    was changed to two arguments "output_water" and 
    "output_solute" to finely tune whether the report 
    should include the target layer, the lower boundary 
    or both.
    
# macroutils2 2.2.1
    
*   2018/12/26  macroutilsFocusGWConc() has now a new argument 
    "output_lower_bound". default behaviour is now to return 
    water percolating at the lower boundary of the profile, 
    but neither solute mass flow nor a PEC for the lower 
    boundary (i.e. like in MACRO In FOCUS), so the user 
    does not pick the wrong PEC.
    
# macroutils2 2.2.0
    
*   2018/11/19  All example/test binary files were updated.
    FOCUS dummy substance GW-C was replaced by GW-D with 
    application every year, every other year or every third 
    year, so these configurations are tested too.
        
*   2018/11/21  In macroutilsFocusGWConc(), use signif() 
    instead of own code to round 
    concentrations like MACRO In FOCUS user interface, 
    i.e. with 3 significant figures rather than a number 
    of digits after the decimal mark.
        
*   2018/12/06  Removed non-essential tests (comparison between 
    bin-files imported by macroutils2 and converted by 
    MACRO 5.2, for biennial and triennial application 
    intervals). This saves space in the binary-package and 
    is covered by the test for annual application.
        
# macroutils2 2.1.2
    
*   2018/11/17  Small bug fix in macroutilsFocusGWConc, 
    formatting of an error message.
    
# macroutils2 2.1.1
    
*   2018/11/08  In macroutilsFocusGWConc():
    *   Fixed NaN values in the output of the fraction of 
        solute in the micropores or macropores when 
        the total solute flow was 0.
    *   Now also exports concentrations rounded like 
        in MACRO In FOCUS, in an attempt to get comparable 
        results (rounded to 2 digits after the decimal mark
        when displayed in scientific mode)
        
# macroutils2 2.1.0
    
*   2018/10/31  
    macroInFocusGWConc() renamed macroutilsFocusGWConc()
    
    macroutilsFocusGWConc() now outputs a list of data.frame.
    The new output format is documented.
    
    macroutilsFocusGWConc() now has an agrument "massunits" 
    to account for the fact that MACRO results may be 
    produced with different mass units (argument MASSUNITS 
    in MACRO).
    
    In all relevant functions (macroReadBin; macroWriteBin; 
    macroConvertBin; macroViewBin), 
    the argument "file" has been renamed "f" to avoid 
    clashes with the function file().
        
# macroutils2 2.0.1
    
*   2018/09/21  Added a new possible value for argument 
    'method' in macroInFocusGWConc(). If set to "test" 
    the function will even work on short simulations 
    used for functional tests.
    
# macroutils2 2.0.0

*   2018/08/27  Clone of the macroutils package created, 
    with the name macroutils2. The aim of macroutils2 
    is to make the source code stand in a single R-file 
    that can be loaded with one call to source(). This 
    is necessary for enabling development and debugging 
    on computers that do not include the R-infrastructure 
    for package development.
        
*   2018/09/04  macroReadBin now reads MACRO intermediate-files
    for metabolites.
    
    macroReadBin now sets automatically the number of years 
    on which average concentrations are calculated (for 
    annual, biennial or triennial application frequencies).
        
*   2018/09/11  A more generic and customisable method for 
    reading bib-files headers (column names) has been 
    implemented. The method is not 100 percent perfect, 
    but generic, and it is possible to not perform any 
    header cleaning, or to trim the column names to a 
    fixed number of characters (known before hand).
    
    The example bin-files have been replaced by 
    non-copyrighted ones (MACRO In FOCUS input and output)
    in order to avoid problems with the new licence terms 
    (MIT).
    
*   2018/09/14  The output of macroInFocusGWConc() has been 
    clarified and now only exports concentrations 
    calculated with one method (FOCUS or R percentile, 
    default to FOCUS).
    
    The default tests (in the folder tests/) have been 
    updated and improved.
        
*   2018/09/18  The function macroutilsInfo() was removed 
    from the package.
        
# macroutils2 1.15.0
    
*   2017/10/02   Compile for R 3.3.2
    
    Implement a new function, macroInFocusGWConc2(). 
    It is a variante of macroInFocusGWConc() that 
    can account for pesticide application every 
    1, 2, 3, ... year, and calculation of yearly, 
    biennial, triennial, ... average-concentrations.
    Does not replace the calculation performed 
    by the official FOCUS-tools.
    
# macroutils2 1.14.0
    
*   2016/06/08  Compile for R 3.3.0 (test)
    
# macroutils2 1.13.0
    
*   2016/02/12  macroReadIndump() now also returns a table 
    with the variables' index (in the indump.tmp)
    
# macroutils2 1.12.1
    
*   2016/01/27  Fix a bug in muPar() that prevented parameter 
    values to be set to NULL. In principle no parameter 
    was concerned (as no parameter need to be set to 
    NULL), so this bug had no effects.
    
# macroutils2 1.12.0

*   2015/12/08  macroBugFixCleanDb() now issues a warning 
    message if not run in R 32 bit (i386), as RODBC 
    for MS Access works (only?) with R 32 bit.
    
    macroBugFixCleanDb() now also attempts to fix a 
    bug that appear when increasing (changing) the 
    number of numerical layers. It seems some values 
    in the parameter table `OutputLayers` (new numerical 
    layers) have their column `Selected` empty, instead 
    of 0 or 1. The bug fix will also attempt to fix 
    value in `OutputLayers` that are present despite 
    the parameter in `Output()` having selected set 
    to 0.
    
# macroutils2 1.11.0
    
*   2015/11/02  macroInFocusGWConc() now calculates the 
    mass fraction of the pesticide flow that is 
    due to micropore or/versus macropore transport.
    This experimental feature aims at estimating the 
    importance of macropore flow in the calculated 
    concentration.
    
# macroutils2 1.10.1
    
*   2015/10/09  macroInFocusGWConc() now checks for negative 
    concentrations in the 80th percentile (or can set 
    negative concentrations to 0)
    
# macroutils2 1.10.0
    
*   2015/10/09  Implemented more strict tests / benchmarks 
    between macroReadBin() and bin-file conversion 
    performed by MACRO 5.2. Should be able to detect 
    unwanted accidental changes in macroReadBin() 
    (at least in terms of numerical accuracy)
    
    Also included a simple benchmark in macroInFocusGWConc()
    on concentration and percolation.
        
# macroutils2 1.9.0
    
*   2015/10/08  Added the function macroInFocusGWConc() 
    to calculate pesticide concentrations from MACROInFOCUS 
    output bin file(s). Internal and experimental.
    
CHANGE SIN VERSION 1.8.4
    
*   2015/09/23  Added an 'overwrite' agument to 
    macroConvertBin(), and fixed a bug that caused an 
    interactive question to be asked to the user even 
    when 'gui' was FALSE and the output files already 
    existed. Now if 'overwrite' is FALSE and 'gui' is 
    TRUE a question is asked to the user, and otherwise 
    if 'gui' is FALSE and 'overwrite' is FALSE, an 
    error is issued when files already exists.

    A sub-section was added in the vignette that describes 
    how to perform a batch conversion of files with 
    macroConvertBin(), including listing all the bin 
    files in a folder.
    
# macroutils2 1.8.3

*   2015/07/23  Added the function isValidTimeSeries(), used
    internally to check that time series read from or 
    written to BIN-files are consistent (increasing, 
    homogeneous increment and no duplicated values).
    
# macroutils2 1.8.2
    
*   2015/04/17  Compiled for R 3.2.0 RC (2015-04-15 r68178).
    
    Cleaned-up internal call to library() or require() 
    and use :: instead (+ Depends or Suggests or Import 
    fields in package DESCRIPTION)
    
*   2015/05/04  Compiled for R 3.2.0 Official release.
    
# macroutils2 1.8.1
    
*   2015/03/17  Moved from a local SVN to a public git (GitHub) 
    repository. Last SVN version was 18:52M (macroutils 1.8.0)
    
# macroutils2 1.8.0
    
*   2015/03/17  From now on macroutils will contain only "official" 
    MACRO routines and utilities, and the routines related 
    to crop growth (under development) have been moved to 
    another R package, macrocrop (not publicly released).
    
    macroutils was split for SVN version "18:50M" (macroutils 
    version 1.7.4).
        
# macroutils2 1.7.4
    
*   2014/12/08  Bug fix in macroLAI()
    
# macroutils2 1.7.3

*   2014/09/28  Compiled for R 3.1.1
    
# macroutils2 1.7.2

*   2014/07/03  Added the function macroutilsInfo() that fetches 
    and return a rather comprehensive report on system info 
    and package(s) version(s) and MD5, either for macroutils 
    or for any other package
    
    SVN revision is now displayed when the package is attached
        
# macroutils2 1.7.1
    
*   2014/05/28 to 2014/06/03    Attempts to improve the LAI-calculations 
    for multiple crops. Did not work in some cases.
    
# macroutils2 1.7.0
    
*   2014/05/26  Now macroLAI() can handle a data.frame of 
    crop parameters (multiple crops).
    
    Parameter "Date" in macroLAI() renamed 'x'
    
    macroIntercept() parameters now simplified
    
# macroutils2 1.6.2
    
*   2014/05/22  fixed a bug in macroLAI() and macroRootDepth() 
    and macroRootDensity(): parameters iharv and laiharv renamed 
    iharv and laihar (now correct)
    
    bug fix: macroPlot() was not always identifying correctly 
    when given a list of data.frame to plot
    
# macroutils2 1.6.1
    
*   2014/05/22  macroPlot() now includes a parameter 'z' for 
    pre-selecting the variables to include in the graph
    
# macroutils2 1.6.0

*   2014/05/15  Included macroLAI() and macroIntercept() to calculate 
    total and green LAI a-la-MACRO and the fraction of irrigation 
    water intercepted by the crop vegetation.
    
# macroutils2 1.5.0

*   2014/05/12  Included macroRootDepth() and macroRootDensity(), 
    functions to estimate root depth and density as in 
    MACRO

# macroutils2 1.4.0
    
*   2014/05/12  Included a bug-fix for MACRO GUI parameter database, 
    macroBugFixCleanDb(), that remove orphan and duplicated 
    values in the table `Output()`. Might be deleted when 
    the bug has been fixed in MACRO GUI.
    
# macroutils2 1.3.0
    
*   2014/03/19
    
    macroReadBin() now output macroTimeSeries or 
    macroTimeSeriesList objects (class), instead of 
    macroData and macroDataList
    
    Some functions made S3 generic and S3 methods, to favour 
    future extensions.
    
    macroPlot() created, generic and method function to plot 
    macroTimeSeries and macroTimeSeriesList, as well 
    as bin files (with GUI). Superseeds macroPlotBin() 
    
    A bug was fixed in macroPlot() background grid, which 
    were not displayed at the right place on the X-axis, 
    because of the POSIXct time format (incompatible with 
    grid()).
    
    macroPlot() now uses a ggplot2-style for axes, grid and 
    background color.
    
    macroPlot() now uses hcl() to generate default variable 
    colors (it looks nicer)

# macroutils2 1.2.7

*   2013/04/24 Compiled on R 3.0.0

# macroutils2 1.2.6
 
*   2013/04/22
        
    The package was renamed from "soilmacroutils" to 
    "macroutils"
    
    The internal documentation was migrated to Roxygen2
    
    SMU.readBin()   renamed to macroReadBin()
    .SMU.readBin()  renamed to .macroReadBin() (internal)
    SMU.writeBin()  renamed to macroWriteBin()
    SMU.plot()      renamed to macroPlotBin()
    SMU.aggregate() renamed to macroAggregateBin()
    SMU.convert()   renamed to macroConvertBin()
    SMU.view()      renamed to macroViewBin()
    smuPar()        renamed to muPar()
    getSmuPar()     renamed to getMuPar()
    
# macroutils2 1.2.5 
 
*   2013/04/08 Fixed a bug in .SMU.rmRunID() that was not 
    systematically removing the RUN_ID from the column 
    names of MACRO simulation results.

# macroutils2 1.2.3 

*   2012/11/19 Created a vignette (tutorial).

# macroutils2 1.2.2 

*   2012/11/19 SMU.convert can now converts binary files into 
    text files with tabulation or a multiple spaces 
    as a field separator.

# macroutils2 1.2.1 (labelled 1.1.8) 
 
*   2012/11/16 Improved legend for single plots in SMU.plot(). 
    
    Fixed a bug when plotting just one variable 
    after a multi-variable plot.

# macroutils2 1.2.0 (labelled 1.1.7) 
 
*   2012/11/16 New option system, smuPar() and getSmuPar() 
    SMU.readBin() now has much less arguments.

    SMU.plot() now has a "menu" to change the 
    variables plotted, the plot style, or to 
    zoom in and out.

    The file chooser in the GUI now remembers 
    the last location.
              
# macroutils2 1.1.6 
 
*   2012/11/15 Corrected a bug in SMU.plot() occuring when 
    only one variable was selected

    Added SMU.convert() to convert binary files into 
    CSV text files

    Added SMU.view() to view the content of binary 
    files in a user friendly way. 

# macroutils2 1.1.5 
 
*   2012/11/14 SMU.readBin() and SMU.plot() now have a complete 
    GUI (simple, but portable). 

    SMU.plot() have been changed heavily, and 
    does not rely any more on 'ggplot2'.

    SMU.rmRunID() becomes .SMU.rmRunID() 
    (hidden)
    
# macroutils2 1.1.4 

*   2012/05/10 Added SMU.rmRunID to remove Run ID from MACRO 
    results column names. Also as an option in 
    SMU.readBin

# macroutils2 1.1.3 and before

*   2010/09/08 Version 1.0 of the package. Documented.
   
*   2010/10/28 New read and write bin functions by Christian 
    Persson.
   
*   2010/10/28 Examples bin with the bin file from the Soil 
    program.
   
*   2011/04/14 Added SMU.aggregate(), to aggregate simulation 
    results by hours or month, etc.
   
*   2011/05/12 Fixed a bug with ggplot2 and SMU.plot() for 
    long time series (Date format needed) 
              
*   2011/10/19 Added a "header" argument to SMU.readBin and 
    SMU.writeBin so weather files without header 
    can be read.
