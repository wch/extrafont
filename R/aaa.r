.onAttach <- function(libname, pkgname) {
    packageStartupMessage("Registering fonts with R")

    ## Load all fonts
    loadfonts("all", quiet = TRUE)
}
