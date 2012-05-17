# TODO:
# - Add function for converting a single TrueType font by name

# Load all .ttf fonts from a directory.
# This does the following:
# - Create afm files in extrafont/inst/afm (or extrafont/afm when extrafont
#   is properly installed as a package)
# - Create a Fontmap file
# TODO: Modularize font search path (for other platforms)
load_ttf_dir <- 
  function(paths = c("/Library/Fonts", "/System/Library/Fonts")) {

  ttfiles <- normalizePath(list.files(paths, pattern = ".ttf$", full.names=TRUE))

  # Extract afm files
  ttf_extract_afm(ttfiles)

  # Build fontmap

}



#' Extract afm files from TrueType fonts.
ttf_extract_afm <- function(ttfiles) {

  # First find the conversion utility
  if (.Platform$OS.type == "unix") {
    ttf2afm <- Sys.which("ttf2afm")
    ttf2pt1 <- Sys.which("ttf2pt1")
  } else if (.Platform$OS.type == "windows") {
    # TODO: Check that these are the correct names in Windows
    ttf2afm <- Sys.which("ttf2afm.exe")
    ttf2pt1 <- Sys.which("ttf2pt1.exe")
  } else {
    error("Unknown platform: ", .Platform$OS.type)
  }

  if (!nzchar(ttf2afm)) {
    # Convert using ttf2afm
    outfiles <- file.path(afm_path(), sub("\\.ttf$", ".afm", basename(ttfiles)))
    
    for (i in seq_along(ttfiles)) {
      system2(ttf2afm, c(shQuote(ttfiles[i]), "-o", shQuote(outfiles[i])))
    }

  } else if (nzchar(ttf2pt1)) {
    # Convert using ttf2pt1
    outfiles <- file.path(afm_path(), sub("\\.ttf$", "", basename(ttfiles)))

    for (i in seq_along(ttfiles)) {
      # The options tell it to only create the .afm file, and not the
      # .t1a/pfa/pfb or .enc files. Run 'ttf2pt1 -G?' for more info.
      system2(ttf2pt1, c("-GfAe", shQuote(ttfiles[i]), shQuote(outfiles[i])))
    }
  }
}
