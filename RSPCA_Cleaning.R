# load the required packages
library(tidyverse)
library(janitor)

#load in the data from the Tidy Tuesday repository
animal_complaints <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-07-21/animal_complaints.csv")
brisbane_complaints <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-07-21/brisbane_complaints.csv")

# dates are saved as the csv names
# extract the unique values
date_range_bc <- unique(brisbane_complaints$date_range)

#create a corresponding table of the quarter and year
date_range_bc_cln <- c("2016.1", "2016.2", "2017.2", "2018.2", "2017.2", "2017.1",
                       "2018.1", "2017.1", "2018.3", "2017.3", "2017.3", "2018.4",
                       "2016.4", "2017.4", "2020.2", "2020.1", "2017.4")

# bind the columns and coerse to a tibble
bound_date_range <- cbind(date_range_bc, date_range_bc_cln)
colnames(bound_date_range) <- c("date_range", "year_quarter")
tibble(bound_date_range)

# clean the column names and join the matrices
brisbane_complaints_cln <- brisbane_complaints %>% 
  clean_names() %>% 
  left_join(bound_date_range, by = c("date_range"), copy = TRUE)

# clear out the unnecesary columns and standardise the column names in order to stack the tables
brisbane_complaints_cln <- brisbane_complaints_cln[, c(2:4, 8)]
colnames(brisbane_complaints_cln) <- c("animal_type", "complaint_type", "suburb", "year_quarter")