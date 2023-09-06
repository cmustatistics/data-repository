# Write a smaller compressed version of the Census data, with only 2020 population estimates

library(dplyr)
library(readr)
library(covidcast) # for FIPS conversion

census <- read_csv("cc-est2022-all.csv.gz") |>
  filter(YEAR == 1,  # April 1, 2020 base estimates
         AGEGRP == 0) # All age groups

census <- census |>
  mutate(
    FIPS = paste0(STATE, COUNTY),
    CTYNAME = gsub(" Parish", "", CTYNAME),
    CTYNAME = gsub(" County", "", CTYNAME),
    CTYNAME = gsub(" Borough", "", CTYNAME),
    CTYNAME = gsub(" Census Area", "", CTYNAME),
    CTYNAME = gsub("-", " ", CTYNAME)
  )

mpv <- read_csv("mapping-police-violence.csv.gz")

mpv$county <- gsub(" Parish", "", mpv$county)
mpv$county <- gsub(" County", "", mpv$county)
mpv$county <- gsub(" Census Area","", mpv$county)
mpv$county <- gsub(" Borough", "", mpv$county)
mpv$county <- gsub("-", " ", mpv$county)
mpv$county <- gsub("Dekalb", "DeKalb", mpv$county) # MPV seems to ignore case

mpv$state <- state.name[match(mpv$state, state.abb)]

fipsen <- census |>
  select(FIPS, STNAME, CTYNAME)

mpv <- left_join(mpv, fipsen, by = c("state" = "STNAME", "county" = "CTYNAME"))

write_csv(mpv, "../../data/mapping-police-violence.csv.gz")
write_csv(census, "../../data/county-census-2020.csv.gz")
