`%>%` <- magrittr::`%>%`

qmd_files <- list.files(path = ".", pattern = "*.qmd", recursive = FALSE, full.names = TRUE)

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


webpages <- df_links %>%
  dplyr::select(links) %>%
  dplyr::filter(!is.na(links)) %>%
  dplyr::distinct() %>%
  dplyr::pull(links)

write(x = webpages, file = "./webpages.txt")

js_array <- paste0('var webPages = [', paste0('"', webpages, '"', collapse = ", "), '];')

js_file <- "webpages.js"

writeLines(js_array, js_file)






markdown <- qmd_content

# Extract headings
headings <- stringr::str_extract(markdown, "^#+\\s.+")
headings <- stringr::str_replace_all(headings, "^#+\\s", "") # Remove the hash symbols and leading spaces
headings <- stringr::str_replace_all(headings, "\\{.*?\\}", "")
headings <- stringr::str_trim(headings)


# Extract links
# links <- stringr::str_extract_all(markdown, "\\[(.*?)\\]\\((https://images.patolojiatlasi.com/.*?\\.html)\\)")
links <- stringr::str_extract_all(markdown, "https://images.patolojiatlasi.com/.*?\\.html")

images <- stringr::str_extract_all(markdown, "./screenshots/.*?\\_screenshot.png")




# Output the results
output <- character()

for (i in seq_along(headings)) {
  output <- c(output, paste("Heading:", headings[i]))

  if (length(links) >= i && length(links[[i]]) > 0) {
    output <- c(output, "Links:")
    output <- c(output, links[[i]])
  } else {
    output <- c(output, "No links found.")
  }

  # Extract images


    if (length(images) >= i && length(images[[i]]) > 0) {
    output <- c(output, "Images:")
    output <- c(output, images[[i]])
  } else {
    output <- c(output, "No images found.")
  }

  output <- c(output, "") # Add an empty line between sections
}

# Convert output to data frame
df_output <- data.frame(Info = output, stringsAsFactors = FALSE)







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
#   output <- c(output, "") # Add an empty line between sections
# }
#
# # Convert output to data frame
# df <- data.frame(Info = output, stringsAsFactors = FALSE)


df_output_2 <- df_output %>%
  dplyr::distinct() %>%
  dplyr::filter(!is.na(Info)) %>%
  dplyr::filter(!(Info == "")) %>%
  dplyr::filter(!(Info == "No links found.")) %>%
  dplyr::filter(!(Info == "Heading: NA")) %>%
  dplyr::filter(!(Info == "Links:")) %>%
  dplyr::filter(!(Info == "No images found.")) %>%
  dplyr::filter(!(Info == "Images:"))




texts <- paste0(df_output_2$Info, collapse = " ")

texts <- stringr::str_extract_all(string = texts,
                     pattern = "Heading: .*?\\.html")

texts <- unlist(texts)

texts <- stringr::str_replace_all(string = texts,
                                  pattern = "Heading: ",
                                  replacement = "")


texts <- stringr::str_replace_all(string = texts,
                                  pattern = "./screenshots/",
                                  replacement = "https://www.patolojiatlasi.com/screenshots/")

texts <- data.frame(texts = texts)

wp_string <- dplyr::sample_n(texts, 1)

wp_string <- wp_string$texts[1]

wp_string <- paste0(wp_string,
                    " #dijitalpatoloji #WSI ",
                    " #patolojiatlasi #patolojinotlari ",
                    " #histopathologyatlas #memorialpatoloji ",
                          .sep ="")

writeLines(text = wp_string, "./wp_string.txt")

