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



markdown <- qmd_content

# Extract headings
headings <- stringr::str_extract(markdown, "^#+\\s.+")
headings <- stringr::str_replace_all(headings, "^#+\\s", "") # Remove the hash symbols and leading spaces
headings <- stringr::str_replace_all(headings, "\\{.*?\\}", "")
headings <- stringr::str_trim(headings)


# Extract links
# links <- stringr::str_extract_all(markdown, "\\[(.*?)\\]\\((https://images.patolojiatlasi.com/.*?\\.html)\\)")
links <- stringr::str_extract_all(markdown, "https://images.patolojiatlasi.com/.*?\\.html")


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

  output <- c(output, "") # Add an empty line between sections
}

# Convert output to data frame
df <- data.frame(Info = output, stringsAsFactors = FALSE)


df2 <- df %>%
  dplyr::distinct() %>%
  dplyr::filter(!is.na(Info)) %>%
  dplyr::filter(!(Info == "")) %>%
  dplyr::filter(!(Info == "No links found.")) %>%
  dplyr::filter(!(Info == "Heading: NA")) %>%
  dplyr::filter(!(Info == "Links:"))


texts <- paste0(df2$Info, collapse = " ")

texts <- stringr::str_extract_all(string = texts,
                     pattern = "Heading: .*?\\.html")

texts <- unlist(texts)

texts <- stringr::str_replace_all(string = texts,
                                  pattern = "Heading: ",
                                  replacement = "")

texts <- data.frame(texts = texts)

