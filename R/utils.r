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


# Fix path separators if on windows, for shell commands
# This is needed because file.path() returns paths with '/' separators, even
# on Windows. But when calling shell commands, they often need '\' instead.
fixpath_os <- function(path) {
  if (grepl("^mingw", sessionInfo()$R.version$os)) {
  gsub("/", "\\\\", path)

  } else {
    path
  }
}

# Escape separators if on windows
# This is needed because in windows, sometimes the paths have '\'
# and they need to be escaped by replacing them with '\\'.
escapepath_os <- function(path) {
  if (grepl("^mingw", sessionInfo()$R.version$os)) {
  # The reason it looks like it's replacing '\\\\' with '\\\\\\\' is that
  # the strings get escaped twice. So this really replaces '\' with '\\'.
  gsub("\\\\", "\\\\\\\\", path)

  } else {
    path
  }
}
