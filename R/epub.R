if (!requireNamespace("xfun", quietly = TRUE)) {
  install.packages("xfun")
}


qmdfiles <- list.files(path = here::here(),
                       pattern = "*.qmd",
                       full.names = TRUE)



xfun::gsub_files(files = qmdfiles,
                 "-   ", ""
                 )

# xfun::gsub_files(files = qmdfiles,
#                  "https://pathologyatlas.github.io", "."
# )

quarto::quarto_render(".")

