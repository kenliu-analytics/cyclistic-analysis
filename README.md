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

## Setup Instructions
1. Clone this repository
2. Install required R packages:
```R
install.packages(c("tidyverse", "ggplot2", "knitr", "dplyr", "kableExtra", 
                  "here", "lubridate", "janitor", "geosphere", "gridExtra",
                  "scales", "igraph", "sf", "patchwork", "viridis"))
```
3. Place your raw data files in the `data/raw/` directory
4. Open `cyclistic-analysis-ver2.Rmd` in RStudio
5. Run the analysis by knitting the R Markdown file

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