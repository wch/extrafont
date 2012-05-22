#' Reads the saved afm table, then registers those fonts with R.
#'
#' This must be run once in each R session.
#'
#' @export
setupPdfFonts <- function() {
  fontdata <- fonttable_load()

  for (family in unique(fontdata$FamilyName)) {
    # All entries for this family
    fd <- fontdata[fontdata$FamilyName == family, ]

    regular     <- fd$afmfile[!fd$Bold & !fd$Italic]
    bold        <- fd$afmfile[ fd$Bold & !fd$Italic]
    italic      <- fd$afmfile[!fd$Bold &  fd$Italic]
    bolditalic  <- fd$afmfile[ fd$Bold &  fd$Italic]

    # There should be >1 entry for a given weight of a font only for weird
    # fonts like Apple Braille. If found, skip this iteration of the loop.
    if (length(regular) > 1  ||  length(bold)       > 1  ||
        length(italic)  > 1  ||  length(bolditalic) > 1) {
      warning("More than one version of regular/bold/italic found for ",
              family, ". Skipping setup for this font.")
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
    if (length(bold)       == 0) bold       <- regular
    if (length(italic)     == 0) italic     <- regular
    if (length(bolditalic) == 0) bolditalic <- bold


    # If there's an afmsymfile entry, use that as the symbol font
    # Also check that all in this family have the same afmsymfile entry
    if (!is.na(fd$afmsymfile[1]) && fd$afmsymfile[1] != ""  &&
        all(fd$afmsymfile[1] == fd$afmsymfile)) {
      symbol <- fd$afmsymfile[1]
    } else {
      symbol <- NULL
    }

    # Now we can register the font with R, with something like this:
    # pdfFonts("Arial" = Type1Font("Arial",
    #   file.path(afmpath, c("Arial.afm", "Arial Bold.afm",
    #                        "Arial Italic.afm", "Arial Italic.afm"))))
    message("Registering font with R using pdfFonts(): ", family)

    # Since 'family' is a string containing the name of the argument, we
    # need to use do.call
    args <- list()
    args[[family]] <- Type1Font(family,
                        metrics = file.path(metrics_path(),
                          c(regular, bold, italic, bolditalic, symbol)))
    do.call(pdfFonts, args)
  }

}


#' Embeds fonts that are listed in the local Fontmap
#'
#' @param file Name of input file.
#' @param outfile Name of the output file (with fonts embedded). (Default is same as input file)
#' @param format File format. (see \code{?embedFonts})
#' @param options Other arguments passed to \code{embedFonts}.
#'
#' @export
embedExtraFonts <- function(file, format, outfile = file, options = "") {
  embedFonts(file = file, outfile = outfile,
    options = paste(
      paste("-I", shQuote(fixpath_os(fontmap_path())), sep = ""),
      options))
}
