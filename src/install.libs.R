# Copy ttf2pt1/ttf2pt1 or ttf2pt1/ttf2pt1.exe binary to /exec/ or /exec/$R_ARCH,
# depending on platform
if (WINDOWS) {
  files <- file.path("ttf2pt1", "ttf2pt1.exe")
  execarch <- "exec"

} else {
  files <- file.path("ttf2pt1", "ttf2pt1")
 # Default installation (from R extensions doc)
 print(R_ARCH)
  execarch <- if (nzchar(R_ARCH)) paste('exec', R_ARCH, sep='') else 'exec'
}

dest <- file.path(R_PACKAGE_DIR, execarch)

message("Installing ", files, " to ", dest)
dir.create(dest, recursive = TRUE, showWarnings = FALSE)
file.copy(files, dest, overwrite = TRUE)
