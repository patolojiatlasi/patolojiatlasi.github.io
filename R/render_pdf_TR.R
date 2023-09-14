
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



chapters <- list.files(path = ".", pattern = ".qmd", recursive = FALSE)

chapters <- paste0("./", chapters)

chapters_pdf_TR <- gsub(pattern = ".qmd", replacement = "_pdf_TR.qmd", x = chapters)

subchapters <- list.files(path = "./_subchapters", pattern = ".qmd", recursive = FALSE)

subchapters <- paste0("./_subchapters/", subchapters)

subchapters_pdf_TR <- gsub(pattern = ".qmd", replacement = "_pdf_TR.qmd", x = subchapters)

all_chapters <- c(chapters, subchapters)

all_chapters_pdf_TR <- c(chapters_pdf_TR, subchapters_pdf_TR)


fs::file_copy(path = all_chapters,
              new_path = all_chapters_pdf_TR,
              overwrite = TRUE)


xfun::gsub_files(files = all_chapters_pdf_TR,
                 pattern = "panel-tabset",
                 replacement = "")

xfun::gsub_files(files = all_chapters_pdf_TR,
                 pattern = ":::::",
                 replacement = "")


xfun::gsub_files(files = all_chapters_pdf_TR,
                 pattern = "#+\\s*WSI - Link",
                 replacement = "")

xfun::gsub_files(files = all_chapters_pdf_TR,
                 pattern = "#+\\s*WSI",
                 replacement = "")

xfun::gsub_files(files = all_chapters_pdf_TR,
                 pattern = "#+\\s*Diagnosis",
                 replacement = "")

xfun::gsub_files(files = all_chapters_pdf_TR,
                 pattern = "#+\\s*Tanı için tıklayın",
                 replacement = "### Tanı")

xfun::gsub_files(files = all_chapters_pdf_TR,
                 pattern = '\\!\\[\\]\\(\\.\\/qrcodes\\/\\{\\{template\\}\\}-\\{\\{stain\\}\\}_qrcode.svg\\)\\{width="15%"\\}',
                 replacement = "")


xfun::gsub_files(files = all_chapters_pdf_TR,
                 pattern = ".qmd >}}",
                 replacement = "_pdf_TR.qmd >}}"
)



# render TR pdf ----

Sys.sleep(2)

quarto::quarto_render(".", as_job = FALSE)


Sys.sleep(2)

# postrender TR pdf ----


if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze",
               new_path = "./_freeze_TR_pdf",
               overwrite = TRUE)
}

Sys.sleep(2)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}


fs::file_copy(path = "./_quarto_TR.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_delete(path = all_chapters_pdf_TR)


