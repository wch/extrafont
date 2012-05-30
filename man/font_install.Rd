\name{font_install}
\alias{font_install}
\title{Install a font package and register it in the fonts database}
\usage{
  font_install(fontpkg = NULL, prompt = TRUE)
}
\arguments{
  \item{fontpkg}{The name of an R package containing a
  font, e.g., \code{"fontcm"}.}

  \item{prompt}{Ask user to install font from CRAN if not
  already installed}
}
\description{
  If the font package specified by \code{fontpkg} is not
  already installed, it will be downloaded from CRAN. The
  font package will then be registered in the fonts
  database.
}
\examples{
\donttest{
font_install('fontcm')
}
}

