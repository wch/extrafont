\name{loadfonts}
\alias{loadfonts}
\title{Reads the fonttable database and registers those fonts with R}
\usage{
  loadfonts(device = "pdf")
}
\arguments{
  \item{device}{The output device. Can be \code{"pdf"} (the
  default) or \code{"postscript"}.}
}
\description{
  This registers fonts so that they can be used with the
  pdf or postscript output device. It must be run once in
  each R session.
}

