# if (!requireNamespace("remotes", quietly = TRUE)) {install.packages("remotes", dependencies = TRUE, quiet = TRUE, verbose = FALSE)}
# remotes::install_deps(dependencies = TRUE)
# if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv", dependencies = TRUE, quiet = TRUE, verbose = FALSE)
# renv::restore()
# if (!requireNamespace("fs", quietly = TRUE)) install.packages("fs", dependencies = TRUE, quiet = TRUE, verbose = FALSE)
# if (!requireNamespace("quarto", quietly = TRUE)) install.packages("quarto", dependencies = TRUE, quiet = TRUE, verbose = FALSE)
# if (!requireNamespace("xfun", quietly = TRUE)) {install.packages("xfun", dependencies = TRUE, quiet = TRUE, verbose = FALSE)}
# if (!requireNamespace("readxl", quietly = TRUE)) {install.packages("readxl", dependencies = TRUE, quiet = TRUE, verbose = FALSE)}
# if (!requireNamespace("tinytex", quietly = TRUE)) {install.packages("tinytex, dependencies = TRUE, quiet = TRUE, verbose = FALSE")}
# if (!tinytex::is_tinytex()) {tinytex::install_tinytex()}


folders_to_delete <- fs::dir_ls(path = ".", recurse = FALSE, regexp = "_files$")
fs::dir_delete(folders_to_delete)
if (dir.exists(paths = "./gitlab_atlas/gitlab_atlas")) { fs::dir_delete(path = "./gitlab_atlas/gitlab_atlas") }
if (dir.exists(paths = "./gitlab_atlas/public")) { fs::dir_delete(path = "./gitlab_atlas/public") }

if (dir.exists(paths = "./docs")) { fs::dir_delete(path = "./docs") }
# if (dir.exists(paths = "./_freeze")) {fs::dir_delete(path = "./_freeze")}

# if (dir.exists(paths = "./_freeze")) { fs::dir_delete(path = "./_freeze") }
# if (dir.exists(paths = "./_freeze_TR")) { fs::dir_copy(path = "./_freeze_TR", new_path = "./_freeze", overwrite = TRUE) }
# fs::file_copy(path = "./_quarto_TR.yml", new_path = "./_quarto.yml", overwrite = TRUE)
fs::file_copy(path = "./R/languageTR.R", new_path = "./R/language.R", overwrite = TRUE)

# Generate format-specific chapter YAML files from base chapters
source("./R/generate-chapter-yamls.R")
generate_all_chapter_yamls("TR")

source("./R/extract-html-links.R")


