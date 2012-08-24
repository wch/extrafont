
# Reads all the .afm (and .afm.gz) files and builds a table of information about them.
afm_scan_files <- function(path = NULL) {
  if (is.null(path))  path <- metrics_path()

  message("Scanning afm files in ", path)
  afmfiles <- normalizePath(list.files(path, pattern = "\\.afm(\\.gz)?$",
                              full.names = TRUE, ignore.case = TRUE))

  # Build a table of information of all the afm files
  afmdata <- lapply(afmfiles, afm_get_info)
  afmdata <- do.call(rbind, afmdata)

  afmdata
}


# Read in font information from an .afm file
afm_get_info <- function(filename) {
  if (grepl("\\.gz", filename)) {
    fd <- gzfile(filename, "r")
  } else {
    fd <- file(filename, "r")
  }
  text <- readLines(fd, 30)  # Reading 30 lines should be more than enough
  close(fd)

  # Pull out the font names from lines like this:
  # FamilyName Arial
  # FontName Arial-ItalicMT
  # FullName Arial Italic
  FamilyName <- sub("^FamilyName ", "", text[grepl("^FamilyName", text)])
  FontName   <- sub("^FontName ",   "", text[grepl("^FontName",   text)])
  FullName   <- sub("^FullName ",   "", text[grepl("^FullName",   text)])
  weight     <- sub("^Weight ",   "", text[grepl("^Weight",   text)])

  # Read in the Weight and figure out of it's Bold
  if (grepl("Bold", weight)) {
    Bold <- TRUE
  } else {
    Bold <- FALSE
  }

  # Lots of special cases.
  # Sometimes Italic is indicated in weight; for some fonts, it's Oblique.
  # For other fonts (like CM), Italic is indicated in FontName, and
  # sometimes it's Slanted.
  if (grepl("Italic", weight) || grepl("Oblique", weight) ||
      grepl("Italic", FontName) || grepl("Slanted", FontName)) {
    Italic <- TRUE
  } else {
    Italic <- FALSE
  }

  if (grepl("Symbol", FamilyName))
    Symbol <- TRUE
  else
    Symbol <- FALSE

  data.frame(FamilyName, FontName, FullName, afmfile = basename(filename),
             Bold, Italic, Symbol, afmsymfile = NA, stringsAsFactors = FALSE)
}
