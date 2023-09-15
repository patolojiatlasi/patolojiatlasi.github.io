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

patolojiatlasi_histopathologyatlas <- readxl::read_excel("./patolojiatlasi_histopathologyatlas.xlsx", sheet = "chapters")

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas[, c("TR_chapter_qmd", "EN_chapter_qmd")]

TR_chapter_qmd <- paste0("./", patolojiatlasi_histopathologyatlas$TR_chapter_qmd, ".qmd")

EN_chapter_qmd <- paste0("./", patolojiatlasi_histopathologyatlas$EN_chapter_qmd, ".qmd")

subchapter_files <- list.files(path = "./_subchapters", pattern = "*.qmd", recursive = FALSE)

subchapter_files  <- paste0("./_subchapters/", subchapter_files)

subchapter_files_EN <- gsub(pattern = ".qmd", replacement = "_EN.qmd", x = subchapter_files)

TR_chapter_qmd <- c(TR_chapter_qmd, subchapter_files)

EN_chapter_qmd <- c(EN_chapter_qmd, subchapter_files_EN)

fs::file_copy(path = TR_chapter_qmd,
              new_path = EN_chapter_qmd,
              overwrite = TRUE)


xfun::gsub_files(files = EN_chapter_qmd,
                 pattern = ".qmd >}}",
                 replacement = "_EN.qmd >}}"
)




# render EN  ----

quarto::quarto_render(".", as_job = FALSE)



# post render EN  ----


if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze",
               new_path = "./_freeze_EN",
               overwrite = TRUE)
}



if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}



files_to_delete <- EN_chapter_qmd[!(EN_chapter_qmd %in% TR_chapter_qmd)]

fs::file_delete(path = files_to_delete)


files_to_revert <- EN_chapter_qmd[EN_chapter_qmd %in% TR_chapter_qmd]


xfun::gsub_files(files = files_to_revert,
                 pattern = "_EN.qmd >}}",
                 replacement = ".qmd >}}"
)


if (file.exists("./_EN/CNAME")){
  fs::file_delete(path = "./_EN/CNAME")
}


if (dir.exists(paths = "./_EN/docs")) {
  fs::dir_delete(path = "./_EN/docs")
}

if (dir.exists(paths = "./_EN/public")) {
  fs::dir_delete(path = "./_EN/public")
}

if (dir.exists(paths = "./_EN")) {
  fs::dir_copy(path = "./_EN", new_path = "./EN", overwrite = TRUE)
}

if (dir.exists(paths = "./_EN")) {
  fs::dir_delete(path = "./_EN")
}



rm(list=ls())

