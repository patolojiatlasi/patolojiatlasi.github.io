# Generate document configurations from selected chapters and explicit mappings.
source("./R/document-chapters.R")

generate_all_chapter_yamls <- function(language) {
  for (format in c("pdf", "epub_word")) {
    plan <- document_chapter_plan(language, format)
    output <- write_document_chapters(plan, language, format)
    message("Generated: ", output)
  }
}

if (!interactive()) {
  generate_all_chapter_yamls("TR")
  generate_all_chapter_yamls("EN")
}
