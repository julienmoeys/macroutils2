% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/macroutils2.r
\name{macroPlot}
\alias{macroPlot}
\alias{macroPlot.macroTimeSeries}
\alias{macroPlot.macroTimeSeriesList}
\alias{macroPlot.data.frame}
\alias{macroPlot.default}
\title{Plot time series from SOIL or MACRO simulation data (input or output).}
\usage{
macroPlot(x, ...)

\method{macroPlot}{macroTimeSeries}(x, ...)

\method{macroPlot}{macroTimeSeriesList}(x, ...)

\method{macroPlot}{data.frame}(x, ...)

\method{macroPlot}{default}(
  x,
  gui = TRUE,
  z = NULL,
  subPlots = TRUE,
  verbose = TRUE,
  xlab = "Date",
  ylab = NULL,
  ylim = NULL,
  xlim = NULL,
  col = NULL,
  sub = NULL,
  lwd = 2L,
  lty = NULL,
  main = NULL,
  cex.main = NULL,
  panel.first = .paf(),
  dLegend = TRUE,
  las = 1L,
  bty = "n",
  ...
)
}
\arguments{
\item{x}{A single \code{\link[base]{data.frame}}, or a
\code{\link[base]{list}} of \code{data.frame} containing the data to be
plotted. Each \code{data.frame} must have at least two columns: one column
\code{Date} containing dates in \code{\link[base:DateTimeClasses]{POSIXct}} format (see
\code{\link[base]{DateTimeClasses}}), and one or more named columns of data
in some numerical formats. Such \code{data.frame} will presumably be
imported from \code{bin} files, with \code{\link[macroutils2:macroReadBin-methods]{macroReadBin}}. If missing,
a pop-up menu will ask you the binary files to be read and that contains the
variables to be plotted.}

\item{\dots}{Additional arguments passed to \code{\link[graphics]{plot}} and
to \code{\link[graphics]{lines}} (when \code{subPlots} is \code{FALSE}).  See
also \code{\link[graphics]{plot.default}}.}

\item{gui}{Single logical. Set to \code{TRUE} if you want to choose only some
of the columns in the table passed to \code{x}. Will be ignored if
\code{\link[base]{interactive}} is \code{FALSE} (i.e.  if ran outside R GUI
for Windows).}

\item{z}{Vector of character strings. Name of the variables to include 
in the graph. If \code{NULL}, all variables in 'x' are included, 
and if \code{gui} is \code{TRUE}, the user is asked with variable 
should be included.}

\item{subPlots}{Single logical. If \code{TRUE} (default), all the variables
in \code{x} will be plotted in separated sub-plots, with sub-plots on top of
each others. If \code{FALSE}, all the variables in \code{x} will be plotted
in the same plot, on top of each other, with the same Y axis. If \code{gui}
is \code{TRUE}, \code{subPlots} is ignored, and a menu will ask you what to
do.}

\item{verbose}{Single logical. If \code{TRUE}, some text message will be
displayed on the console to explain what is going on.}

\item{xlab}{See \code{\link[graphics]{plot.default}}. A single character
string.  Label of the 'x' axis.}

\item{ylab}{See \code{\link[graphics]{plot.default}}. A vector of character
strings of length one or of the same length as the variables in (or chosen
from) \code{x}.}

\item{ylim}{See \code{\link[graphics]{plot.default}}.}

\item{xlim}{See \code{\link[graphics]{plot.default}}.}

\item{col}{See \code{\link[graphics]{plot.default}} or
\code{\link[graphics]{lines}}. Vector of character strings, line colors.}

\item{sub}{See \code{\link[graphics]{plot}} or \code{\link[graphics]{title}}.
Vector of character strings, sub-titles of each plot.}

\item{lwd}{See \code{\link[graphics]{plot.default}} or
\code{\link[graphics]{lines}}. Vector of integers, line widths (thicknesses).}

\item{lty}{See \code{\link[graphics]{plot.default}}. a vector of line types.}

\item{main}{See \code{\link[graphics]{plot.default}}. Plot title(s).}

\item{cex.main}{See \code{\link[graphics]{par}}. Title(s) expansion factor.}

\item{panel.first}{See \code{\link[graphics]{plot.default}}.}

\item{dLegend}{Single logical value. If \code{TRUE} and \code{subPlots=FALSE}
and more than one variable is plotted, a legend is drawn above the plot (with
distinct colors for each variables).}

\item{las}{See \code{\link[graphics]{par}}.}

\item{bty}{See \code{\link[graphics]{par}}.}
}
\value{
Invisibly returns 'x', or the content of the files selected.
}
\description{
Plot time series from SOIL or MACRO simulation data (input or output). When
 \code{x} is missing and/or \code{gui} is \code{FALSE}, the function pops-up
 menu asking the user which file(s) and which variable(s) to plot, and how.
}
\examples{

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
out2 <- out2[ out2[, "Date" ] \%in\% out1[, "Date" ], ]


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
}
