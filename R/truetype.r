# Load all .ttf fonts from a directory.
# This does the following:
# - Create afm files in extrafont/inst/afm (or extrafont/afm when extrafont
#   is properly installed as a package)
# - Create font_table.csv
# - Create Fontmap file (for Ghostscript)
#' Imports all TrueType fonts in a directory and all subdirectories
#'
#' @export
ttf_import <- function(paths = NULL, recursive = TRUE, prompt = TRUE) {

  if (prompt) {
    resp <- readline("Importing fonts may take a few minutes, depending on the number of fonts and the speed of the system. Continue? [y/n] ")
    if (tolower(resp) != "y") {
      message("Exiting.")
      return(invisible())
    }
  }

  if (is.null(paths))  paths <- ttf_find_default_path()

  ttfiles <- normalizePath(list.files(paths, pattern = "\\.ttf$",
                                      full.names=TRUE, recursive = recursive))

  # This message really belongs in ttf_scan_files, but the pathnames
  # are lost by that point...
  message("Scanning ttf files in ", paste(paths, collapse=", "), " ...")
  fontmap <- ttf_extract(ttfiles)

  # Drop fonts with no name
  fontmap <- subset(fontmap, !is.na(FontName))
  message("Found FontName for ", nrow(fontmap), " fonts.")

  font_save_table(fontmap)

  # This generates the Fontmap file, which is used by Ghostscript.
  generate_fontmap_file()
}


# Finds the executable for ttf2pt1
which_ttf2pt1 <- function() {
  if (.Platform$OS.type == "unix") {
    bin <- "ttf2pt1"
  } else if (.Platform$OS.type == "windows") {
    bin <- "ttf2pt1.exe"
  } else {
    stop("Unknown platform: ", .Platform$OS.type)
  }

  # First check if it was installed with the package
  binpath <- file.path(inst_path(), "libs", .Platform$r_arch, bin)
  if (file.exists(binpath))
    return(binpath)

  # If we didn't find it installed with the package, check search path
  binpath <- Sys.which(bin)
  if (binpath == "")
    stop(bin, " not found in path.")
  else
    return(binpath)
}


#' Extract .afm  files from TrueType fonts.
ttf_extract <- function(ttfiles) {
  message("Extracting .afm files from .ttf files...")

  # This stores information about the fonts
  fontdata <- data.frame(fontfile = ttfiles, FontName = "", 
                         stringsAsFactors = FALSE)

  outfiles <- file.path(metrics_path(), sub("\\.ttf$", "", basename(ttfiles)))

  ttf2pt1 <- which_ttf2pt1()

  for (i in seq_along(ttfiles)) {
    message(ttfiles[i], appendLF = FALSE)

    # This runs:
    #  ttf2pt1 -GfAe /Library/Fonts/Impact.ttf /out/path/Impact
    # The -GfAe options tell it to only create the .afm file, and not the
    # .t1a/pfa/pfb or .enc files. Run 'ttf2pt1 -G?' for more info.
    ret <- system2(ttf2pt1, c("-GfAe", shQuote(ttfiles[i]), shQuote(outfiles[i])),
            stdout = TRUE, stderr = TRUE)

    fontnameidx <- grepl("^FontName ", ret)
    if (sum(fontnameidx) == 0) {
      fontname <- ""
    } else if (sum(fontnameidx) == 1) {
      fontname <- sub("^FontName ", "", ret[fontnameidx])
    } else if (sum(fontnameidx) > 1) {
      warning("More than one FontName found for ", ttfiles[i])
    }

    if (fontname == "" || fontname == "Unknown") {
      fontdata$FontName[i] <- NA
      message(" : No FontName. Skipping.")

      # Delete the .afm files that were created
      unlink(sub("$", ".afm", outfiles[i]))

    } else {
      fontdata$FontName[i] <- fontname
      message(" => ", paste(outfiles[i], sep=""))
    }

  }

  return(fontdata)

}

# Previously, this also allowed using ttf2afm to do the afm extraction,
# but the afm files created by ttf2afm didn't work with R.
# The command for ttf2afm was:
#   ttf2afm Impact.ttf -o Impact.afm


# Returns vector of default truetype paths, depending on platform.
ttf_find_default_path <- function() {
  os <- sessionInfo()$R.version$os

  if (grepl("^darwin", os)) {
    return(c("/Library/Fonts", "/System/Library/Fonts"))

  } else if (grepl("^linux-gnu", os)) {
    # Possible font paths, depending on the system
    paths <-
      c("/usr/share/fonts/truetype/",         # Ubuntu/Debian
        "/usr/X11R6/lib/X11/fonts/TrueType/")  # RH 6
    return(paths[file.exists(paths)])

  } else if (grepl("^mingw", os)) {
    return(paste(Sys.getenv("SystemRoot"), "\\Fonts", sep=""))
  } else {
    stop("Unknown platform. Sorry!")
  }

}
