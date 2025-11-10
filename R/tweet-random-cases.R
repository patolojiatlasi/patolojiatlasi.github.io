if (!requireNamespace("jsonlite", quietly = TRUE)) {install.packages("jsonlite", dependencies = TRUE, quiet = TRUE, verbose = FALSE)}
library(jsonlite, quietly = TRUE, warn.conflicts = FALSE, verbose = FALSE)
if (!requireNamespace("magrittr", quietly = TRUE)) {install.packages("magrittr", dependencies = TRUE, quiet = TRUE, verbose = FALSE)}
library(magrittr, quietly = TRUE, warn.conflicts = FALSE, verbose = FALSE)
if (!requireNamespace("dplyr", quietly = TRUE)) {install.packages("dplyr", dependencies = TRUE, quiet = TRUE, verbose = FALSE)}
library(dplyr, quietly = TRUE, warn.conflicts = FALSE, verbose = FALSE)
if (!requireNamespace("glue", quietly = TRUE)) {install.packages("glue", dependencies = TRUE, quiet = TRUE, verbose = FALSE)}
library(glue, quietly = TRUE, warn.conflicts = FALSE, verbose = FALSE)

searchcontent <- jsonlite::fromJSON(txt = "./docs/search.json", simplifyDataFrame = TRUE) %>% as.data.frame()
searchcontent <- searchcontent %>% dplyr::filter(!is.na(section))
searchcontent <- searchcontent %>% dplyr::filter(!(section ==""))
searchcontent <- searchcontent %>% dplyr::filter(!title %in% c("Yazarlar ve Katkıda Bulunanlar","Appendix A — Yönetim ve Geliştirme"))
searchcontent$title <- trimws(gsub(pattern = "\\d|.\\d", replacement = "", x = searchcontent$title))
searchcontent$section <- trimws(gsub(pattern = "\\d|.\\d", replacement = "", x = searchcontent$section))

searchcontent <- sample_n(searchcontent, 1)

tweetstring <- glue::glue("Patoloji atlası {searchcontent$title} bölümünden bir vaka: {searchcontent$section} https://www.patolojiatlasi.com/{searchcontent$href} #dijitalpatoloji #WSI #preparat",
                          " #patolojiatlasi #patolojinotlari #histopathologyatlas",
                          " #memorialsaglik #memorialpatoloji",
                          .sep ="")

tweetstring <- trimws(tweetstring)

writeLines(text = tweetstring, "./output/tweetstring.txt")
