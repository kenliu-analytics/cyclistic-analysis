# analysis_functions.R

# Network Analysis Functions
# Analyzes the connections between stations with minimum trip threshold

# Load required libraries
library(tidyverse)
library(ggplot2)
library(scales)
library(igraph)
library(sf)
library(patchwork)
library(viridis)

# Temporal patterns analysis function

analyze_temporal_patterns <- function(data) {
  # Hourly patterns
  hourly <- data %>%
    group_by(member_casual, hour_of_day) %>%
    summarize(
      rides = n(),
      avg_duration = mean(ride_length_mins),
      .groups = "drop"
    )
  
  # Weekly patterns
  weekly <- data %>%
    group_by(member_casual, day_of_week, is_weekend) %>%
    summarize(
      rides = n(),
      avg_duration = mean(ride_length_mins),
      .groups = "drop"
    )
  
  # Seasonal patterns
  seasonal <- data %>%
    group_by(member_casual, season, month) %>%
    summarize(
      rides = n(),
      avg_duration = mean(ride_length_mins),
      .groups = "drop"
    )
  
  return(list(hourly = hourly, weekly = weekly, seasonal = seasonal))
}


# Trip characteristics analysis function

analyze_trip_characteristics <- function(data) {
  # Basic trip metrics
  trip_metrics <- data %>%
    group_by(member_casual) %>%
    summarize(
      total_rides = n(),
      avg_duration = mean(ride_length_mins),
      avg_distance = mean(ride_distance_km),
      pct_round_trips = mean(is_round_trip) * 100,
      .groups = "drop"
    )
  
  # Distance distribution
  distance_dist <- data %>%
    group_by(member_casual) %>%
    summarize(
      q25 = quantile(ride_distance_km, 0.25),
      median = median(ride_distance_km),
      q75 = quantile(ride_distance_km, 0.75),
      .groups = "drop"
    )
  
  return(list(metrics = trip_metrics, distance_dist = distance_dist))
}

# Popular routes and stations analysis function
analyze_popular_routes <- function(data, top_n = 20) {
  # Most popular routes
  popular_routes <- data %>%
    group_by(
      start_station_name, 
      end_station_name, 
      member_casual
    ) %>%
    summarize(
      total_trips = n(),
      avg_duration = mean(ride_length_mins),
      avg_distance = mean(ride_distance_km),
      .groups = "drop"
    ) %>%
    arrange(desc(total_trips)) %>%
    slice_head(n = top_n)
  
  # Popular stations (either as start or end)
  popular_stations <- data %>%
    gather(key = "station_type", 
           value = "station_name", 
           start_station_name, 
           end_station_name) %>%
    group_by(station_name, member_casual) %>%
    summarize(
      total_uses = n(),
      .groups = "drop"
    ) %>%
    arrange(desc(total_uses)) %>%
    slice_head(n = top_n)
  
  return(list(routes = popular_routes, stations = popular_stations))
}

# User Segmentation Analysis

complete_rides <- complete_rides %>%
  mutate(
    likely_commuter = case_when(
      ride_period %in% c("Morning Rush", "Evening Rush") &
        !is_weekend & 
        ride_distance_km >= 1 & 
        ride_distance_km <= 8 ~ TRUE,
      TRUE ~ FALSE
    ),
    usage_pattern = case_when(
      likely_commuter ~ "Commuter",
      is_weekend & ride_period %in% c("Mid-Day") ~ "Weekend Leisure",
      is_round_trip ~ "Round Trip",
      ride_period == "Night" ~ "Night Rider",
      !is_weekend & ride_period == "Mid-Day" ~ "Midday Casual",
      TRUE ~ "Mixed Usage"
    )
  )

# User segmentation analysis
analyze_user_segments <- function(data) {
  segments <- data %>%
    group_by(member_casual, usage_pattern) %>%
    summarize(
      total_rides = n(),
      avg_duration = mean(ride_length_mins),
      avg_distance = mean(ride_distance_km),
      pct_of_type = n() / sum(n()) * 100,
      .groups = "drop"
    )
  
  commuter_stats <- data %>%
    filter(likely_commuter) %>%
    group_by(member_casual) %>%
    summarize(
      regular_commuters = n_distinct(ride_id),
      avg_commute_distance = mean(ride_distance_km),
      common_start_time = median(hour_of_day)
    )
  
  return(list(segments = segments, commuter_stats = commuter_stats))
}

