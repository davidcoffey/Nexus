#' Filter Data
#'
#' Filters and renames extracted Diamonds data by specified time points.
#'
#' @param data A data frame extracted from the Diamonds database in "raw" format.
#' @param patients A required character vector of patient medical record numbers.
#' @param ids An optional character vector of patient identifiers in the same
#' order as patients.  If provided, a new column titled "PatientId" is added
#' to the output data frame.
#' @param dates A required date vector in the same order as patients
#' corresponding to the dates to filter the data with.  There may be multiple
#' dates per patient as long as the order remains the same.
#' @param timepoints An optional character vector in the same order as dates
#' corresponding to a description of the timepoint.  If provided, a new column
#' titled "TimePoints" is added to the output data frame.
#' @param groups An optional character vector of patient groupings in the same
#' order as patients.  If provided, a new column titled "Groups" is added
#' to the output data frame.
#' @param range A character vector specifying the range of dates for each time
#' point to be extracted.  Available options include "on", "before", "after",
#' and  "within".  If "within" is selected a range of values must be provided in
#' the "within" argument.
#' @param within An integer vector of length 2 providing the number of dates
#' before and after each time point to filter.  For example, c(-14, 14) would
#' indicate that all dates less than or greater than 14 days of the specified
#' time point are to be filtered.
#' @param multiple An optional character vector for how to handle multiple lab
#' results available for the same patient.  If "closet", then the lab result
#' closet to the timepoint is given.  If "furthest", the the lab result
#' furthest to the timepoint is given.  If NULL, then all test results
#' that satisfiy the filter criteria are given.
#' @param format A character vector indicating the output format.  Options
#' include "raw", "byObservationId", "byDaysFromFirstTimePoint",
#' "byObservationDate", or "byTimePoint".
#' @param observation.column A character vector indicating the name of the column
#' corresponding to the observation.
#' @param date.column A character vector indicating the name of the column
#' corresponding to the observation date.
#' @param value.column A character vector indicating the value of the observation.
#' @param na.rm A Boolean indicating whether rows with NA valules should be
#' removed.
#' @return Returns a data frame with patient observations from the Diamonds
#' filtered by the desired dates.  A new column is added giving
#' the number of days from the first specified time point.  Optionally, additional
#' columns for Groups, Timepoints, and PatientIds are added if specified.
#' @export
#' @importFrom reshape melt cast
#' @importFrom stats na.omit
filterData <- function(data, patients, ids = NULL, dates, timepoints = NULL,
                       groups = NULL, range = "on", within = NULL,
                       format = "raw", na.rm = FALSE, multiple = NULL, date.column = "ObservationDate",
                       observation.column = "ObservationId", value.column = "ObservationValueNumeric") {
    if(!length(patients) == length(dates)){stop("The length of patients and dates are not the same", call. = FALSE)}
    filtered.all <- data.frame()
    i = 1
    for(i in 1:length(patients)){
        patient <- as.character(patients)[i]
        date <- as.Date(dates)[i]
        if(range == "on"){
            filtered = data[data$PatientMRN == patient & data[,date.column] == date,]
        }
        if(range == "after"){
            filtered = data[data$PatientMRN == patient & data[,date.column] >= date,]
        }
        if(range == "before"){
            filtered = data[data$PatientMRN == patient & data[,date.column] <= date,]
        }
        if(range == "within"){
            if(is.null(within)){stop("Please specify a day range using the 'within' parameter", call. = FALSE)}
            filtered = data[data$PatientMRN == patient &
                                (data[,date.column] >= date + min(within)) &
                                (data[,date.column] <= date + max(within)),]
        }
        filtered$DaysFromFirstTimePoint <- as.integer(filtered[,date.column] - min(as.Date(dates[which(patients == patient)])))
        if(na.rm == TRUE){
            filtered = na.omit(filtered)
        }
        if(nrow(filtered) != 0){
            if(!is.null(multiple)){
                if(multiple == "closest"){
                    filtered.min = aggregate(data = filtered, as.formula(paste("DaysFromFirstTimePoint~PatientMRN+", observation.column)), min)
                    filtered = merge(filtered, filtered.min)
                }
                if(multiple == "furthest"){
                    filtered.max = aggregate(data = filtered, as.formula(paste("DaysFromFirstTimePoint~PatientMRN+", observation.column)), max)
                    filtered = merge(filtered, filtered.max)
                }
            }
            if(!is.null(ids)){
                filtered$PatientId <- as.character(ids)[i]
            }
            if(!is.null(timepoints)){
                filtered$TimePoint <- as.character(timepoints)[i]
            }
            if(!is.null(groups)){
                filtered$Groups <- as.character(groups)[i]
            }
            filtered.all <- rbind(filtered.all, filtered)
        } else {
            warning(paste("No observations for patient", patient, "within the specified range of", date), call. = FALSE)
        }
    }
    if(format == "raw") {
        return(droplevels(filtered.all))
    }
    if(format == "byObservationId") {
        melt <- reshape::melt(filtered.all, id = c("PatientMRN", date.column, observation.column),
                     measure.vars = value.column)
        cast <- reshape::cast(melt, as.formula(paste("PatientMRN +", date.column, "~ ObservationId")), mean, fill ="")
        if(!is.null(groups)){
            cast <- merge(unique(data.frame(PatientMRN = patients, Groups = groups)), cast)
        }
        if(!is.null(ids)){
            cast <- merge(unique(data.frame(PatientMRN = patients, PatientId = ids)), cast)
        }
        return(cast)
    }
    if(format == "byDaysFromFirstTimePoint") {
        melt <- reshape::melt(filtered.all, id = c("PatientMRN", "DaysFromFirstTimePoint", observation.column),
                     measure.vars = value.column)
        cast <- reshape::cast(melt, as.formula(paste("PatientMRN + ", observation.column, "~ DaysFromFirstTimePoint")), mean, fill = "")
        if(!is.null(groups)){
            cast <- merge(unique(data.frame(PatientMRN = patients, Groups = groups)), cast)
        }
        if(!is.null(ids)){
            cast <- merge(unique(data.frame(PatientMRN = patients, PatientId = ids)), cast)
        }
        return(cast)
    }
    if(format == "byObservationDate") {
        melt <- reshape::melt(filtered.all, id = c("PatientMRN", date.column, observation.column),
                     measure.vars = value.column)
        cast <- reshape::cast(melt, as.formula(paste("PatientMRN + ObservationId ~", date.column)), mean, fill = "")
        if(!is.null(groups)){
            cast <- merge(unique(data.frame(PatientMRN = patients, Groups = groups)), cast)
        }
        if(!is.null(ids)){
            cast <- merge(unique(data.frame(PatientMRN = patients, PatientId = ids)), cast)
        }
        return(cast)
    }
    if(format == "byTimePoint") {
        melt <- reshape::melt(filtered.all, id = c("PatientMRN", "TimePoint", observation.column),
                              measure.vars = value.column)
        cast <- reshape::cast(melt, as.formula(paste("PatientMRN + ", observation.column, "~ TimePoint")), mean, fill = "")
        if(!is.null(groups)){
            cast <- merge(unique(data.frame(PatientMRN = patients, Groups = groups)), cast)
        }
        if(!is.null(ids)){
            cast <- merge(unique(data.frame(PatientMRN = patients, PatientId = ids)), cast)
        }
        return(cast)
    }
}
