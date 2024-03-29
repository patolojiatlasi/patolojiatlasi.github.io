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

if (!requireNamespace("readxl", quietly = TRUE)) {
  install.packages("readxl")
}

if (!requireNamespace("tinytex", quietly = TRUE)) {
  install.packages("tinytex")
}

if (!tinytex::is_tinytex()) {
  tinytex::install_tinytex()
}

# prepare EN ----


folders_to_delete <- fs::dir_ls(path = ".",
                                recurse = FALSE, regexp = "_files$")

fs::dir_delete(folders_to_delete)



if (dir.exists(paths = "./public")) {
  fs::dir_delete(path = "./public")
}

if (dir.exists(paths = "./EN")) {
  fs::dir_delete(path = "./EN")
}

if (dir.exists(paths = "./docs")) {
  fs::dir_delete(path = "./docs")
}



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

# https://chat.openai.com/share/20462a5b-e72e-4e0c-a5bc-aff81517b40a

patolojiatlasi_histopathologyatlas <- readxl::read_excel(path = "./patolojiatlasi_histopathologyatlas.xlsx",
                                                         sheet = "chapters")


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



# render EN ----

quarto::quarto_render(".", as_job = FALSE)


if (file.exists("./_EN/CNAME")){
  fs::file_delete(path = "./_EN/CNAME")
}

if (dir.exists(paths = "./_EN/public")) {
  fs::dir_delete(path = "./_EN/public")
}

if (dir.exists(paths = "./_EN/docs")) {
  fs::dir_delete(path = "./_EN/docs")
}

if (dir.exists(paths = "./_freeze")) {
fs::dir_copy(path = "./_freeze",
             new_path = "./_freeze_EN",
             overwrite = TRUE)
}



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


rm(list=ls())





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

if (dir.exists(paths = "./_freeze_TR")) {
fs::dir_copy(path = "./_freeze_TR",
             new_path = "./_freeze",
             overwrite = TRUE)
}


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

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}


if (dir.exists(paths = "./_docs/public")) {
  fs::dir_delete(path = "./_docs/public")
}

if (dir.exists(paths = "./_docs/_public")) {
  fs::dir_delete(path = "./_docs/_public")
}

if (dir.exists(paths = "./_docs/EN")) {
  fs::dir_delete(path = "./_docs/EN")
}

if (dir.exists(paths = "./_docs/_EN")) {
  fs::dir_delete(path = "./_docs/_EN")
}

if (dir.exists(paths = "./_docs/_lecture-notes")) {
  fs::dir_delete(path = "./_docs/_lecture-notes")
}

if (dir.exists(paths = "./_docs/lecture-notes")) {
  fs::dir_delete(path = "./_docs/lecture-notes")
}




fs::dir_copy(path = "./_docs", new_path = "./public", overwrite = TRUE)

if (file.exists("./public/CNAME")){
  fs::file_delete(path = "./public/CNAME")
}



fs::dir_copy(path = "./_docs", new_path = "./docs", overwrite = TRUE)

if (dir.exists(paths = "./_docs")) {
  fs::dir_delete(path = "./_docs")
}

if (dir.exists(paths = "./_EN")) {
fs::dir_copy(path = "./_EN", new_path = "./EN", overwrite = TRUE)
}

if (dir.exists(paths = "./_EN")) {
  fs::dir_delete(path = "./_EN")
}


folders_to_delete <- fs::dir_ls(path = ".",
                                recurse = FALSE, regexp = "_files$")

fs::dir_delete(folders_to_delete)


cat("\Ud83E\UdD83")

source("./R/tweet-random-cases.R")

source("./R/extract-html-links.R")

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


rm(list=ls())




