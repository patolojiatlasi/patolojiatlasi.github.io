# Load utilities ----
source("./R/config.R")
source("./R/utils.R")

# Render English EPUB/Word ----
render_format(
  language = "EN",
  format = "epub_word",
  config_file = "./_quarto_EN_epub_word.yml",
  excel_column_suffix = "epub_word"
)

rm(list=ls())
