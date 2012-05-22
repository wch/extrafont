#' Import system fonts
#'
#' Presently only supports TrueType fonts.
#'
#' @export
font_import <- function(paths = NULL, recursive = TRUE, prompt = TRUE) {
  ttf_import(paths, recursive, prompt)
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

}


