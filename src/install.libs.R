# Copy ttf2pt1/ttf2pt1 or ttf2pt1/ttf2pt1.exe binary
files <- file.path("ttf2pt1", if (WINDOWS) "ttf2pt1.exe" else "ttf2pt1")

# Default installation (from R extensions doc)
libarch <- if (nzchar(R_ARCH)) paste('libs', R_ARCH, sep='') else 'libs'
dest <- file.path(R_PACKAGE_DIR, libarch)

message("Installing ", files, " to ", dest)
dir.create(dest, recursive = TRUE, showWarnings = FALSE)
file.copy(files, dest, overwrite = TRUE)
