
# prepare TR epub_word ----

fs::file_copy(path = "./_quarto_TR_epub_word.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_copy(path = "./R/languageTR.R",
              new_path = "./R/language.R",
              overwrite = TRUE)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

if (dir.exists(paths = "./_freeze_TR_epub_word")) {
  fs::dir_copy(path = "./_freeze_TR_epub_word",
               new_path = "./_freeze",
               overwrite = TRUE)
}



chapters <- list.files(path = ".", pattern = ".qmd", recursive = FALSE)

chapters <- paste0("./", chapters)

chapters_epub_word_TR <- gsub(pattern = ".qmd", replacement = "_epub_word_TR.qmd", x = chapters)

subchapters <- list.files(path = "./_subchapters", pattern = ".qmd", recursive = FALSE)

subchapters <- paste0("./_subchapters/", subchapters)

subchapters_epub_word_TR <- gsub(pattern = ".qmd", replacement = "_epub_word_TR.qmd", x = subchapters)

all_chapters <- c(chapters, subchapters)

all_chapters_epub_word_TR <- c(chapters_epub_word_TR, subchapters_epub_word_TR)


fs::file_copy(path = all_chapters,
              new_path = all_chapters_epub_word_TR,
              overwrite = TRUE)


xfun::gsub_files(files = all_chapters_epub_word_TR,
                 pattern = "panel-tabset",
                 replacement = "")

xfun::gsub_files(files = all_chapters_epub_word_TR,
                 pattern = ":::::",
                 replacement = "")


xfun::gsub_files(files = all_chapters_epub_word_TR,
                 pattern = "#+\\s*WSI - Link",
                 replacement = "")

xfun::gsub_files(files = all_chapters_epub_word_TR,
                 pattern = "#+\\s*WSI",
                 replacement = "")

xfun::gsub_files(files = all_chapters_epub_word_TR,
                 pattern = "#+\\s*Diagnosis",
                 replacement = "")

xfun::gsub_files(files = all_chapters_epub_word_TR,
                 pattern = "#+\\s*Tanı için tıklayın",
                 replacement = "### Tanı")

xfun::gsub_files(files = all_chapters_epub_word_TR,
                 pattern = '\\!\\[\\]\\(\\.\\/qrcodes\\/\\{\\{template\\}\\}-\\{\\{stain\\}\\}_qrcode.svg\\)\\{width="15%"\\}',
                 replacement = "")


xfun::gsub_files(files = all_chapters_epub_word_TR,
                 pattern = ".qmd >}}",
                 replacement = "_epub_word_TR.qmd >}}"
)



# render TR epub_word ----

Sys.sleep(2)

quarto::quarto_render(".", as_job = FALSE)


Sys.sleep(2)

# postrender TR epub_word ----


if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze",
               new_path = "./_freeze_TR_epub_word",
               overwrite = TRUE)
}

Sys.sleep(2)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}


fs::file_copy(path = "./_quarto_TR.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_delete(path = all_chapters_epub_word_TR)


