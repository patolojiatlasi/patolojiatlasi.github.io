
# prepare TR epub ----

fs::file_copy(path = "./_quarto_TR_others.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_copy(path = "./R/languageTR.R",
              new_path = "./R/language.R",
              overwrite = TRUE)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

if (dir.exists(paths = "./_freeze_TR_others")) {
  fs::dir_copy(path = "./_freeze_TR_others",
               new_path = "./_freeze",
               overwrite = TRUE)
}

chapter_mappings <- readxl::read_excel("./config/chapter-mapping.xlsx", sheet = "chapters")

chapter_mappings <- chapter_mappings[, c("TR_chapter_qmd", "TR_others_chapter_qmd")]

chapter_mappings$TR_chapter_qmd <- paste0(chapter_mappings$TR_chapter_qmd, ".qmd")

chapter_mappings$TR_others_chapter_qmd <- paste0(chapter_mappings$TR_others_chapter_qmd, ".qmd")


fs::file_copy(path = chapter_mappings$TR_chapter_qmd,
              new_path = chapter_mappings$TR_others_chapter_qmd,
              overwrite = TRUE)


qmd_others_TR_files <- list.files(path = ".", pattern = "./*_others_TR.qmd", recursive = FALSE)

xfun::gsub_files(files = qmd_others_TR_files,
                 pattern = "panel-tabset",
                 replacement = "")

xfun::gsub_files(files = qmd_others_TR_files,
                 pattern = ":::::",
                 replacement = "")


xfun::gsub_files(files = qmd_others_TR_files,
                 pattern = "### WSI - Link",
                 replacement = "")

xfun::gsub_files(files = qmd_others_TR_files,
                 pattern = "### WSI",
                 replacement = "")

xfun::gsub_files(files = qmd_others_TR_files,
                 pattern = "### Diagnosis",
                 replacement = "")

# xfun::gsub_files(files = qmd_others_TR_files,
#                  pattern = '::: {.callout-tip collapse="true" appearance="default" icon="true"}',
#                  replacement = "")

xfun::gsub_files(files = qmd_others_TR_files,
                 pattern = "### Tanı için tıklayın",
                 replacement = "### Tanı")

# xfun::gsub_files(files = qmd_others_TR_files,
#                  pattern = ":::",
#                  replacement = "")


# render TR epub ----

quarto::quarto_render(".", as_job = FALSE)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze",
               new_path = "./_freeze_TR_others",
               overwrite = TRUE)
}

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}




chapter_mappings <- readxl::read_excel("./config/chapter-mapping.xlsx", sheet = "chapters")

chapter_mappings <- chapter_mappings[, c("TR_chapter_qmd", "TR_others_chapter_qmd")]

'%>%' <- magrittr:::`%>%`

chapter_mappings <- chapter_mappings %>%
  dplyr::distinct() %>%
  dplyr::filter(TR_chapter_qmd != TR_others_chapter_qmd)

chapter_mappings$TR_others_chapter_qmd <- paste0(chapter_mappings$TR_others_chapter_qmd, ".qmd")

fs::file_delete(path = chapter_mappings$TR_others_chapter_qmd)


