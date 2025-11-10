#' Bilingual Pathology Atlas - Main Build Script
#'
#' @description
#' Master build orchestrator for the bilingual (Turkish/English) pathology atlas.
#' This script coordinates the entire build process:
#'   1. English (EN) version: Copy files, modify references, render
#'   2. Turkish (TR) version: Render with original files
#'   3. Deploy outputs to multiple directories for GitHub Pages, GitLab, etc.
#'
#' @details
#' Build Process Flow:
#'   - Phase 1: Setup (load dependencies, fix corruptions, clean directories)
#'   - Phase 2: EN Build (copy .qmd → *_EN.qmd, update references, render)
#'   - Phase 3: EN Cleanup (save freeze cache, delete temp files, revert originals)
#'   - Phase 4: TR Build (render from original .qmd files)
#'   - Phase 5: Deployment (copy outputs to docs/, EN/, public/, gitlab_atlas/)
#'   - Phase 6: Post-processing (generate RSS feeds, tweet random cases)
#'
#' Output Directories:
#'   - docs/: Turkish HTML site (served by GitHub Pages)
#'   - EN/: English HTML site (synced to mirror repos)
#'   - public/: Staging directory (Turkish content without CNAME)
#'   - gitlab_atlas/public/: GitLab mirror content
#'
#' Duration: ~10-15 minutes for full build
#'
#' @seealso
#' - R/config.R for configuration settings
#' - R/utils.R for helper functions
#' - DEVELOPMENT.md for detailed build process documentation
#' - GitHub Actions workflow for CI/CD usage
#'
#' @examples
#' \dontrun{
#'   # Full bilingual build (typically run by CI/CD)
#'   source("./R/bilingual-quarto-book.R")
#'
#'   # For local testing, use individual renderers:
#'   source("./R/render_TR.R")  # Turkish only
#'   source("./R/render_EN.R")  # English only
#' }


# ============================================================================
# PHASE 1: INITIALIZATION & CLEANUP
# ============================================================================

# Load dependencies and utility functions
source("./R/setup-dependencies.R")
source("./R/config.R")
source("./R/utils.R")

# Ensure all required R packages are installed
ensure_dependencies(quiet = TRUE)

# CRITICAL: Fix any _EN_EN_EN... accumulations from previous failed builds
# This prevents suffix multiplication bug
fix_corrupted_en_references(quiet = TRUE)


# ============================================================================
# PHASE 2: ENGLISH (EN) BUILD PREPARATION
# ============================================================================

# Clean up temporary *_files directories from previous builds
folders_to_delete <- fs::dir_ls(path = ".",
                                recurse = FALSE, regexp = "_files$")
fs::dir_delete(folders_to_delete)

# Remove all previous output directories to ensure clean build
if (dir.exists(paths = "./public")) {
  fs::dir_delete(path = "./public")
}

if (dir.exists(paths = "./EN")) {
  fs::dir_delete(path = "./EN")
}

if (dir.exists(paths = "./docs")) {
  fs::dir_delete(path = "./docs")
}

# Switch language to EN (creates symlink: R/language.R → R/languageEN.R)
setup_language_build("EN", source_freeze_dir = "./_freeze_EN")

# ----------------------------------------------------------------------------
# Load Chapter Mappings
# ----------------------------------------------------------------------------
# Read Turkish ↔ English chapter name mappings from YAML file
# This replaced the previous Excel-based approach for better maintainability
chapter_mappings <- read_chapter_mappings()
chapter_mappings <- chapter_mappings[, c("TR_chapter_qmd", "EN_chapter_qmd")]

# Build file path lists for main chapters
tr_chapter_qmd <- paste0("./", chapter_mappings$TR_chapter_qmd, ".qmd")
en_chapter_qmd <- paste0("./", chapter_mappings$EN_chapter_qmd, ".qmd")

# ----------------------------------------------------------------------------
# Handle Subchapters (Reusable Content in _subchapters/)
# ----------------------------------------------------------------------------
subchapter_files <- list.files(path = "./_subchapters", pattern = "*.qmd", recursive = FALSE)

# CRITICAL FIX: Exclude files that already have _EN suffix
# This prevents the _EN_EN_EN multiplication bug if script runs multiple times
subchapter_files <- subchapter_files[!grepl("_EN\\.qmd$", subchapter_files)]

subchapter_files  <- paste0("./_subchapters/", subchapter_files)
subchapter_files_EN <- gsub(pattern = ".qmd", replacement = "_EN.qmd", x = subchapter_files)

