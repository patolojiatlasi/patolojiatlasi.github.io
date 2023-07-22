library(stringr)
library(dplyr)
library(purrr)

# Function to extract URLs from a file
extract_urls <- function(filename) {
  content <- readLines(filename, warn = FALSE)
  all_urls <- unlist(str_extract_all(content, "\\(https?://[^\r\n)]+|\\(\\./[^\r\n)]+"))

  # Extract the URLs from the parentheses
  all_urls <- gsub("^\\(", "", all_urls)

  image_urls <- all_urls[grep("\\.(png|jpg|jpeg|gif|bmp|tif|tiff)$", all_urls)]
  html_urls <- all_urls[grep("\\.html$", all_urls)]

  max_len <- max(length(image_urls), length(html_urls))
  data.frame(
    filename = rep(filename, max_len),
    image_url = c(image_urls, rep(NA, max_len - length(image_urls))),
    html_url = c(html_urls, rep(NA, max_len - length(html_urls)))
  )
}

# Get all .qmd files from a directory
file_list <- list.files(path = ".", pattern = "\\.qmd$", full.names = TRUE)

# Process all files and combine results
my_df <- map_dfr(file_list, extract_urls)

rio::export(my_df, "./my_df.xlsx")
