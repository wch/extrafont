#' Choose an installed font from a list
#'
#' For a sequence of font family names, return the first one
#' installed on the system. This makes it easy for code to specify a
#' preferred font-family, but fall back to other font families if
#' that is not installed on the system. This function acts much like
#' the CSS font-family property.
#'
#' @param fonts \code{character} List of font family names to try.
#' @param quiet \code{logical} Do not print warning if the preferred
#' font not found.
#' @return \code{character}. First font in \code{fonts} that is installed
#' on the system or \code{""} if none of those are installed.
#' @export
#' @examples
#' choose_font(c("GillSans",  "Verdana", "sans"), quiet=TRUE)
#' choose_font(c("BemeboStd", "Garamond", "serif"), quiet=TRUE)
choose_font <- function(fonts, quiet=TRUE) {
  fonts <- c(fonts, "")
  installed <- c(fonts(), "")
  touse <- fonts[fonts %in% installed][1]
  if (!quiet && (touse != fonts[1])) {
    warning(sprintf("Font family '%s' not installed, using '%s' instead",
                    fonts[1], touse))
  }
  touse
}
