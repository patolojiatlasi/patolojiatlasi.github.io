`%>%` <- magrittr::`%>%`

qmd_files1 <- list.files(path = ".", pattern = "*.qmd", recursive = FALSE, full.names = TRUE)

qmd_files2 <- list.files(path = "./_subchapters", pattern = "*.qmd", recursive = FALSE, full.names = TRUE)

qmd_files <- c(qmd_files1, qmd_files2)

# qmd_files[31]

# qmd_content <- readLines(con = qmd_files[31])

qmd_content <- list()

for (file in qmd_files) {
  text <- readLines(file)
  qmd_content[[file]] <- text
}

qmd_content2 <-
unlist(qmd_content, use.names = TRUE)



qmd_content <- qmd_content2

link_list <-
  stringr::str_extract(string = qmd_content,
                    pattern = "https:\\/\\/images\\.patolojiatlasi\\.com\\/.*?\\.html")

explanation_list <-
stringr::str_extract(string = qmd_content,
                     pattern = "\\*\\*.*?\\*\\*")


heading_list <-
  stringr::str_extract(string = qmd_content,
                       pattern = "\\*\\*.*?\\*\\*")



df_links <- data.frame(
  links = link_list,
  explanation = explanation_list
  )

df_links <- df_links %>%
  dplyr::filter(
    !(stringr::str_detect(string = links,
                        pattern = "template")
    )
  )


webpages <- df_links %>%
  dplyr::select(links) %>%
  dplyr::filter(!is.na(links)) %>%
  dplyr::distinct() %>%
  dplyr::pull(links)

write(x = webpages, file = "./webpages.txt")

yaml_preparation_file <- df_links %>%
  dplyr::select(links) %>%
  dplyr::filter(!is.na(links)) %>%
  dplyr::distinct()

yaml_preparation_file <- yaml_preparation_file %>%
# remove https://images.patolojiatlasi.com/ from the links
  dplyr::mutate(
    repo = stringr::str_replace(string = links,
                                 pattern = "https://images.patolojiatlasi.com/",
                                 replacement = "")
  ) %>%
  dplyr::mutate(
    stainname = stringr::str_replace(string = repo,
                                     pattern = "/",
                                     replacement = "-")
  ) %>%
  dplyr::mutate(
    stainname = stringr::str_replace(string = stainname,
                                     pattern = ".html",
                                     replacement = "")
  ) %>%
# extract repo name from the repo up to first forward slash
  dplyr::mutate(
    reponame = stringr::str_extract(string = repo,
                                pattern = ".*?\\/")
  ) %>%
  dplyr::mutate(
    reponame = stringr::str_replace(string = reponame,
                                 pattern = "/",
                                 replacement = "")
  ) %>%
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
       type = "published",
       author = list("Serdar Balci", "Memorial Patoloji"),
       date = as.character(Sys.Date()),
       url = yaml_preparation_file$links[i],
       note = "",
       categoriesTR = list("", "", "", "patoloji", "atlas", "histopatoloji", "whole slide image"),
       categoriesEN = list("", "", "", "pathology", "atlas", "histopathology", "whole slide image"),
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

js_file <- "webpages.js"

writeLines(js_array, js_file)




# Install required packages if not already installed
if (!requireNamespace("yaml", quietly = TRUE)) install.packages("yaml")
if (!requireNamespace("jsonlite", quietly = TRUE)) install.packages("jsonlite")

library(yaml)
library(jsonlite)

# Read the YAML file
yaml_data <- yaml::read_yaml("./lists/list.yaml")

# Convert YAML to JSON
json_data <- jsonlite::toJSON(yaml_data, auto_unbox = TRUE, pretty = TRUE)

# Wrap the JSON in a JavaScript variable declaration
js_data <- paste0("const specimensData = ", json_data, ";")

# Write the JavaScript to a file
writeLines(js_data, "./lists/specimensData.js")




