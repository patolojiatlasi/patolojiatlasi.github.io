# libraries ----
if (!requireNamespace("xfun", quietly = TRUE)) {
  install.packages("xfun")
}

if (!requireNamespace("quarto", quietly = TRUE)) {
  install.packages("quarto")
}

if (!requireNamespace("fs", quietly = TRUE)) {
  install.packages("fs")
}

# prepare EN ----

fs::file_copy(path = "./_quarto_EN.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)

fs::file_copy(path = "./R/languageEN.R",
              new_path = "./R/language.R",
              overwrite = TRUE)

# render EN ----

quarto::quarto_render(".", as_job = FALSE)


if (file.exists("./EN/CNAME")){
  fs::file_delete(path = "./EN/CNAME")
}


# prepare TR ----

fs::file_copy(path = "./_quarto_TR.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_copy(path = "./R/languageTR.R",
              new_path = "./R/language.R",
              overwrite = TRUE)

# render TR ----

quarto::quarto_render(".", as_job = FALSE)


fs::dir_copy(path = "./docs", new_path = "./public", overwrite = TRUE)


cat("\Ud83E\UdD83")

##### ----


# fs::dir_copy(path = "./EN",
#              new_path = "./docs/EN",
#              overwrite = TRUE
# )


# language <- c("TR", "EN")

# system2(command = "quarto render --to all")

# quarto::quarto_render(".")

# language <- language[2]
# language <- "EN"

# quarto::quarto_render(".")

# fs::file_delete(path = "./_quarto.yml")



# qmdfiles <- list.files(path = here::here(),
#                        pattern = "*.qmd",
#                        full.names = TRUE)



# xfun::gsub_files(files = qmdfiles,
#                  "-   ", ""
#                  )

# xfun::gsub_files(files = qmdfiles,
#                  "https://pathologyatlas.github.io", "."
# )


