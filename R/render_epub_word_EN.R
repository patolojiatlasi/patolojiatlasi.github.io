
# prepare EN epub ----

fs::file_copy(path = "./_quarto_EN_epub_word.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_copy(path = "./R/languageEN.R",
              new_path = "./R/language.R",
              overwrite = TRUE)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

if (dir.exists(paths = "./_freeze_EN_epub_word")) {
  fs::dir_copy(path = "./_freeze_EN_epub_word",
               new_path = "./_freeze",
               overwrite = TRUE)
}

patolojiatlasi_histopathologyatlas <- readxl::read_excel("./patolojiatlasi_histopathologyatlas.xlsx")

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas[, c("TR_chapter_qmd", "EN_epub_word_chapter_qmd")]

patolojiatlasi_histopathologyatlas$TR_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$TR_chapter_qmd, ".qmd")

patolojiatlasi_histopathologyatlas$EN_epub_word_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$EN_epub_word_chapter_qmd, ".qmd")


fs::file_copy(path = patolojiatlasi_histopathologyatlas$TR_chapter_qmd,
              new_path = patolojiatlasi_histopathologyatlas$EN_epub_word_chapter_qmd,
              overwrite = TRUE)


qmd_epub_word_EN_files <- list.files(path = ".", pattern = "./*_epub_word_EN.qmd", recursive = FALSE)

xfun::gsub_files(files = qmd_epub_word_EN_files,
                 pattern = "panel-tabset",
                 replacement = "")

xfun::gsub_files(files = qmd_epub_word_EN_files,
                 pattern = ":::::",
                 replacement = "")


xfun::gsub_files(files = qmd_epub_word_EN_files,
                 pattern = "### WSI - Link",
                 replacement = "")

xfun::gsub_files(files = qmd_epub_word_EN_files,
                 pattern = "### WSI",
                 replacement = "")

xfun::gsub_files(files = qmd_epub_word_EN_files,
                 pattern = "### Diagnosis",
                 replacement = "")

# xfun::gsub_files(files = qmd_epub_word_EN_files,
#                  pattern = '::: {.callout-tip collapse="true" appearance="default" icon="true"}',
#                  replacement = "")

xfun::gsub_files(files = qmd_epub_word_EN_files,
                 pattern = "### Click for Diagnosis",
                 replacement = "### Diagnosis")

# xfun::gsub_files(files = qmd_epub_word_EN_files,
#                  pattern = ":::",
#                  replacement = "")


# render EN epub ----

Sys.sleep(2)

quarto::quarto_render(".", as_job = FALSE)


Sys.sleep(2)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze",
               new_path = "./_freeze_EN_epub_word",
               overwrite = TRUE)
}

Sys.sleep(2)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}




patolojiatlasi_histopathologyatlas <- readxl::read_excel("./patolojiatlasi_histopathologyatlas.xlsx")

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas[, c("TR_chapter_qmd", "EN_epub_word_chapter_qmd")]

'%>%' <- magrittr:::`%>%`

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas %>%
  dplyr::distinct() %>%
  dplyr::filter(TR_chapter_qmd != EN_epub_word_chapter_qmd)

patolojiatlasi_histopathologyatlas$EN_epub_word_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$EN_epub_word_chapter_qmd, ".qmd")

fs::file_delete(path = patolojiatlasi_histopathologyatlas$EN_epub_word_chapter_qmd)

