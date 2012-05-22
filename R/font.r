#' Import system fonts
#'
#' Presently only supports TrueType fonts.
#'
#' @export
font_import <- function(paths = NULL, recursive = TRUE, prompt = TRUE) {
  ttf_import(paths, recursive, prompt)
}


#' Install a font package and register it with extrafont
#'
#' If the font package specified by \code{fontpkg} is not already installed,
#' it will be downloaded from CRAN. The font package will then be registered
#' with extrafont.
#'
#' @param fontpkg The name of an R package containing a font.
#'
#' @export
font_install <- function(fontpkg = NULL) {
  if (is.null(fontpkg))
    stop("fontpkg must be specified.")

  # Check if font package already installed
  if (is.element(fontpkg, installed.packages()[,1])) {
    message('Package "', fontpkg, '" already installed.')
  } else {
    # Not installed; try to install from cran
    message('Package "', fontpkg, '" not installed. Attempting to install from CRAN...')
    install.packages(fontpkg)

    if (!is.element(fontpkg, installed.packages()[,1]))
      stop('Package "', fontpkg, '" not successfully installed.')
  }


  # Check if font needs to be registered with extrafont
  # (and do it if needed.)
  message('Registering font package "', fontpkg, '" with extrafont.')
  font_addpackage(fontpkg)

}


#' Add font from an installed package to extrafont's registry
#'
#' @param pkg The name of the font package, e.g., \code{"fontcm"}.
#' @export
font_addpackage <- function(pkg = NULL) {
  if(is.null(pkg)) stop("No package specified.")

  # Check if font package already added
  ft <- fonttable_load()
  if (any(ft$package == pkg)) {
    message('Font package "', pkg, '" already registered with extrafont.')
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
