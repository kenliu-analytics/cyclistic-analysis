# Cyclistic Bike-Share Analysis

## Overview
This project analyzes Cyclistic bike-share data from December 2023 to November 2024 to identify conversion strategies for turning casual riders into annual members. The analysis includes temporal patterns, user behavior analysis, and geographic usage patterns to develop data-driven marketing recommendations.

## Project Structure
```
cyclistic-analysis/
├── README.md                          # Project documentation
├── cyclistic-analysis.Rmd             # Main analysis R Markdown file
├── scripts/                           # R scripts for data processing and analysis
├── images/                            # Visualization images
└── data/                              # Data directory (not tracked in git)
```

## Requirements
- R (version 4.0.0 or higher)
- RStudio (for R Markdown compilation)

### Required R Packages
- tidyverse
- ggplot2
- knitr
- dplyr
- kableExtra
- here
- lubridate
- janitor
- geosphere
- gridExtra
- scales
- igraph
- sf
- patchwork
- viridis

## Data Source
This analysis uses Cyclistic bike-share historical trip data from December 2023 to November 2024. The complete dataset is available at [Divvy Bikes Historical Trip Data](https://divvy-tripdata.s3.amazonaws.com/index.html).

### Data Structure
Each trip record contains:
  ```
ride_id            : unique identifier for each ride
rideable_type      : type of bike (classic, electric, docked)
started_at         : start time of trip
ended_at           : end time of trip
start_station_name : name of start station
start_station_id   : ID of start station
end_station_name   : name of end station
end_station_id     : ID of end station
start_lat          : start location latitude
start_lng          : start location longitude
end_lat            : end location latitude
end_lng            : end location longitude
member_casual      : rider type (member or casual)
```

### Sample Data
A sample dataset (`data/raw/sample_cyclistic_data.csv`) is included in this repository for demonstration purposes. To reproduce the full analysis:
  1. Download the complete dataset from the source above
2. Place the CSV files in the `data/raw` directory
3. Run the analysis scripts

## Setup Instructions
1. Clone this repository
2. Install required R packages:
```R
install.packages(c("tidyverse", "ggplot2", "knitr", "dplyr", "kableExtra", 
                  "here", "lubridate", "janitor", "geosphere", "gridExtra",
                  "scales", "igraph", "sf", "patchwork", "viridis"))
```
3. Open `cyclistic-analysis.Rmd` in RStudio
4. Run the analysis by knitting the R Markdown file

## Scripts
- `data_loading.R`: Handles import and initial processing of raw CSV files
- `data_prep.R`: Data cleaning and preparation functions
- `analysis_functions.R`: Core analysis and visualization functions
- `helper_functions.R`: Utility functions used across the analysis

## Key Findings
1. Usage Patterns
   - Members primarily use bikes for commuting (63% during rush hours)
   - Casual riders show strong weekend preference (47% of rides)
   - Significant seasonal variation in casual ridership

2. Trip Characteristics
   - Members take shorter, more direct routes
   - Casual riders show more exploratory behavior
   - Round trips more common among casual riders

3. Geographic Preferences
   - Members concentrate around business districts
   - Casual riders cluster near tourist attractions
   - Station preference varies by time of day

## Contributing
This project is part of a data analysis case study. Contributions and suggestions are welcome. Please open an issue or submit a pull request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
- Data provided by Motivate International Inc.
- Analysis conducted as part of the Google Data Analytics Professional Certificate

## Contact
Liu Hiu Lo (Ken) - [https://www.linkedin.com/in/kenliuhk/]

Project Link: [https://github.com/kenliu-analytics/cyclistic-analysis]