\name{font_import}
\alias{font_import}
\title{Import system fonts}
\usage{
  font_import(paths = NULL, recursive = TRUE,
    prompt = TRUE)
}
\arguments{
  \item{paths}{A vector of directories to search in.
  (Default is to auto-detect based on OS)}

  \item{recursive}{Search recursively in directories?
  (Default TRUE)}

  \item{prompt}{Show confirmation prompt? (Default TRUE)}
}
\description{
  Presently only supports TrueType fonts.
}
\examples{
font_import()
}