analyze_usage_patterns <- function(data) {
  usage_data <- data %>%
    group_by(member_casual, usage_pattern) %>%
    summarize(
      total_rides = n(),
      .groups = "drop"
    ) %>%
    group_by(member_casual) %>% # Calculate percentages within each member type
    mutate(
      percentage = total_rides / sum(total_rides) * 100,
      usage_pattern = factor(
        usage_pattern,
        levels = c("Commuter", "Weekend Leisure", "Round Trip", "Midday Casual", "Mixed Usage", "Night Rider") # Define order
      )
    ) %>%
    ungroup() # Important to ungroup after percentage calculation
  
  return(usage_data) # Return the data frame
}

# Run initial analysis
temporal_analysis <- analyze_temporal_patterns(complete_rides)
trip_analysis <- analyze_trip_characteristics(complete_rides)
route_analysis <- analyze_popular_routes(complete_rides)
user_segments <- analyze_user_segments(complete_rides)
usage_patterns_data <- analyze_usage_patterns(complete_rides)

# Analyze top stations with proper sorting
station_analysis <- complete_rides %>%
  group_by(start_station_name, member_casual) %>%
  summarise(
    total_rides = n(),
    pct_commute_hours = mean(ride_period %in% c("Morning Rush", "Evening Rush")) * 100,
    .groups = 'drop'
  ) %>%
  arrange(member_casual, desc(total_rides)) %>%
  group_by(member_casual) %>%
  slice_head(n = 20)
# Print summary statistics
summary_stats <- station_analysis %>%
  group_by(member_casual) %>%
  summarise(
    avg_commute_pct = mean(pct_commute_hours)
  )
print("Top Station Summary")
print(summary_stats)



# Visualization Theme Setup
# Creates a consistent theme for all visualizations with corporate styling

create_custom_theme <- function() {
  theme_minimal() +
    theme(
      # Title and subtitle formatting
      plot.title = element_text(size = 14, face = "bold", margin = margin(b = 10)),
      plot.subtitle = element_text(size = 12, color = "grey40"),
      
      # Axis formatting
      axis.title = element_text(size = 11),
      axis.text = element_text(size = 10),
      axis.text.x = element_text(angle = 45, hjust = 1),
      
      # Legend formatting
      legend.position = "bottom",
      legend.title = element_text(size = 10),
      legend.text = element_text(size = 9),
      
      # Grid lines
      panel.grid.major = element_line(color = "grey90"),
      panel.grid.minor = element_blank(),
      
      # Facet formatting
      strip.text = element_text(size = 11, face = "bold"),
      
      # Margins
      plot.margin = margin(20, 20, 20, 20)
    )
}

# Color Palette Definition
# Corporate colors: Blue for members (professional), Yellow for casual (friendly)

cyclistic_colors <- c(
  "member" = "#2E86AB",    # Professional blue for members
  "casual" = "#F6B018"     # Warm yellow for casual riders
)

# Hourly pattern plot
create_hourly_pattern_plot <- function(data) {
  ggplot(temporal_analysis$hourly,
         aes(x = hour_of_day, 
             y = rides, 
             color = member_casual,
             group = member_casual)) +
    geom_line(size = 1.2) +
    geom_point(size = 2.5, alpha = 0.7) +
    scale_color_manual(values = cyclistic_colors) +
    scale_x_continuous(breaks = 0:23,
                       labels = function(x) sprintf("%02d:00", x)) +
    scale_y_continuous(labels = scales::comma_format()) +
    labs(
      title = "Hourly Ridership Patterns",
      subtitle = "24-hour usage distribution by rider type",
      x = "Time of Day",
      y = "Number of Rides",
      color = "Rider Type"
    ) +
    create_custom_theme()
}

# Weekly pattern plot
create_weekly_pattern_plot <- function(data) {
  ggplot(temporal_analysis$weekly,
         aes(x = day_of_week, 
             y = rides, 
             fill = member_casual)) +
    geom_bar(stat = "identity", 
             position = "dodge",
             width = 0.8,
             alpha = 0.9) +
    scale_fill_manual(values = cyclistic_colors) +
    scale_y_continuous(labels = scales::comma_format()) +
    labs(
      title = "Weekly Ridership Patterns",
      subtitle = "Comparison of weekend vs. weekday usage",
      x = "Day of Week",
      y = "Number of Rides",
      fill = "Rider Type"
    ) +
    create_custom_theme()
}

