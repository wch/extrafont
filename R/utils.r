# Borrowed this from staticdocs
inst_path <- function() {
  envname <- environmentName(parent.env(environment()))

  # If installed in package, envname == "extrafont"
  # If loaded with load_all, envname == "package:extrafont"
  # (This is kind of strange)
  if (envname == "extrafont") {
    system.file(package = "extrafont")
  } else {
    srcfile <- attr(attr(inst_path, "srcref"), "srcfile")
    file.path(dirname(dirname(srcfile$filename)), "inst")
  }
}


# Get the path where extrafontdb is installed
db_path <- function() {
  system.file(package = "extrafontdb")
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
  if (grepl("^mingw", R.version$os)) {
    gsub("/", "\\\\", path)
  } else {
    path
  }
}

# Escape separators if on windows
# This is needed because in windows, sometimes the paths have '\'
# and they need to be escaped by replacing them with '\\'.
escapepath_os <- function(path) {
  if (grepl("^mingw", R.version$os)) {
  # The reason it looks like it's replacing '\\\\' with '\\\\\\\' is that
  # the strings get escaped twice. So this really replaces '\' with '\\'.
  gsub("\\\\", "\\\\\\\\", path)

  } else {
    path
  }
}

# gzip a file
#
# @param src Source filename.
# @param dest Destination filename. Defaults to source filename with .gz
# @param delete Delete the source file when done?
# Currently the maximum file size is 100MB
gzcopy <- function(src, dest = NULL, delete = FALSE) {
  srcfile <- file(src, "rb")
  srcdat <- readBin(srcfile, "raw", n = 1e8)
  close(srcfile)

  # Add .gz if destination file is not specified
  if (is.null(dest))  dest <- paste(src, ".gz", sep = "")

  destfile <- gzfile(dest, "wb")
  writeBin(srcdat, destfile)
  close(destfile)

  if (delete)  unlink(src)
}

# gzip a file, excluding certain lines
#
# @param src Source filename.
# @param dest Destination filename. Defaults to source filename with .gz
# @param delete Delete the source file when done?
# Currently the maximum file size is 100MB
gzcopy_exclude <- function(src, dest = NULL, delete = FALSE, 
                           exclusions = NULL) {
  # read in text mode so we can parse
  srcfile <- file(src, "r")
  srcdat <- readLines(srcfile, n = 1e8)
  close(srcfile)

  # remove any line matching an exclusion pattern
  notexcluded <- rep(TRUE, length(srcdat))
  for (exclusion in exclusions){
      notexcluded[grepl(exclusion, srcdat, useBytes = TRUE)] <- FALSE
  }
  srcdat <- srcdat[notexcluded]

  # Add .gz if destination file is not specified
  if (is.null(dest))  dest <- paste(src, ".gz", sep = "")

  destfile <- gzfile(dest, "w")
  writeLines(srcdat, con = destfile)
  close(destfile)

  if (delete)  unlink(src)
}
