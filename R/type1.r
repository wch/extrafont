# Import a type1 package
type1_import <- function(pkgdir, pkgname = "") {
  message("Importing type1 font from ", pkgdir)

  # Directory structure:
  # pkgdir/inst/fonts: .enc and .map files
  # pkgdir/inst/fonts/metrics: .afm files
  # pkgdir/inst/fonts/outlines: .pfb files

  # Get info from the afm files
  afmdata <- afm_scan_files(file.path(pkgdir, "fonts", "metrics"))


  # Copy the .afm files over
  afmfile <- list.files(file.path(pkgdir, "fonts", "metrics"), "*.afm",
                        full.names = TRUE, ignore.case = TRUE)
  file.copy(afmfile, metrics_path())

  # Create a data frame to start storing the info
  fontdata <- data.frame(afmfile = basename(afmfile))
  # Store the name without extension (will remove later)
  fontdata$base <- sub("\\.afm$", "", fontdata$afmfile)


  # Match up with the .pfb/pfa files
  pfbfile <- list.files(file.path(pkgdir, "fonts", "outlines"), "*.pf?",
                        full.names = TRUE, ignore.case = TRUE)
  
  # Set up the pfb/pfa data to merge
  pfbdata <- data.frame(fontfile = pfbfile,
                        base = sub("\\.pf?$", "", basename(pfbfile)))

  # Line up the afmfile and fontfile columns, matching on 'base'
  fontdata <- merge(fontdata, pfbdata)
  fontdata$base <- NULL # base is no longer needed


  # Merge fontdata with afmdata
  fontdata <- merge(fontdata, afmdata)


  # If there's one row with Symbol==TRUE, it should be used as the
  # afmsymfile entry for all others
  nsymbol <- sum(fontdata$Symbol)
  if (nsymbol > 1) {
    stop("More than one symbol font file. Not sure how to handle this.")
  } else if (nsymbol == 1) {
    fontdata$afmsymfile <- fontdata[fontdata$Symbol, "afmfile"]
  }


  # Sort
  fontdata <- fontdata[ order(fontdata$FamilyName, fontdata$FullName), ]

  fontdata$package <- pkgname

  fonttable_add(fontdata)
}
