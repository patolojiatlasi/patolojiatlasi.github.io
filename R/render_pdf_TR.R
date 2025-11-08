# Load utilities ----
source("./R/config.R")
source("./R/utils.R")

# Render Turkish PDF ----
render_format(
  language = "TR",
  format = "pdf",
  config_file = "./_quarto_TR_pdf.yml",
  excel_column_suffix = "pdf"
)

rm(list=ls())
