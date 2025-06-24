# Set working directory
setwd("C:/Users/steli/Stelios/DS AUEB/Trimester 3/Data Visualization/Project 2/FranceRoadAccidents/data")

# Load required libraries
library(dplyr)
library(readr)
library(lubridate)
library(stringr)

# Load datasets
characteristics <- read_csv("characteristics_clean.csv", locale = locale(encoding = "Latin1"))
vehicles <- read_csv("vehicles_clean.csv", locale = locale(encoding = "Latin1"))
places <- read_csv("places_clean.csv", locale = locale(encoding = "Latin1"))
users <- read_csv("users_clean.csv", locale = locale(encoding = "Latin1"))
holiday <- read_csv("holidays.csv", locale = locale(encoding = "Latin1"))

# Convert date columns
characteristics$Date <- dmy(characteristics$Date)
holiday$ds <- ymd(holiday$ds)  # assuming ds is in "yyyy-mm-dd" format

# Filter for 2009–2012
filtered_characteristics <- characteristics %>%
  filter(Date >= as.Date("2009-01-01") & Date <= as.Date("2012-12-31"))

# Join holidays by matching Date
filtered_characteristics <- filtered_characteristics %>%
  left_join(holiday, by = c("Date" = "ds")) %>%
  mutate(holiday = ifelse(is.na(holiday), "None", holiday))

# Get matching Accident_IDs
accident_ids <- filtered_characteristics$Accident_ID

# Filter the other datasets
filtered_vehicles <- vehicles %>% filter(Accident_ID %in% accident_ids)
filtered_places   <- places   %>% filter(Accident_ID %in% accident_ids)
filtered_users    <- users    %>% filter(Accident_ID %in% accident_ids)

# Save filtered datasets (optional)
write_csv(filtered_characteristics, "characteristics_2009_2012.csv")
write_csv(filtered_vehicles, "vehicles_2009_2012.csv")
write_csv(filtered_places, "places_2009_2012.csv")
write_csv(filtered_users, "users_2009_2012.csv")

# Merge all filtered datasets
merged_df <- filtered_characteristics %>%
  left_join(filtered_places, by = "Accident_ID", relationship = "many-to-many") %>%
  left_join(filtered_users, by = "Accident_ID", relationship = "many-to-many") %>%
  left_join(filtered_vehicles, by = "Accident_ID", relationship = "many-to-many")

# Save final merged dataset with holiday info
write_csv(merged_df, "road_accidents_2009_2012_merged.csv")
