filestorender <- list.files(path = '.', pattern = '.md', full.names = TRUE, recursive = TRUE)
render_file <- purrr::safely(function(file) {rmarkdown::render(file, encoding = 'UTF-8', output_dir = './patoloji-hakkinda/')})
purrr::map(.x = filestorender, .f= render_file)


filestorender <- list.files(path = "./lecture-notes", pattern = ".qmd", full.names = TRUE, recursive = TRUE)
purrr::map(.x = filestorender[1:10], .f= quarto::quarto_render, output_format = "all")
# quarto::quarto_render(input = "./lecture-notes/*.qmd")

quarto::quarto_render("./lecture-notes/alt-gis-tumorleri-sunum-2.qmd", output_format = "all")

quarto::quarto_render(input = "./lecture-notes/alt-gis-tumorleri-sunum-2.qmd",
                      output_format = "revealjs")


purrr::map(
  .x = c("revealjs", "gfm"),
  .f =
    ~ quarto::quarto_render(input = "./lecture-notes/alt-gis-tumorleri-sunum-2.qmd",
                    execute_params = list(format = .x)
                    # ,
                    # output_file = paste0("final_report", .x)
                    )
    )


quarto::quarto_render(input = "./lecture-notes/alt-gis-tumorleri-sunum-2.qmd",
                      output_format = "all")




filestorender <- list.files(path = "./lecture-notes/", pattern = ".qmd", full.names = TRUE)

# file.exists(filestorender)

purrr::map(.x = filestorender,
           .f = quarto::quarto_render,
           output_format = "gfm"
           )

quarto::quarto_render(input = "./lecture-notes/pulmonary-infections.qmd",
                      output_format = "gfm")



purrr::map2( .x = filestorender,
             .y = c("revealjs", "gfm"),
             .f = quarto::quarto_render(input = .x, output_format = .y)
)



md_files <- list.files(path = './lecture-notes', pattern = '*\\.md', full.names = FALSE, recursive = TRUE)

md_files <- md_files[!grepl(pattern = "README", x = md_files)]

md_files <- gsub(pattern = "\\.md", replacement = "", x = md_files)

md_files_list <- purrr::map(
  .x = md_files,
  .f = ~ paste0(
    "[", .x , "](./lecture-notes/", .x , ".md)\n"
  )
)

readme_text <- paste0(unlist(md_files_list), collapse = "\n\n")

readme_text <- paste0("# Patoloji Ders Notları \n\n", readme_text)

writeLines(text = readme_text, con = "./lecture-notes/README.md")




quarto::quarto_render(input = "./lecture-notes/alt-gis-tumorleri.qmd",
                      output_format = "all")


quarto::quarto_render(input = "./lecture-notes/alt-gis-tumorleri.qmd",
                      output_format = "gfm")


quarto::quarto_render(input = filestorender,
                      output_format = "gfm")


quarto::quarto_render(input = filestorender,
                      output_format = "all")



