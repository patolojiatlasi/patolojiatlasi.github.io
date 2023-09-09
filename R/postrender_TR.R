# if (dir.exists(paths = "./_freeze")) { fs::dir_copy(path = "./_freeze", new_path = "./_freeze_TR", overwrite = TRUE) }
# if (dir.exists(paths = "./_freeze")) { fs::dir_delete(path = "./_freeze") }
# if (dir.exists(paths = "./_docs/gitlab_atlas")) { fs::dir_delete(path = "./_docs/gitlab_atlas") }
# if (dir.exists(paths = "./_docs/EN")) { fs::dir_delete(path = "./_docs/EN") }
# if (dir.exists(paths = "./_docs/_EN")) { fs::dir_delete(path = "./_docs/_EN") }
# if (dir.exists(paths = "./_docs/_lecture-notes")) { fs::dir_delete(path = "./_docs/_lecture-notes") }
# if (dir.exists(paths = "./_docs/lecture-notes")) { fs::dir_delete(path = "./_docs/lecture-notes") }
# if (dir.exists(paths = "./_docs/EN")) { fs::dir_delete(path = "./_docs/EN") }
# if (dir.exists(paths = "./_docs/public")) {fs::dir_delete(path = "./_docs/public")}
# if (dir.exists(paths = "./_docs/gitlab_atlas")) {fs::dir_delete(path = "./_docs/gitlab_atlas")}
# folders_to_delete <- fs::dir_ls(path = "./_docs", recurse = FALSE, regexp = "_files$")
# fs::dir_delete(folders_to_delete)
# folders_to_delete <- fs::dir_ls(path = "./_docs", recurse = FALSE, regexp = "_pdf_")
# fs::dir_delete(folders_to_delete)
# folders_to_delete <- fs::dir_ls(path = "./_docs", recurse = FALSE, regexp = "_epub_")
# fs::dir_delete(folders_to_delete)
# folders_to_delete <- fs::dir_ls(path = "./_docs", recurse = FALSE, regexp = "_freeze")
# fs::dir_delete(folders_to_delete)
# if (dir.exists(paths = "./_docs")) { fs::dir_copy(path = "./_docs", new_path = "./gitlab_atlas/public", overwrite = TRUE) }
# if (dir.exists(paths = "./_docs")) { fs::dir_copy(path = "./_docs", new_path = "./docs", overwrite = TRUE) }
# if (dir.exists(paths = "./_docs")) { fs::dir_delete(path = "./_docs") }
# if (file.exists("./gitlab_atlas/public/CNAME")){fs::file_delete(path = "./gitlab_atlas/public/CNAME")}
# if (dir.exists(paths = "./docs/EN/lecture-notes")) { fs::dir_delete(path = "./docs/EN/lecture-notes") }
# folders_to_delete <- fs::dir_ls(path = ".", recurse = FALSE, regexp = "_files$")
# fs::dir_delete(folders_to_delete)
