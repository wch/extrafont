#' Import system fonts
#'
#' Presently only supports TrueType fonts.
#'
#' @export
font_import <- function() {
  ttf_import()
}

#' Import font from an installed package
#'
#' @param pkg The name of the font package, e.g., \code{"fontcm"}.
#' @export
font_addpackage <- function(pkg = NULL) {
  if(is.null(pkg)) stop("No package specified.")

  pkgdir <- system.file(package = pkg)

  if (length(list.files(file.path(pkgdir, "fonts", "metrics"), "*.afm")) > 0) {
    # It's a type1 (postscript) package
    type1_import(pkgdir)

  } else if(length(list.files(file.path(pkgdir, "fonts"), "*.ttf")) > 0) {
    # It's a ttf package
    # TODO: Implement this
    stop("ttf font package import not yet implemented.")

  } else {
    stop("Unknown font package type: not type1 or ttf.")
  }

  generate_fontmap_file()
}


# TODO: move fontmap stuff out and modularize
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

#' Show the fonts that are in the font table (and available for embedding)
#'
#' @export
fonts <- function() {
  unique(font_load_table()$FamilyName)
}

#' Returns the full font table
#'
#' @export
font_load_table <- function() {
  if (!file.exists(font_table_file()))
    return(data.frame())

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
