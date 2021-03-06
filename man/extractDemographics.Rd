% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extractDemographics.R
\name{extractDemographics}
\alias{extractDemographics}
\title{Extract demographics}
\usage{
extractDemographics(connection, patients = NULL, n = -1)
}
\arguments{
\item{connection}{ODBC connection object returned by dbConnect.}

\item{patients}{A character vector of patient medical record numbers.  If no
limit is desired then set as NULL.}

\item{n}{Number of records to retrieve.  Use n = -1 to retrieve all records.}
}
\value{
Returns a data frame with patient demographics from the Diamonds database.
PatientAge and PatientAgeGroup are added columns calculated from today's date.
RacialGroup column is also added which aggregates similar races into a single group.
}
\description{
Extracts patient demographics from the Diamonds database and returns a data frame.
}