# markdown <- qmd_content
#
# # Extract headings
# headings <- stringr::str_extract(markdown, "^#+\\s.+")
# headings <- stringr::str_replace_all(headings, "^#+\\s", "") # Remove the hash symbols and leading spaces
# headings <- stringr::str_replace_all(headings, "\\{.*?\\}", "")
# headings <- stringr::str_trim(headings)
#
#
# # Extract links
# # links <- stringr::str_extract_all(markdown, "\\[(.*?)\\]\\((https://images.patolojiatlasi.com/.*?\\.html)\\)")
# links <- stringr::str_extract_all(markdown, "https://images.patolojiatlasi.com/.*?\\.html")
#
# images <- stringr::str_extract_all(markdown, "./screenshots/.*?\\_screenshot.png")
#
#
#
#
# # Output the results
# output <- character()
#
# for (i in seq_along(headings)) {
#   output <- c(output, paste("Heading:", headings[i]))
#
#   if (length(links) >= i && length(links[[i]]) > 0) {
#     output <- c(output, "Links:")
#     output <- c(output, links[[i]])
#   } else {
#     output <- c(output, "No links found.")
#   }
#
#   # Extract images
#
#
#     if (length(images) >= i && length(images[[i]]) > 0) {
#     output <- c(output, "Images:")
#     output <- c(output, images[[i]])
#   } else {
#     output <- c(output, "No images found.")
#   }
#
#   output <- c(output, "") # Add an empty line between sections
# }
#
# # Convert output to data frame
# df_output <- data.frame(Info = output, stringsAsFactors = FALSE)
#
#
#
#
#
#
#
# # # Output the results
# # output <- character()
# #
# # for (i in seq_along(headings)) {
# #   output <- c(output, paste("Heading:", headings[i]))
# #
# #   if (length(links) >= i && length(links[[i]]) > 0) {
# #     output <- c(output, "Links:")
# #     output <- c(output, links[[i]])
# #   } else {
# #     output <- c(output, "No links found.")
# #   }
# #
# #   output <- c(output, "") # Add an empty line between sections
# # }
# #
# # # Convert output to data frame
# # df <- data.frame(Info = output, stringsAsFactors = FALSE)
#
#
# df_output_2 <- df_output %>%
#   dplyr::distinct() %>%
#   dplyr::filter(!is.na(Info)) %>%
#   dplyr::filter(!(Info == "")) %>%
#   dplyr::filter(!(Info == "No links found.")) %>%
#   dplyr::filter(!(Info == "Heading: NA")) %>%
#   dplyr::filter(!(Info == "Links:")) %>%
#   dplyr::filter(!(Info == "No images found.")) %>%
#   dplyr::filter(!(Info == "Images:"))
#
#
#
#
# texts <- paste0(df_output_2$Info, collapse = " ")
#
# texts <- stringr::str_extract_all(string = texts,
#                      pattern = "Heading: .*?\\.html")
#
# texts <- unlist(texts)
#
# texts <- stringr::str_replace_all(string = texts,
#                                   pattern = "Heading: ",
#                                   replacement = "")
#
#
# texts <- stringr::str_replace_all(string = texts,
#                                   pattern = "./screenshots/",
#                                   replacement = "https://www.patolojiatlasi.com/screenshots/")
#
# texts <- data.frame(texts = texts)
#
# wp_string <- dplyr::sample_n(texts, 1)
#
# wp_string <- wp_string$texts[1]
#
#
# wp_text <- paste0(wp_string,
#                   " #dijitalpatoloji #WSI ",
#                   " #patolojiatlasi #patolojinotlari ",
#                   " #histopathologyatlas #memorialpatoloji ",
#                   .sep ="")
#
#
# wp_text <- gsub(pattern = "https://www.patolojiatlasi.com/screenshots/",
#                 replacement = "<img src='https://www.patolojiatlasi.com/screenshots/",
#                 x = wp_text)
#
# wp_text <- gsub(pattern = "_screenshot.png",
#                 replacement = "_screenshot.jpg'>",
#                 x = wp_text)
#
# writeLines(text = wp_text, "./wp_text.txt")
#
# wp_heading <- paste0(wp_string,
#                     " #dijitalpatoloji #WSI ",
#                     " #patolojiatlasi #patolojinotlari ",
#                     " #histopathologyatlas #memorialpatoloji ",
#                           .sep ="")
#
# wp_heading <- gsub(pattern = "https?://[^ ]+\\.png",
#                    replacement = "",
#                    x = wp_heading)
#
# writeLines(text = wp_heading, "./wp_heading.txt")

