# Title: Video Metadata Extractor
# Description: This script scans a specified root directory and all its subfolders,
#              identifies video files, 
#              extracts their full file path and duration, and creation date/time.
#              and saves the results to a CSV file.
# Date created: 2025-10-15, 2026-01-14
# Date modified: 2026-04-17

# =========== 1. SETUP =========================================
library(av)
library(lubridate)

# =========== 2. CONFIGURATION ===========================

# set the root directory to scan (where all video subfolders are)
# Ex: "F:/TUV-2025/dives"
root_directory <- "C:\\Users\\wgoodell\\National Geographic Dropbox\\Dropcam Data\\Pristine Seas Dropcam Data" 

# output path and filename for resulting CSV file
# Ex: "C:/Users/YourName/Desktop/all_video_durations.csv"
output_csv_path <- "G:/My Drive/Whitney Goodell Pristine Seas/Vanuatu/sub/all_video_durations_dives1-5.csv"