# Combine main chapters and subchapters
tr_chapter_qmd <- c(tr_chapter_qmd, subchapter_files)
en_chapter_qmd <- c(en_chapter_qmd, subchapter_files_EN)

# ----------------------------------------------------------------------------
# Copy Turkish Files to English Variants
# ----------------------------------------------------------------------------
# Create *_EN.qmd copies of all Turkish .qmd files
# These will be modified to reference other *_EN.qmd files in cross-links
fs::file_copy(path = tr_chapter_qmd,
              new_path = en_chapter_qmd,
              overwrite = TRUE)

# ----------------------------------------------------------------------------
# Update Cross-References in English Files (IDEMPOTENT)
# ----------------------------------------------------------------------------
# Update {{< include .qmd >}} references to {{< include _EN.qmd >}}
# This ensures EN files include EN subchapters, not TR subchapters
#
# CRITICAL FIX: This operation is made IDEMPOTENT (safe to run multiple times)
# by cleaning first, then adding fresh _EN suffixes

# Step 1: Remove ALL existing _EN suffixes from include statements
# Multiple passes handle accumulated corruptions (_EN_EN_EN → _EN_EN → _EN → clean)
for (pass in 1:5) {
  xfun::gsub_files(files = en_chapter_qmd,
                   pattern = "_EN.qmd >}}",
                   replacement = ".qmd >}}",
                   fixed = TRUE)
}

# Step 2: Add _EN suffix fresh (now safe since all patterns are .qmd)
xfun::gsub_files(files = en_chapter_qmd,
                 pattern = ".qmd >}}",
                 replacement = "_EN.qmd >}}",
                 fixed = TRUE
)


# ============================================================================
# PHASE 3: RENDER ENGLISH VERSION
# ============================================================================
# Render the EN version using Quarto
# - Uses ./_quarto_EN.yml configuration
# - Language variable is set to "EN" via R/language.R symlink
# - Output directory: ./_EN/
# Duration: ~5-8 minutes

quarto::quarto_render(".", as_job = FALSE)


# ============================================================================
# PHASE 4: POST-RENDER CLEANUP (EN)
# ============================================================================

# Remove CNAME file from EN output and replace with histopathologyatlas CNAME
# The EN version needs the histopathologyatlas.com CNAME
if (file.exists("./_EN/CNAME")){
  fs::file_delete(path = "./_EN/CNAME")
}
# Copy the correct CNAME file for the English site
fs::file_copy(path = "./CNAME-histopathologyatlas", new_path = "./_EN/CNAME", overwrite = TRUE)

# Remove any nested output directories that shouldn't exist
# (prevents directory structure pollution from failed builds)
if (dir.exists(paths = "./_EN/public")) {
  fs::dir_delete(path = "./_EN/public")
}

if (dir.exists(paths = "./_EN/docs")) {
  fs::dir_delete(path = "./_EN/docs")
}

# ----------------------------------------------------------------------------
# Save Freeze Directory for Incremental Builds
# ----------------------------------------------------------------------------
# Preserve Quarto's computation cache to speed up future EN builds
# Only recomputes chunks that changed since last render
save_freeze_directory("EN")

# Remove temporary _freeze directory (cache saved to _freeze_EN/)
if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

# ----------------------------------------------------------------------------
# Delete Temporary *_EN.qmd Files
# ----------------------------------------------------------------------------
# Remove *_EN.qmd files that don't have corresponding base files
# These were created during the build but aren't needed anymore
files_to_delete <- en_chapter_qmd[!(en_chapter_qmd %in% tr_chapter_qmd)]

fs::file_delete(path = files_to_delete)

# ----------------------------------------------------------------------------
# Revert Cross-References in Dual-Language Files
# ----------------------------------------------------------------------------
# For .qmd files that contain BOTH languages, revert the _EN suffix changes
# These files will be re-modified during the next EN build
files_to_revert <- en_chapter_qmd[en_chapter_qmd %in% tr_chapter_qmd]

# Revert include statements back to original (.qmd instead of _EN.qmd)
xfun::gsub_files(files = files_to_revert,
                 pattern = "_EN.qmd >}}",
                 replacement = ".qmd >}}",
                 fixed = TRUE
)


# ============================================================================
# PHASE 5: TURKISH (TR) BUILD
# ============================================================================

# Clear environment to prevent variable conflicts between EN and TR builds
rm(list=ls())

# Re-load utilities after clearing environment
source("./R/config.R")
source("./R/utils.R")

