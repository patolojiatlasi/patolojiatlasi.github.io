filestorender <- list.files(path = '.', pattern = '.md', full.names = TRUE, recursive = TRUE)
render_file <- purrr::safely(function(file) {rmarkdown::render(file, encoding = 'UTF-8', output_dir = './patoloji-hakkinda/')})
purrr::map(.x = filestorender, .f= render_file)


filestorender <- list.files(path = "./lecture-notes/", pattern = ".qmd", full.names = TRUE, recursive = TRUE)
purrr::map(.x = filestorender, .f= quarto::quarto_render)
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
