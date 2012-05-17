# Borrowed this from staticdocs
inst_path <- function() {
  srcref <- attr(load_ttf_dir, "srcref")

  if (is.null(srcref)) {
    # Probably in package
    system.file(package = "extrafont")
  } else {
    # Probably in development
    file.path(dirname(dirname(attr(srcref, "srcfile")$filename)),
      "inst")
  }
}

# Path for the afm files
afm_path <- function() {
  file.path(inst_path(), "afm")
}

# Path for the Fontmap
fontmap_file <- function() {
  file.path(inst_path(), "fontmap", "Fontmap")
}