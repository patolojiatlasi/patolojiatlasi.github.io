# Load utilities ----
source("./R/config.R")
source("./R/utils.R")

# Render Turkish EPUB/Word ----
render_format(
  language = "TR",
  format = "epub_word",
  config_file = "./_quarto_TR_epub_word.yml",
  excel_column_suffix = "epub_word"
)

rm(list=ls())
