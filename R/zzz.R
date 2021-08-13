# nocov start
.onLoad <- function(libname, pkgname) {
  parallel_mclapply <<- parallel::mclapply
}

.onUnload <- function(libpath) {
  undo_overload_mclapply(TRUE, TRUE, "all")
}
#nocov end
