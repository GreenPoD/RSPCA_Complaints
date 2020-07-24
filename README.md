#### TidyTuesday_RSPCA_Complaints

Data Cleaning using the tidyverse, Geocoding Data, Shiny Leaflet Application

Launch the [RSPCA Complaints Shiny Application](https://greenpod303.shinyapps.io/TidyTuesday_RSPCA_Complaints/) from which you can layer and filter the quarterly timespan, with animal types and the complaint types. I've set the zoom to show the entire continent and would suggest making your animal selection first, so you can see the plotted points before zooming into the region. (set your cursor, hold down the 'Ctrl' key and push the scroll forward on your mouse to get there fast) 

This project is part of the [TidyTuesday/R4DS](https://github.com/rfordatascience/tidytuesday) weekly contest?

#### Cleaning The Data

I've commented my code to explain the process and I'm certain there may be `tidyr` ways to do so. The main challenge was to standardize the brisbane table with the animal complaints. I began recoding the quarterly dates as they were represented as the individual *csv names* in the brisbane table and *Month Year* in the animal complaints table. Using the `unique()` function to extract the variables. One of my major issues was using the `cbind()` function rather than `bind_cols()` which would be the correct *tidyverse* approach. 

Once the dates were standardized the tables were stacked (using `rbind()` no less) as I was experiencing an issue with `bind_rows()`.

There was a bit of cross contamination in the data having animal names in the complaint column and complaints in the animal column so I've used `mutate()` and `case_when()` to recode the columns and touch up the descriptions. Also a bit of housekeeping with `stringr::str_to_title()`

#### Geocoding

With the hopes of plotting the data using a *leaflet* map, I've pasted "Austrailia" to the suburb in the hopes that google and the *ggmap* package can do all of the heavy lifting. 

#### Shiny Application

Using one of my beloved *shiny* templates I've done a bit of reworking to display the animal types and complaints in a useful way. [Shiny/IO](https://www.shinyapps.io/) is an amazing service that RStudio offers to the amateur useR. I have committed to myself that the moment I monetize any use of the RStudio IDE and their support applications that I will be an official licence holder.

#### Citation

I personally rejected the early days when coding was repetitive and frustrating. I appreciate all of the package builders and visionaries that stuck with it and did the hard work. The R Community is wonderfully supportive and constantly improving the workflows of millions of people arround the globe.

Packages Used:

*[tidyverse](https://github.com/tidyverse)
*[janitor](https://github.com/sfirke/janitor)
*[ggmap](https://github.com/dkahle/ggmap)
*[leaflet](https://github.com/rstudio/leaflet)
*[shiny](https://github.com/rstudio/shiny)
*[lubridate](https://github.com/tidyverse/lubridate)