# ----------------------------------------------------------------------------- #
# script:      01_prepare_top_shared_images
# description: This script processes raw user share data to identify and prepare 
#              the most frequently shared images for analysis. 
# details:     It first converts the timestamp to a readable date-time format, 
#              then filters for images shared at least 10 times, excluding 
#              irrelevant or missing hashes. Finally, it creates a new data file 
#              with only the metadata for these top-performing images, saving it
#              to the data folder for further use.
# ----------------------------------------------------------------------------- #

library(tidyverse)

user_shares_metadata <- read_csv("raw_data/user_shares_metadata.csv")

# Identify the most frequently shared images.
high_freq_images <- user_shares_metadata |>
  group_by(hash) |>
    summarize(freq = n()) |>
      filter(!hash %in% c("0000000000000000", "0100000000000000"),
             !is.na(hash),
             freq >= 10)

# Create a new data frame that contains only the metadata for the most popular images.
# This filters the original data to match the list of high-frequency hashes
top_shared_images <- user_shares_metadata |>
  filter(hash %in% high_freq_images$hash)

# Save the clean, filtered data to the 'data' folder as a CSV file.
write.csv(top_shared_images, file = "data/top_shared_images.csv", row.names = F)

rm(list = ls())
gc()