# Seasonal pattern plot
create_seasonal_pattern_plot <- function(data) {
  ggplot(temporal_analysis$seasonal,
         aes(x = month, 
             y = rides, 
             color = member_casual,
             group = member_casual)) +
    geom_line(size = 1.2) +
    geom_point(size = 3, alpha = 0.8) +
    scale_color_manual(values = cyclistic_colors) +
    scale_y_continuous(labels = scales::comma_format()) +
    labs(
      title = "Seasonal Ridership Patterns",
      subtitle = "Monthly trends highlighting seasonal variations",
      x = "Month",
      y = "Number of Rides",
      color = "Rider Type"
    ) +
    create_custom_theme()
}

# Trip duration plots
library(ggplot2)
library(patchwork)

create_trip_duration_plot <- function(data) {
  ggplot(data,
         aes(x = ride_length_mins, fill = member_casual)) +
    geom_density(alpha = 0.7) +
    scale_fill_manual(values = cyclistic_colors) +
    scale_x_continuous(
      limits = c(0, 60),
      breaks = seq(0, 60, 10),
      labels = function(x) sprintf("%d min", x)
    ) +
    scale_y_continuous(labels = scales::comma_format()) +
    labs(
      title = "Trip Duration Distribution",
      subtitle = "Distribution of ride durations by rider type",
      x = "Duration (minutes)",
      y = "Density",
      fill = "Rider Type"
    ) +
    create_custom_theme() +
    theme(
      legend.position = "bottom",
      panel.grid.minor.x = element_blank(),
      panel.grid.major.y = element_line(color = "grey90", linetype = "dashed")
    )
}

# Trip distance plots
create_trip_distance_plot <- function(data) {
  ggplot(data,
         aes(x = ride_distance_km, fill = member_casual)) +
    geom_density(alpha = 0.7) +
    scale_fill_manual(values = cyclistic_colors) +
    scale_x_continuous(
      limits = c(0, 10),
      breaks = seq(0, 10, 2),
      labels = function(x) sprintf("%.0f km", x)
    ) +
    scale_y_continuous(labels = scales::comma_format()) +
    labs(
      title = "Trip Distance Distribution",
      subtitle = "Distribution of ride distances by rider type",
      x = "Distance (kilometers)",
      y = "Density",
      fill = "Rider Type"
    ) +
    create_custom_theme() +
    theme(
      legend.position = "bottom",
      panel.grid.minor.x = element_blank(),
      panel.grid.major.y = element_line(color = "grey90", linetype = "dashed")
    )
}

# Top stations analysis plot
analyze_top_stations <- function(data, n_stations = 10) {
  commute_colors <- colorRampPalette(c("#FFF5EB", "#FD8D3C"))(5)
  
  ggplot(station_analysis, 
         aes(y = fct_reorder(start_station_name, total_rides),
             x = total_rides, 
             fill = factor(cut(pct_commute_hours, 5)))) +
    geom_bar(stat = "identity", alpha = 0.9) +
    facet_wrap(~member_casual, 
               scales = "free_y",
               labeller = labeller(member_casual = c(
                 "member" = "Annual Members",
                 "casual" = "Casual Riders"
               ))) +
    scale_fill_manual(
      values = commute_colors,
      name = "% Commute Hours",
      labels = c("0-20%", "21-40%", "41-60%", "61-80%", "81-100%")
    ) +
    scale_x_continuous(labels = scales::comma_format()) +
    labs(
      title = "Top 20 Most Popular Stations",
      subtitle = "Station usage patterns by rider type",
      y = "Station Name",
      x = "Total Number of Rides"
    ) +
    create_custom_theme() +
    theme(
      axis.text.y = element_text(size = 8),
      plot.margin = margin(20, 20, 20, 30)
    )
}

# Usage patterns plot
create_usage_patterns_plot <- function(data) {
  ggplot(data, aes(x = usage_pattern, y = percentage, fill = member_casual)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, alpha = 0.9) +
    scale_fill_manual(values = cyclistic_colors, name = "Rider Type") + 
    scale_y_continuous(labels = scales::percent_format(scale = 1)) +
    labs(
      title = "Usage Patterns by Rider Type",
      subtitle = "Comparison of riding behaviors",
      x = "Usage Pattern",
      y = "Percentage of Total Rides",
      fill = "Rider Type"
    ) +
    create_custom_theme() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10)) # Rotate x-axis labels
}