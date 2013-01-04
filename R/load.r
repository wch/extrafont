#' Reads the fonttable database and registers those fonts with R
#'
#' This registers fonts so that they can be used with the pdf,
#' postscript, or Windows bitmap output device. It must be run
#' once in each R session.
#'
#' @param device The output device. Can be \code{"pdf"} (the default),
#'   \code{"postscript"}, or \code{"win"}.
#' @param quiet If \code{FALSE}, print a status message as each font
#'   is registered. If \code{TRUE}, don't print.
#'
#'
#' @seealso \code{\link{embed_fonts}}
#' @import grDevices
#' @export
loadfonts <- function(device = "pdf", quiet = FALSE) {
  fontdata <- fonttable()

  if (device == "pdf") {
    # Get names of fonts that are already registered
    cfonts   <- names(pdfFonts())
    ffname   <- "pdfFonts"
  } else if (device == "postscript") {
    cfonts   <- names(postscriptFonts())
    ffname   <- "postscriptFonts"
  } else if (device == "win") {
    cfonts   <- names(windowsFonts())
    ffname   <- "windowsFonts"
  } else {
    stop("Unknown device: ", device)
  }

  fontfunc <- match.fun(ffname)

  if (device %in% c("pdf", "postscript")) {
    for (family in unique(fontdata$FamilyName)) {
      if (family %in% cfonts) {
        if (!quiet)
          message(family, " already registered with ", ffname, "().")

        next()
      }

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
      if (!quiet)
        message("Registering font with R using ", ffname, "(): ", family)

      # Since 'family' is a string containing the name of the argument, we
      # need to use do.call
      args <- list()
      args[[family]] <- Type1Font(family,
                          metrics = file.path(metrics_path(),
                            c(regular, bold, italic, bolditalic, symbol)))
      do.call(fontfunc, args)
    }

  } else if (device == "win") {
    for (family in unique(fontdata$FamilyName)) {
      if (family %in% cfonts) {
        if (!quiet)
          message(family, " already registered with ", ffname, "().")

        next()
      }

      # All entries for this family
      fd <- fontdata[fontdata$FamilyName == family, ]

      # Now we can register the font with R, with something like this:
      # windowsFonts("Arial" = windowsFont("Arial"))
      if (!quiet)
        message("Registering font with R using ", ffname, "(): ", family)

      # Since 'family' is a string containing the name of the argument, we
      # need to use do.call
      args <- list()
      args[[family]] <- windowsFont(family)
      do.call(fontfunc, args)
    }
  }
}


#' Embeds fonts that are listed in the local Fontmap
#'
#' @param file Name of input file.
#' @param outfile Name of the output file (with fonts embedded). (Default is same as input file)
#' @param format File format. (see \code{?embedFonts})
#' @param options Other arguments passed to \code{embedFonts}.
#'
#' @examples
#'
#' \donttest{
#' loadfonts()
#' pdf('fonttest.pdf')
#' library(ggplot2)
#'
#' p <- ggplot(mtcars, aes(x=wt, y=mpg)) + geom_point()
#'
#' # Run only the code below that is appropriate for your system
#' # On Mac and Windows, Impact should be available
#' p + opts(axis.title.x=theme_text(size=16, family="Impact", colour="red"))
#'
#' # On Linux, Purisa may be available
#' p + opts(axis.title.x=theme_text(size=16, family="Purisa", colour="red"))
#' dev.off()
#'
#' embed_fonts('fonttest.pdf', outfile='fonttest-embed.pdf')
#' }
#'
#' @seealso \code{\link{loadfonts}}
#' @export
embed_fonts <- function(file, format, outfile = file, options = "") {
  # This type detection code is necessary because of a bug in embedFonts where
  # it does not correctly detect file type when there are space in the filename.
  # https://bugs.r-project.org/bugzilla3/show_bug.cgi?id=15149
  if (missing(format)) {
    suffix <- gsub(".+[.]", "", file)
    format <- switch(suffix, ps = , eps = "pswrite", pdf = "pdfwrite")
  }

  # To handle spaces, the input file can have quotes, but the output file
  # shouldn't for some reason. We need to force evaluation here; if not, then
  # lazy evaluation will result in outfile having quotes because of the change
  # to file, below.
  force(outfile)

  # Quote filenames so that spaces will work
  file <- shQuote(file)

  embedFonts(file = file, format = format, outfile = outfile,
    options = paste(
      paste("-I", shQuote(fixpath_os(fontmap_path())), sep = ""),
      options))
}
