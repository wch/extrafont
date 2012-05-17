# Borrowed this from staticdocs
inst_path <- function() {
  srcref <- attr(inst_path, "srcref")

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

afm_table_file <- function() {
  file.path(inst_path(), "afm", "afm_table.csv")
}


fontmap_path <- function() {
  file.path(inst_path(), "Fontmap")
}

# Fontmap file
fontmap_file <- function() {
  file.path(fontmap_path(), "Fontmap")
}