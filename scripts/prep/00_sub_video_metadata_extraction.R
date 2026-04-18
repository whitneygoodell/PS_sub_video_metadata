# title: "00_sub_video_metadata_extraction"
# scripts/prep/00_sub_video_metadata_extraction.R
# Description: This script scans a specified root directory and all its subfolders,
#              identifies video files, extracts their full file path, duration, and creation date/time.
#              and saves the results to a CSV file.
# Date created: 2026-04-17

# Advisory: This script should only be run on hard drives or downloaded files.
#           If running on 'cloud' files such as Dropbox, it will initiate a download of all files
#           in order to read the file data.

# =========== 1. SETUP =========================================
library(av)
library(lubridate)
library(googlesheets4)
library(dplyr)
library(exifr)

# =========== 2. CONFIGURATION ===========================
# video directory to scan (where all video subfolders are)
root_directory <- "E:/dives"

# output path and filename for resulting CSV file
output_csv_path <- file.path("G:/My Drive/Whitney Goodell Pristine Seas/Fiji/sub","FJI_2025_sub_video_metadata.csv")

# set up steps 4, 5a, and 5b according to whether there will be two batches of extractions (i.e. two separate LaCie drives)
# or just a single batch to export to .csv

# ========== 3. FUNCTION DEFINITION =======================
extract_video_metadata <- function(video_dir_path) {
  
  if (!dir.exists(video_dir_path)) {
    stop("Error: The specified directory does not exist. Check your drive connection.")
  }
  
  # 1. Find Video Files
  message("Scanning for video files in: ", video_dir_path)
  all_files <- list.files(video_dir_path, full.names = TRUE, recursive = TRUE)
  
  # search video file types
  video_extensions <- c(".mp4", ".mov", ".avi", ".mkv", ".flv", ".wmv", ".mpeg", ".mpg", ".mts", ".m4v")
  video_files <- all_files[grepl(paste(video_extensions, collapse = "|"), tolower(all_files))]
  
  if (length(video_files) == 0) {
    message("No video files found.")
    return(NULL)
  }
  
  message(paste("Found", length(video_files), "videos. Extracting metadata with 'av'..."))
  
  # 2. Process Files
  metadata_list <- list()
  
  for (i in seq_along(video_files)) {
    file_path <- video_files[i]
    
    tryCatch({
      # Get file system info (mtime) and av media info (duration)
      # mtime more accurate to original creation than ctime
      file_info <- file.info(file_path)
      media_info <- av_media_info(file_path)
      
      duration_seconds <- media_info$duration
      
      # Calculate the true start time 
      # mtime is the end of recording, so subtract the duration
      start_datetime <- file_info$mtime - duration_seconds
      
      # Build the data frame for this specific file
      metadata_list[[i]] <- data.frame(
        filename = basename(file_path),
        duration = sprintf("%02d:%02d:%02d",
                           floor(duration_seconds / 3600),
                           floor((duration_seconds %% 3600) / 60),
                           floor(duration_seconds %% 60)),
        creation_date = format(start_datetime, "%Y-%m-%d"),
        creation_time = format(start_datetime, "%H:%M"),
        full_path = file_path,
        stringsAsFactors = FALSE
      )
      
    }, error = function(e) {
      warning(paste("Could not process:", basename(file_path), "| Error:", e$message))
    })
    
    # Progress indicator
    if (i %% 10 == 0) message(paste("Processed", i, "of", length(video_files), "files..."))
  }
  
  # 3. Combine and return
  final_df <- bind_rows(metadata_list)
  return(final_df)
}

# =========== 4. RUN EXTRACTION =======================
# Execute function
video_metadata_results_3_13 <- extract_video_metadata(root_directory)

# =========== 5. SAVE TO CSV ==========================
# run ONE of the subsections below

## =========== 5a. one data frame ==========================
# Run this if there's only one chunk of files (i.e. one drive)
if (!is.null(video_metadata_results)) {
  write.csv(video_metadata_results, output_csv_path, row.names = FALSE)
  message("---")
  message("SUCCESS: Metadata saved to: ", output_csv_path)
} else {
  message("No metadata was extracted.")
}

## ========== 5b. multiple data frames ==========
# Run this if there are multiple drives (i.e. two LaCie drives for sub data)
# In this case, run Step 4 for each drive, naming the data frames uniquely.
# Include unique data frame names in the code below.

message("Merging batches...")
combined_metadata <- bind_rows(
  video_metadata_results_1_2,
  video_metadata_results_3_13
)

if (!is.null(combined_metadata) && nrow(combined_metadata) > 0) {
  write.csv(combined_metadata, output_csv_path, row.names = FALSE)
  message("SUCCESS: Merged metadata saved locally to: ", output_csv_path)
} else {
  warning("No metadata was extracted.")
}
