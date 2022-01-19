.onLoad <- function(libname, pkgname){
  path <- system.file("packer", package = "idler")
  shiny::addResourcePath('idler-assets', path)
}
