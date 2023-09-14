
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



chapters <- list.files(path = ".", pattern = ".qmd", recursive = FALSE)

chapters <- paste0("./", chapters)

chapters_pdf_EN <- gsub(pattern = ".qmd", replacement = "_pdf_EN.qmd", x = chapters)

subchapters <- list.files(path = "./_subchapters", pattern = ".qmd", recursive = FALSE)

subchapters <- paste0("./_subchapters/", subchapters)

subchapters_pdf_EN <- gsub(pattern = ".qmd", replacement = "_pdf_EN.qmd", x = subchapters)

all_chapters <- c(chapters, subchapters)

all_chapters_pdf_EN <- c(chapters_pdf_EN, subchapters_pdf_EN)


fs::file_copy(path = all_chapters,
              new_path = all_chapters_pdf_EN,
              overwrite = TRUE)


xfun::gsub_files(files = all_chapters_pdf_EN,
                 pattern = "panel-tabset",
                 replacement = "")

xfun::gsub_files(files = all_chapters_pdf_EN,
                 pattern = ":::::",
                 replacement = "")


xfun::gsub_files(files = all_chapters_pdf_EN,
                 pattern = "#+\\s*WSI - Link",
                 replacement = "")

xfun::gsub_files(files = all_chapters_pdf_EN,
                 pattern = "#+\\s*WSI",
                 replacement = "")

xfun::gsub_files(files = all_chapters_pdf_EN,
                 pattern = "#+\\s*Diagnosis",
                 replacement = "")

xfun::gsub_files(files = all_chapters_pdf_EN,
                 pattern = "#+\\s*Tanı için tıklayın",
                 replacement = "### Tanı")

xfun::gsub_files(files = all_chapters_pdf_EN,
                 pattern = '\\!\\[\\]\\(\\.\\/qrcodes\\/\\{\\{template\\}\\}-\\{\\{stain\\}\\}_qrcode.svg\\)\\{width="15%"\\}',
                 replacement = "")


xfun::gsub_files(files = all_chapters_pdf_EN,
                 pattern = ".qmd >}}",
                 replacement = "_pdf_EN.qmd >}}"
)



# render EN pdf ----

Sys.sleep(2)

quarto::quarto_render(".", as_job = FALSE)


Sys.sleep(2)

# postrender EN pdf ----


if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze",
               new_path = "./_freeze_EN_pdf",
               overwrite = TRUE)
}

Sys.sleep(2)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}


fs::file_copy(path = "./_quarto_EN.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_delete(path = all_chapters_pdf_EN)


