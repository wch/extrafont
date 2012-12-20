.onAttach <- function(libname, pkgname) {
    packageStartupMessage("Registering fonts with R")

    ## Load all fonts
    loadfonts("pdf", quiet = TRUE)
    loadfonts("postscript", quiet = TRUE)
    if (.Platform$OS.type == "windows") {
        loadfonts("win", quiet = TRUE)
    }
}
