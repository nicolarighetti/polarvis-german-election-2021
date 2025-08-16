# ----------------------------------------------------------------------------- #
# script:      02_process_top_images.R
# description: Filters and processes physical image files.
# details:     Identifies relevant images, removes duplicates and irrelevant
#              hashes. Resizes and compresses the final list of images,
#              saving them to a new folder. It then add to the metadata table
#              the URL where the images are stored on GitHub.
# ----------------------------------------------------------------------------- #

library(tidyverse)
library(magick)

# ---- 1. FILTER AND GET TOP IMAGE PATHS ----

top_shared_images <- read_csv("data/top_shared_images.csv")

# Get a vector of all file paths in the images folder.
images_folder <- "raw_data/hashed_images"
all_image_paths <- list.files(images_folder, full.names = TRUE, recursive = T)

# Deduplicate multiple paths for the same hash.
# 1. 'basename()' extracts just the filename (e.g., "43411715ae9fd3a9.jpg").
# 2. 'tools::file_path_sans_ext()' removes the file extension (".jpg"), leaving only the hash.
all_image_hashes <- tools::file_path_sans_ext(basename(all_image_paths))
is_unique <- !duplicated(all_image_hashes)
all_image_paths <- all_image_paths[is_unique]

# Filter the list of image paths to keep only those that are among the top shared images.
top_image_paths <- all_image_paths[tools::file_path_sans_ext(basename(all_image_paths)) %in% 
                                     top_shared_images$hash]


# ---- 2. RESIZE AND SAVE IMAGES ----

# Define output folder
output_folder <- "data/top_images_normalized"

# Create the output folder if it doesn't exist
if (!dir.exists(output_folder)) {
  dir.create(output_folder)
}

# Define the target size and compression quality
target_width <- 800
target_height <- 600
compression_quality <- 70 

# Loop through each image path
for (i in 1:length(top_image_paths)) {
  # Get the path for the current image in the loop
  current_image_path <- top_image_paths[i]
  
  # Read the image from the current path
  img <- image_read(current_image_path)
  
  # Resize the image while preserving the aspect ratio
  resized_img <- image_scale(img, paste0(target_width, "x", target_height))
  
  # Construct the output file path using the original filename
  output_file_path <- file.path(output_folder, basename(current_image_path))
  
  # Save the resized image with specified quality
  image_write(resized_img, path = output_file_path, quality = compression_quality)
  
  cat("Successfully resized and compressed:", basename(current_image_path), "\n")
}

# ---- 3. INCLUDE GITHUB IMAGE PATHS ----
gith_path <- "https://raw.githubusercontent.com/nicolarighetti/polarvis-german-election-2021/main/data/top_images_normalized/"
github_image_paths <- paste0(gith_path, basename(top_image_paths))

path_table <- data.frame(
  "image_url" = github_image_paths,
  "hash" = tools::file_path_sans_ext(basename(github_image_paths)))

top_shared_images <- merge(top_shared_images, path_table, all.x = T)

write_csv(top_shared_images, "data/top_shared_images.csv")

rm(list = ls())
gc()
