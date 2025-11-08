# Load utilities ----
source("./R/config.R")
source("./R/utils.R")

# prepare EN  ----
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




# render EN  ----

quarto::quarto_render(".", as_job = FALSE)



# post render EN  ----

# Save freeze directory for future builds
save_freeze_directory("EN")

if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}



files_to_delete <- EN_chapter_qmd[!(EN_chapter_qmd %in% TR_chapter_qmd)]

fs::file_delete(path = files_to_delete)


files_to_revert <- EN_chapter_qmd[EN_chapter_qmd %in% TR_chapter_qmd]


xfun::gsub_files(files = files_to_revert,
                 pattern = "_EN\\.qmd\\s*>}}",
                 replacement = ".qmd >}}",
                 fixed = FALSE
)


if (file.exists("./_EN/CNAME")){
  fs::file_delete(path = "./_EN/CNAME")
}


if (dir.exists(paths = "./_EN/docs")) {
  fs::dir_delete(path = "./_EN/docs")
}

if (dir.exists(paths = "./_EN/public")) {
  fs::dir_delete(path = "./_EN/public")
}

if (dir.exists(paths = "./_EN")) {
  fs::dir_copy(path = "./_EN", new_path = "./EN", overwrite = TRUE)
}

if (dir.exists(paths = "./_EN")) {
  fs::dir_delete(path = "./_EN")
}



rm(list=ls())

