# data_prep.R

# Define cleaning function
clean_cyclistic_data <- function(data) {
  # Define Chicago boundaries
  chicago_bounds <- list(
    lat_min = 41.6, lat_max = 42.1,
    lng_min = -87.9, lng_max = -87.5
  )
  
  # Initial cleaning
  cleaned_data <- data %>%
    # Filter for valid start and end times, and within the time frame
    filter(
      !is.na(started_at),
      !is.na(ended_at),
      ended_at > started_at,
      difftime(ended_at, started_at, units = "hours") < 24,
      difftime(ended_at, started_at, units = "mins") >= 1  # Added minimum duration check
    ) %>%
    # Geographic validation within Chicago boundaries
    filter(
      start_lat >= chicago_bounds$lat_min & start_lat <= chicago_bounds$lat_max &
        start_lng >= chicago_bounds$lng_min & start_lng <= chicago_bounds$lng_max &
        end_lat >= chicago_bounds$lat_min & end_lat <= chicago_bounds$lat_max &
        end_lng >= chicago_bounds$lng_min & end_lng <= chicago_bounds$lng_max
    )
  
  # Calculate distance between coordinates
  cleaned_data <- cleaned_data %>%
    mutate(
      ride_distance_km = distHaversine(
        cbind(start_lng, start_lat),
        cbind(end_lng, end_lat)
      ) / 1000
    )
  
  # Enrich data with additional features
  enriched_data <- cleaned_data %>%
    mutate(
      # Time-based calculations
      ride_length_mins = as.numeric(difftime(ended_at, started_at, units = "mins")),
      day_of_week = wday(started_at, label = TRUE),
      month = month(started_at, label = TRUE),
      hour_of_day = hour(started_at),

      # Seasonal and time period categorization
      season = case_when(
        month %in% c("Dec", "Jan", "Feb") ~ "Winter",
        month %in% c("Mar", "Apr", "May") ~ "Spring",
        month %in% c("Jun", "Jul", "Aug") ~ "Summer",
        TRUE ~ "Fall"
      ),
      is_weekend = wday(started_at) %in% c(1, 7),

      ride_period = case_when(
        hour_of_day >= 6 & hour_of_day < 10 ~ "Morning Rush",
        hour_of_day >= 10 & hour_of_day < 16 ~ "Mid-Day",
        hour_of_day >= 16 & hour_of_day < 19 ~ "Evening Rush",
        TRUE ~ "Night"
      ),
      
      # Distance and speed metrics
      speed_kph = (ride_distance_km / (ride_length_mins/60)),
      
      # Round trip indicators
      is_round_trip = case_when(
        is.na(start_station_id) | is.na(end_station_id) ~ NA,
        start_station_id == end_station_id ~ TRUE,
        TRUE ~ FALSE
      ),

      # Station validity status
      start_station_valid = !is.na(start_station_name),
      end_station_valid = !is.na(end_station_name),
      station_status = case_when(
        start_station_valid & end_station_valid ~ "Both Valid",
        start_station_valid & !end_station_valid ~ "Start Only",
        !start_station_valid & end_station_valid ~ "End Only",
        TRUE ~ "Neither Valid"
      )
    )
  
  # Final filtering
  final_data <- enriched_data %>%
    # Remove rides with unrealistic speeds and distances
    filter(
      speed_kph <= 35 | is.na(speed_kph),                # Maximum reasonable biking speed in urban environment
      ride_distance_km <= 15 | is.na(ride_distance_km)   # Maximum reasonable trip distance for bike share
    )
  
  # Generate quality report
  quality_report <- list(
    initial_rows = nrow(data),
    final_rows = nrow(final_data),
    rows_removed = nrow(data) - nrow(final_data),
    pct_rows_kept = (nrow(final_data) / nrow(data)) * 100,
    pct_missing_stations = mean(is.na(final_data$start_station_name)) * 100,
    avg_ride_length = mean(final_data$ride_length_mins),
    median_ride_length = median(final_data$ride_length_mins),
    pct_valid_coordinates = mean(!is.na(final_data$ride_distance_km)) * 100,
    pct_complete_station_data = mean(final_data$station_status == "Both Valid") * 100
  )
  
  return(list(
    clean_data = final_data,
    quality_metrics = quality_report
  ))
}

# Process the data
results <- clean_cyclistic_data(cyclistic_data)
cleaned_cyclistic_data <- results$clean_data
quality_report <- results$quality_metrics

# Create validation summary
station_comparison <- cleaned_cyclistic_data %>%
  group_by(station_status) %>%
  summarize(
    total_rides = n(),
    pct_of_total = n() / nrow(cleaned_cyclistic_data) * 100,
    avg_duration = mean(ride_length_mins),
    avg_distance = mean(ride_distance_km, na.rm = TRUE),
    pct_members = mean(member_casual == "member") * 100,
    .groups = 'drop'
  )

# Filter for complete station data
complete_rides <- cleaned_cyclistic_data %>%
  filter(station_status == "Both Valid")

# Make the data available to other scripts
assign("cleaned_cyclistic_data", cleaned_cyclistic_data, envir = .GlobalEnv)
assign("quality_report", quality_report, envir = .GlobalEnv)
assign("complete_rides", complete_rides, envir = .GlobalEnv)
assign("station_comparison", station_comparison, envir = .GlobalEnv)

