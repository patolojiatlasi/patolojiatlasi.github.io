library(stringr)
library(tidyverse)

# Read markdown file
md_text <- read_file("hucreicibirikimler.qmd")

# Split text by line
lines <- str_split(md_text, "\n") %>% unlist()

# Initialize variables
current_heading <- NA
current_png <- NA
current_url <- NA
data_extracted <- tibble(heading = character(), png = character(), url = character())

# Iterate through lines
for (line in lines) {
  # Check if line is a heading
  if (str_detect(line, "^#+ .+")) {
    # Remove '#' from heading
    current_heading <- str_replace_all(line, "#", "")
    current_png <- NA
    current_url <- NA
  }
  # Check if line is a png file
  else if (str_detect(line, "!\\[.+\\]\\(.+\\.png\\)")) {
    # Extract file path
    current_png <- str_extract(line, "\\(.*\\.png\\)") %>% str_replace_all(c("\\(" = "", "\\)" = ""))
      }
  # Check if line is a html url
  else if (str_detect(line, "\\(.+\\.html\\)")) {
    # Extract url
    current_url <- str_extract(line, "\\(.*\\.html\\)") %>% str_replace_all(c("\\(" = "", "\\)" = ""))
      }
  # If line is blank or end of file, add data_extracted to the tibble
  if (line == "" | identical(line, tail(lines, n = 1))) {
    data_extracted <- data_extracted %>% add_row(heading = current_heading, png = current_png, url = current_url)
  }
}

# View data_extracted
print(data_extracted)
