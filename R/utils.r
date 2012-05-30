# Borrowed this from staticdocs
inst_path <- function() {
  envname <- environmentName(environment(inst_path))

  # If installed in package, envname == "fonts"
  # If loaded with load_all, envname == "package:fonts"
  # (This is kind of strange)
  if (envname == "fonts") {
    system.file(package = "fonts")
  } else {
    srcfile <- attr(attr(inst_path, "srcref"), "srcfile")
    file.path(dirname(dirname(srcfile$filename)), "inst")
  }
}


# Get the path where fontsdb is installed
db_path <- function() {
  system.file(package = "fontsdb")
}

# Path for the afm files
metrics_path <- function() {
  file.path(db_path(), "metrics")
}

# fonttable file
fonttable_file <- function() {
  file.path(fontmap_path(), "fonttable.csv")
}

# Path of fontmap directory
fontmap_path <- function() {
  file.path(db_path(), "fontmap")
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
