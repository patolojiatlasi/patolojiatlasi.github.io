# source("./R/render_epub_word_TR.R")
# source("./R/render_pdf_TR.R")
# source("./R/render_epub_word_EN.R")
# source("./R/render_pdf_EN.R")



# prepare TR Web ----

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



# render TR Web ----

quarto::quarto_render(".", as_job = FALSE)


# post-render TR Web ----


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

if (dir.exists(paths = "./_docs/_pdf_TR")) {
  fs::dir_delete(path = "./_docs/_pdf_TR")
}

if (dir.exists(paths = "./_docs/_pdf_EN")) {
  fs::dir_delete(path = "./_docs/_pdf_EN")
}

if (dir.exists(paths = "./_docs/_epub_word_EN")) {
  fs::dir_delete(path = "./_docs/_epub_word_EN")
}


if (dir.exists(paths = "./_docs/_epub_word_TR")) {
  fs::dir_delete(path = "./_docs/_epub_word_TR")
}

if (dir.exists(paths = "./_docs/_freeze_EN")) {
  fs::dir_delete(path = "./_docs/_freeze_EN")
}

if (dir.exists(paths = "./_docs/_freeze_EN_epub_word")) {
  fs::dir_delete(path = "./_docs/_freeze_EN_epub_word")
}

if (dir.exists(paths = "./_docs/_freeze_EN_pdf")) {
  fs::dir_delete(path = "./_docs/_freeze_EN_pdf")
}

if (dir.exists(paths = "./_docs/_freeze_TR")) {
  fs::dir_delete(path = "./_docs/_freeze_TR")
}

if (dir.exists(paths = "./_docs/_freeze_TR_epub_word")) {
  fs::dir_delete(path = "./_docs/_freeze_TR_epub_word")
}

if (dir.exists(paths = "./_docs/_freeze_TR_others")) {
  fs::dir_delete(path = "./_docs/_freeze_TR_others")
}

if (dir.exists(paths = "./_docs/_freeze_TR_pdf")) {
  fs::dir_delete(path = "./_docs/_freeze_TR_pdf")
}

if (dir.exists(paths = "./_docs/_lecture1")) {
  fs::dir_delete(path = "./_docs/_lecture1")
}

if (dir.exists(paths = "./_docs/_others_TR")) {
  fs::dir_delete(path = "./_docs/_others_TR")
}

if (dir.exists(paths = "./_docs/_pdf_EN")) {
  fs::dir_delete(path = "./_docs/_pdf_EN")
}

if (dir.exists(paths = "./_docs/_pdf_TR")) {
  fs::dir_delete(path = "./_docs/_pdf_TR")
}


fs::dir_copy(path = "./_docs", new_path = "./public", overwrite = TRUE)

fs::dir_copy(path = "./_docs", new_path = "./docs", overwrite = TRUE)

if (dir.exists(paths = "./_docs")) {
  fs::dir_delete(path = "./_docs")
}

if (file.exists("./public/CNAME")){fs::file_delete(path = "./public/CNAME")}

if (dir.exists(paths = "./docs/EN/lecture-notes")) { fs::dir_delete(path = "./docs/EN/lecture-notes") }

if (dir.exists(paths = "./docs/EN")) { fs::dir_delete(path = "./docs/EN") }

if (dir.exists(paths = "./docs/public")) {fs::dir_delete(path = "./docs/public")}

folders_to_delete <- fs::dir_ls(path = ".",
                                recurse = FALSE, regexp = "_files$")

fs::dir_delete(folders_to_delete)



