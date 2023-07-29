
# prepare TR epub ----

fs::file_copy(path = "./_quarto_TR_epub.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_copy(path = "./R/languageTR.R",
              new_path = "./R/language.R",
              overwrite = TRUE)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

if (dir.exists(paths = "./_freeze_TR_epub")) {
  fs::dir_copy(path = "./_freeze_TR_epub",
               new_path = "./_freeze",
               overwrite = TRUE)
}

patolojiatlasi_histopathologyatlas <- readxl::read_excel("./patolojiatlasi_histopathologyatlas.xlsx")

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas[, c("TR_chapter_qmd", "TR_epub_chapter_qmd")]

patolojiatlasi_histopathologyatlas$TR_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$TR_chapter_qmd, ".qmd")

patolojiatlasi_histopathologyatlas$TR_epub_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$TR_epub_chapter_qmd, ".qmd")


fs::file_copy(path = patolojiatlasi_histopathologyatlas$TR_chapter_qmd,
              new_path = patolojiatlasi_histopathologyatlas$TR_epub_chapter_qmd,
              overwrite = TRUE)


qmd_epub_TR_files <- list.files(path = ".", pattern = "./*_epub_TR.qmd", recursive = FALSE)

xfun::gsub_files(files = qmd_epub_TR_files,
                 pattern = "panel-tabset",
                 replacement = "")

xfun::gsub_files(files = qmd_epub_TR_files,
                 pattern = ":::::",
                 replacement = "")



# render TR epub ----

Sys.sleep(2)

quarto::quarto_render(".", as_job = FALSE)


Sys.sleep(2)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze",
               new_path = "./_freeze_TR_epub",
               overwrite = TRUE)
}

Sys.sleep(2)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}




patolojiatlasi_histopathologyatlas <- readxl::read_excel("./patolojiatlasi_histopathologyatlas.xlsx")

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas[, c("TR_chapter_qmd", "TR_epub_chapter_qmd")]

'%>%' <- magrittr:::`%>%`

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas %>%
  dplyr::distinct() %>%
  dplyr::filter(TR_chapter_qmd != TR_epub_chapter_qmd)

patolojiatlasi_histopathologyatlas$TR_epub_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$TR_epub_chapter_qmd, ".qmd")

fs::file_delete(path = patolojiatlasi_histopathologyatlas$TR_epub_chapter_qmd)


