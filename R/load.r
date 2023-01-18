#' Reads the fonttable database and registers those fonts with R
#'
#' This registers fonts so that they can be used with the pdf, postscript, or
#' Windows bitmap output device. It must be run once in each R session.
#'
#' @param device The output device. If \code{"all"}, then it will load
#'   \code{"pdf"}, \code{"postscript"}, and \code{"win"} (if on Windows).
#' @param quiet If \code{FALSE}, print a status message as each font is
#'   registered. If \code{TRUE}, don't print.
#'
#' @return A named list with up to three elements, one for each device for which
#'   fonts were loaded. Each device element is a named list, with an element for
#'   each family that was the function attempted to register with that device.
#'   The value is \code{NULL} if the function did not register the font family
#'   due to problems or because the font family was already registered. If value
#'   is the return value of \code{windowsFonts} for \code{"win"},
#'   \code{\link{postscriptFonts}} for \code{"postscript"}, and
#'   \code{\link{pdfFonts}} for \code{"pdf"}.
#'
#' @seealso \code{\link{embed_fonts}}, #ifdef windows
#'   \code{\link[grDevices]{windowsFont}}, \code{\link[grDevices]{windowsFonts}},
#'   #endif \code{\link{postscriptFonts}}, \code{\link{pdfFonts}},
#'   \code{\link{Type1Font}}.
#' @import grDevices
#' @export
loadfonts <- function(device = c("all", "pdf", "postscript", "win"),
                      quiet = FALSE) {

  device <- match.arg(device)
  if (device == "all") {
    if (.Platform$OS.type == "windows") {
      device <- c("pdf", "postscript", "win")
    } else {
      device <- c("pdf", "postscript")
    }
  }
  ret <- list()
  if ("win" %in% device) {
    ret[["win"]] <- loadfonts_win(quiet = quiet)
  }
  if ("pdf" %in% device) {
    ret[["pdf"]] <- loadfonts_pdf_ps(pdf = TRUE, quiet = quiet)
  }
  if ("postscript" %in% device) {
    ret[["postscript"]] <- loadfonts_pdf_ps(pdf = FALSE, quiet = quiet)
  }
  invisible(ret)
}

register_family_win <- function(family, quiet = FALSE, cfonts = character()) {
  ffname <- "windowsFonts"
  fontfunc <- windowsFonts
  # Now we can register the font with R, with something like this:
  # windowsFonts("Arial" = windowsFont("Arial"))
  if (family %in% cfonts) {
    if (!quiet) {
      message(family, " already registered with ", ffname, "().")
    }
    return(NULL)
  }
  if (!quiet) {
    message("Registering font with R using ", ffname, "(): ", family)
  }
  # Since 'family' is a string containing the name of the argument, we
  # need to use do.call
  args <- list()
  args[[family]] <- windowsFont(family)
  do.call(fontfunc, args)
}

loadfonts_win <- function(quiet = FALSE) {
  ffname <- "windowsFonts"
  if (.Platform$OS.type != "windows") {
    warning("OS is not Windows. No fonts registered with ", ffname, "().")
    return(NULL)
  }
  fontdata <- fonttable()
  # remove empty FamilyNames
  fontdata <- fontdata[fontdata$FamilyName != "", , drop = FALSE]
  cfonts <- names(windowsFonts())
  families <- unique(fontdata$FamilyName)
  lapply(families, register_family_win, cfonts = cfonts, quiet = quiet)
}

register_family_afm <- function(family, fd, pdf = TRUE, quiet = FALSE,
                                cfonts = character()) {
  if (pdf) {
    ffname <- "pdfFont"
    fontfunc <- pdfFonts
  } else {
    ffname <- "postscriptFont"
    fontfunc <- postscriptFonts
  }

  if (family %in% cfonts) {
    if (!quiet) {
      message(family, " already registered with ", ffname, "().")
    }
    return(NULL)
  }

  regular     <- fd$afmfile[!fd$Bold & !fd$Italic]
  bold        <- fd$afmfile[ fd$Bold & !fd$Italic]
  italic      <- fd$afmfile[!fd$Bold &  fd$Italic]
  bolditalic  <- fd$afmfile[ fd$Bold &  fd$Italic]

  # There should be >1 entry for a given weight of a font only for weird
  # fonts like Apple Braille. If found, skip this iteration of the loop.
  if (length(regular) > 1  ||  length(bold)       > 1  ||
      length(italic)  > 1  ||  length(bolditalic) > 1) {
    if (!quiet) {
      message("More than one version of regular/bold/italic found for ",
              family, ". Skipping setup for this font.")
    }
    return(NULL)
  }

  # There should be a regular entry for most every font. Exceptions
  # include Brush Script MT.
  if (length(regular) == 0) {
    if (!quiet) {
      message("No regular (non-bold, non-italic) version of ", family,
              ". Skipping setup for this font.")
    }
    return(NULL)
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
  if (!quiet) {
    message("Registering font with R using ", ffname, "(): ", family)
  }

  # Since 'family' is a string containing the name of the argument, we
  # need to use do.call
  args <- list()
  args[[family]] <-
    Type1Font(family, metrics = file.path(metrics_path(),
                                          c(regular, bold, italic,
                                            bolditalic, symbol)))
  do.call(fontfunc, args)
}

loadfonts_pdf_ps <- function(pdf = TRUE, quiet = FALSE) {
  if (pdf) {
    # Get names of fonts that are already registered
    cfonts <- names(pdfFonts())
  } else {
    cfonts <- names(postscriptFonts())
  }
  fontdata <- fonttable()
  # remove empty FamilyNames
  fontdata <- fontdata[fontdata$FamilyName != "", , drop = FALSE]
  # split fontdata into list of family data frames
  family_data <- split(fontdata, fontdata$FamilyName)
  mapply(register_family_afm, names(family_data), family_data,
         MoreArgs = list(pdf = pdf, quiet = quiet, cfonts = cfonts),
         SIMPLIFY = FALSE, USE.NAMES = TRUE)
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
#' \dontrun{
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

  # This code block is needed in R <= 2.15.2 because of a bug in embedFonts()
  if (getRversion() <= numeric_version("2.15.2")) {
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
  }

  fontmap <- fixpath_os(fontmap_path())

  # This is a hack to work around a bug in gs, as of version 9.05. When the
  # fontmap path contains "Resources", it causes a confusing error about
  # GenericResourceDir. On Macs, the default installation directory for R
  # packages contains "Resources" in the path, so this problem is common.
  # The workaround is to create a symlink to the fontmap path, which doesn't
  # contain "Resources".
  if (grepl("^darwin", R.version$os) && grepl("Resources", fontmap)) {
    tmpdir <- tempfile()
    file.symlink(fontmap, tmpdir)
    on.exit(file.remove(tmpdir))
    fontmap <- tmpdir
  }

  embedFonts(file = file, format = format, outfile = outfile,
    options = paste(
      paste("-I", shQuote(fontmap), sep = ""),
      options))
}
