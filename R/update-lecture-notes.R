# list.files(path = "./_lecture-notes", pattern = ".qmd")

# Render Lecture Notes ----

quarto::quarto_render(input = "./_lecture-notes/*.qmd", as_job = FALSE, quiet = TRUE)


# Prepare md files ----

if (file.exists('./_lecture-notes/README.md')){fs::file_delete(path = './_lecture-notes/README.md')}
md_files <- list.files(path = './_lecture-notes/', pattern = '*\\.md', full.names = FALSE, recursive = TRUE)
md_files_text <- gsub(pattern = '\\.md', replacement = '', x = md_files)
md_files_text <- purrr::map(.x = md_files, .f = ~ paste0('[', .x , '](./', .x , ')\n'))
readme_text <- paste0(unlist(md_files_text), collapse = "\n\n")
timestamp_text <- as.character(Sys.time())
readme_text <- paste0('# Patoloji Ders Notları \n\n', timestamp_text, '\n\n', readme_text)
writeLines(text = readme_text, con = './_lecture-notes/README.md')

md_files <- c("README.md", md_files)

if (dir.exists(paths = "./ders-notlari")) {
  # unlink(x = "./ders-notlari", recursive = TRUE, force = TRUE)
  fs::dir_delete(path = "./ders-notlari")
  }

dir.create("./ders-notlari")


# Move md files ----

fs::file_move(path = paste0("./_lecture-notes/", md_files), new_path = paste0("./ders-notlari/", md_files))


if (!dir.exists(paths = "./ders-sunumlari")) {
  fs::dir_create(path = "./ders-sunumlari")
}


# prepare presentations ----

lecturenames <- list.files(path = "./_lecture-notes", pattern = ".qmd")
lecturenames <- gsub(pattern = '\\.qmd', replacement = '', x = lecturenames)

lecturenames <- data.frame(lectures = lecturenames)

rio::export(x = lecturenames, file = "./_lecture-notes/lecturenames.xlsx")

selected_lectures <- readxl::read_excel("./_lecture-notes/selected_lectures.xlsx")

selected_lectures$lecture_html <- paste0(selected_lectures$lectures, ".html")
selected_lectures$lecture_files <- paste0(selected_lectures$lectures, "_files")

lecture_html <- selected_lectures$lecture_html
lecture_files <- selected_lectures$lecture_files


# move presenttaions ----

fs::file_move(path = paste0("./_lecture-notes/", lecture_html), new_path = paste0("./ders-sunumlari/", lecture_html))
fs::file_move(path = paste0("./_lecture-notes/", lecture_files), new_path = paste0("./ders-sunumlari/", lecture_files))


