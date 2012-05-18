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
    if (length(regular) > 1  ||  length(bold)       > 1  ||
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
    if (length(bold)       == 0)   bold      <- regular
    if (length(italic)     == 0)   italic    <- regular
    if (length(bolditalic) == 0)  bolditalic <- bold

    # Now we can register the font with R, with something like this:
    # pdfFonts("Arial" = Type1Font("Arial",
    #   file.path(afmpath, c("Arial.afm", "Arial Bold.afm",
    #                        "Arial Italic.afm", "Arial Italic.afm"))))
    message("Registering font with R using pdfFonts(): ", family)
    # Since 'family' is a string containing the name of the argument, we
    # need to use do.call
    args <- list()
    args[[family]] <- Type1Font(family, file.path(afm_path(),
                        c(regular, bold, italic, bolditalic)))
    do.call(pdfFonts, args)
  }

}


#' Embeds fonts that are listed in the local Fontmap
#'
#' @export
embedExtraFonts <- function(file, format, outfile = file, options = "") {
  embedFonts(file = file, format = format, outfile = outfile,
             options = paste("-I", fontmap_path(), sep = ""))
}
