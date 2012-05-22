# extrafont

The extrafont package makes it easier to use fonts other than the basic PostScript fonts that R uses, such as system TrueType fonts.

There are two hurdles for using fonts in PDF (or Postscript) output files:

* Making R aware of the font and the dimensions of the characters.
* Embedding the fonts so that the PDF can be displayed properly on a device that doesn't have the font.

The extrafont package makes both of these things easier.

Presently it allows the use of system TrueType fonts with R, and installation of Type 1 font packages.
Support for other kinds of fonts will be added in the future.
It has been tested on Mac OS X 10.7 and Ubuntu Linux 12.04 and Windows XP.


# Using extrafont

## Requirements

You must have Ghostscript installed on your system for embedding fonts into PDF files.

You can install the extrafont package directly from GitHub:

```R
library(devtools)
install_github('extrafont', 'wch')
library(extrafont)
```


There are three categories of things you need to do to use fonts:

* things that need to be run once
* things that need to be run in each R session
* things that need to be run for each output file

## One-time setup

First, import the fonts installed on the system.
(This only works with TrueType fonts right now.)

```R
font_import()
# This tries to autodetect the directory containing the TrueType fonts.
# If it fails on your system, please let me know.
```

This does the following:

* Finds the fonts on your system.
* Extracts the FontName (like ArialNarrow-BoldItalic).
* Extracts/converts a PostScript .afm file for each font. This file contains the *font metrics*, which are the rectangular dimensions of each character that are needed for placement of the characters. These are not the *glyphs*, which the curves defining the visual shape of each character. The glyphs are only in the .ttf file.
* Scan all the resulting .afm files, and save a table with information about them.
This table will be used when making plots with R.
* Creates a file `Fontmap`, which contains the mapping from FontName to the .ttf file. This is required by Ghostscript for embedding fonts.


You can view the resulting table of font information with:

```R
# Show entire table
fonttable()

# Vector of font family names
fonts()
```

If you install new fonts on your computer, you'll have to redo this stage to re-import them for R.

## Run each R session

This registers each of the fonts in the afm table with R. This is needed for R to know about the new fonts (but it forgets about them after each session).

```R
setupPdfFonts()
```

If you are running Windows, you may need to tell it where the Ghostscript program is, for embedding fonts. (See Windows installation notes below.)

```R
# This is needed only on Windows
# (adjust the path to match your installation of Ghostscript)
Sys.setenv(R_GSCMD = "C:/Program Files/gs/gs9.05/bin/gswin32c.exe")
```


## Run for each output file

After you create a PDF output file, you should *embed* the fonts into the file.
The 14 PostScript *base fonts* never need to be embedded, because they are included with every PostScript/PDF renderer.
However, the extra fonts aren't necessarily available on other devices, so they should be embedded.
The `embedExtraFonts()` function will do this.

Here's an example of a PDF plot made with ggplot2. (Run only the plots that use fonts available on your system.)

```R
pdf('fonttest.pdf', width=4, height=4)
library(ggplot2)
p <- ggplot(mtcars, aes(x=wt, y=mpg)) + geom_point()

# On Mac, Impact is available
p + opts(axis.title.x=theme_text(size=16, family="Impact", colour="red"))

# On Linux, Purisa and/or Droid Serif may be available
p + opts(axis.title.x=theme_text(size=16, family="Purisa", colour="red"))
p + opts(axis.title.x=theme_text(size=16, family="Droid Serif", colour="red"))
dev.off()
```

The first time you use a font, it may throw some warnings about unknown characters.


After creating the PDF file, embed the fonts:

```R
# This does the embedding
embedExtraFonts('fonttest.pdf', outfile='fonttest-embed.pdf')
```

To check if the fonts have been properly embedded, open each of the PDF files with Adobe Reader, and go to File->Properties->Fonts.
If a font is embedded, it will say "Embedded Subset" by the font's name; otherwise it will say nothing next to the name.

On Linux you can also use evince (the default PDF viewer) to view embedded fonts.
Open the file and go to File->Properties->Fonts.
If a font is embedded, it will say "Embedded subset"; otherwise it will say "Not embedded".


*****

# Installation notes

## ttf2pt1

The source code for the utility program `ttf2pt1` is included.
It will be compiled on installation, so you need a build environment on your system.


## Windows installation notes

In Windows, you need to make sure that Ghostscript is installed.

In each R session where you embed fonts, you will need to tell R where Ghostscript is installed.
For example, when Ghostscript 9.05 is installed to the default location, running this command will do it (adjust the path for your installation):

```R
Sys.setenv(R_GSCMD="C:/Program Files/gs/gs9.05/bin/gswin32c.exe")

# After this is done, you can run embedExtraFonts()
```

# Licensing notes

This product includes software developed by the TTF2PT1 Project and its contributors.
See `src/ttf2pt1/COPYRIGHT` for more information.
