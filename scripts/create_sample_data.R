# create_sample_data.R
# Create sample data for Github

library(tidyverse)
library(lubridate)
library(janitor)

# Function to create stratified sample
create_sample_dataset <- function(data, sample_size = 1000) {
  # Ensure we get data from each month
  sample_data <- data %>%
    # Add month-year column for stratification
    mutate(month_year = floor_date(started_at, "month")) %>%
    # Group by month and member type
    group_by(month_year, member_casual) %>%
    # Take proportional samples from each group
    slice_sample(
      prop = sample_size/nrow(data),
      replace = FALSE
    ) %>%
    # Remove the temporary column
    select(-month_year) %>%
    # Sort by date
    arrange(started_at)
  
  return(sample_data)
}

# Create sample
set.seed(123) # For reproducibility
sample_cyclistic_data <- create_sample_dataset(cyclistic_data)

# Create directory if it doesn't exist
dir.create(here::here("data", "raw"), recursive = TRUE, showWarnings = FALSE)

# Save sample data
write_csv(
  sample_cyclistic_data,
  here::here("data", "raw", "sample_cyclistic_data.csv")
)

# Print summary to verify representativeness
summary_stats <- list(
  "Original Data" = cyclistic_data %>%
    summarise(
      n_rides = n(),
      pct_member = mean(member_casual == "member") * 100,
      n_months = n_distinct(floor_date(started_at, "month"))
    ),
  "Sample Data" = sample_cyclistic_data %>%
    summarise(
      n_rides = n(),
      pct_member = mean(member_casual == "member") * 100,
      n_months = n_distinct(floor_date(started_at, "month"))
    )
)

print(summary_stats)