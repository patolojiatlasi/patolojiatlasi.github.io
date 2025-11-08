# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **bilingual Quarto book project** that generates a comprehensive pathology atlas with whole slide images (WSI). The project produces two versions:
- **Turkish (TR)**: Main site at patolojiatlasi.com
- **English (EN)**: Translated site at histopathologyatlas.com

The content consists of medical pathology teaching materials with embedded whole slide image viewers using OpenSeadragon.

## Build System

### Rendering the Books

The project uses **Quarto** for rendering. There are separate configuration files for different outputs:

**Turkish Version:**
```bash
quarto render --profile=default
# Uses _quarto_TR.yml, outputs to _docs/
```

**English Version:**
```bash
# The EN version is generated via GitHub Actions
# It copies TR .qmd files, renames them to *_EN.qmd, and renders with _quarto_EN.yml
```

**Key Quarto Config Files:**
- `_quarto_TR.yml` - Main Turkish book configuration (outputs to `_docs/`)
- `_quarto_EN.yml` - English book configuration (outputs to `_EN/`)
- `_quarto_TR_pdf.yml` - PDF output for Turkish
- `_quarto_EN_pdf.yml` - PDF output for English
- `_quarto_TR_epub_word.yml` - EPUB/Word for Turkish
- `_quarto_EN_epub_word.yml` - EPUB/Word for English

### R Scripts in /R Directory

- `languageTR.R` / `languageEN.R` - Set the `language` variable used in conditional content blocks
- `prerender_TR.R` - Pre-render script for Turkish (copies subchapters, prepares files)
- `postrender_TR.R` - Post-render cleanup script
- `extract-html-links.R` - Extracts links from rendered HTML
- `render_TR.R` / `render_EN.R` - Helper scripts for rendering specific versions

## Architecture

### Content Structure

**Main Content Files:**
- `index.qmd` - Homepage
- `*.qmd` - Individual chapter files (e.g., `mide.qmd`, `akciger.qmd`, `gliom.qmd`)
- `_subchapters/*.qmd` - Reusable case content included in multiple chapters
- `_lecture-notes/*.qmd` - Lecture note content (separate from main atlas)

**Bilingual Content Pattern:**
All `.qmd` files use conditional rendering based on the `language` variable:

```r
```{r language, echo=FALSE, include=TRUE}
source("./R/language.R")
output_type <- knitr::opts_knit$get("rmarkdown.pandoc.to")
```

```{asis, echo = (language == "TR")}
# Turkish content
```

```{asis, echo = (language == "EN")}
# English content
```
```

### GitHub Actions Workflow

**Main workflow:** `.github/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml`

This workflow:
1. Renders the English version first (copies TR qmd → EN qmd, renders with EN config)
2. Renders the Turkish version (renders with TR config)
3. Commits rendered output to `docs/` and `EN/` directories
4. Pushes to multiple repositories:
   - `patolojiatlasi/EN` (English content)
   - `histopathologyatlas/histopathologyatlas.github.io` (English site)
   - `sbalci/atlas` (GitLab mirror)

**Skip patterns:** Workflow skips if commit message contains `WIP`, `merge`, or `lecture`

### Image and Asset Management

- `screenshots/` - PNG screenshots converted to JPG by GitHub Actions
- `images/` - Cover images and graphics
- `qrcodes/` - QR codes for cases
- `openseadragon/` - Whole slide image viewer library
- `annotorious/` - Image annotation library

### Dependencies

**R packages** (managed via `renv`):
- `quarto` - Rendering engine
- `fs` - File system operations
- `xfun` - Utility functions
- `readxl` - Excel file reading (for `patolojiatlasi_histopathologyatlas.xlsx` mapping)

**System dependencies:**
- Quarto CLI (pre-release version)
- TinyTeX (LaTeX for PDF generation)
- VIPS (image processing)
- R 4.1+

## Key Files

- `patolojiatlasi_histopathologyatlas.xlsx` - Maps Turkish chapter names to English equivalents
- `CNAME` / `CNAME-histopathologyatlas` - Domain configuration for GitHub Pages
- `script.js` / `webpages.js` - Custom JavaScript for interactive features
- `headerTR.html` / `headerEN.html` - Custom HTML headers
- `references.bib` - Bibliography database

## Development Workflow

### Adding New Content

1. Create or edit a `.qmd` file in the root directory
2. Use the bilingual content pattern with `{asis}` blocks
3. Add chapter reference to both `_quarto_TR.yml` and `_quarto_EN.yml`
4. If using a subchapter, place it in `_subchapters/`
5. Update `patolojiatlasi_histopathologyatlas.xlsx` if adding new chapters

### Local Development

```bash
# Render Turkish version locally
quarto render

# Preview during development
quarto preview

# Render specific format
quarto render --to html
quarto render --to pdf
```

### Testing Changes

- Test both languages by switching the `language` variable in `R/language.R`
- Check that conditional content blocks render correctly
- Verify links between chapters work in both versions

## Important Conventions

1. **Chapter IDs:** Use `#sec-` prefix (e.g., `#sec-gliom`, `#sec-stomach`)
2. **Image paths:** Relative paths from project root (e.g., `./images/cover.png`)
3. **Cross-references:** Use Quarto syntax `@sec-chapter-name`
4. **Bilingual linking:** EN pages link to `*_EN.qmd` files; this is handled by `xfun::gsub_files()` in the workflow
5. **Output directories:** Never commit `_docs/`, `docs/`, `EN/`, or `public/` - these are generated
6. **Freeze:** Quarto uses `freeze: auto` to cache computations in `_freeze_EN/` and `_freeze_TR/`

## Common Issues

- **Rendering fails:** Check that `language.R` is properly sourced in the chapter
- **Missing images:** Ensure paths are relative to project root, not the qmd file location
- **EN/TR mismatch:** Verify `patolojiatlasi_histopathologyatlas.xlsx` has correct mappings
- **Workflow skipped:** Check commit message doesn't contain skip patterns

## Special Features

- **RSS feeds:** Generated automatically for both versions
- **Social embeds:** Filtered using `collapse-social-embeds` Quarto extension
- **Comments:** Multiple systems supported (Hypothesis, Utterances, Disqus)
- **Analytics:** Google Analytics enabled for TR version
- **Search:** Full-text search with overlay interface
- **Whole slide images:** OpenSeadragon integration for zoomable medical images
