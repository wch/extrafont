# Merges information from fontmap and afm data, and saves it to font table
font_save_table <- function(fontmap = NULL) {
  if(is.null(fontmap))
    stop("fontmap must not be NULL")

  afmdata <- afm_scan_files()

  # Merge the fontfile - FontName mapping, and the info extracted from 
  # the afm files
  fontdata <- merge(fontmap, afmdata)

  message("Saving font table in ", font_table_file())
  write.csv(fontdata, file = font_table_file(), row.names = FALSE)
}


#' @export
font_load_table <- function() {
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
