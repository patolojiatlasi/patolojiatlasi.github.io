# Pre-render script for English version
# Generates format-specific chapter YAML files before rendering

# Copy English language configuration
fs::file_copy(path = "./R/languageEN.R", new_path = "./R/language.R", overwrite = TRUE)

# Generate format-specific chapter YAML files from base chapters
source("./R/generate-chapter-yamls.R")
generate_all_chapter_yamls("EN")
