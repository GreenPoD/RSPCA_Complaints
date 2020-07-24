
library(tidyverse)
library(janitor)

#load in the data
animal_complaints <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-07-21/animal_complaints.csv")
animal_outcomes <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-07-21/animal_outcomes.csv")
brisbane_complaints <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-07-21/brisbane_complaints.csv")

# dates are saved as the csv names
# extract the unique values
date_range_bc <- unique(brisbane_complaints$date_range)

#create a corresponding table of the quarter and year
date_range_bc_key <- c(2016.1, 2016.2, 2017.2, 2018.2, 2017.2, 2017.1,
                       2018.1, 2017.1, 2018.3, 2017.3, 2017.3, 2018.4,
                       2016.4, 2017.4, 2020.2, 2020.1, 2017.4)

# bind the columns and coerse to a tibble
bound_date_range <- bind_cols(date_range_bc, date_range_bc_key)
colnames(bound_date_range) <- c("date_range", "year_quarter")

# clean the column names and join the matrices
brisbane_complaints_key <- brisbane_complaints %>% 
  clean_names() %>% 
  left_join(bound_date_range, by = c("date_range"), copy = TRUE)

# clear out the unnecesary columns and standardise the column names in order to stack the tables
brisbane_complaints_cln <- brisbane_complaints_key[, c(2:4, 8)]
colnames(brisbane_complaints_cln) <- c("animal_type", "complaint_type", "suburb", "year_quarter" )

# clean the column names
animal_complaints <- animal_complaints %>% 
  clean_names()

# create a tibble containing the unique values
date_range_ac <- unique(animal_complaints$date_received)
tibble(date_range_ac)

# create a matrix of year_quarters
date_range_ac_cln <- c(2020.2, 2020.2, 2020.2, 2020.1, 2020.1, 2020.1,
                       2019.4, 2019.4, 2019.4, 2019.3, 2019.3, 2019.3,
                       2019.2, 2019.2, 2019.2, 2019.1, 2019.1, 2019.1,
                       2018.4, 2018.4, 2018.4, 2018.3, 2018.3, 2018.3,
                       2018.2, 2018.2, 2018.2, 2018.1, 2018.1, 2018.1,
                       2017.4, 2017.4, 2017.4, 2017.3, 2017.3, 2017.3,
                       2017.2, 2017.2, 2017.2, 2017.1, 2017.1, 2017.1,
                       2016.4, 2016.4, 2016.4, 2016.3, 2016.3, 2016.3,
                       2016.2, 2016.2, 2016.2, 2016.1, 2016.1, 2016.1,
                       2015.4, 2015.4, 2015.4, 2015.3, 2015.3, 2015.3,
                       2015.2, 2015.2, 2015.2, 2015.1, 2015.1, 2015.1,
                       2014.4, 2014.4, 2014.4, 2014.3, 2014.3, 2014.3,
                       2014.2, 2014.2, 2014.2, 2014.1, 2014.1, 2014.1,
                       2013.4, 2013.4, 2013.4)

# bind the unique date_recieved with the quarter_year
bound_date_range_ac <- bind_cols(date_range_ac, date_range_ac_cln)
colnames(bound_date_range_ac) <- c("date_received", "year_quarter")

# join the new column to the data frame
animal_complaints_cln <- animal_complaints %>% 
  left_join(bound_date_range_ac, by = "date_received") 

# drop the inconsistent columns before stacking the data frames
animal_complaints_cln <- animal_complaints_cln[, c(1,2,4,6)]

# bind the dataframes
rspca_complaints <- rbind(animal_complaints_cln, brisbane_complaints_cln)

# load ggmap
library(ggmap)

# include the country so google is able to locate the suburbs
geocode_rspca <- rspca_complaints %>% 
  mutate(suburb_country = paste(suburb, "Australia", sep = ","))

# extract the unique suburbs
unique_suburbs <- unique(geocode_rspca$suburb_country)
unique_suburbs <- data_frame(unique_suburbs)

# reapply the column name
colnames(unique_suburbs) <- c("suburb_country")

# function for looking up the longitude and latitude values
for(i in 1:nrow(unique_suburbs))
{
  result <- geocode(unique_suburbs$suburb_country[i], output = "latlona", source = "google")
  unique_suburbs$lon[i] <- as.numeric(result[1])
  unique_suburbs$lat[i] <- as.numeric(result[2])
}

