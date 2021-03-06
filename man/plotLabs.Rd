% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotLabs.R
\name{plotLabs}
\alias{plotLabs}
\title{Plot labs}
\usage{
plotLabs(data, lab, chart, id = FALSE, timepoint = FALSE,
  groups = FALSE, interactive = FALSE)
}
\arguments{
\item{data}{A data frame extracted from Diamonds in the `raw`` format.}

\item{lab}{A character vector of a single lab from the ObservationId column
to be plotted.}

\item{chart}{A character vector of the chart type.  Available options include
"line" or "box".}

\item{id}{A Boolean indicating if the patient medical record numbers should
be replaced with patient IDs.  If this option is selected, filter the data
first using the filterDiamonds function and specify IDs.}

\item{timepoint}{A Boolean indicating if the the name of the time point should
be displayed in place of the nubmer of days since the first time point.  If
this option is selected, filter the data first using the filterDiamonds
function and time points.}

\item{groups}{A Boolean indicating if the data should be grouped.  If this
option is selected, filter the data first using the filterDiamonds function
and specify a grouping variable.}

\item{interactive}{A Boolean indicating if the plot should interactive.  If
TRUE then plot is interactive, if FALSE then the plot is static.}
}
\value{
Returns a line plot or box plot in ggplot sytle.
}
\description{
Plots a single lab as line plot or box plot.
}
