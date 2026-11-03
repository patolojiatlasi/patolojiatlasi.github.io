# Run from the repository root; no network, Quarto, or TeX is needed.
source("R/document-chapters.R")
source("R/utils.R")
fail <- function(expr, pattern) {
  result <- tryCatch({force(expr); NULL}, error = identity)
  stopifnot(inherits(result, "error"), grepl(pattern, conditionMessage(result)))
}
original_config <- readBin("_quarto.yml", "raw", file.info("_quarto.yml")$size)
original_language <- readBin("R/language.R", "raw", file.info("R/language.R")$size)
tryCatch({
  for (language in c("TR", "EN")) for (format in c("pdf", "epub_word")) {
    plan <- document_chapter_plan(language, format)
    suffix <- paste0("_", format, "_", language, ".qmd")
    stopifnot(all(file.exists(plan$copies$source)),
              plan$copies$target[1] == "index.qmd",
              paste0("adrenal", suffix) %in% plan$copies$target,
              paste0(if (language == "TR") "referanslar" else "references", suffix) %in% plan$copies$target)
    omitted <- if (language == "TR")
      c("karaciger-transplantasyonu.qmd", "artirilmis-gerceklik.qmd", "lists/index.qmd") else
      c("liver-transplantation.qmd", "augmented-reality.qmd")
    stopifnot(setequal(names(plan$omissions), omitted))
    if (language == "TR") stopifnot(all(paste0(c("hemodinamik-bozukluklar", "yonetim-gelistirme", "heterojenite"), suffix) %in% plan$copies$target))
    output <- write_document_chapters(plan, language, format)
    stopifnot(identical(yaml::read_yaml(output), plan$config))
    # Exercise the production preparation/transform/cleanup path with a render spy.
    # Validate actual generated chapters and their rewritten case includes.
    called <- FALSE
    check <- function(input, as_job) {
      called <<- TRUE
      stopifnot(all(file.exists(plan$copies$target)))
      for (file in plan$copies$target) {
        text <- readLines(file, warn = FALSE)
        includes <- regmatches(text, gregexpr("\\{\\{< include [^ ]+", text))
        includes <- sub("\\{\\{< include ", "", unlist(includes))
        stopifnot(all(file.exists(includes)))
      }
    }
    render_format(language, format, paste0("_quarto_", language, "_", format, ".yml"), format, render = check)
    stopifnot(called, !any(file.exists(plan$copies$target[-1])))
    fail(render_format(language, format, paste0("_quarto_", language, "_", format, ".yml"), format,
                       render = function(...) stop("synthetic render failure")), "synthetic render failure")
    stopifnot(!any(file.exists(plan$copies$target[-1])))
    message(language, "/", format, ": PASS")
  }
  mappings <- yaml::read_yaml("chapter-mappings.yml")
  path <- tempfile(fileext = ".yml")
  # Unexpected mappings, unexplained nulls, and genuinely absent sources fail early.
  altered <- mappings
  altered$chapters <- Filter(function(row) row$tr != "adrenal", altered$chapters)
  yaml::write_yaml(altered, path)
  fail(document_chapter_plan("TR", "pdf", path), "Expected one mapping.*adrenal")
  altered <- mappings
  i <- which(vapply(altered$chapters, function(row) row$tr == "artirilmis-gerceklik", logical(1)))
  altered$chapters[[i]]$document_omission <- NULL
  yaml::write_yaml(altered, path)
  fail(document_chapter_plan("EN", "pdf", path), "Unexplained document omission")
  altered <- mappings
  i <- which(vapply(altered$chapters, function(row) row$tr == "adrenal", logical(1)))
  altered$chapters[[i]]$tr <- "missing-source-for-test"
  yaml::write_yaml(altered, path)
  fail(document_chapter_plan("EN", "epub_word", path), "Missing chapter source")
  # A nonconventional mapped target is authoritative; do not synthesize a suffix.
  altered$chapters[[i]]$tr <- "adrenal"
  altered$chapters[[i]]$en_pdf <- "custom-adrenal-document"
  yaml::write_yaml(altered, path)
  stopifnot("custom-adrenal-document.qmd" %in% document_chapter_plan("EN", "pdf", path)$copies$target)
  unlink(path)
}, finally = {
  writeBin(original_config, "_quarto.yml")
  writeBin(original_language, "R/language.R")
})
message("All document chapter regression checks passed")