# ----------------------------------------------------------------------------
# Prepare TR Build Environment
# ----------------------------------------------------------------------------
# Switch language to TR (creates symlink: R/language.R → R/languageTR.R)
# Restore TR freeze cache from _freeze_TR/ for incremental builds
setup_language_build("TR", source_freeze_dir = "./_freeze_TR")

# ----------------------------------------------------------------------------
# Render Turkish Version
# ----------------------------------------------------------------------------
# Render the TR version using Quarto
# - Uses ./_quarto_TR.yml configuration
# - Language variable is set to "TR" via R/language.R symlink
# - Output directory: ./_docs/
# Duration: ~5-8 minutes

quarto::quarto_render(".", as_job = FALSE)

# ----------------------------------------------------------------------------
# Save TR Freeze Directory
# ----------------------------------------------------------------------------
# Preserve Quarto's computation cache for future TR builds
save_freeze_directory("TR")

# Remove temporary _freeze directory (cache saved to _freeze_TR/)
if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}

# ----------------------------------------------------------------------------
# Clean Up TR Output Directory
# ----------------------------------------------------------------------------
# Remove any nested directories that shouldn't exist in the TR output
# These sometimes appear from failed builds or incorrect configurations
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

# Remove lecture notes directories (built separately)
if (dir.exists(paths = "./_docs/_lecture-notes")) {
  fs::dir_delete(path = "./_docs/_lecture-notes")
}

if (dir.exists(paths = "./_docs/lecture-notes")) {
  fs::dir_delete(path = "./_docs/lecture-notes")
}


# ============================================================================
# PHASE 6: DEPLOYMENT - COPY TO FINAL DIRECTORIES
# ============================================================================

# ----------------------------------------------------------------------------
# Deploy to public/ Directory
# ----------------------------------------------------------------------------
# Copy TR output to ./public/ (staging directory for deployments)
# Note: CNAME removed from public/ as it's not needed there
fs::dir_copy(path = "./_docs", new_path = "./public", overwrite = TRUE)

if (file.exists("./public/CNAME")){
  fs::file_delete(path = "./public/CNAME")
}

# ----------------------------------------------------------------------------
# Deploy to docs/ Directory (Main GitHub Pages)
# ----------------------------------------------------------------------------
# Copy TR output to ./docs/ (served at https://www.patolojiatlasi.com/)
# This is the primary Turkish site with CNAME for custom domain
fs::dir_copy(path = "./_docs", new_path = "./docs", overwrite = TRUE)

# ----------------------------------------------------------------------------
# Deploy to GitLab Mirror
# ----------------------------------------------------------------------------
# Copy TR output to gitlab_atlas/public/ for GitLab Pages deployment
# Synced to https://gitlab.com/sbalci/atlas
if (dir.exists(paths = "./_docs")) {
  fs::dir_copy(path = "./_docs", new_path = "./gitlab_atlas/public", overwrite = TRUE)
}

# Remove CNAME from GitLab copy (GitLab Pages doesn't use GitHub CNAME)
if (file.exists("./gitlab_atlas/public/CNAME")) {
  fs::file_delete(path = "./gitlab_atlas/public/CNAME")
}

# Remove temporary _docs directory (all deployments complete)
if (dir.exists(paths = "./_docs")) {
  fs::dir_delete(path = "./_docs")
}

# ----------------------------------------------------------------------------
# Deploy English Version
# ----------------------------------------------------------------------------
# Copy EN output to ./EN/ directory
# This will be pushed to https://www.histopathologyatlas.com/
if (dir.exists(paths = "./_EN")) {
  fs::dir_copy(path = "./_EN", new_path = "./EN", overwrite = TRUE)
}

# Remove temporary _EN directory (deployment complete)
if (dir.exists(paths = "./_EN")) {
  fs::dir_delete(path = "./_EN")
}

# ----------------------------------------------------------------------------
# Final Cleanup: Remove Temporary Render Artifacts
# ----------------------------------------------------------------------------
# Delete all *_files directories created by Quarto during rendering
# These contain intermediate files and are safe to remove
folders_to_delete <- fs::dir_ls(path = ".",
                                recurse = FALSE, regexp = "_files$")

fs::dir_delete(folders_to_delete)


# ============================================================================
# POST-PROCESSING TASKS
# ============================================================================

cat("\Ud83E\UdD83")  # DNA emoji indicating data generation

# Generate social media content from random cases
source("./R/tweet-random-cases.R")

# Extract and aggregate HTML links for RSS feeds and sitemap generation
source("./R/extract-html-links.R")

cat("\Ud83E\UdD83")  # DNA emoji indicating completion

# Clear environment for clean exit
rm(list=ls())




