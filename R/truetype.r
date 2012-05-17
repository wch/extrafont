# TODO:
# - Add function for converting a single TrueType font by name

# Load all .ttf fonts from a directory.
# This does the following:
# - Create afm files in extrafont/inst/afm (or extrafont/afm when extrafont
#   is properly installed as a package)
# - Create a Fontmap file
# TODO: Modularize font search path (for other platforms)
#' @export
import_ttf_dir <-
  function(paths = c("/Library/Fonts", "/System/Library/Fonts")) {

  ttfiles <- normalizePath(list.files(paths, pattern = "\\.ttf$", full.names=TRUE))

  # This message really belongs in ttf_scan_files, but the pathnames
  # are lost by that point...
  message("Scanning ttf files in ", paste(paths, collapse=", "), " ...")
  fontdata <- ttf_scan_files(ttfiles)

  # Drop fonts with no name or "Unknown" name
  fontdata <- subset(fontdata, fontname != "" & fontname != "Unknown")
  message("Found FontName for ", length(fontdata), " fonts.")

  write_fontmap(fontdata)

  ttf_extract_afm(fontdata$filename)
}


# Scans ttf files in a vector, and returns a data frame with:
# - filename: 
# - fontname:
# - valid:
ttf_scan_files <- function(ttfiles) {

  fontdata <- data.frame(filename = ttfiles, fontname = "", 
                         stringsAsFactors = FALSE)

  ttf2pt1 <- which_ttf2pt1()

  for (i in seq_along(ttfiles)) {
    message(ttfiles[i])

    # This runs:
    #  ttf2pt1 -Gfae /Library/Fonts/Impact.ttf
    # The options tell it to not create any output files.
    # We'll scan the text output to get the FontName
    ret <- system2(ttf2pt1, c("-Gfae", shQuote(ttfiles[i])),
                   stdout = TRUE, stderr = TRUE)

    fontnameidx <- grepl("^FontName ", ret)
    if (sum(fontnameidx) == 1) {
      fontdata$fontname[i] <- sub("^FontName ", "", ret[fontnameidx])
    } else if (sum(fontnameidx) > 1) {
      warning("More than one FontName found for ", ttfiles[i])
    }
  }

  return(fontdata)
}

# Writes the Fontmap file
write_fontmap <- function(fontdata) {
  outfile <- fontmap_file()

  message("Writing Fontmap to ", outfile, "...")

  # Output format is:
  # /Arial-BoldMT (/Library/Fonts/Arial Bold.ttf) ;
  writeLines(
    paste("/", fontdata$fontname, " (", fontdata$filename, ") ;", sep=""),
    outfile)
}


# Finds the executable for ttf2pt1
which_ttf2pt1 <- function() {
  if (.Platform$OS.type == "unix") {
    Sys.which("ttf2pt1")
  } else if (.Platform$OS.type == "windows") {
    # TODO: Check that this is the correct name in Windows
    Sys.which("ttf2pt1.exe")
  } else {
    error("Unknown platform: ", .Platform$OS.type)
  }
}


#' Extract afm files from TrueType fonts.
ttf_extract_afm <- function(ttfiles) {
  message("Extracting afm files from ttf files...")

  outfiles <- file.path(afm_path(), sub("\\.ttf$", "", basename(ttfiles)))

  ttf2pt1 <- which_ttf2pt1()

  for (i in seq_along(ttfiles)) {
    message(ttfiles[i], " => ", paste(outfiles[i], ".afm", sep=""))

    # This runs:
    #  ttf2pt1 -GfAe /Library/Fonts/Impact.ttf /out/path/Impact
    # The -GfAe options tell it to only create the .afm file, and not the
    # .t1a/pfa/pfb or .enc files. Run 'ttf2pt1 -G?' for more info.
    ret <- system2(ttf2pt1, 
                   c("-GfAe", shQuote(ttfiles[i]), shQuote(outfiles[i])),
                   stdout = TRUE, stderr = TRUE)
  }

}


# Previously, this also allowed using ttf2afm to do the afm extraction,
# but the afm files created by ttf2afm didn't work with R.
# The command for ttf2afm was:
#   ttf2afm Impact.ttf -o Impact.afm

