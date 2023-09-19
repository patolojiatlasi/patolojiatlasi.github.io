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

patolojiatlasi_histopathologyatlas <- readxl::read_excel("./patolojiatlasi_histopathologyatlas.xlsx", sheet = "chapters")

patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas[, c("TR_chapter_qmd", "TR_pdf_chapter_qmd")]

TR_chapter_qmd <- paste0("./", patolojiatlasi_histopathologyatlas$TR_chapter_qmd, ".qmd")

TR_pdf_chapter_qmd <- paste0("./", patolojiatlasi_histopathologyatlas$TR_pdf_chapter_qmd, ".qmd")

subchapter_files <- list.files(path = "./_subchapters", pattern = "*.qmd", recursive = FALSE)

subchapter_files  <- paste0("./_subchapters/", subchapter_files)

subchapter_files_pdf_TR <- gsub(pattern = ".qmd", replacement = "_pdf_TR.qmd", x = subchapter_files)

TR_chapter_qmd <- c(TR_chapter_qmd, subchapter_files)

pdf_TR_chapter_qmd <- c(TR_pdf_chapter_qmd, subchapter_files_pdf_TR)

fs::file_copy(path = TR_chapter_qmd,
              new_path = pdf_TR_chapter_qmd,
              overwrite = TRUE)



xfun::gsub_files(files = pdf_TR_chapter_qmd,
                 pattern = "panel-tabset",
                 replacement = "")

xfun::gsub_files(files = pdf_TR_chapter_qmd,
                 pattern = ":::::",
                 replacement = "")


xfun::gsub_files(files = pdf_TR_chapter_qmd,
                 pattern = "#+\\s*WSI - Link",
                 replacement = "")

xfun::gsub_files(files = pdf_TR_chapter_qmd,
                 pattern = "#+\\s*WSI",
                 replacement = "")

xfun::gsub_files(files = pdf_TR_chapter_qmd,
                 pattern = "#+\\s*Diagnosis",
                 replacement = "")

xfun::gsub_files(files = pdf_TR_chapter_qmd,
                 pattern = "#+\\s*Click for Diagnosis",
                 replacement = "### Diagnosis")

xfun::gsub_files(files = pdf_TR_chapter_qmd,
                 pattern = '\\!\\[\\]\\(\\.\\/qrcodes\\/\\{\\{template\\}\\}-\\{\\{stain\\}\\}_qrcode.svg\\)\\{width="15%"\\}',
                 replacement = "")



xfun::gsub_files(files = pdf_TR_chapter_qmd,
                 pattern = ".qmd >}}",
                 replacement = "_pdf_TR.qmd >}}"
)




# render TR pdf ----

quarto::quarto_render(".", as_job = FALSE)



# post render TR pdf ----


if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze",
               new_path = "./_freeze_TR_pdf",
               overwrite = TRUE)
}



if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}



pdf_TR_chapter_qmd <- pdf_TR_chapter_qmd[!(pdf_TR_chapter_qmd %in% TR_chapter_qmd)]

fs::file_delete(path = pdf_TR_chapter_qmd)

rm(list=ls())

