.onAttach <- function(libname, pkgname) {
    ## Load all fonts
    loadfonts("pdf")
    loadfonts("postscript")
    if (.Platform$OS.type == "windows") {
        loadfonts("win")
    }
}
