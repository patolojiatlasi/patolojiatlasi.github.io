
# prepare EN  ----

fs::file_copy(path = "./_quarto_EN.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_copy(path = "./R/languageEN.R",
              new_path = "./R/language.R",
              overwrite = TRUE)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

if (dir.exists(paths = "./_freeze_EN")) {
  fs::dir_copy(path = "./_freeze_EN",
               new_path = "./_freeze",
               overwrite = TRUE)
}



chapters <- list.files(path = ".", pattern = ".qmd", recursive = FALSE)

chapters <- paste0("./", chapters)

chapters_EN <- gsub(pattern = ".qmd", replacement = "_EN.qmd", x = chapters)

subchapters <- list.files(path = "./_subchapters", pattern = ".qmd", recursive = FALSE)

subchapters <- paste0("./_subchapters/", subchapters)

subchapters_EN <- gsub(pattern = ".qmd", replacement = "_EN.qmd", x = subchapters)

all_chapters <- c(chapters, subchapters)

all_chapters_EN <- c(chapters_EN, subchapters_EN)


fs::file_copy(path = all_chapters,
              new_path = all_chapters_EN,
              overwrite = TRUE)

xfun::gsub_files(files = all_chapters_EN,
                 pattern = ".qmd >}}",
                 replacement = "_EN.qmd >}}"
)



# render EN  ----

Sys.sleep(2)

quarto::quarto_render(".", as_job = FALSE)


Sys.sleep(2)

# postrender EN  ----


if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze",
               new_path = "./_freeze_EN",
               overwrite = TRUE)
}

Sys.sleep(2)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

fs::file_delete(path = all_chapters_EN)


