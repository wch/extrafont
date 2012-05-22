\name{font_install}
\alias{font_install}
\title{Install a font package and register it with extrafont}
\usage{
  font_install(fontpkg = NULL)
}
\arguments{
  \item{fontpkg}{The name of an R package containing a
  font.}
}
\description{
  If the font package specified by \code{fontpkg} is not
  already installed, it will be downloaded from CRAN. The
  font package will then be registered with extrafont.
}

