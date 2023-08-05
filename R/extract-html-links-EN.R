`%>%` <- magrittr::`%>%`

qmd_files <- list.files(path = ".", pattern = "*.qmd", recursive = FALSE, full.names = TRUE)

qmd_content <- list()

for (file in qmd_files) {
  text <- readLines(file)
  qmd_content[[file]] <- text
}

qmd_content2 <-
unlist(qmd_content, use.names = TRUE)



qmd_content <- qmd_content2



link_list <- stringr::str_extract(string = qmd_content,
                     pattern = "Click for Full Screen WSI.*?\\.html"
                     )


df_links <- data.frame(
  links = link_list
)

df_links <- df_links %>%
  dplyr::filter(!is.na(links))


df_links <- df_links %>%
  dplyr::mutate(
    images = stringr::str_extract(string = links,
                                  pattern = "screenshots.*?\\.png")
  )

df_links <- df_links %>%
  dplyr::mutate(
    web = stringr::str_extract(string = links,
                               pattern = "https:\\/\\/images\\.patolojiatlasi\\.com\\/.*?\\.html")
  )

df_links <- df_links %>%
  dplyr::mutate(
    web = gsub(pattern = "patolojiatlasi",
               replacement = "histopathologyatlas",
               x = web,
               fixed = TRUE)
  )


df_links <- df_links %>%
  dplyr::mutate(
    images = paste0("https://www.histopathologyatlas.com/", images)
  )

df_links <- df_links %>%
  dplyr::mutate(
    images = gsub(pattern = ".png", replacement = ".jpg", x = images, fixed = TRUE)
  )


random_df_link <- dplyr::sample_n(df_links, 1)

web_link <- random_df_link$web[1]

img_link <- random_df_link$images[1]

text_heading <- paste0("View this #wholeslideimage in #HistopathologyAtlas ",
                  web_link,
                  " #digitalpathology #WSI #preparat",
                          " #patolojiatlasi #patolojinotlari #histopathologyatlas",
                          " #memorialsaglik #memorialpatoloji",
                          .sep ="")

text_body <- paste0("View this #wholeslideimage in #HistopathologyAtlas ",
                  web_link,
                  " #digitalpathology #WSI #preparat",
                  " #patolojiatlasi #patolojinotlari #histopathologyatlas",
                  " #memorialsaglik #memorialpatoloji",
                  "<br><img src='", img_link, "'></img><br>"
                  .sep ="")


writeLines(text = text_heading, "./text_heading.txt")

writeLines(text = text_body, "./text_body.txt")
