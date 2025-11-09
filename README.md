# Patoloji Atlası / Histopathology Atlas

[![Quarto Render Bilingual Book Push Other Repos GitLab](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml/badge.svg)](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml)
[![Monthly Release](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/monthly-release.yml/badge.svg)](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/monthly-release.yml)
[![Lecture Notes](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/lecture-notes.yml/badge.svg)](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/lecture-notes.yml)

A comprehensive, bilingual (Turkish/English) digital pathology atlas featuring whole slide images (WSI) for medical education.

## 🌐 Live Sites

- **Turkish:** [https://www.patolojiatlasi.com/](https://www.patolojiatlasi.com/)
- **English:** [https://www.histopathologyatlas.com/](https://www.histopathologyatlas.com/)

## 📖 About

This is an open-source pathology teaching resource built with [Quarto](https://quarto.org/), featuring:

- **265+ pathology cases** with high-resolution whole slide images
- **Bilingual content** (Turkish and English) in a single codebase
- **Interactive WSI viewers** using OpenSeadragon
- **Multiple output formats**: Web (HTML), PDF, EPUB, Word
- **Monthly releases** with downloadable books
- **Automated CI/CD** with GitHub Actions

## 🚀 Quick Start

### Prerequisites

- [R](https://www.r-project.org/) (≥ 4.3.0)
- [Quarto](https://quarto.org/) (pre-release version recommended)
- [Git](https://git-scm.com/)

### Local Development

```bash
# Clone the repository
git clone https://github.com/patolojiatlasi/patolojiatlasi.github.io.git
cd patolojiatlasi.github.io

# Install R dependencies (first time only)
Rscript -e "source('./R/setup-dependencies.R'); ensure_dependencies()"

# Render Turkish version
quarto render

# Render English version
Rscript R/render_EN.R

# Preview during development
quarto preview
```

## 📁 Project Structure

```
.
├── R/                          # R scripts for build automation
│   ├── config.R               # Language-specific configuration
│   ├── utils.R                # Reusable utility functions
│   ├── bilingual-quarto-book.R # Main bilingual build script
│   ├── render_pdf_TR.R        # Turkish PDF renderer
│   ├── render_epub_word_EN.R  # English EPUB/Word renderer
│   └── ...
├── _subchapters/              # Reusable case content (included in chapters)
├── _quarto_TR.yml             # Turkish Quarto configuration
├── _quarto_EN.yml             # English Quarto configuration
├── chapter-mappings.yml       # Chapter name mappings (TR ↔ EN)
├── *.qmd                      # Individual chapter files
├── images/                    # Static images and assets
├── screenshots/               # WSI screenshots (auto-generated JPGs)
├── qrcodes/                   # QR codes for cases
├── openseadragon/             # WSI viewer library
├── .github/workflows/         # CI/CD automation
└── docs/                      # Generated output (Turkish site)
```

## 🔧 How It Works

### Bilingual Content System

All `.qmd` files contain **both languages** using conditional rendering:

```r
```{r language, echo=FALSE}
source("./R/language.R")
```

```{asis, echo = (language == "TR")}
# Turkish content here
```

```{asis, echo = (language == "EN")}
# English content here
```
```

During build:
1. The `language` variable is set in `R/language.R`
2. Quarto renders only the content matching the active language
3. Output goes to `docs/` (TR) or `EN/` (EN)

### Build Outputs

| Format | Turkish Config | English Config | Output Directory |
|--------|---------------|----------------|------------------|
| **Web (HTML)** | `_quarto_TR.yml` | `_quarto_EN.yml` | `docs/`, `EN/` |
| **PDF** | `_quarto_TR_pdf.yml` | `_quarto_EN_pdf.yml` | `_pdf_TR/`, `_pdf_EN/` |
| **EPUB/Word** | `_quarto_TR_epub_word.yml` | `_quarto_EN_epub_word.yml` | `_epub_word_TR/`, `_epub_word_EN/` |

### CI/CD Workflows

- **Main workflow** (`.github/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml`):
  - Renders both TR and EN versions
  - Pushes to multiple repositories (GitHub Pages, GitLab mirror)
  - Converts PNG screenshots to JPG
  - Generates QR codes

- **Monthly release** (`.github/workflows/monthly-release.yml`):
  - Generates PDF, EPUB, and Word formats
  - Creates GitHub releases with downloadable files
  - Runs on 1st of each month

## ✅ Build Validation & Quality Assurance

The project includes comprehensive validation and error handling systems to ensure build quality.

### Validation System

The `R/validation.R` script provides automated validation functions:

```r
source("./R/validation.R")

# Validate prerequisites before building
validate_build_prerequisites("TR")

# Validate chapter generation
validate_chapter_generation("TR")

# Validate build output
validate_build_output("TR", min_chapters = 60)

# Run all validations
validate_all("TR")
```

**What gets validated:**
- ✓ Required files and directories exist
- ✓ R packages are installed
- ✓ Quarto CLI is available
- ✓ Chapter files were generated correctly
- ✓ Expected number of HTML files rendered
- ✓ Essential resources (images, JavaScript) are present
- ✓ Search index is valid JSON

### Error Handling

The `R/utils.R` script includes robust error handling with logging:

```r
source("./R/utils.R")

# Safe file operations with validation
safe_file_copy("source.R", "destination.R")

# Safe directory operations
safe_dir_copy("_freeze", "_freeze_backup")

# Quarto render with retry logic
safe_quarto_render(input = ".", max_retries = 2)

# Logging
log_info("Build started")
log_warning("Potential issue detected")
log_error("Operation failed", context = "function_name")
```

### Automated Chapter Generation

The build system automatically generates format-specific chapter lists:

**Base files** (manually maintained):
- `_quarto_chapters_TR.yml` - Turkish chapter list
- `_quarto_chapters_EN.yml` - English chapter list

**Auto-generated** (from base files):
- `_quarto_chapters_TR_pdf.yml` - Turkish PDF variant (with suffixed hrefs)
- `_quarto_chapters_EN_pdf.yml` - English PDF variant
- `_quarto_chapters_TR_epub_word.yml` - Turkish EPUB/Word variant
- `_quarto_chapters_EN_epub_word.yml` - English EPUB/Word variant

This eliminates 1,200+ lines of duplicate configuration and ensures consistency across formats.

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for comprehensive guidelines on:
- Adding new pathology cases
- Bilingual content workflow
- Translation standards
- Technical contributions
- Testing procedures
- Pull request process

For technical development details, see [CLAUDE.md](CLAUDE.md).

### Adding New Cases

1. Create a new `.qmd` file or edit existing chapter
2. Use the bilingual content pattern (see above)
3. Add case to `chapter-mappings.yml` if creating new file
4. Place images in appropriate directories
5. Test locally with `quarto preview`
6. Submit a pull request

### Chapter Mappings

The `chapter-mappings.yml` file maps Turkish chapter names to English equivalents:

```yaml
chapters:
  - tr: "mide"
    en: "stomach"
    tr_pdf: "mide_pdf"
    en_pdf: "stomach_pdf"
```

## 📦 Dependencies

Key R packages (auto-installed via `R/setup-dependencies.R`):
- `quarto` - Rendering engine
- `fs` - File system operations
- `yaml` - Configuration parsing
- `xfun` - Text manipulation
- `tinytex` - LaTeX for PDF generation

## 📄 Output Files

Generated files (excluded from git via `.gitignore`):
- `docs/` - Turkish HTML site
- `EN/` - English HTML site
- `public/` - Copy of docs/ for deployment
- `_pdf_TR/`, `_pdf_EN/` - PDF outputs
- `_epub_word_TR/`, `_epub_word_EN/` - EPUB/Word outputs
- `_freeze_TR/`, `_freeze_EN/` - Quarto computation cache

## 🔗 Related Repositories

- **English site:** [histopathologyatlas/histopathologyatlas.github.io](https://github.com/histopathologyatlas/histopathologyatlas.github.io)
- **GitLab mirror:** [sbalci/atlas](https://gitlab.com/sbalci/atlas)

## 🔧 Troubleshooting

### Common Build Issues

**Problem: "Quarto command not found"**
```bash
# Verify Quarto is installed
quarto --version

# If not installed, download from https://quarto.org/docs/get-started/
```

**Problem: "Package 'xyz' not found"**
```r
# Reinstall dependencies
source("./R/setup-dependencies.R")
ensure_dependencies()

# Or manually install missing package
install.packages("packagename")
```

**Problem: "Render fails with file not found"**
```r
# Run validation to identify missing files
source("./R/validation.R")
validate_build_prerequisites("TR")
```

**Problem: "Build succeeds but output is incomplete"**
```r
# Validate build output
source("./R/validation.R")
validate_build_output("TR", min_chapters = 60)

# Check for specific issues
validate_all("TR", verbose = TRUE)
```

**Problem: "Changes not appearing in output"**
```bash
# Clear Quarto cache and rebuild
rm -rf _freeze_TR/ _freeze_EN/
quarto render
```

**Problem: "_EN files multiply with suffixes"**

This bug was fixed. If you encounter it:
```bash
# Clean up duplicate files
find . -name "*_EN_EN*.qmd" -delete

# Update to latest version with fix
git pull origin main
```

### Debugging CI/CD Failures

1. **Check workflow logs** in GitHub Actions tab
2. **Look for error patterns:**
   - Missing files → Check file paths and mappings
   - Render failures → Test locally first
   - Validation failures → Run validation locally
3. **Skip workflow if needed:** Add `WIP` to commit message

### Getting Help

- **Issues:** [GitHub Issues](https://github.com/patolojiatlasi/patolojiatlasi.github.io/issues)
- **Discussions:** [GitHub Discussions](https://github.com/patolojiatlasi/patolojiatlasi.github.io/discussions)
- **Contributing guide:** See [CONTRIBUTING.md](CONTRIBUTING.md)

## 📝 License

[Add license information]

## 🙏 Acknowledgments

This atlas is compiled from cases in the Memorial Pathology archives and contributions from colleagues at various institutions.

## 📮 Contact

- Website: [https://www.patolojiatlasi.com/](https://www.patolojiatlasi.com/)
- Issues: [GitHub Issues](https://github.com/patolojiatlasi/patolojiatlasi.github.io/issues)
