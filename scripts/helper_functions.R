# helper_functions.R

# Helper Functions for Cyclistic Bike-Share Analysis
# This file contains utility functions for data processing and visualization
# Used across the analysis pipeline

# Libraries
library(tidyverse)
library(lubridate)

# Calculate ride duration in minutes
#' @param start_time POSIXct start time of ride
#' @param end_time POSIXct end time of ride
#' @return numeric duration in minutes
#' 
calculate_ride_duration <- function(start_time, end_time) {
  as.numeric(difftime(end_time, start_time, units = "mins"))
}

#' Add time-based features to the dataset
#' @param df dataframe containing started_at column
#' @return dataframe with additional time-based columns
#' 
add_time_features <- function(df) {
  df %>%
    mutate(
      hour = hour(started_at),
      day_of_week = wday(started_at, label = TRUE),
      month = month(started_at, label = TRUE),
      is_weekend = day_of_week %in% c("Sat", "Sun"),
      time_of_day = case_when(
        hour >= 5 & hour < 12 ~ "Morning",
        hour >= 12 & hour < 17 ~ "Afternoon",
        hour >= 17 & hour < 22 ~ "Evening",
        TRUE ~ "Night"
      )
    )
}