# prepare TR pdf ----

fs::file_copy(path = "./_quarto_TR_pdf.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_copy(path = "./R/languageTR.R",
              new_path = "./R/language.R",
              overwrite = TRUE)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

if (dir.exists(paths = "./_freeze_TR_pdf")) {
  fs::dir_copy(path = "./_freeze_TR_pdf",
               new_path = "./_freeze",
               overwrite = TRUE)
}

patolojiatlasi_histopathologyatlas <- readxl::read_excel("./patolojiatlasi_histopathologyatlas.xlsx")

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas[, c("TR_chapter_qmd", "TR_pdf_chapter_qmd")]

patolojiatlasi_histopathologyatlas$TR_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$TR_chapter_qmd, ".qmd")

patolojiatlasi_histopathologyatlas$TR_pdf_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$TR_pdf_chapter_qmd, ".qmd")


fs::file_copy(path = patolojiatlasi_histopathologyatlas$TR_chapter_qmd,
              new_path = patolojiatlasi_histopathologyatlas$TR_pdf_chapter_qmd,
              overwrite = TRUE)


qmd_pdf_TR_files <- list.files(path = ".", pattern = "./*_pdf_TR.qmd", recursive = FALSE)

subchapter_files <- list.files(path = "./_subchapters", pattern = "_pdf_TR.qmd", recursive = FALSE)

subchapter_files <- paste0("./_subchapters/", subchapter_files)

qmd_pdf_TR_files <- c(qmd_pdf_TR_files, subchapter_files)

xfun::gsub_files(files = qmd_pdf_TR_files,
                 pattern = "panel-tabset",
                 replacement = "")

xfun::gsub_files(files = qmd_pdf_TR_files,
                 pattern = ":::::",
                 replacement = "")


xfun::gsub_files(files = qmd_pdf_TR_files,
                 pattern = "### WSI - Link",
                 replacement = "")

xfun::gsub_files(files = qmd_pdf_TR_files,
                 pattern = "### WSI",
                 replacement = "")

xfun::gsub_files(files = qmd_pdf_TR_files,
                 pattern = "### Diagnosis",
                 replacement = "")

xfun::gsub_files(files = qmd_pdf_TR_files,
                 pattern = "### Tanı için tıklayın",
                 replacement = "### Tanı")

xfun::gsub_files(files = qmd_pdf_TR_files,
                 pattern = '\\!\\[\\]\\(\\.\\/qrcodes\\/\\{\\{template\\}\\}-\\{\\{stain\\}\\}_qrcode.svg\\)\\{width="15%"\\}',
                 replacement = "")

xfun::gsub_files(files = "./bs_pdf_EN.qmd",
                 pattern = ".qmd",
                 replacement = "_pdf_EN.qmd"
                 )

# render TR pdf ----

Sys.sleep(2)

quarto::quarto_render(".", as_job = FALSE)


Sys.sleep(2)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze",
               new_path = "./_freeze_TR_pdf",
               overwrite = TRUE)
}

Sys.sleep(2)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}




patolojiatlasi_histopathologyatlas <- readxl::read_excel("./patolojiatlasi_histopathologyatlas.xlsx")

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas[, c("TR_chapter_qmd", "TR_pdf_chapter_qmd")]

'%>%' <- magrittr:::`%>%`

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas %>%
  dplyr::distinct() %>%
  dplyr::filter(TR_chapter_qmd != TR_pdf_chapter_qmd)

patolojiatlasi_histopathologyatlas$TR_pdf_chapter_qmd <- paste0(patolojiatlasi_histopathologyatlas$TR_pdf_chapter_qmd, ".qmd")

fs::file_delete(path = patolojiatlasi_histopathologyatlas$TR_pdf_chapter_qmd)


