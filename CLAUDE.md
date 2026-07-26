# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bilingual (Turkish/English) Quarto book project generating a pathology atlas with 265+ cases and whole slide images (WSI). Two output sites:
- **Turkish**: patolojiatlasi.com (primary, `docs/` on GitHub Pages)
- **English**: histopathologyatlas.com (mirror repos)

## Build Commands

```bash
# Local preview (Turkish, default)
quarto preview

# Render Turkish version locally
quarto render

# Render English version
Rscript R/render_EN.R

# Full bilingual build (used by CI, ~10-15 min)
Rscript R/bilingual-quarto-book.R

# Install R dependencies (first time)
Rscript -e "source('./R/setup-dependencies.R'); ensure_dependencies()"

# Validate build output
Rscript -e "source('./R/validation.R'); validate_all('TR')"
```

**How `quarto render` resolves config:** The active config is always `_quarto.yml` in the project root. Build scripts copy the language-specific config (`_quarto_TR.yml` or `_quarto_EN.yml`) to `_quarto.yml` before rendering. The `R/language.R` symlink is similarly switched between `R/languageTR.R` and `R/languageEN.R`.

## Architecture

### Config Inheritance

Quarto configs use a layered `metadata-files` inheritance:

```
_quarto_base.yml          ← shared: project type, freeze, bibliography, comments
  └─ _quarto_html_base.yml  ← shared HTML: theme, CSS, search, feeds, filters
       ├─ _quarto_TR.yml     ← TR: chapters, lang, output-dir (_docs), pre/post-render
       └─ _quarto_EN.yml     ← EN: chapters, lang, output-dir (_EN)
```

Each language config also includes a chapter list file via `metadata-files`:
- `_quarto_chapters_TR.yml` / `_quarto_chapters_EN.yml` — **manually maintained** base chapter lists
- `_quarto_chapters_{TR,EN}_{pdf,epub_word}.yml` — **auto-generated** by `R/generate-chapter-yamls.R` (adds format suffixes to hrefs)

### Bilingual Content Pattern

Every `.qmd` file contains both languages using R conditional blocks:

```r
```{r language, echo=FALSE, include=TRUE}
source("./R/language.R")
output_type <- knitr::opts_knit$get("rmarkdown.pandoc.to")
```

```{asis, echo = (language == "TR")}
# Turkish heading {#sec-id}
Turkish content...
```

```{asis, echo = (language == "EN")}
# English heading {#sec-id}
English content...
```
```

The `language` variable is set to `"TR"` or `"EN"` based on which `R/language*.R` was copied to `R/language.R`.

### Full Build Process (bilingual-quarto-book.R)

The CI build has 6 phases:

1. **Init**: Load deps, fix corrupted `_EN` references, clean artifacts
2. **EN Prep**: Read `chapter-mappings.yml`, copy `*.qmd` → `*_EN.qmd`, update `{{< include >}}` cross-references to point to `_EN.qmd` variants
3. **EN Render**: `quarto::quarto_render()` with EN config active
4. **EN Cleanup**: Save `_freeze` → `_freeze_EN`, delete temp `*_EN.qmd` files, revert shared files
5. **TR Render**: Switch to TR config, `quarto::quarto_render()`, save `_freeze` → `_freeze_TR`
6. **Deploy**: Copy outputs to `docs/` (TR GitHub Pages), `EN/` (EN mirror), `public/` (staging), `gitlab_atlas/public/` (GitLab)

### Chapter Mappings

`chapter-mappings.yml` maps Turkish filenames to English equivalents and format-specific variants:

```yaml
chapters:
  - tr: mide
    en: stomach
    tr_pdf: mide_pdf_TR
    en_pdf: stomach_pdf_EN
    tr_epub_word: mide_epub_word_TR
    en_epub_word: stomach_epub_word_EN
```

This replaced the old `patolojiatlasi_histopathologyatlas.xlsx` approach. Some chapters share the same filename for both languages (e.g., `benign.qmd`, `crohn.qmd`, `hodgkin.qmd`).

### Key R Scripts

| Script | Purpose |
|--------|---------|
| `R/config.R` | Centralized project config (paths, dirs, language settings) |
| `R/utils.R` | Build utilities: `setup_language_build()`, `read_chapter_mappings()`, `fix_corrupted_en_references()`, safe file ops |
| `R/validation.R` | Build validation: `validate_all()`, `validate_build_output()`, `validate_build_prerequisites()` |
| `R/generate-chapter-yamls.R` | Auto-generates PDF/EPUB chapter YAML files from base chapter lists |
| `R/bilingual-quarto-book.R` | Master build orchestrator (all 6 phases) |
| `R/prerender_TR.R` | Quarto pre-render hook: sets language, generates chapter YAMLs |
| `R/prerender_EN.R` | Quarto pre-render hook for EN |
| `R/postrender_TR.R` | Quarto post-render cleanup |

