
# prepare EN pdf ----

fs::file_copy(path = "./_quarto_EN_pdf.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_copy(path = "./R/languageEN.R",
              new_path = "./R/language.R",
              overwrite = TRUE)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

if (dir.exists(paths = "./_freeze_EN_pdf")) {
  fs::dir_copy(path = "./_freeze_EN_pdf",
               new_path = "./_freeze",
               overwrite = TRUE)
}

patolojiatlasi_histopathologyatlas <- readxl::read_excel("./patolojiatlasi_histopathologyatlas.xlsx", sheet = "chapters")

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas[, c("TR_chapter_qmd", "EN_pdf_chapter_qmd")]

patolojiatlasi_histopathologyatlas$TR_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$TR_chapter_qmd, ".qmd")

patolojiatlasi_histopathologyatlas$EN_pdf_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$EN_pdf_chapter_qmd, ".qmd")


fs::file_copy(path = patolojiatlasi_histopathologyatlas$TR_chapter_qmd,
              new_path = patolojiatlasi_histopathologyatlas$EN_pdf_chapter_qmd,
              overwrite = TRUE)


qmd_pdf_EN_files <- list.files(path = ".", pattern = "./*_pdf_EN.qmd", recursive = FALSE)

subchapter_files <- list.files(path = "./_subchapters", pattern = "*.qmd", recursive = FALSE)

subchapter_files <- paste0("./_subchapters/", subchapter_files)

qmd_pdf_EN_files <- c(qmd_pdf_EN_files, subchapter_files)


xfun::gsub_files(files = qmd_pdf_EN_files,
                 pattern = "panel-tabset",
                 replacement = "")

xfun::gsub_files(files = qmd_pdf_EN_files,
                 pattern = ":::::",
                 replacement = "")


xfun::gsub_files(files = qmd_pdf_EN_files,
                 pattern = "### WSI - Link",
                 replacement = "")

xfun::gsub_files(files = qmd_pdf_EN_files,
                 pattern = "### WSI",
                 replacement = "")

xfun::gsub_files(files = qmd_pdf_EN_files,
                 pattern = "### Diagnosis",
                 replacement = "")

xfun::gsub_files(files = qmd_pdf_EN_files,
                 pattern = "### Click for Diagnosis",
                 replacement = "### Diagnosis")

xfun::gsub_files(files = qmd_pdf_EN_files,
                 pattern = '\\!\\[\\]\\(\\.\\/qrcodes\\/\\{\\{template\\}\\}-\\{\\{stain\\}\\}_qrcode.svg\\)\\{width="15%"\\}',
                 replacement = "")


xfun::gsub_files(files = "./bs_pdf_TR.qmd",
                 pattern = ".qmd",
                 replacement = "_pdf_TR.qmd"
)


# render EN pdf ----

quarto::quarto_render(".", as_job = FALSE)



# post render EN pdf ----


if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze",
               new_path = "./_freeze_EN_pdf",
               overwrite = TRUE)
}



if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}




patolojiatlasi_histopathologyatlas <- readxl::read_excel("./patolojiatlasi_histopathologyatlas.xlsx", sheet = "chapters")

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas[, c("TR_chapter_qmd", "EN_pdf_chapter_qmd")]

'%>%' <- magrittr:::`%>%`

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas %>%
  dplyr::distinct() %>%
  dplyr::filter(TR_chapter_qmd != EN_pdf_chapter_qmd)

patolojiatlasi_histopathologyatlas$EN_pdf_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$EN_pdf_chapter_qmd, ".qmd")

fs::file_delete(path = patolojiatlasi_histopathologyatlas$EN_pdf_chapter_qmd)


