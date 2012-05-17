#' Reads the saved afm table, then registers those fonts with R.
#'
#' This must be run once in each R session.
#'
#' @export
setupPdfFonts <- function() {
  afmdata <- afm_load_table()

  for (family in unique(afmdata$FamilyName)) {
    famdata <- subset(afmdata, FamilyName == family)

    regular    <- subset(famdata, Bold == FALSE & Italic == FALSE)$afmfile
    bold       <- subset(famdata, Bold == TRUE  & Italic == FALSE)$afmfile
    italic     <- subset(famdata, Bold == FALSE & Italic == TRUE)$afmfile
    bolditalic <- subset(famdata, Bold == TRUE  & Italic == TRUE)$afmfile

    # There should be >1 entry for a given weight of a font only for weird
    # fonts like Apple Braille. Skip this iteration of the loop.
    if (length(regular) > 1  ||  length(bold)        > 1  ||
        length(italic)  > 1  ||  length(bolditalic) > 1) {
      next()
    }

    # There should be a regular entry for most every font. Exceptions
    # include Brush Script MT.
    if (length(regular) == 0) {
      warning("No regular (non-bold, non-italic) version of ", family,
              ". Skipping setup for this font.")
      next()
    }

    # If there aren't bold/italic entries, inherit the afm info from regular
    if (length(bold)      == 0)   bold       <- regular
    if (length(italic)    == 0)   italic     <- regular
    if (length(bolditalic) == 0)  bolditalic <- bold

    # Now we can register the font with R, with something like this:
    # pdfFonts("Arial" = Type1Font("Arial",
    #   file.path(afmpath, c("Arial.afm", "Arial Bold.afm",
    #                        "Arial Italic.afm", "Arial Italic.afm"))))
    message("Registering font with R using pdfFonts(): ", family)
    pdfFonts(family = Type1Font(family,
      file.path(afm_path(), c(regular, bold, italic, bolditalic))))
  }

}


# Scans all the .afm files and saves a csv file with information about them.
#' @export
afm_save_table <- function() {
  afmdata <- afm_scan_files()

  message("Saving afm table in ", afm_table_file())
  write.csv(afmdata, file = afm_table_file(), row.names = FALSE)
}


# Reads all the .afm files and builds a table of information about them. 
afm_scan_files <- function() {
  message("Scanning afm files in ", afm_path())
  afmfiles <- normalizePath(list.files(afm_path(), pattern = "\\.afm$", full.names=TRUE))

  # Build a table of information of all the afm files
  afmdata <- lapply(afmfiles, afm_get_info)
  afmdata <- do.call(rbind, afmdata)

  afmdata
}


# Read in font information from an .afm file
afm_get_info <- function(filename) {
  fd <- file(filename, "r")
  text <- readLines(fd, 30)  # Reading 30 lines should be more than enough
  close(fd)

  # Pull out the font names from lines like this:
  # FamilyName Arial
  # FontName Arial-ItalicMT
  # FullName Arial Italic
  FamilyName <- sub("^FamilyName ", "", text[grepl("^FamilyName", text)])
  FontName   <- sub("^FontName ",   "", text[grepl("^FontName",   text)])
  FullName   <- sub("^FullName ",   "", text[grepl("^FullName",   text)])

  # Read in the Weight field and figure out of it's Bold and/or Italic
  weight <- sub("^Weight ",   "", text[grepl("^Weight",   text)])
  if (grepl("Bold",   weight))  Bold = TRUE
  else                          Bold = FALSE

  if (grepl("Italic", weight))  Italic = TRUE
  else                          Italic = FALSE

  data.frame(FamilyName, FontName, FullName, afmfile = basename(filename),
             Bold, Italic, stringsAsFactors = FALSE)
}


afm_load_table <- function() {
  read.csv(afm_table_file(), stringsAsFactors = FALSE)
}