# separate the suburb and country columns
unique_suburbs_split <- unique_suburbs %>% 
  separate(suburb_country, sep = ",", into = c("suburb", "country")) %>% 
  mutate(suburb = str_to_title(suburb))

# the animal and complaint columns were cross contaminated and required a bit of tlc
# a bit of cleanup on the names eliminated some of the duplicates
rspca_complaints_cln <- rspca_complaints %>% 
  mutate(animal_type = str_to_title(animal_type),
         complaint_type = str_to_title(complaint_type),
         suburb = str_to_title(suburb),
         animal = case_when(
           animal_type == "Dog" ~ "Dog",
           animal_type == "Cat" ~ "Cat",
           animal_type == "Attack" ~ "Other Animal",
           animal_type == "Cat Trapping" ~ "Cat",
           complaint_type == "Deer" ~ "Deer",
           complaint_type == "Dog" ~ "Dog",
           complaint_type == "Feral Cat" ~ "Feral Cat",
           complaint_type == "Feral Goat" ~ "Feral Goat",
           complaint_type == "Feral Pig" ~ "Feral Pig",
           complaint_type == "Fox" ~ "Fox",
           complaint_type == "Rabbit" ~ "Rabbit",
           complaint_type == "Wild Dog" ~ "Wild Dog",
           TRUE ~ animal_type),
         complaint = case_when(
           complaint_type == "Attack On A Person" ~ "Attacked Person",
           complaint_type == "Attack On An Animal" ~ "Attacked Animal",
           complaint_type == "NA" ~ "Animal Sighting",
           complaint_type == "Pest / Feral Animal" ~ "Pest Feral Animal",
           complaint_type == "Not An Attack" ~ "Not Attack",
           complaint_type == "Defecating In Public" ~ "Public Defication",
           complaint_type == "Too Many Animals" ~ "Animal Hoarding",
           complaint_type %in% c("Fox", "Wild Dog", "Feral Cat",
                                 "Feral Pig", "Feral Goat", "Deer",
                                 "Dog", "Rabbit") ~ "Sighting",
           TRUE ~ complaint_type)
  ) %>% 
  mutate(complaint = replace_na(complaint, replace = "Unknown"))

# creating a dataframe containing the complaint counts per quarter + animal
rspca_complaints_counts <- rspca_complaints_cln %>% 
  group_by(year_quarter, suburb, complaint) %>% 
  count(animal, name = "animal_count")


# join the longitude and latitude information to the rspca_complaints
animal_complaints_rspca <- rspca_complaints_counts %>% 
  left_join(unique_suburbs_split, by = "suburb")

animal_complaints_rspca <- animal_complaints_rspca %>% 
  mutate(year_quarter = lubridate::yq(year_quarter),
         colour = case_when(
           animal == "Dog" ~ "#7a93d6",
           animal == "Cat" ~ "#77ed5c",
           animal == "Fox" ~ "#9bd678",
           animal == "Feral Cat" ~ "#d44660",
           animal == "Feral Goat" ~ "#47d6ca",
           animal == "Feral Pig" ~ "#d64e29",
           animal == "Deer" ~ "#4e0887",
           animal == "Rabbit" ~ "#d917e3",
           animal == "Other Animal" ~ "#e0e317"
           ),
         complaint_colour = case_when(
           complaint == "Animal Hoarding" ~ "#bf2f24",
           complaint == "Attack" ~ "#f00a21",
           complaint == "Enclosure" ~ "#479e4a",
           complaint == "Noise" ~ "#f5f52f",
           complaint == "Private Impound" ~ "#772ff5",
           complaint == "Wandering" ~ "#9dcf78",
           complaint == "Aggressive Animal" ~ "#f51d62",
           complaint == "Attacked Animal" ~ "#e6921e", 
           complaint == "Attacked Person" ~ "#f06007",
           complaint == "Fencing Issues" ~ "#90c765",
           complaint == "Not Attack" ~ "#29f273",
           complaint == "Nuisance Animal" ~ "#f6a6f7",
           complaint == "Unknown" ~ "#b5ebdd",
           complaint == "Unregistered" ~ "#31b593",
           complaint == "Odour" ~ "#f4f719",
           complaint == "Public Defication" ~ "#73471c",
           complaint == "Sighting" ~ "#4bc97f",
           complaint == "Menacing" ~ "#9c2769",
           complaint == "Pest Feral Animal" ~ "#9c2769",
           complaint == "Surrender" ~ "#9c2769",
           complaint == "Insufficient Space" ~ "#316e94",
           complaint == "Dangerous" ~ "#940732"
         ))
