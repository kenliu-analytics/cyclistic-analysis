# data_loading.R

# Data Loading Script for Cyclistic Analysis
# Handles the import and initial processing of raw CSV files
# Expects data files in ./data/raw/ directory

# Import and standardize monthly Cyclistic data
#' @param filename Name of the CSV file to import
#' @return Standardized dataframe with consistent column names and data types
#' 
import_monthly_data <- function(filename) {
  read_csv(
    file.path(data_dir, filename),
    col_types = cols(
      ride_id = col_character(),
      rideable_type = col_factor(),
      started_at = col_datetime(),
      ended_at = col_datetime(),
      start_station_name = col_character(),
      start_station_id = col_character(),
      end_station_name = col_character(),
      end_station_id = col_character(),
      start_lat = col_double(),
      start_lng = col_double(),
      end_lat = col_double(),
      end_lng = col_double(),
      member_casual = col_factor()
    )
  ) %>%
    clean_names()
}

# Set data directory
data_dir <- here::here("data", "raw")

# Import and combine all monthly files
tryCatch(
  {
    cyclistic_data <- list.files(
    path = data_dir,
    pattern = "*.csv",
    full.names = FALSE
    ) %>%
    map_df(import_monthly_data)
  },
  error = function(e){
    stop("Error loading data files: ", e$message)
  }
)

# Validation checks after import
validate_imported_data <- function(df) {
  stopifnot(
    "Missing required columns" = 
      all(c("ride_id", "started_at", "ended_at") %in% names(df))
  )
}

assign("cyclistic_data", cyclistic_data, envir = .GlobalEnv)