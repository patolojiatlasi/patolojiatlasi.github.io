# list.files(path = "./_lecture-notes", pattern = ".qmd")

quarto::quarto_render(input = "./_lecture-notes/*.qmd", as_job = FALSE, quiet = TRUE)


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

fs::file_copy(path = paste0("./_lecture-notes/", md_files), new_path = paste0("./ders-notlari/", md_files))

