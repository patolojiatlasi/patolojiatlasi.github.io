# Development Guide: Patoloji Atlası / Pathology Atlas

This guide provides technical documentation for developers working on the bilingual pathology atlas build system.

## Table of Contents

- [Development Environment Setup](#development-environment-setup)
- [Architecture Overview](#architecture-overview)
- [Bilingual Content System](#bilingual-content-system)
- [Quarto Configuration](#quarto-configuration)
- [Build Process](#build-process)
- [R Package Management](#r-package-management)
- [Debugging Guide](#debugging-guide)
- [Advanced Topics](#advanced-topics)

## Development Environment Setup

### Prerequisites

**Required Software:**
- **R** (≥ 4.3.0): Statistical computing environment
- **Quarto** (pre-release): Document publishing system
- **Git**: Version control
- **RStudio** (optional but recommended): IDE for R development

**System Dependencies:**
- **TinyTeX** or full TeX distribution (for PDF generation)
- **Pandoc** (included with Quarto)

### Initial Setup

#### 1. Clone and Navigate

```bash
git clone https://github.com/patolojiatlasi/patolojiatlasi.github.io.git
cd patolojiatlasi.github.io
```

#### 2. Install R Dependencies with renv

The project uses `renv` for reproducible R package management:

```r
# Open R in project directory
R

# renv should auto-activate. If not:
install.packages("renv")
renv::restore()  # Install all packages from renv.lock
```

**Key packages installed:**
- `quarto` - Rendering engine interface
- `fs` - Cross-platform file system operations
- `yaml` - YAML parser
- `xfun` - Text manipulation utilities
- `jsonlite` - JSON parser
- `xml2` - XML processing (for RSS feeds)
- `readxl` - Excel file reading (deprecated, now uses YAML)

#### 3. Verify Quarto Installation

```bash
quarto --version
# Should show: 99.9.9 or similar pre-release version

quarto check
# Verifies R, Knitr, and other dependencies
```

#### 4. Test Local Rendering

```bash
# Render Turkish version (quick test)
quarto render index.qmd

# Full Turkish build
quarto render

# Preview with live reload
quarto preview
```

## Architecture Overview

### Directory Structure

```
patolojiatlasi.github.io/
│
├── R/                              # Build automation scripts
│   ├── config.R                   # Centralized configuration
│   ├── utils.R                    # Utility functions (error handling, logging)
│   ├── validation.R               # Build validation functions
│   ├── bilingual-quarto-book.R   # Main bilingual build orchestrator
│   ├── languageTR.R / languageEN.R # Language switchers
│   ├── render_*.R                 # Format-specific renderers
│   └── extract-html-links.R       # RSS feed generation
│
├── _subchapters/                  # Reusable case content
│   └── _case-name.qmd            # Cases included in multiple chapters
│
├── _lecture-notes/                # Lecture materials (separate build)
│
├── images/                        # Static images
├── screenshots/                   # WSI screenshots (PNG → JPG via CI)
├── qrcodes/                       # QR codes for cases
│
├── Configuration Files
│   ├── _quarto_TR.yml            # Turkish main config
│   ├── _quarto_EN.yml            # English main config
│   ├── _quarto_chapters_TR.yml   # Turkish chapter list (base)
│   ├── _quarto_chapters_EN.yml   # English chapter list (base)
│   ├── _quarto_TR_pdf.yml        # Turkish PDF config
│   ├── _quarto_EN_pdf.yml        # English PDF config
│   ├── _quarto_TR_epub_word.yml  # Turkish EPUB/Word config
│   ├── _quarto_EN_epub_word.yml  # English EPUB/Word config
│   └── chapter-mappings.yml      # TR ↔ EN chapter name mappings
│
├── Auto-generated Chapter Files (DO NOT EDIT)
│   ├── _quarto_chapters_TR_pdf.yml
│   ├── _quarto_chapters_EN_pdf.yml
│   ├── _quarto_chapters_TR_epub_word.yml
│   └── _quarto_chapters_EN_epub_word.yml
│
├── Content Files
│   ├── index.qmd                 # Homepage
│   └── *.qmd                     # Chapter files (bilingual)
│
└── Build Outputs (gitignored)
    ├── docs/                     # Turkish HTML output
    ├── EN/                       # English HTML output
    ├── _freeze_TR/               # Turkish computation cache
    ├── _freeze_EN/               # English computation cache
    ├── _pdf_TR/, _pdf_EN/        # PDF outputs
    └── _epub_word_TR/, _epub_word_EN/  # EPUB/Word outputs
```

### Configuration Architecture

The project uses a **hierarchical configuration system**:

#### 1. Central Configuration (`R/config.R`)

Defines all project paths and settings:

```r
get_project_config()
# Returns:
# - languages: c("TR", "EN")
# - quarto configs for each language
# - output directories
# - freeze directories
# - deployment directories

get_language_config("TR")
# Returns language-specific config
```

#### 2. Quarto Base Configs

**`_quarto_TR.yml` and `_quarto_EN.yml`:**
- Project metadata (title, author, description)
- Output formats (HTML, PDF, EPUB)
- Theme and styling
- Include common settings

**`_quarto_chapters_TR.yml` and `_quarto_chapters_EN.yml`:**
- Chapter listing (manually maintained)
- Sidebar navigation structure
- Part/section organization

#### 3. Auto-Generated Configs

The build system generates format-specific chapter files:

```r
# R/bilingual-quarto-book.R generates:
_quarto_chapters_TR_pdf.yml         # Adds _pdf_TR suffix to hrefs
_quarto_chapters_EN_pdf.yml         # Adds _pdf_EN suffix to hrefs
_quarto_chapters_TR_epub_word.yml   # Adds _epub_word_TR suffix
_quarto_chapters_EN_epub_word.yml   # Adds _epub_word_EN suffix
```

**Why?** Different output formats require different file naming to avoid conflicts.

#### 4. YAML Inheritance

Quarto configs use YAML merge keys for DRY principle:

```yaml
# _quarto_TR.yml
project:
  type: book
  output-dir: _docs

metadata-files:
  - _quarto_chapters_TR.yml  # Imports chapter list

# _quarto_TR_pdf.yml
project:
  type: book
  output-dir: _pdf_TR

metadata-files:
  - _quarto_chapters_TR_pdf.yml  # Auto-generated with suffixes
```

## Bilingual Content System

### How It Works

All `.qmd` files contain **both languages** using conditional rendering:

```r
---
title: "Chapter Title"
---

```{r language, echo=FALSE, include=TRUE}
source("./R/language.R")
output_type <- knitr::opts_knit$get("rmarkdown.pandoc.to")
```

```{asis, echo = (language == "TR")}
## Türkçe Başlık {#sec-chapter-id}

Türkçe içerik...
```

```{asis, echo = (language == "EN")}
## English Title {#sec-chapter-id}

English content...
```
```

### Language Switching

**`R/language.R`** is a symlink that points to either:
- `R/languageTR.R` → sets `language <- "TR"`
- `R/languageEN.R` → sets `language <- "EN"`

During build:
1. Symlink is switched to target language
2. All `.qmd` files source `./R/language.R`
3. Only blocks matching `language` variable render
4. Output goes to language-specific directory

### Chapter Name Mappings

**`chapter-mappings.yml`** maps Turkish names to English equivalents:

```yaml
chapters:
  - tr: "mide"
    en: "stomach"
    tr_pdf: "mide_pdf"
    en_pdf: "stomach_pdf"
    tr_epub_word: "mide_epub_word"
    en_epub_word: "stomach_epub_word"
```

Used by `R/bilingual-quarto-book.R` to generate file copies and update references.

## Quarto Configuration

### Configuration Files Deep Dive

#### Main Quarto Configs

**`_quarto_TR.yml` (Turkish):**
```yaml
project:
  type: book
  output-dir: _docs           # Build outputs here
  preview:
    port: 4545
    browser: true

book:
  title: "Patoloji Atlası"
  author: "Dr. Serdar Balcı"
  date: last-modified
  site-url: https://www.patolojiatlasi.com/

  page-navigation: true
  search: true
  repo-url: https://github.com/patolojiatlasi/patolojiatlasi.github.io
  repo-actions: [edit, issue]

metadata-files:
  - _quarto_chapters_TR.yml   # Chapter structure imported from here

format:
  html:
    theme:
      light: [cosmo, theme-light.scss]
      dark: [cosmo, theme-dark.scss]
    css: styles.css
    toc: true
    toc-depth: 3
```

**`_quarto_EN.yml` (English):**
- Same structure, English metadata
- `output-dir: _EN`
- `site-url: https://www.histopathologyatlas.com/`
- References `_quarto_chapters_EN.yml`

#### Chapter List Files

**`_quarto_chapters_TR.yml`:**
```yaml
book:
  chapters:
    - index.qmd
    - part: "Sistem Patolojisi"
      chapters:
        - mide.qmd
        - akciger.qmd
        - bobrek.qmd
    - part: "Merkezi Sinir Sistemi"
      chapters:
        - gliom.qmd
        - meningiom.qmd
```

**Auto-generated `_quarto_chapters_TR_pdf.yml`:**
```yaml
book:
  chapters:
    - index.qmd
    - part: "Sistem Patolojisi"
      chapters:
        - href: mide_pdf_TR.qmd    # Suffix added
        - href: akciger_pdf_TR.qmd
        - href: bobrek_pdf_TR.qmd
```

**Why Suffixes?**
- Allows simultaneous HTML, PDF, and EPUB builds
- Prevents file naming conflicts
- Each format can have format-specific processing

### Output Formats

| Format | Config | Output Directory | File Extension |
|--------|--------|------------------|----------------|
| **HTML** (Web) | `_quarto_TR.yml` | `docs/` | `.html` |
| **PDF** | `_quarto_TR_pdf.yml` | `_pdf_TR/` | `.pdf` |
| **EPUB** | `_quarto_TR_epub_word.yml` | `_epub_word_TR/` | `.epub` |
| **Word** | `_quarto_TR_epub_word.yml` | `_epub_word_TR/` | `.docx` |

## Build Process

### Build Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    BILINGUAL BUILD PROCESS                  │
└─────────────────────────────────────────────────────────────┘

Step 1: PREPARATION
┌──────────────────────┐
│ Load Configuration   │  R/config.R
│ - get_project_config │  → Languages, paths, directories
│ - get_language_config│
└──────────┬───────────┘
           │
Step 2: GENERATE CHAPTER FILES (Auto)
           │
    ┌──────▼──────────────────────────────────────┐
    │ R/bilingual-quarto-book.R                   │
    │ generate_chapter_variants()                 │
    ├─────────────────────────────────────────────┤
    │ Base files (manual):                        │
    │   _quarto_chapters_TR.yml                   │
    │   _quarto_chapters_EN.yml                   │
    │         ↓                                   │
    │ Auto-generated (with suffixes):             │
    │   _quarto_chapters_TR_pdf.yml               │
    │   _quarto_chapters_EN_pdf.yml               │
    │   _quarto_chapters_TR_epub_word.yml         │
    │   _quarto_chapters_EN_epub_word.yml         │
    └──────┬──────────────────────────────────────┘
           │
Step 3: ENGLISH VERSION (First)
           │
    ┌──────▼─────────────────────────────┐
    │ Set language = "EN"                │
    │ ln -sf languageEN.R language.R     │
    └──────┬─────────────────────────────┘
           │
    ┌──────▼─────────────────────────────┐
    │ Copy .qmd → *_EN.qmd               │
    │ (for all chapters)                 │
    └──────┬─────────────────────────────┘
           │
    ┌──────▼─────────────────────────────┐
    │ quarto render                      │
    │ --profile EN                       │
    │ Output → EN/                       │
    └──────┬─────────────────────────────┘
           │
Step 4: TURKISH VERSION
           │
    ┌──────▼─────────────────────────────┐
    │ Set language = "TR"                │
    │ ln -sf languageTR.R language.R     │
    └──────┬─────────────────────────────┘
           │
    ┌──────▼─────────────────────────────┐
    │ quarto render                      │
    │ --profile default                  │
    │ Output → docs/                     │
    └──────┬─────────────────────────────┘
           │
Step 5: VALIDATION
           │
    ┌──────▼─────────────────────────────┐
    │ R/validation.R                     │
    │ - validate_build_output()          │
    │ - Check file counts                │
    │ - Verify resources                 │
    └──────┬─────────────────────────────┘
           │
Step 6: DEPLOYMENT
           │
    ┌──────▼─────────────────────────────┐
    │ Copy _docs/ → docs/                │
    │ Commit to Git                      │
    │ Push to GitHub Pages               │
    └────────────────────────────────────┘
```

### Manual Build Commands

#### Local Turkish Build

```bash
# Quick render (default profile)
quarto render

# With validation
Rscript -e "source('./R/validation.R'); validate_all('TR')"
```

#### Local English Build

```bash
# Switch language symlink
ln -sf R/languageEN.R R/language.R

# Render English version
quarto render --profile EN

# Switch back to Turkish
ln -sf R/languageTR.R R/language.R
```

#### Full Bilingual Build

```bash
# Run complete bilingual build
Rscript R/bilingual-quarto-book.R
```

#### Format-Specific Builds

```bash
# PDF (Turkish)
Rscript R/render_pdf_TR.R

# PDF (English)
Rscript R/render_pdf_EN.R

# EPUB/Word (Turkish)
Rscript R/render_epub_word_TR.R

# EPUB/Word (English)
Rscript R/render_epub_word_EN.R
```

### CI/CD Workflow

**`.github/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml`**

**Trigger:** Push to `main` branch (except commits with `WIP`, `merge`, or `lecture`)

**Steps:**
1. **Setup**
   - Checkout code
   - Install Quarto (pre-release)
   - Setup R environment
   - Restore R packages from cache

2. **Asset Processing**
   - Convert PNG screenshots → JPG (VIPS)
   - Generate QR codes
   - Optimize images

3. **Build**
   - Generate chapter variants
   - Render English version (EN/)
   - Render Turkish version (docs/)

4. **Validation**
   - Check file counts
   - Verify resources
   - Validate search index

5. **Deployment**
   - Commit rendered output
   - Push to multiple repositories:
     - `patolojiatlasi/patolojiatlasi.github.io` (main)
     - `patolojiatlasi/EN` (English mirror)
     - `histopathologyatlas/histopathologyatlas.github.io` (English site)
     - `sbalci/atlas` (GitLab mirror)

## R Package Management

### Using renv

**renv** provides isolated, reproducible package management.

#### Common renv Commands

```r
# Check package status
renv::status()

# Install a new package
install.packages("packagename")
renv::snapshot()  # Record in renv.lock

# Update packages
renv::update()

# Restore packages (e.g., after git pull)
renv::restore()

# View package sources
renv::dependencies()

# Clean unused packages
renv::clean()
```

#### Adding a New Dependency

```r
# 1. Install the package
install.packages("newpackage")

# 2. Use it in your code
source("./R/utils.R")
library(newpackage)

# 3. Record the dependency
renv::snapshot()

# 4. Commit renv.lock
# git add renv.lock
# git commit -m "Add newpackage dependency"
```

### Package Update Policy

- **Major version updates:** Test thoroughly, may break builds
- **Minor version updates:** Generally safe, test locally first
- **Patch updates:** Usually safe to apply

## Debugging Guide

### Common Issues and Solutions

#### 1. Build Fails with "Quarto not found"

```bash
# Verify installation
quarto --version

# If not installed
# Download from https://quarto.org/docs/get-started/
```

#### 2. Package Loading Errors

```r
# Restore packages
renv::restore()

# If specific package fails
remove.packages("packagename")
install.packages("packagename")
renv::snapshot()
```

#### 3. Language Variable Not Set

**Error:** `object 'language' not found`

**Solution:**
```bash
# Check symlink
ls -la R/language.R

# Should point to languageTR.R or languageEN.R
# If broken, recreate:
ln -sf R/languageTR.R R/language.R
```

#### 4. Freeze Directory Conflicts

**Problem:** Cached computations from wrong language

**Solution:**
```bash
# Clear freeze caches
rm -rf _freeze_TR/ _freeze_EN/

# Rebuild
quarto render
```

#### 5. File Not Found During Render

**Use validation to diagnose:**
```r
source("./R/validation.R")
validate_build_prerequisites("TR")
```

#### 6. _EN Files Multiply (Suffix Bug)

**Symptoms:** Files like `chapter_EN_EN_EN.qmd`

**Solution:** This bug was fixed. Update to latest code:
```bash
git pull origin main

# Clean up duplicates if any
find . -name "*_EN_EN*.qmd" -delete
```

### Debug Mode Rendering

```bash
# Verbose Quarto output
quarto render --log-level debug

# R script with tracing
R --verbose < R/bilingual-quarto-book.R

# Keep intermediate files
quarto render --keep-md
```

### Validation Functions

```r
source("./R/validation.R")

# Before build
validate_build_prerequisites("TR")

# After chapter generation
validate_chapter_generation("TR")

# After build
validate_build_output("TR", min_chapters = 60)

# All checks
validate_all("TR", verbose = TRUE)
```

### Using Error Handling Functions

```r
source("./R/utils.R")

# Safe file operations
safe_file_copy("source.R", "dest.R")

# With retry logic
safe_quarto_render(input = ".", max_retries = 2)

# Check logs
# Errors go to stderr, info to stdout
# grep "ERROR" build.log
```

## Advanced Topics

### Customizing the Build

#### Adding a New Language (e.g., French)

1. **Update `R/config.R`:**
```r
languages = c("TR", "EN", "FR")

quarto = list(
  FR = list(
    config = "./_quarto_FR.yml",
    output_dir = "_FR",
    deploy_dir = "FR",
    freeze_dir = "./_freeze_FR"
  )
)
```

2. **Create `R/languageFR.R`:**
```r
language <- "FR"
```

3. **Create `_quarto_FR.yml`** and **`_quarto_chapters_FR.yml`**

4. **Add French blocks to all `.qmd` files:**
```markdown
```{asis, echo = (language == "FR")}
## Titre Français
```
```

5. **Update `chapter-mappings.yml`**

6. **Modify `R/bilingual-quarto-book.R`** to include FR in build loop

#### Adding a New Output Format

1. **Create format-specific config** (e.g., `_quarto_TR_slides.yml`)

2. **Add format to `R/bilingual-quarto-book.R`:**
```r
formats <- c("pdf", "epub_word", "slides")
```

3. **Create renderer script** (e.g., `R/render_slides_TR.R`)

### Performance Optimization

#### Freeze Computation Cache

Quarto's `freeze` feature caches R code execution:

```yaml
# In _quarto_TR.yml
execute:
  freeze: auto  # Re-run only if source changes
```

**Freeze directories:**
- `_freeze_TR/` - Turkish cache
- `_freeze_EN/` - English cache

**When to clear:**
- Global dependencies changed (e.g., `R/utils.R`)
- Unexpected stale output
- After major R package updates

#### Parallel Builds

For very large books, consider parallel chapter rendering:

```r
# In R/bilingual-quarto-book.R
library(future)
plan(multisession, workers = 4)

chapters <- c("chapter1.qmd", "chapter2.qmd", ...)
future_lapply(chapters, quarto::quarto_render)
```

### Testing Changes Locally

Before pushing to GitHub:

1. **Test both languages:**
```bash
Rscript R/bilingual-quarto-book.R
```

2. **Run validation:**
```r
source("./R/validation.R")
validate_all("TR")
validate_all("EN")
```

3. **Check file count:**
```bash
ls docs/*.html | wc -l  # Should be >= 60
ls EN/*.html | wc -l    # Should be >= 60
```

4. **Test in browser:**
```bash
quarto preview
# Navigate to different chapters, check links
```

5. **Verify search works:**
- Open browser preview
- Test search functionality
- Check search.json is valid

### Extending Validation

Add custom validation in `R/validation.R`:

```r
#' Validate Custom Requirement
validate_custom_check <- function(language, verbose = TRUE) {
  if (verbose) {
    message("Checking custom requirement...")
  }

  # Your validation logic
  if (!condition) {
    stop("Custom validation failed")
  }

  invisible(TRUE)
}
```

Add to `validate_all()` function.

## Resources

- **Quarto Documentation:** https://quarto.org/docs/
- **renv Documentation:** https://rstudio.github.io/renv/
- **Project README:** README.md
- **Contributing Guide:** CONTRIBUTING.md
- **Issue Tracker:** https://github.com/patolojiatlasi/patolojiatlasi.github.io/issues

---

**Last Updated:** 2025-11-08
**Maintainer:** Dr. Serdar Balcı
