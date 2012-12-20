# Functions related to the font table

#' Show the fonts that are registered in the font table
#' (and available for embedding)
#'
#' @export
fonts <- function() {
  unique(fonttable()$FamilyName)
}


#' Returns the full font table
#'
#' @importFrom utils read.csv
#' @export
fonttable <- function() {
  if (!file.exists(fonttable_file()))
    return(data.frame())

  utils::read.csv(fonttable_file(), stringsAsFactors = FALSE)
}


# Add to the font table.
# When append is TRUE, add to the table. When FALSE, overwrite table.
fonttable_add <- function(fontdata = NULL, append = TRUE) {
  if(is.null(fontdata) || nrow(fontdata) == 0)
    return(invisible())

  cols <- c("package", "afmfile", "fontfile", "FullName", "FamilyName",
            "FontName", "Bold", "Italic", "Symbol", "afmsymfile")

  if (!all(sort(cols) == sort(names(fontdata)))) {
    stop("Column names do not match. Expected: ", paste(cols, collapse=" "),
         ".\nActual: ", paste(names(fontdata), collapse=" "))
  }

  ft <- rbind(fonttable(), fontdata)

  # Arrange the columns
  ft<- ft[, cols]

  message("Writing font table in ", fonttable_file())
  write.csv(ft, file = fonttable_file(), row.names = FALSE)

  # Update the Fontmap file
  generate_fontmap_file()
}


# Writes the Fontmap file for use by Ghostscript when embedding fonts
# Loads the data from the font table
generate_fontmap_file <- function() {
  fontdata <- fonttable()
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
