require(shiny)
require(shinydashboard)
require(leaflet)
require(DT)

header <- dashboardHeader(
  title = "PRISMA utilities",
  tags$li(class ="dropdown", tags$h3(
    style = "color:white;margin:0;padding-top:12px;padding-bottom:12px;padding-left:50px;padding-right:50px;",
    "Read XML orbit file"
  )),
  tags$li(class ="dropdown", tags$a(
    href="https://github.com/ranghetti/prismautils",
    tags$img(src="github_logo.png"),
    style="margin:0;padding-top:2px;padding-bottom:2px;padding-left:10px;padding-right:10px;",
    target="_blank"
  )),
  tags$li(class ="dropdown", tags$a(
    href="http://www.irea.cnr.it",
    tags$img(src="irea_logo.png"),
    style="margin:0;padding-top:2px;padding-bottom:2px;padding-left:10px;padding-right:10px;",
    target="_blank"
  ))
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