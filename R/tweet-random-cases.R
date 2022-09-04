if (!requireNamespace("jsonlite", quietly = TRUE)) {install.packages("jsonlite")}
library(jsonlite, quietly = TRUE, warn.conflicts = FALSE, verbose = FALSE)
if (!requireNamespace("magrittr", quietly = TRUE)) {install.packages("magrittr")}
library(magrittr, quietly = TRUE, warn.conflicts = FALSE, verbose = FALSE)
if (!requireNamespace("dplyr", quietly = TRUE)) {install.packages("dplyr")}
library(dplyr, quietly = TRUE, warn.conflicts = FALSE, verbose = FALSE)

searchcontent <- jsonlite::fromJSON(txt = "./docs/search.json", simplifyDataFrame = TRUE) %>% as.data.frame()
searchcontent <- searchcontent %>% dplyr::filter(!is.na(section))
searchcontent <- searchcontent %>% dplyr::filter(!(section ==""))
searchcontent <- searchcontent %>% dplyr::filter(!title %in% c("Yazarlar ve Katkıda Bulunanlar","Appendix A — Yönetim ve Geliştirme"))
searchcontent <- sample_n(searchcontent, 1)

tweetstring <- glue::glue("{searchcontent$title} bölümünden bir vaka: {searchcontent$section}")

cat(tweetstring)
