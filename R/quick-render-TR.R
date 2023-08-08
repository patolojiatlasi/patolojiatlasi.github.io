# prepare TR ----

fs::file_copy(path = "./_quarto_TR.yml",
              new_path = "./_quarto.yml",
              overwrite = TRUE)


fs::file_copy(path = "./R/languageTR.R",
              new_path = "./R/language.R",
              overwrite = TRUE)

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

if (dir.exists(paths = "./_freeze_TR")) {
fs::dir_copy(path = "./_freeze_TR",
             new_path = "./_freeze",
             overwrite = TRUE)
}

if (dir.exists(paths = "./docs")) {
  fs::dir_delete(path = "./docs")
}

if (dir.exists(paths = "./public")) {
  fs::dir_delete(path = "./public")
}



# render TR ----

quarto::quarto_render(".", as_job = FALSE)

if (dir.exists(paths = "./_freeze")) {
fs::dir_copy(path = "./_freeze",
             new_path = "./_freeze_TR",
             overwrite = TRUE)
}

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}


if (dir.exists(paths = "./_docs/public")) {
  fs::dir_delete(path = "./_docs/public")
}

if (dir.exists(paths = "./_docs/docs")) {
  fs::dir_delete(path = "./_docs/docs")
}

if (dir.exists(paths = "./_docs/_public")) {
  fs::dir_delete(path = "./_docs/_public")
}

if (dir.exists(paths = "./_docs/EN")) {
  fs::dir_delete(path = "./_docs/EN")
}

if (dir.exists(paths = "./_docs/_EN")) {
  fs::dir_delete(path = "./_docs/_EN")
}

if (dir.exists(paths = "./_docs/_lecture-notes")) {
  fs::dir_delete(path = "./_docs/_lecture-notes")
}

if (dir.exists(paths = "./_docs/lecture-notes")) {
  fs::dir_delete(path = "./_docs/lecture-notes")
}


fs::dir_copy(path = "./_docs", new_path = "./public", overwrite = TRUE)

fs::dir_copy(path = "./_docs", new_path = "./docs", overwrite = TRUE)

if (dir.exists(paths = "./_docs")) {
  fs::dir_delete(path = "./_docs")
}


folders_to_delete <- fs::dir_ls(path = ".",
                                recurse = FALSE, regexp = "_files$")

fs::dir_delete(folders_to_delete)

