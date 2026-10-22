# Source-driven HTML metadata for both editions. No network or publishing actions.
config <- yaml::read_yaml("_quarto.yml")
edition <- toupper(config$lang)
if (!edition %in% c("TR", "EN")) stop("Unknown atlas edition")
output <- config$project[["output-dir"]]
seo <- yaml::read_yaml("config/seo.yml")
editions <- lapply(c("TR", "EN"), function(code) {
  settings <- yaml::read_yaml(paste0("_quarto_", code, ".yml"))
  list(root = settings$book[["site-url"]],
       book = yaml::read_yaml(paste0("_quarto_chapters_", code, ".yml"))$book)
})
names(editions) <- c("TR", "EN")
chapter_paths <- function(book) {
  values <- unlist(book[c("chapters", "appendices")], use.names = FALSE)
  unique(sub("\\.qmd$", ".html", values[grepl("\\.qmd$", values)]))
}
paths <- lapply(editions, function(value) chapter_paths(value$book))
page_url <- function(code, path) {
  path <- sub("(^|/)index\\.html$", "\\1", path)
  paste0(editions[[code]]$root, path)
}
mapping <- yaml::read_yaml("chapter-mappings.yml")$chapters
pairs <- lapply(mapping, function(row) {
  # The English build prepares index_EN.qmd, but its configured homepage is index.qmd.
  en <- if (row$tr == "index" && row$en == "index_EN") "index" else row$en
  c(TR = paste0(row$tr, ".html"), EN = paste0(en, ".html"))
})
pairs <- Filter(function(pair) {
  pair[["TR"]] %in% paths$TR && pair[["EN"]] %in% paths$EN &&
    !any(pair %in% seo[["hreflang-exclude"]])
}, pairs)
alternates <- function(path) {
  match <- Filter(function(pair) identical(unname(pair[[edition]]), path), pairs)
  if (!length(match)) return(character())
  pair <- match[[1]]
  c(tr = page_url("TR", pair[["TR"]]), en = page_url("EN", pair[["EN"]]))
}
set_meta <- function(head, attribute, key, value) {
  nodes <- xml2::xml_find_all(head, paste0("meta[@", attribute, "='", key, "']"))
  xml2::xml_remove(nodes)
  node <- xml2::xml_add_child(head, "meta", content = value)
  xml2::xml_set_attr(node, attribute, key)
}
for (path in paths[[edition]]) {
  file <- file.path(output, path)
  if (!file.exists(file)) next # A focused render need not create every chapter.
  html <- xml2::read_html(file)
  head <- xml2::xml_find_first(html, "//head")
  # Replace Quarto's native canonical (if present), never add a duplicate.
  xml2::xml_remove(xml2::xml_find_all(head, "link[@rel='canonical']"))
  xml2::xml_add_child(head, "link", rel = "canonical", href = page_url(edition, path))
  xml2::xml_remove(xml2::xml_find_all(head, "link[@rel='alternate'][@hreflang]"))
  links <- alternates(path)
  for (code in names(links)) {
    xml2::xml_add_child(head, "link", rel = "alternate", hreflang = code, href = links[[code]])
  }
  description <- seo$descriptions[[edition]][[path]]
  if (!is.null(description)) {
    set_meta(head, "name", "description", description)
    set_meta(head, "property", "og:description", description)
    set_meta(head, "name", "twitter:description", description)
  }
  if (path == "index.html") {
    cover <- config$book[["cover-image"]]
    if (!file.exists(cover)) stop("Configured cover image is missing")
    cover_url <- paste0(editions[[edition]]$root, cover)
    set_meta(head, "property", "og:image", cover_url)
    set_meta(head, "name", "twitter:image", cover_url)
  }
  xml2::write_html(html, file)
}
sitemap_file <- file.path(output, "sitemap.xml")
if (file.exists(sitemap_file)) {
  sitemap <- xml2::read_xml(sitemap_file)
  for (entry in xml2::xml_find_all(sitemap, "//*[local-name()='url']")) {
    loc <- xml2::xml_find_first(entry, "*[local-name()='loc']")
    path <- sub("^https?://[^/]+/", "", xml2::xml_text(loc))
    if (path == "") path <- "index.html"
    if (!path %in% paths[[edition]]) next
    xml2::xml_set_text(loc, page_url(edition, path))
    xml2::xml_remove(xml2::xml_find_all(entry, "*[local-name()='link'][@hreflang]"))
    links <- alternates(path)
    for (code in names(links)) {
      node <- xml2::read_xml(sprintf(
        '<xhtml:link xmlns:xhtml="http://www.w3.org/1999/xhtml" rel="alternate" hreflang="%s" href="%s"/>',
        code, links[[code]]))
      xml2::xml_add_child(entry, xml2::xml_root(node))
    }
  }
  xml2::write_xml(sitemap, sitemap_file)
}
robots_file <- file.path(output, "robots.txt")
if (file.exists(robots_file)) {
  robots <- readLines(robots_file, warn = FALSE)
  robots <- robots[!grepl("^Sitemap:", robots, ignore.case = TRUE)]
  writeLines(c(robots, paste0("Sitemap: ", editions[[edition]]$root, "sitemap.xml")), robots_file)
}
