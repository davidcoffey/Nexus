% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extractSurvival.R
\name{extractSurvival}
\alias{extractSurvival}
\title{Extract surivival information}
\usage{
extractSurvival(connection, patients = NULL,
  CaisisDiagnosis = "Multiple Myeloma",
  CaisisGroup = "Plasma Cell Neoplasm", DiamondsDiagnosis = c("C90.00",
  "C90.01", "C90.03", "203.0", "203.00", "203.01", "203.02"))
}
\arguments{
\item{connection}{ODBC connection object returned by dbConnect.}

\item{patients}{A character vector of patient medical record numbers.  If no
limit is desired then set as NULL.}

\item{CaisisDiagnosis}{Caisis diagnosis from which to extract the date of diagnoisis.  Survival
length in months will be computed from the earliest date of diagnosis between Caisis and Diamonds.}

\item{CaisisGroup}{Caisis disease group from which to extract the last known alive date.}

\item{DiamondsDiagnosis}{Diamonds ICD codes from which to extract the date of diagnoisis.  Survival
length in months will be computed from the earliest date of diagnosis between Caisis and Diamonds.}
}
\value{
Returns a data frame with PatientMRN, date of birth, last known alive date, last lab date,
and surival status and death dates from both Caisis and Diamonds databases.
From this information, the most recent date ('LastDate') is determined and the survival in
months is computed between this date and the date of earliest date of diagnosis reported in
Caisis and Diamonds ('SurvivalMonths'). The surival status is the must up-to-date status from
both Caisis and Diamonds databses. The patient is assumed alive if the status is not dead and the
CaisisLastAliveDate or the LastLabDate is within the past 6 months.
}
\description{
Extracts surival information from the Caisis and Diamonds databases and returns a data frame.
}
