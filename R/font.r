#' Import system fonts
#'
#' Presently only supports TrueType fonts.
#'
#' @param paths A vector of directories to search in. (Default is to auto-detect based on OS)
#' @param recursive Search recursively in directories? (Default TRUE)
#' @param prompt Show confirmation prompt? (Default TRUE)
#'
#' @examples
#' font_import()
#'
#' @export
font_import <- function(paths = NULL, recursive = TRUE, prompt = TRUE) {

  if (prompt) {
    resp <- readline("Importing fonts may take a few minutes, depending on the number of fonts and the speed of the system. Continue? [y/n] ")
    if (tolower(resp) != "y") {
      message("Exiting.")
      return(invisible())
    }
  }

  ttf_import(paths, recursive)
}


#' Install a font package and register it in the fonts database
#'
#' If the font package specified by \code{fontpkg} is not already installed,
#' it will be downloaded from CRAN. The font package will then be registered
#' in the fonts database.
#'
#' @param fontpkg The name of an R package containing a font, e.g., \code{"fontcm"}.
#' @param prompt Ask user to install font from CRAN if not already installed
#'
#' @examples
#' \donttest{
#' font_install('fontcm')
#' }
#'
#' @export
font_install <- function(fontpkg = NULL, prompt = TRUE) {
  if (is.null(fontpkg))
    stop("fontpkg must be specified.")

  # Check if font package already installed
  if (is.element(fontpkg, installed.packages()[,1])) {
    message('Package "', fontpkg, '" already installed.')
  } else {
    # Not installed; try to install from cran
    if (prompt) {
      resp <- readline(paste('Package "', fontpkg, 
        '" not installed. Would you like to install it from CRAN? [y/n] ',
        sep = ""))
      if (tolower(resp) != "y") {
        message("Exiting.")
        return(invisible())
      }
    }

    message('Attempting to install "', fontpkg, '" from CRAN...')
    install.packages(fontpkg)

    if (!is.element(fontpkg, installed.packages()[,1]))
      stop('Package "', fontpkg, '" not successfully installed.')
  }


  # Check if font needs to be registered with fonts db
  # (and do it if needed.)
  message('Registering font package "', fontpkg, '" with fonts.')
  font_addpackage(fontpkg)

}


#' Add font from an installed package to fonts database
#'
#' This is usually not called directly, but via \code{\link{font_install}}.
#'
#' @param pkg The name of the font package, e.g., \code{"fontcm"}.
#' @seealso \code{\link{font_install}}
#'
#' @export
font_addpackage <- function(pkg = NULL) {
  if(is.null(pkg)) stop("No package specified.")

  # Check if font package already added
  ft <- fonttable()
  # need the isTRUE in case ft$package is all NA
  if (isTRUE(any(ft$package == pkg))) {
    message('Font package "', pkg, '" already registered in fonts database.')
    return(invisible())
  }

  pkgdir <- system.file(package = pkg)

  if (length(list.files(file.path(pkgdir, "fonts", "metrics"), "*.afm")) > 0) {
    # It's a type1 (postscript) package
    type1_import(pkgdir, pkgname = pkg)

  } else if(length(list.files(file.path(pkgdir, "fonts"), "*.ttf")) > 0) {
    # It's a ttf package
    # TODO: Implement this
    stop("ttf font package import not yet implemented.")

  } else {
    stop("Unknown font package type: not type1 or ttf.")
  }

}
