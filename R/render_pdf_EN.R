# Load utilities ----
source("./R/config.R")
source("./R/utils.R")

# Render English PDF ----
render_format(
  language = "EN",
  format = "pdf",
  config_file = "./_quarto_EN_pdf.yml",
  excel_column_suffix = "pdf"
)

rm(list=ls())
