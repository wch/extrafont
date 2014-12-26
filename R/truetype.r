# Load all .ttf fonts from a directory.
# This does the following:
# - Create afm files in extrafontdb/inst/afm (or extrafontdb/afm when fonts
#   is properly installed as a package)
# - Create fonttable.csv
# - Create Fontmap file (for Ghostscript)
#' Imports all TrueType fonts in a directory and all subdirectories
#'
#' @param paths A vector of directories to search in. (Default is to auto-detect based on OS)
#' @param recursive Search recursively in directories? (Default TRUE)
#' @param pattern A regular expression that the filenames must match.
#'
#' @importFrom Rttf2pt1 which_ttf2pt1
#' @export
ttf_import <- function(paths = NULL, recursive = TRUE, pattern = NULL, perl = FALSE) {

  if (is.null(paths))  paths <- ttf_find_default_path()

  ttfiles <- normalizePath(list.files(paths, pattern = "\\.ttf$",
                                      full.names=TRUE, recursive = recursive,
                                      ignore.case = TRUE))

  if (!is.null(pattern)) {
    matchfiles <- grepl(pattern, basename(ttfiles), perl = perl)
    ttfiles <- ttfiles[matchfiles]
  }

  # This message really belongs in ttf_scan_files, but the pathnames
  # are lost by that point...
  message("Scanning ttf files in ", paste(paths, collapse=", "), " ...")
  fontmap <- ttf_extract(ttfiles)

  # Drop fonts with no name
  fontmap <- fontmap[!is.na(fontmap$FontName), ]
  message("Found FontName for ", nrow(fontmap), " fonts.")

  # Merge fontmap with afm data
  afmdata <- afm_scan_files()

  # Merge the fontfile-FontName mapping, and the info extracted from
  # the afm files
  fontdata <- merge(fontmap, afmdata)

  if (nrow(fontdata) > 0) {
    # Mark that these fonts were not installed with a package
    fontdata$package <- NA

    fonttable_add(fontdata)
  }
}


# Extract .afm  files from TrueType fonts.
# Returns mapping between .ttf file name and FontName
ttf_extract <- function(ttfiles) {
  message("Extracting .afm files from .ttf files...")

  # This stores information about the fonts
  fontdata <- data.frame(fontfile = ttfiles, FontName = "",
                         stringsAsFactors = FALSE)

  outfiles <- file.path(metrics_path(),
                sub("\\.ttf$", "", basename(ttfiles), ignore.case = TRUE))

  dir.create(file.path(tempdir(), "fonts"), showWarnings = FALSE)
  tmpfiles <- file.path(tempdir(), "fonts",
                sub("\\.ttf$", "", basename(ttfiles), ignore.case = TRUE))

  ttf2pt1 <- which_ttf2pt1()

  # Windows passes the args differently
  # -pft means use Freetype to process fonts
  # -a means extract all glyphs (needed for minus sign - latin1 doesn't include it)
  # -GfAe means extract AFM file only
  if (.Platform$OS.type == "windows")  args <- c("-a", "-G", "fAe")
  else                                 args <- c("-a", "-GfAe")

  for (i in seq_along(ttfiles)) {
    message(ttfiles[i], appendLF = FALSE)

    # This runs:
    #  ttf2pt1 -GfAe /Library/Fonts/Impact.ttf /out/path/Impact
    # The -GfAe options tell it to only create the .afm file, and not the
    # .t1a/pfa/pfb or .enc files. Run 'ttf2pt1 -G?' for more info.
    ret <- system2(ttf2pt1, c(args, shQuote(ttfiles[i]), shQuote(tmpfiles[i])),
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

    } else if (fontname %in% fonttable()$FontName) {
      fontdata$FontName[i] <- NA
      message(" : ", fontname, " already registered in fonts database. Skipping.")

    } else {
      fontdata$FontName[i] <- fontname
      gzcopy_exclude(paste(tmpfiles[i], ".afm", sep=""),
             paste(outfiles[i], ".afm.gz", sep=""),
             delete = TRUE,
             exclusions = c("^Characters"))
      message(" => ", paste(outfiles[i], sep=""))
    }
  }

  return(fontdata)
}

# Previously, I tried using ttf2afm to do the afm extraction,
# but the afm files created by ttf2afm didn't work with R.
# The command for ttf2afm was:
#   ttf2afm Impact.ttf -o Impact.afm


# Returns vector of default truetype paths, depending on platform.
ttf_find_default_path <- function() {

  if (grepl("^darwin", R.version$os)) {
    paths <-
      c("/Library/Fonts/",                      # System fonts
        "/System/Library/Fonts",                # More system fonts
        "~/Library/Fonts/")                     # User fonts
    return(paths[file.exists(paths)])

  } else if (grepl("^linux-gnu", R.version$os)) {
    # Possible font paths, depending on the system
    paths <-
      c("/usr/share/fonts/",                    # Ubuntu/Debian/Arch/Gentoo
        "/usr/X11R6/lib/X11/fonts/TrueType/",   # RH 6
        "~/.fonts/")                            # User fonts
    return(paths[file.exists(paths)])

  } else if (grepl("^freebsd", R.version$os)) {
    # Possible font paths, depending on installed ports
    paths <-
      c("/usr/local/share/fonts/truetype/",
        "/usr/local/lib/X11/fonts/",
        "~/.fonts/")                            # User fonts
    return(paths[file.exists(paths)])

  } else if (grepl("^mingw", R.version$os)) {
    return(paste(Sys.getenv("SystemRoot"), "\\Fonts", sep=""))
  } else {
    stop("Unknown platform. Don't know where to look for truetype fonts. Sorry!")
  }

}
