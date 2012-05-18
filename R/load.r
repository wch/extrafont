#' Reads the saved afm table, then registers those fonts with R.
#'
#' This must be run once in each R session.
#'
#' @export
setupPdfFonts <- function() {
  afmdata <- afm_load_table()

  for (family in unique(afmdata$FamilyName)) {
    # All entries for this family
    fd <- subset(afmdata, FamilyName == family)

    regular     <- fd$afmfile[!fd$Bold & !fd$Italic & !fd$Oblique]
    bold        <- fd$afmfile[ fd$Bold & !fd$Italic & !fd$Oblique]
    italic      <- fd$afmfile[!fd$Bold &  fd$Italic & !fd$Oblique]
    bolditalic  <- fd$afmfile[ fd$Bold &  fd$Italic & !fd$Oblique]
    # Some fonts have an oblique version (mutually exclusive with italic).
    # If italic is NOT present, we'll use oblique as the italic face.
    # If italic is present, we'll ignore oblique.
    oblique     <- fd$afmfile[!fd$Bold & !fd$Italic & fd$Oblique]
    boldoblique <- fd$afmfile[ fd$Bold & !fd$Italic & fd$Oblique]

    # There should be >1 entry for a given weight of a font only for weird
    # fonts like Apple Braille. If found, skip this iteration of the loop.
    if (length(regular) > 1  ||  length(bold)       > 1  ||
        length(italic)  > 1  ||  length(bolditalic) > 1  ||
        length(oblique) > 1  ||  length(boldoblique) > 1) {
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
    if (length(bold)       == 0)    bold      <- regular
    if (length(italic)     == 0) {
      if (length(oblique) == 1)     italic    <- oblique
      else                          italic    <- regular
    }
    if (length(bolditalic) == 0) {
      if (length(boldoblique) == 1) bolditalic <- boldoblique
      else                          bolditalic <- bold
    }

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
             options = paste("-I", shQuote(fixpath_os(fontmap_path())), sep = ""))
}
