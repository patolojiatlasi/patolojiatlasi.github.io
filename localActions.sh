# sh '/Users/serdarbalci/Documents/GitHub/patolojiatlasi.github.io/localActions.sh'
Rscript -e 'if (!requireNamespace("xfun", quietly = TRUE)) {install.packages("xfun")}'
Rscript -e 'if (!requireNamespace("quarto", quietly = TRUE)) {install.packages("quarto")}'
Rscript -e 'if (!requireNamespace("fs", quietly = TRUE)) {install.packages("fs")}'
Rscript -e 'fs::file_copy(path = "./_quarto_EN.yml", new_path = "./_quarto.yml", overwrite = TRUE)'
Rscript -e 'fs::file_copy(path = "./R/languageEN.R", new_path = "./R/language.R", overwrite = TRUE)'
Rscript -e 'quarto::quarto_render(".", as_job = FALSE)'
Rscript -e 'if (file.exists("./EN/CNAME")){fs::file_delete(path = "./EN/CNAME")}'
Rscript -e 'fs::file_copy(path = "./_quarto_TR.yml", new_path = "./_quarto.yml", overwrite = TRUE)'
Rscript -e 'fs::file_copy(path = "./R/languageTR.R", new_path = "./R/language.R", overwrite = TRUE)'
Rscript -e 'quarto::quarto_render(".", as_job = FALSE)'
Rscript -e 'fs::dir_copy(path = "./EN", new_path = "./docs/EN", overwrite = TRUE)'
act --secret-file ~/my.secrets
git add .
git commit -m "WIP local render added changes `date +'%Y-%m-%d %H:%M:%S'`" # WIP ifadesi eklenirse github actions çalışmaz.
git commit -m "local render added changes `date +'%Y-%m-%d %H:%M:%S'`"
git push origin main
