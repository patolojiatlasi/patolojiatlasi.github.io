page_string <- '

```{comment}
---
description: |
    {{TemplateTR}}, {{TemplateEN}}, patoloji, atlas, pathology, whole slide image, virtual microscopy, virtual microscope, sanal mikroskop
date: last-modified
categories: [{{TemplateTR}}, {{TemplateEN}}]
page-layout: full
bibliography: references.bib
---
```

'

page_list <- paste0("./_subchapters/_BS",1:31, ".qmd")

# for (page in page_list) {
#   writeLines(page_string, page)
# }

# Write to each file in the list
for (page in page_list) {
  write(page_string, page, append = TRUE)
}


# Write to each file in the list
# for (page in page_list) {
#   cat(page_string, file = page, append = TRUE, sep = "\n")
# }



link_list <- paste0("{{< include ./_subchapters/_BS",1:31, ".qmd >}}")

cat(link_list, sep = "\n\n\n\n")
