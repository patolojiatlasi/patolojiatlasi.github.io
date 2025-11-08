# Load utilities and ensure dependencies ----
source("./R/setup-dependencies.R")
source("./R/config.R")
source("./R/utils.R")

# Ensure all dependencies are installed
ensure_dependencies(quiet = TRUE)

# Safety check: Fix any corrupted _EN references from previous failed builds ----
fix_corrupted_en_references(quiet = TRUE)

# prepare EN ----

# Clean up _files directories
folders_to_delete <- fs::dir_ls(path = ".",
                                recurse = FALSE, regexp = "_files$")
fs::dir_delete(folders_to_delete)

# Clean up output directories
if (dir.exists(paths = "./public")) {
  fs::dir_delete(path = "./public")
}

if (dir.exists(paths = "./EN")) {
  fs::dir_delete(path = "./EN")
}

if (dir.exists(paths = "./docs")) {
  fs::dir_delete(path = "./docs")
}

# Setup EN build environment
setup_language_build("EN", source_freeze_dir = "./_freeze_EN")

# Read chapter mappings from YAML (replaces Excel dependency)
patolojiatlasi_histopathologyatlas <- read_chapter_mappings()
patolojiatlasi_histopathologyatlas <- patolojiatlasi_histopathologyatlas[, c("TR_chapter_qmd", "EN_chapter_qmd")]

TR_chapter_qmd <- paste0("./", patolojiatlasi_histopathologyatlas$TR_chapter_qmd, ".qmd")

EN_chapter_qmd <- paste0("./", patolojiatlasi_histopathologyatlas$EN_chapter_qmd, ".qmd")

subchapter_files <- list.files(path = "./_subchapters", pattern = "*.qmd", recursive = FALSE)

# CRITICAL FIX: Exclude files that already have _EN suffix to prevent _EN_EN_EN multiplication
subchapter_files <- subchapter_files[!grepl("_EN\\.qmd$", subchapter_files)]

subchapter_files  <- paste0("./_subchapters/", subchapter_files)

subchapter_files_EN <- gsub(pattern = ".qmd", replacement = "_EN.qmd", x = subchapter_files)

TR_chapter_qmd <- c(TR_chapter_qmd, subchapter_files)

EN_chapter_qmd <- c(EN_chapter_qmd, subchapter_files_EN)

fs::file_copy(path = TR_chapter_qmd,
              new_path = EN_chapter_qmd,
              overwrite = TRUE)


# CRITICAL FIX: Make pattern replacement IDEMPOTENT
# First, clean up any _EN_EN_EN... accumulations from previous failed builds
# Then, add _EN suffix fresh
# This makes the operation safe to run multiple times

# Step 1: Remove ALL _EN suffixes (handle _EN_EN_EN_EN -> _EN_EN_EN -> _EN_EN -> _EN -> clean)
# Multiple passes to handle accumulated corruptions
for (pass in 1:5) {
  xfun::gsub_files(files = EN_chapter_qmd,
                   pattern = "_EN.qmd >}}",
                   replacement = ".qmd >}}",
                   fixed = TRUE)
}

# Step 2: Now safely add _EN suffix (we know all patterns are .qmd now)
xfun::gsub_files(files = EN_chapter_qmd,
                 pattern = ".qmd >}}",
                 replacement = "_EN.qmd >}}",
                 fixed = TRUE
)



# render EN ----

quarto::quarto_render(".", as_job = FALSE)


if (file.exists("./_EN/CNAME")){
  fs::file_delete(path = "./_EN/CNAME")
}

if (dir.exists(paths = "./_EN/public")) {
  fs::dir_delete(path = "./_EN/public")
}

if (dir.exists(paths = "./_EN/docs")) {
  fs::dir_delete(path = "./_EN/docs")
}

# Save freeze directory for future builds
save_freeze_directory("EN")

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}




files_to_delete <- EN_chapter_qmd[!(EN_chapter_qmd %in% TR_chapter_qmd)]

fs::file_delete(path = files_to_delete)


files_to_revert <- EN_chapter_qmd[EN_chapter_qmd %in% TR_chapter_qmd]



xfun::gsub_files(files = files_to_revert,
                 pattern = "_EN.qmd >}}",
                 replacement = ".qmd >}}",
                 fixed = TRUE
)


rm(list=ls())

# Re-load utilities after clearing environment
source("./R/config.R")
source("./R/utils.R")

# prepare TR ----
setup_language_build("TR", source_freeze_dir = "./_freeze_TR")


# render TR ----

quarto::quarto_render(".", as_job = FALSE)

# Save freeze directory for future builds
save_freeze_directory("TR")

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}


if (dir.exists(paths = "./_docs/public")) {
  fs::dir_delete(path = "./_docs/public")
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

if (file.exists("./public/CNAME")){
  fs::file_delete(path = "./public/CNAME")
}



fs::dir_copy(path = "./_docs", new_path = "./docs", overwrite = TRUE)

# Create gitlab_atlas/public for GitLab mirror
if (dir.exists(paths = "./_docs")) {
  fs::dir_copy(path = "./_docs", new_path = "./gitlab_atlas/public", overwrite = TRUE)
}

# Remove CNAME from gitlab_atlas/public (GitLab doesn't need it)
if (file.exists("./gitlab_atlas/public/CNAME")) {
  fs::file_delete(path = "./gitlab_atlas/public/CNAME")
}

if (dir.exists(paths = "./_docs")) {
  fs::dir_delete(path = "./_docs")
}

if (dir.exists(paths = "./_EN")) {
fs::dir_copy(path = "./_EN", new_path = "./EN", overwrite = TRUE)
}

if (dir.exists(paths = "./_EN")) {
  fs::dir_delete(path = "./_EN")
}


folders_to_delete <- fs::dir_ls(path = ".",
                                recurse = FALSE, regexp = "_files$")

fs::dir_delete(folders_to_delete)


cat("\Ud83E\UdD83")

source("./R/tweet-random-cases.R")

source("./R/extract-html-links.R")

cat("\Ud83E\UdD83")

rm(list=ls())




