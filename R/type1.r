# Import a type1 package
type1_import <- function(pkgdir) {
  message("Importing type1 font from ", pkgdir)

  # Directory structure:
  # pkgdir/inst/fonts: .enc and .map files
  # pkgdir/inst/fonts/metrics: .afm files
  # pkgdir/inst/fonts/outlines: .pfb files

  # Get info from the afm files
  afmdata <- afm_scan_files(file.path(pkgdir, "fonts", "metrics"))


  # Copy the .afm files over
  afmfile <- list.files(file.path(pkgdir, "fonts", "metrics"), "*.afm",
                        full.names = TRUE)
  file.copy(afmfile, metrics_path())

  # Create a data frame to start storing the info
  fontdata <- data.frame(afmfile = basename(afmfile))
  # Store the name without extension (will remove later)
  fontdata$base <- sub("\\.afm$", "", fontdata$afmfile)


  # Match up with the .pfb files
  pfbfile <- list.files(file.path(pkgdir, "fonts", "outlines"), 
                         "*.pfb", full.names = TRUE)
  
  # Set up the pfb data to merge
  pfbdata <- data.frame(fontfile = pfbfile,
                        base = sub("\\.pfb$", "", basename(pfbfile)))

  # Line up the afmfile and fontfile columns, matching on 'base'
  fontdata <- merge(fontdata, pfbdata)
  fontdata$base <- NULL # base is no longer needed


  # Merge fontdata with afmdata
  fontdata <- merge(fontdata, afmdata)

  # Sort
  fontdata <- fontdata[ order(fontdata$FamilyName, fontdata$FullName), ]

  # TODO: The rest should be moved out to fonts.r
  # Combine with existing font data
  fontdata <- rbind(font_load_table(), fontdata)

  # TODO: Allow this to work even if no existing table
  message("Adding to font table in ", font_table_file())
  write.csv(fontdata, file = font_table_file(), row.names = FALSE)
}
