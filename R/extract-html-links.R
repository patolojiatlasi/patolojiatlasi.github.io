#' Extract HTML Links and Generate Data Feeds
#'
#' @description
#' Post-processing script that extracts whole slide image (WSI) links from Quarto
#' markdown files and generates various data formats for the pathology atlas:
#'   1. Extracts links from .qmd files
#'   2. Generates YAML metadata for all cases
#'   3. Creates JSON data for JavaScript consumption
#'   4. Generates RSS feeds for both TR and EN versions
#'   5. Creates webpages.txt and webpages.js for navigation
#'
#' @details
#' This script is called at the end of the bilingual build process to aggregate
#' all pathology case links and metadata from the rendered content.
#'
#' Output Files Generated:
#'   - webpages.txt: Plain text list of all WSI viewer URLs
#'   - webpages.js: JavaScript array of URLs for web integration
#'   - lists/yaml_preparation_file.yaml: Auto-generated YAML template
#'   - lists/list.yaml: Updated master list with manual metadata
#'   - lists/specimensData.js: JSON data for published specimens
#'   - rss_feed.xml: Turkish RSS feed
#'   - rss_feed_EN.xml: English RSS feed
#'
#' @seealso
#' - R/bilingual-quarto-book.R: Main build script that calls this
#' - lists/list.yaml: Master metadata list (manually curated)
#' - DEVELOPMENT.md: Documentation on metadata workflow
#'
#' @examples
#' \dontrun{
#'   # Typically run automatically by bilingual-quarto-book.R
#'   source("./R/extract-html-links.R")
#' }


# ============================================================================
# SETUP
# ============================================================================

`%>%` <- magrittr::`%>%`


# ============================================================================
# PHASE 1: EXTRACT LINKS FROM QMD FILES
# ============================================================================

# Find all .qmd files in root directory and _subchapters/
qmd_files1 <- list.files(path = ".", pattern = "*.qmd", recursive = FALSE, full.names = TRUE)

qmd_files2 <- list.files(path = "./_subchapters", pattern = "*.qmd", recursive = FALSE, full.names = TRUE)

qmd_files <- c(qmd_files1, qmd_files2)

# ----------------------------------------------------------------------------
# Read Content from All QMD Files
# ----------------------------------------------------------------------------
# Read all .qmd files and store their content in a list
qmd_content <- list()

for (file in qmd_files) {
  text <- readLines(file)
  qmd_content[[file]] <- text
}

# Flatten list to single character vector (preserves file names)
qmd_content2 <-
unlist(qmd_content, use.names = TRUE)

qmd_content <- qmd_content2

# ----------------------------------------------------------------------------
# Extract WSI Links from Content
# ----------------------------------------------------------------------------
# Extract all links matching https://images.patolojiatlasi.com/*.html
# These are the whole slide image viewer URLs
link_list <-
  stringr::str_extract(string = qmd_content,
                    pattern = "https:\\/\\/images\\.patolojiatlasi\\.com\\/.*?\\.html")

# Extract explanation text (bold markdown **text**)
explanation_list <-
stringr::str_extract(string = qmd_content,
                     pattern = "\\*\\*.*?\\*\\*")

# Extract headings (also bold markdown)
heading_list <-
  stringr::str_extract(string = qmd_content,
                       pattern = "\\*\\*.*?\\*\\*")


# ============================================================================
# PHASE 2: PROCESS AND FILTER EXTRACTED DATA
# ============================================================================

# Create data frame combining links with their explanations
df_links <- data.frame(
  links = link_list,
  explanation = explanation_list
  )

# Filter out template/example links (not actual pathology cases)
df_links <- df_links %>%
  dplyr::filter(
    !(stringr::str_detect(string = links,
                        pattern = "template")
    )
  )

# ----------------------------------------------------------------------------
# Generate webpages.txt (Plain Text Link List)
# ----------------------------------------------------------------------------
# Extract unique, non-NA links for simple text list
webpages <- df_links %>%
  dplyr::select(links) %>%
  dplyr::filter(!is.na(links)) %>%
  dplyr::distinct() %>%
  dplyr::pull(links)

# Write to webpages.txt (used by various scripts and navigation)
write(x = webpages, file = "./output/webpages.txt")


# ============================================================================
# PHASE 3: GENERATE YAML METADATA
# ============================================================================

# ----------------------------------------------------------------------------
# Prepare YAML Data Structure
# ----------------------------------------------------------------------------
# Extract and transform link data for YAML generation
yaml_preparation_file <- df_links %>%
  dplyr::select(links) %>%
  dplyr::filter(!is.na(links)) %>%
  dplyr::distinct()

# Transform links into structured metadata fields
yaml_preparation_file <- yaml_preparation_file %>%
  # Remove base URL to get repository path
  dplyr::mutate(
    repo = stringr::str_replace(string = links,
                                 pattern = "https://images.patolojiatlasi.com/",
                                 replacement = "")
  ) %>%
  # Create stainname identifier (repo/file → repo-file)
  dplyr::mutate(
    stainname = stringr::str_replace(string = repo,
                                     pattern = "/",
                                     replacement = "-")
  ) %>%
  # Remove .html extension from stainname
  dplyr::mutate(
    stainname = stringr::str_replace(string = stainname,
                                     pattern = ".html",
                                     replacement = "")
  ) %>%
  # Extract repository name (before first slash)
  dplyr::mutate(
    reponame = stringr::str_extract(string = repo,
                                pattern = ".*?\\/")
  ) %>%
  # Remove trailing slash from reponame
  dplyr::mutate(
    reponame = stringr::str_replace(string = reponame,
                                 pattern = "/",
                                 replacement = "")
  ) %>%
  # Generate screenshot URL
  dplyr::mutate(
    screenshot = paste0("https://www.patolojiatlasi.com/screenshots/thumbnail_",
                        stainname, ".png")
  )