### Subchapters

`_subchapters/*.qmd` contains reusable case content included in multiple chapters via:
```
{{< include _subchapters/_case-name.qmd >}}
```

During EN builds, these are copied to `_subchapters/_case-name_EN.qmd` and include references are rewritten. The `_EN` suffix handling is the most fragile part of the build.

## Known Pitfall: _EN Suffix Multiplication Bug

If a build fails mid-way, `_EN.qmd` references in shared files can accumulate: `_EN.qmd` → `_EN_EN.qmd` → `_EN_EN_EN.qmd`. The build system handles this:
- `fix_corrupted_en_references()` in `R/utils.R` runs at build start
- The EN reference update is made idempotent: strip all `_EN` suffixes first, then add one fresh pass

If you see `_EN_EN` patterns in `.qmd` files, run:
```r
source("./R/utils.R"); fix_corrupted_en_references()
```

## Known Pitfall: `quarto render`/`quarto preview` Destroys `docs/`

`R/prerender_TR.R` unconditionally runs `fs::dir_delete("./docs")` and
`fs::dir_delete("./gitlab_atlas/public")`, and `R/postrender_TR.R` is entirely commented out — the
copy back into `docs/` happens in phase 6 of `R/bilingual-quarto-book.R`, not in the post-render
hook. So **any** bare `quarto render` or `quarto preview`, including rendering a single page, wipes
both directories and only the full build script puts them back. Since `docs/` and `gitlab_atlas/`
are *tracked* (convention 4 below is wrong on this point), the damage shows up as ~1800 staged
deletions.

The same pre-render also runs `R/extract-html-links.R`, which re-derives `lists/list.yaml`,
`lists/specimensData.js`, `lists/yaml_preparation_file.yaml` and `rss_feed.xml` **from the HTML in
`docs/`**. With `docs/` freshly deleted it silently strips `note:` and `titleTR`/`titleEN` fields
from existing entries and drops items from the RSS feed.

After any partial render, restore before committing:

```bash
git checkout -- docs/ gitlab_atlas/ lists/ rss_feed.xml
```

Let CI regenerate those files from a full build; never commit a partially regenerated `lists/` or
`rss_feed.xml`.

## CI/CD

**Main workflow**: `.github/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml`

Triggers on push (except `.md` files, `lecture-notes/`, `deneme/` dirs, `.gitignore`, `.gitattributes`). Also supports `workflow_dispatch`.

The workflow: checkout with LFS → convert PNG screenshots to JPG (VIPS) → install Quarto pre-release + TinyTeX → install R + packages → run `bilingual-quarto-book.R` → commit/push to main + mirror repos.

**Other workflows**: `monthly-release.yml` (PDF/EPUB/Word on 1st of month), `lecture-notes.yml`, social media posting workflows.

## Important Conventions

1. **Chapter IDs**: Use `#sec-` prefix (e.g., `#sec-gliom`, `#sec-stomach`)
2. **Cross-references**: Quarto syntax `@sec-chapter-name`
3. **Image paths**: Relative to project root (e.g., `./images/cover.png`, `./screenshots/thumbnail_*.png`)
4. **Never commit generated output**: `_docs/`, `docs/`, `EN/`, `public/`, `*_EN.qmd`, `*_pdf_*.qmd`, `*_epub_word_*.qmd` are all gitignored
5. **Freeze dirs**: `_freeze_TR/` and `_freeze_EN/` cache computed R chunks between builds. Delete them to force full recomputation: `rm -rf _freeze_TR/ _freeze_EN/`
6. **Adding chapters**: Edit both `_quarto_chapters_TR.yml` and `_quarto_chapters_EN.yml` (base files), plus add mapping in `chapter-mappings.yml`
7. **WSI viewers**: Use OpenSeadragon with unique div IDs per viewer; images hosted on `images.patolojiatlasi.com`
8. **R code style**: `snake_case` for functions/variables, roxygen2 docs, use `safe_*` wrappers from `R/utils.R`

## Output Directories

| Directory | Content | Served at |
|-----------|---------|-----------|
| `_docs/` | TR build output (temp) | — |
| `docs/` | TR deployment | patolojiatlasi.com |
| `_EN/` | EN build output (temp) | — |
| `EN/` | EN deployment | histopathologyatlas.com |
| `public/` | TR staging (no CNAME) | — |
| `_freeze_TR/` / `_freeze_EN/` | Quarto computation cache | — |

## Dependencies

**System**: Quarto CLI (pre-release), R (>= 4.3), TinyTeX (PDF only), VIPS (image conversion in CI)

**R packages** (core): `quarto`, `fs`, `yaml`, `xfun`, `jsonlite`. Optional: `webshot2` (screenshots), `qrcode` (QR generation), `tinytex` (PDF).