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

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

fs::dir_copy(path = "./_freeze_EN",
             new_path = "./_freeze",
             overwrite = TRUE)


# render EN ----

quarto::quarto_render(".", as_job = FALSE)


if (file.exists("./EN/CNAME")){
  fs::file_delete(path = "./EN/CNAME")
}

if (dir.exists(paths = "./EN/public")) {
  fs::dir_delete(path = "./EN/public")
}

if (dir.exists(paths = "./EN/docs")) {
  fs::dir_delete(path = "./EN/docs")
}

if (dir.exists(paths = "./_freeze")) {
fs::dir_copy(path = "./_freeze",
             new_path = "./_freeze_EN",
             overwrite = TRUE)
}

# prepare TR ----

fs::file_copy(path = "./_quarto_TR.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_copy(path = "./R/languageTR.R",
              new_path = "./R/language.R",
              overwrite = TRUE)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

fs::dir_copy(path = "./_freeze_TR",
             new_path = "./_freeze",
             overwrite = TRUE)


# render TR ----

Sys.sleep(2)

quarto::quarto_render(".", as_job = FALSE)


Sys.sleep(2)

if (dir.exists(paths = "./_freeze")) {
fs::dir_copy(path = "./_freeze",
             new_path = "./_freeze_TR",
             overwrite = TRUE)
}

Sys.sleep(2)

if (dir.exists(paths = "./docs/public")) {
  fs::dir_delete(path = "./docs/public")
}

if (dir.exists(paths = "./docs/EN")) {
  fs::dir_delete(path = "./docs/EN")
}

if (dir.exists(paths = "./public")) {
  fs::dir_delete(path = "./public")
}

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


