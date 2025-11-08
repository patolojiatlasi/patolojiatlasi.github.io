# Load utilities ----
source("./R/config.R")
source("./R/utils.R")

# prepare TR Web ----
setup_language_build("TR", source_freeze_dir = "./_freeze_TR")

# Clean up output directories ----
cleanup_paths <- c("./docs", "./public")
for (path in cleanup_paths) {
  if (dir.exists(path)) fs::dir_delete(path)
}

# render TR Web ----
quarto::quarto_render(".", as_job = FALSE)

# post-render TR Web ----

# Save freeze directory for future builds
save_freeze_directory("TR")

# Clean _freeze directory
if (dir.exists("./_freeze")) fs::dir_delete("./_freeze")

# Clean unwanted subdirectories from _docs
docs_cleanup_paths <- c(
  "./_docs/public", "./_docs/docs", "./_docs/_public",
  "./_docs/EN", "./_docs/_EN",
  "./_docs/_lecture-notes", "./_docs/lecture-notes",
  "./_docs/_pdf_TR", "./_docs/_pdf_EN",
  "./_docs/_epub_word_EN", "./_docs/_epub_word_TR",
  "./_docs/_freeze_EN", "./_docs/_freeze_EN_epub_word", "./_docs/_freeze_EN_pdf",
  "./_docs/_freeze_TR", "./_docs/_freeze_TR_epub_word", "./_docs/_freeze_TR_others", "./_docs/_freeze_TR_pdf",
  "./_docs/_lecture1", "./_docs/_others_TR"
)
for (path in docs_cleanup_paths) {
  if (dir.exists(path)) fs::dir_delete(path)
}

# Copy _docs to output directories
fs::dir_copy("./_docs", "./public", overwrite = TRUE)
fs::dir_copy("./_docs", "./docs", overwrite = TRUE)

# Clean up temporary _docs directory
if (dir.exists("./_docs")) fs::dir_delete("./_docs")

# Remove CNAME from public (not needed there)
if (file.exists("./public/CNAME")) fs::file_delete("./public/CNAME")

# Final cleanup of docs subdirectories
final_cleanup <- c("./docs/EN/lecture-notes", "./docs/EN", "./docs/public")
for (path in final_cleanup) {
  if (dir.exists(path)) fs::dir_delete(path)
}

# Clean up generated _files folders
folders_to_delete <- fs::dir_ls(".", recurse = FALSE, regexp = "_files$")
if (length(folders_to_delete) > 0) fs::dir_delete(folders_to_delete)

rm(list=ls())