yaml_data <- lapply(1:nrow(yaml_preparation_file), function(i) {
  list(stainname = yaml_preparation_file$stainname[i],
       reponame = yaml_preparation_file$reponame[i],
       titleTR = "",
       titleEN = "",
       organTR = "",
       organEN = "",
       speciality = "",
       type = "unpublished",
       author = list("Serdar Balci", "Memorial Patoloji"),
       date = as.character(Sys.Date()),
       url = yaml_preparation_file$links[i],
       note = "",
       categoriesTR = list("patoloji", "atlas", "histopatoloji", "whole slide image"),
       categoriesEN = list("pathology", "atlas", "histopathology", "whole slide image"),
       screenshot = yaml_preparation_file$screenshot[i],
       githubrepo = paste0("https:///github.com/pathologyatlas/", yaml_preparation_file$reponame[i]),
       githubpage = paste0("https:///pathologyatlas.github.io/", yaml_preparation_file$reponame[i]),
       youtube = ""
       )
})


yaml_string <- yaml::as.yaml(yaml_data)

# cat(yaml_string)

yaml_file <- "lists/yaml_preparation_file.yaml"

writeLines(yaml_string, yaml_file)


original_content <- yaml::yaml.load_file("lists/yaml_preparation_file.yaml")
update_content <- yaml::yaml.load_file("lists/list.yaml")


update_yaml_entries <- function(original, update) {
  for (update_entry in update) {
    matched_index <- NULL
    for (i in seq_along(original)) {
      if (original[[i]]$stainname == update_entry$stainname) {
        matched_index <- i
        break
      }
    }
    if (!is.null(matched_index)) {
      # Update the matched entry with the new values
      original[[matched_index]] <- update_entry
    } else {
      # If no match is found, append the new entry to the original list
      original <- c(original, list(update_entry))
    }
  }
  return(original)
}

updated_content <- update_yaml_entries(original_content, update_content)

yaml::write_yaml(updated_content, "lists/list.yaml")


js_array <- paste0('var webPages = [', paste0('"', webpages, '"', collapse = ", "), '];')

js_file <- "./output/webpages.js"

writeLines(js_array, js_file)




# Install required packages if not already installed
if (!requireNamespace("yaml", quietly = TRUE)) install.packages("yaml")
if (!requireNamespace("jsonlite", quietly = TRUE)) install.packages("jsonlite")

library(yaml)
library(jsonlite)

# Read the YAML file
yaml_data <- yaml::read_yaml("./lists/list.yaml")

# Filter the data where type is "published"
filtered_data <- yaml_data[sapply(yaml_data, function(x) x$type == "published")]

# Convert YAML to JSON
json_data <- jsonlite::toJSON(filtered_data, auto_unbox = TRUE, pretty = TRUE)

# Wrap the JSON in a JavaScript variable declaration
js_data <- paste0("const specimensData = ", json_data, ";")

# Write the JavaScript to a file
writeLines(js_data, "./lists/specimensData.js")



library(xml2)
library(lubridate)

# Read YAML data
yaml_data <- yaml::read_yaml("./lists/list.yaml")

yaml_data <- yaml_data[sapply(yaml_data, function(x) x$type == "published")]

# Create the root element
rss <- xml2::xml_new_root("rss", version = "2.0")
channel <- xml2::xml_add_child(rss, "channel")

# Add channel information
xml2::xml_add_child(channel, "title", "Patoloji Atlası")
xml2::xml_add_child(channel, "link", "https://www.patolojiatlasi.com")
xml2::xml_add_child(channel, "description", "Patoloji Atlası RSS Feed")
xml2::xml_add_child(channel, "language", "tr-tr")

# Add items
for (item in yaml_data) {
  entry <- xml_add_child(channel, "item")

  xml_add_child(entry, "title", item$titleTR)  # Changed to Turkish title
  xml_add_child(entry, "link", item$url)
  xml_add_child(entry, "guid", item$url)

  description <- paste(
    item$titleTR, "-", item$organTR, "-",  # Changed to Turkish
    paste(item$categoriesTR, collapse = ", "),  # Changed to Turkish categories
    if (!is.null(item$note) && item$note != "") paste("\n\nNot:", item$note) else ""  # Added note
  )
  xml_add_child(entry, "description", description)

  date <- format(as.Date(item$date), "%a, %d %b %Y 00:00:00 +0000")
  xml_add_child(entry, "pubDate", date)

  for (category in item$categoriesTR) {  # Changed to Turkish categories
    xml_add_child(entry, "category", category)
  }

  # Add screenshot as enclosure
  if (!is.null(item$screenshot)) {
    enclosure <- xml_add_child(entry, "enclosure")
    xml_attr(enclosure, "url") <- item$screenshot
    xml_attr(enclosure, "type") <- "image/png"
    xml_attr(enclosure, "length") <- "0"
  }
}

# Write to file
write_xml(rss, "./rss_feed.xml")
