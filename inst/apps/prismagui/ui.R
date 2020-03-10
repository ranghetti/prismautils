require(shiny)
require(shinydashboard)
require(leaflet)
require(DT)

header <- dashboardHeader(
  title = "PRISMA utilities"
)

body <- dashboardBody(
  fluidRow(
    column(
      width = 3,
      box(
        title = "XML input file",
        width = NULL,
        fileInput("input_orbit_xml", label = NULL)#,
        # p(
        #   class = "text-muted",
        #   paste("")
        # )
      ),
      conditionalPanel(
        condition = "output.guiorbit_onoff",
        box(
          title = "Export table",
          width = NULL,
          div(
            style = "margin-top:10px;",
            downloadButton("download_orbit_csv", "Download CSV", style = "width:100%")
          ),
          div(
            style = "margin-top:10px;",
            downloadButton("download_orbit_poly", "Download Polygon", style = "width:100%")
          ),
          div(
            style = "margin-top:10px;",
            downloadButton("download_orbit_pt", "Download Centre", style = "width:100%")
          ),
        )
      )
    ),
    column(
      width = 9,
      conditionalPanel(
        condition = "output.guiorbit_onoff",
        box(
        width = NULL,# solidHeader = TRUE,
        leafletOutput("orbit_map", height = 500)
      )
      )
    )
  ),
  conditionalPanel(
    condition = "output.guiorbit_onoff",
    box(
      width = NULL,
      DT::dataTableOutput("orbit_table")
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)