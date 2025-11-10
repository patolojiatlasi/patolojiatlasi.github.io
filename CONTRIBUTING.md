# Contributing to Patoloji Atlası / Pathology Atlas

Thank you for your interest in contributing to the Patoloji Atlası (Pathology Atlas) project! This bilingual educational resource serves medical students, pathology residents, and practitioners worldwide.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Content Contributions](#content-contributions)
- [Technical Contributions](#technical-contributions)
- [Translation Guidelines](#translation-guidelines)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

This project is an educational medical resource. All contributions should:
- Be medically accurate and evidence-based
- Respect patient privacy (all images are de-identified)
- Follow professional medical communication standards
- Be respectful and constructive

## Getting Started

### Prerequisites

**Required:**
- [R](https://www.r-project.org/) (4.1 or higher)
- [Quarto CLI](https://quarto.org/docs/get-started/) (pre-release version)
- Git

**Optional but recommended:**
- RStudio (for R script development)
- VS Code with Quarto extension

### Initial Setup

1. **Fork and clone the repository:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/patolojiatlasi.github.io.git
   cd patolojiatlasi.github.io
   ```

2. **Install R dependencies:**
   ```r
   # Install renv if not already installed
   install.packages("renv")

   # Restore project dependencies
   renv::restore()
   ```

3. **Verify Quarto installation:**
   ```bash
   quarto --version
   ```

4. **Test local rendering:**
   ```bash
   # Render Turkish version
   quarto render --profile=default

   # Preview with live reload
   quarto preview
   ```

### Project Structure

```
.
├── R/                          # R utility scripts
│   ├── config.R               # Project configuration
│   ├── utils.R                # Utility functions
│   ├── validation.R           # Build validation
│   ├── languageTR.R / languageEN.R  # Language settings
│   └── bilingual-quarto-book.R      # Main build orchestrator
│
├── config/                    # Configuration files
│   └── chapter-mapping.xlsx   # Turkish ↔ English chapter mappings
│
├── output/                    # Generated files (gitignored)
│   ├── webpages.txt           # Plain text link list
│   ├── webpages.js            # JavaScript array of links
│   └── tweetstring.txt        # Social media content
│
├── _subchapters/              # Reusable case content
├── _lecture-notes/            # Lecture materials
├── images/                    # Cover images (Git LFS tracked)
├── screenshots/               # Case screenshots (Git LFS tracked, ~177MB)
├── qrcodes/                   # QR codes for cases (Git LFS tracked)
│
├── _quarto_TR.yml             # Turkish book configuration
├── _quarto_EN.yml             # English book configuration
├── _quarto_chapters_TR.yml    # Turkish chapter list (base)
├── _quarto_chapters_EN.yml    # English chapter list (base)
│
└── *.qmd                      # Chapter files (see File Naming Conventions below)
```

**Important Directories:**
- **`/config/`** - Static configuration files that don't change frequently
- **`/output/`** - Auto-generated files during builds (don't commit - gitignored)
- **`/R/`** - Build scripts and utilities (documented in DEVELOPMENT.md)
- **`/_subchapters/`** - Reusable content included in multiple chapters
- **Images directories** - All PNG/JPG files tracked with Git LFS for efficient storage

## Development Workflow

### Bilingual Content Pattern

All `.qmd` files use conditional rendering for bilingual support:

```r
```{r language, echo=FALSE, include=TRUE}
source("./R/language.R")
output_type <- knitr::opts_knit$get("rmarkdown.pandoc.to")
```

```{asis, echo = (language == "TR")}
# Türkçe başlık

Türkçe içerik...
```

```{asis, echo = (language == "EN")}
# English title

English content...
```
```

### Adding a New Case/Chapter

1. **Create the `.qmd` file** in the root directory (e.g., `new-diagnosis.qmd`)

2. **Use the bilingual template:**
   ```yaml
   ---
   description: |
       Brief description (Turkish)
       Brief description (English)
   date: last-modified
   categories: [category1, category2]
   page-layout: full
   ---

   ```{r language, echo=FALSE, include=TRUE}
   source("./R/language.R")
   output_type <- knitr::opts_knit$get("rmarkdown.pandoc.to")
   ```

   ```{asis, echo = (language == "TR")}
   # Tanı Adı {#sec-diagnosis-name}

   İçerik...
   ```

   ```{asis, echo = (language == "EN")}
   # Diagnosis Name {#sec-diagnosis-name}

   Content...
   ```
   ```

3. **Add to chapter lists:**
   - Edit `_quarto_chapters_TR.yml` - Add to appropriate section
   - Edit `_quarto_chapters_EN.yml` - Add to corresponding section

4. **Update mapping file:**
   - Add entry to `config/chapter-mapping.xlsx`
   - Map Turkish chapter name to English equivalent

5. **Test rendering:**
   ```bash
   quarto render new-diagnosis.qmd
   ```

### Adding Whole Slide Images

Whole slide images (WSI) use OpenSeadragon for interactive viewing:

```html
<div id="osd-viewer-unique-id"></div>
<script src="https://openseadragon.github.io/openseadragon/openseadragon.min.js"></script>
<script>
  var viewer = OpenSeadragon({
    id: "osd-viewer-unique-id",
    prefixUrl: "https://openseadragon.github.io/openseadragon/images/",
    tileSources: {
      type: 'image',
      url: './path/to/image.jpg'
    }
  });
</script>
```

**Guidelines:**
- Use unique IDs for each viewer on the page
- Images should be de-identified (no patient information)
- Provide both low-resolution preview and high-resolution zoomable version
- Include descriptive captions in both languages

### Working with Subchapters

Subchapters in `_subchapters/` are reusable content included in multiple chapters:

```markdown
{{< include _subchapters/_case-name.qmd >}}
```

**When to use subchapters:**
- Content appears in multiple disease categories
- Case demonstrates multiple diagnostic features
- Shared teaching points across chapters

### File Naming Conventions

To maintain consistency and make files easy to find, follow these naming standards:

#### Main Chapter Files (Root Directory)

**Format:** `{topic-name}.qmd`

**Rules:**
- Use **lowercase** letters only
- Use **hyphens** (`-`) to separate words, not underscores or spaces
- Use **descriptive English medical terms** (not Turkish) for filename
- Keep names **concise** (2-4 words maximum)
- Avoid special characters (no: `ç, ş, ğ, ı, ö, ü`)

**Examples:**
```
✅ Good:
   kidney.qmd
   liver-cirrhosis.qmd
   acute-inflammation.qmd
   gastric-cancer.qmd

❌ Avoid:
   Kidney.qmd                    # Capital letters
   liver_cirrhosis.qmd           # Underscores instead of hyphens
   akut-inflamasyon.qmd         # Turkish in filename
   very-long-descriptive-diagnosis-name.qmd  # Too long
```

#### Subchapter Files (`_subchapters/` Directory)

**Format:** `_{case-description}.qmd` / `_{case-description}_EN.qmd`

**Rules:**
- **Prefix with underscore** (`_`) to distinguish from main chapters
- Use **English medical terminology** for case description
- Use **hyphens** to separate words
- Use lowercase only
- English variant adds `_EN` suffix before `.qmd`

**Examples:**
```
✅ Good:
   _acute-appendicitis.qmd
   _acute-appendicitis_EN.qmd
   _chronic-gastritis.qmd
   _chronic-gastritis_EN.qmd
   _squamous-cell-carcinoma.qmd
   _squamous-cell-carcinoma_EN.qmd

❌ Avoid:
   acute-appendicitis.qmd        # Missing underscore prefix
   _Acute_Appendicitis.qmd       # Capital letters and underscores
   _akut-apandisit.qmd          # Turkish in filename
```

#### R Script Files (`R/` Directory)

**Format:** `{descriptive-name}.R`

**Rules:**
- Use **lowercase** with hyphens
- Descriptive function-based names
- Follow existing patterns: `render_*.R`, `config.R`, `utils.R`

**Examples:**
```
✅ Good:
   render-tr.R  or  render_TR.R   # Both acceptable (matches existing)
   config.R
   utils.R
   extract-html-links.R

❌ Avoid:
   RenderTR.R                     # CamelCase
   my_custom_script.R             # Underscores (prefer hyphens for new files)
```

#### YAML Configuration Files (Root Directory)

**Format:** `_quarto_{variant}.yml`

**Rules:**
- Prefix with `_quarto_` for Quarto configurations
- Use lowercase with underscores
- Follow existing patterns

**Examples:**
```
✅ Existing patterns (don't change):
   _quarto_TR.yml
   _quarto_EN.yml
   _quarto_TR_pdf.yml
```

#### Legacy Files

**Important:** Existing files don't need immediate renaming. These conventions apply to:
- ✅ **All new files** - must follow conventions
- ✅ **Files being significantly refactored** - rename at that time
- ❌ **Existing stable files** - leave as-is to avoid breaking links

**When renaming legacy files:**
1. Update all cross-references in other files
2. Update `_quarto_chapters_TR.yml` and `_quarto_chapters_EN.yml`
3. Update `config/chapter-mapping.xlsx` mapping
4. Test that all links still work

#### Quick Reference Table

| File Type | Prefix | Case | Separator | Example |
|-----------|--------|------|-----------|---------|
| Main chapter | none | lowercase | hyphens | `liver-cirrhosis.qmd` |
| Subchapter (TR) | `_` | lowercase | hyphens | `_acute-appendicitis.qmd` |
| Subchapter (EN) | `_` | lowercase | hyphens + `_EN` | `_acute-appendicitis_EN.qmd` |
| R script | none | lowercase | hyphens/underscores | `render-tr.R` |
| Quarto config | `_quarto_` | lowercase | underscores | `_quarto_TR.yml` |

## Content Contributions

### Medical Content Standards

- **Evidence-based:** Reference authoritative sources (WHO classifications, major textbooks)
- **Current:** Use recent classification systems and terminology
- **Accurate:** Verify diagnoses and descriptions
- **Educational:** Focus on teaching value for learners

### Image Guidelines

- **De-identification:** Remove all patient identifiers before submission
- **Quality:** Use high-resolution images (WSI preferred)
- **Permissions:** Ensure you have rights to share images
- **Format:** PNG for screenshots, JPG for photographs (automated conversion available)

### Citation Style

Use BibTeX format in `references.bib`:

```bibtex
@book{key,
  author = {Author Name},
  title = {Book Title},
  year = {2024},
  publisher = {Publisher},
  edition = {5th}
}
```

Reference in text: `[@key]`

## Technical Contributions

### R Script Development

When modifying R scripts in `/R`:

1. **Follow existing patterns:**
   - Use roxygen2 documentation (`#'`)
   - Include `@param`, `@return`, `@export`, `@examples`
   - Add error handling using functions from `R/utils.R`

2. **Use the configuration system:**
   ```r
   source("./R/config.R")
   config <- get_language_config("TR")
   # Access: config$quarto_file, config$output_dir, etc.
   ```

3. **Use safe operations:**
   ```r
   source("./R/utils.R")
   safe_file_copy(from, to)
   safe_quarto_render(input = ".")
   ```

4. **Add logging:**
   ```r
   log_info("Starting process...")
   log_warning("Potential issue detected")
   log_error("Operation failed", context = "function_name")
   ```

5. **Follow code style conventions:**
   - Use `snake_case` for all variables and functions
   - Prefer concise, clear names over long descriptive ones
   - Use lowercase for language identifiers (e.g., `tr_chapter_qmd`, not `TR_chapter_qmd`)

   **Examples:**
   ```r
   # Good
   chapter_mappings <- read_chapter_mappings()
   tr_chapter_qmd <- paste0("./", chapter_mappings$TR_chapter_qmd, ".qmd")
   en_chapter_qmd <- paste0("./", chapter_mappings$EN_chapter_qmd, ".qmd")

   # Avoid
   patolojiatlasi_histopathologyatlas <- read_chapter_mappings()  # Old name (too long)
   TR_chapter_qmd <- ...  # Mixed case instead of snake_case
   ```

### Validation

Before submitting changes that modify build scripts:

```r
source("./R/validation.R")

# Validate prerequisites
validate_build_prerequisites("TR")

# Validate chapter generation
validate_chapter_generation("TR")

# Validate build output
validate_build_output("TR", check_deploy = FALSE)

# Or run all validations
validate_all("TR")
```

### GitHub Actions Workflow

The main build workflow (`.github/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml`):

1. Renders English version (copies TR `.qmd` → `*_EN.qmd`)
2. Renders Turkish version
3. Commits to `docs/` and `EN/` directories
4. Pushes to mirror repositories

**Skip patterns:** Workflow skips if commit message contains:
- `WIP` - Work in progress
- `merge` - Merge commits
- `lecture` - Lecture notes only

## Translation Guidelines

### Turkish → English Translation

1. **Medical terminology:**
   - Use standard English medical terms
   - Reference WHO classifications and ICD-O coding
   - Consult `config/chapter-mapping.xlsx` for consistency

2. **Maintain structure:**
   - Keep same heading levels
   - Preserve section IDs (`#sec-name` stays the same)
   - Match image placements

3. **Cultural considerations:**
   - Adapt examples for international audience
   - Use international units (with conversions if needed)

### Adding New Language Support

To add a third language (e.g., French):

1. Update `R/config.R`:
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

2. Create `_quarto_FR.yml` configuration
3. Create `R/languageFR.R` with `language <- "FR"`
4. Add conditional blocks to all `.qmd` files
5. Update GitHub Actions workflow

## Testing

### Local Testing Checklist

Before submitting a pull request:

- [ ] Renders successfully in Turkish (`quarto render`)
- [ ] Renders successfully in English (test via GitHub Actions or local EN setup)
- [ ] All cross-references work (`@sec-*` links)
- [ ] Images display correctly
- [ ] Whole slide images are interactive
- [ ] Search functionality works
- [ ] No broken links (internal or external)
- [ ] Mobile-responsive layout
- [ ] Validation passes: `validate_all("TR")`

### Testing Specific Formats

```bash
# HTML (default)
quarto render

# PDF output
quarto render --to pdf

# EPUB output
quarto render --to epub
```

## Submitting Changes

### Commit Message Guidelines

Use clear, descriptive commit messages:

**Good:**
```
Add gastric adenocarcinoma case with WSI

- Created new chapter: gastric-adenocarcinoma.qmd
- Added bilingual content (TR/EN)
- Included 3 whole slide images with OpenSeadragon
- Updated chapter lists and mapping file
```

**Avoid:**
```
update
fix
changes
```

### Pull Request Process

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/add-new-case
   ```

2. **Make your changes and commit:**
   ```bash
   git add .
   git commit -m "Add comprehensive description"
   ```

3. **Push to your fork:**
   ```bash
   git push origin feature/add-new-case
   ```

4. **Open a pull request:**
   - Provide clear title and description
   - Reference any related issues
   - Include screenshots for visual changes
   - Explain medical context if adding new content

5. **Respond to feedback:**
   - Address reviewer comments
   - Update PR based on requested changes
   - Keep discussion professional and constructive

### What Happens Next

- Automated checks will run (render tests, validation)
- Maintainers will review your contribution
- You may receive feedback or change requests
- Once approved, changes will be merged
- Build workflow will deploy to production sites

## Getting Help

- **Documentation issues:** Open an issue with the `documentation` label
- **Technical problems:** Open an issue with the `bug` label
- **Content questions:** Open an issue with the `question` label
- **Feature requests:** Open an issue with the `enhancement` label

## Recognition

All contributors are valued! Your contributions help medical education worldwide.

- Content contributors are listed in the acknowledgments section
- Significant contributions may warrant co-authorship on derivative works
- All contributions are licensed under the project's license terms

---

**Thank you for contributing to medical education!**

For questions, contact: [project maintainer contact information]
