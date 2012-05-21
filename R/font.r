# Merges information from fontmap and afm data, and saves it to font table
font_save_table <- function(fontmap = NULL) {
  if(is.null(fontmap))
    stop("fontmap must not be NULL")

  afmdata <- afm_scan_files()

  # The .enc files should have the same base name as the .afm files
  afmdata$encfile <- sub("\\.afm$", ".enc", afmdata$afmfile)
  # Check that each .enc file exists; if not, set to NA
  afmdata$encfile[!file.exists(file.path(metrics_path(), afmdata$encfile))] <- NA

  # Merge the fontfile - FontName mapping, and the info extracted from 
  # the afm files
  fontdata <- merge(fontmap, afmdata)

  message("Saving font table in ", font_table_file())
  write.csv(fontdata, file = font_table_file(), row.names = FALSE)
}

#' Show the fonts that are in the font table (and available for embedding)
#'
#' @export
fonts <- function() {
  unique(font_load_table()$FamilyName)
}

#' @export
font_load_table <- function() {
  if (!file.exists(font_table_file()))
    stop("Can't find ", font_table_file(), ". Have you run ttf_import()?")

  read.csv(font_table_file(), stringsAsFactors = FALSE)
}


# Writes the Fontmap file for use by Ghostscript when embedding fonts
# Loads the data from the font table
generate_fontmap_file <- function() {
  fontdata <- font_load_table()
  outfile <- fontmap_file()

  message("Writing Fontmap to ", outfile, "...")
  # Output format is:
  # /Arial-BoldMT (/Library/Fonts/Arial Bold.ttf) ;
  # For Windows, it works with a '/', or a '\\':
  # /Arial-BoldMT (C:/Windows/Fonts/Arial Bold.ttf) ;
  writeLines(
    paste("/", fontdata$FontName, " (", escapepath_os(fontdata$fontfile),
      ") ;", sep=""),
    outfile)
}
