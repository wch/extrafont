# Functions related to the font table

#' Show the fonts that are in the font table (and available for embedding)
#'
#' @export
fonts <- function() {
  unique(fonttable_load()$FamilyName)
}


#' Returns the full font table
#'
#' @export
fonttable_load <- function() {
  if (!file.exists(fonttable_file()))
    return(data.frame())

  read.csv(fonttable_file(), stringsAsFactors = FALSE)
}


# Add to the font table.
# When append is TRUE, add to the table. When FALSE, overwrite table.
fonttable_add <- function(fontdata = NULL, append = TRUE) {
  if(is.null(data)) return(invisible())

  ft <- rbind(fonttable_load(), fontdata)

  # Arrange the columns
  ft<- ft[, c("afmfile", "fontfile", "FullName", "FamilyName",
              "FontName", "Bold", "Italic", "Symbol", "afmsymfile")]

  message("Writing font table in ", fonttable_file())
  write.csv(ft, file = fonttable_file(), row.names = FALSE)

  # Update the Fontmap file
  generate_fontmap_file()
}


# Writes the Fontmap file for use by Ghostscript when embedding fonts
# Loads the data from the font table
generate_fontmap_file <- function() {
  fontdata <- fonttable_load()
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
