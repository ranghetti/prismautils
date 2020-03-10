#' @title Main prismutils GUI
#' @description Open the GUI containing utilities for PRISMA
#'  (at this stage, the possibility to read, visualise and export PRISMA
#'  orbits).
#' @export
#' @seealso \code{\link{read_prisma_orbit}} to import XML files from the 
#' command line.
#' @author Luigi Ranghetti, phD (2020) <ranghetti.l@irea.cnr.it>
#' @importFrom sf st_sf st_write
#' @importFrom DT datatable renderDT dataTableOutput
#' @importFrom leaflet addCircleMarkers addLayersControl addPolygons addTiles 
#'  layersControlOptions leaflet renderLeaflet leafletOutput
#' @importFrom shiny br div downloadHandler observeEvent outputOptions p 
#'  reactive reactiveValues req
#'  column conditionalPanel div downloadButton fileInput fluidRow
#' @importFrom shinyWidgets sendSweetAlert
#' @importFrom shinydashboard box dashboardBody dashboardHeader dashboardPage 
#'  dashboardSidebar
#' @importFrom utils write.csv
prismagui <- function()  {
  
  # run
  if (interactive()) {
    options(device.ask.default = FALSE)
    return(shiny::runApp(
      system.file("apps/prismagui", package = "prismautils"),
      display.mode = "normal",
      launch.browser = TRUE
    ))
  } else {
    stop("The function must be run from an interactive R session.")
  }
  
}
