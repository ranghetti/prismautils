
function(input, output, session) {
  
  require(shiny)
  require(shinydashboard)
  require(shinyWidgets)
  require(leaflet)
  require(DT)
  require(sf)
  
  rv <- reactiveValues()
  
  
  # Read input XML orbit file
  observeEvent(input$input_orbit_xml, {
    if (input$input_orbit_xml$type == "text/xml") {
      rv$orbit_xml_name <- input$input_orbit_xml$name
      rv$orbit_table <- try(prismautils::read_prisma_orbit(input$input_orbit_xml$datapath), silent = TRUE)
      if (inherits(rv$orbit_table, "try-error")) {
        sendSweetAlert(
          session, title =  "File not recognised", type = "error",
          div(
            p("Some errors occurred importing the file;", br(),
              "please load a valid input file."),
            p(style = "font-family: monospace;", as.character(rv$orbit_table))
          )
        )
        rv$orbit_xml_name <- rv$orbit_table <- NULL
        # } else {
      #   rv$change_input_orbit <- sample(1E6,1) # dummy var for map/table update
      }
    } else {
      sendSweetAlert(
        session, title =  "Format not recognised", type = "error",
       "Please load a valid XML file."
      )
      rv$orbit_xml_name <- rv$orbit_table <- NULL
    }
  })
  output$guiorbit_onoff <- shiny::reactive(!is.null(rv$orbit_table))
  shiny::outputOptions(output, "guiorbit_onoff", suspendWhenHidden = FALSE)
  
  
  # Export output CSV / Shapefiles
  output$download_orbit_csv <- downloadHandler(
    filename = function() {
      gsub("\\.xml$", ".csv", rv$orbit_xml_name)
    },
    content = function(con) {
      write.csv(
        rv$orbit_table[,which(!names(rv$orbit_table) %in% c("ReferencePosition", "Polygon"))], 
        con, 
        na = "", row.names = FALSE, quote = FALSE
      )
    },
    contentType = "text/csv"
  )
  output$download_orbit_poly <- downloadHandler(
    filename = function() {
      gsub("\\.xml$", "_polygon.gpkg", rv$orbit_xml_name)
    },
    content = function(con) {
      st_write(rv$orbit_polygon_sf, con, driver = "gpkg", quiet = TRUE)
    },
    contentType = "application/x-sqlite3"
  )
  output$download_orbit_pt <- downloadHandler(
    filename = function() {
      gsub("\\.xml$", "_centre.gpkg", rv$orbit_xml_name)
    },
    content = function(con) {
      st_write(rv$orbit_centre_sf, con, driver = "gpkg", quiet = TRUE)
    },
    contentType = "application/x-sqlite3"
  )
  

  # Output table
  output$orbit_table <- DT::renderDT({
    req(rv$orbit_table)
    DT <- DT::datatable(
      rv$orbit_table[,which(!names(rv$orbit_table) %in% c("Polygon"))],
      # options = list(
      #   paging = ifelse(nrow(rv$orbit_table) > 10, TRUE, FALSE),
      #   
      #   # columnDefs = list(list(
      #   #   visible = FALSE#,
      #   #   # targets = targets
      #   # ))
      # ),
      selection = "none", rownames = FALSE, 
      extensions = c('Buttons','FixedColumns','Scroller'),
      options = list(
        dom = 'Bfrtip', buttons = c(I('colvis'), 'copy'), # Buttons 
        scrollX = TRUE, fixedColumns = TRUE, # FixedColumns
        deferRender = TRUE, scroller = TRUE # Scroller
      )
    )
    DT
  })




  # Output map
  observeEvent(rv$orbit_table, ignoreNULL = FALSE, {
    if (is.null(rv$orbit_table)) {
      rv$orbit_polygon_sf <- rv$orbit_centre_sf <- NULL
    } else {
      rv$orbit_polygon_sf <- st_sf(
        "geometry" = do.call(c, rv$orbit_table$Polygon),
        rv$orbit_table[,which(!names(rv$orbit_table) %in% c("ReferencePosition", "Polygon"))]
      )
      rv$orbit_centre_sf <- st_sf(
        "geometry" = do.call(c, rv$orbit_table$ReferencePosition),
        rv$orbit_table[,which(!names(rv$orbit_table) %in% c("ReferencePosition", "Polygon"))]
      )
    }
  })

  output$orbit_map <- renderLeaflet({
    req(rv$orbit_polygon_sf)
    map <- leaflet(rv$orbit_polygon_sf) %>%
      addTiles("https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
               group = "Ortophoto") %>%
      addTiles("https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_only_labels/{z}/{x}/{y}.png",
               group = "Ortophoto") %>%
      addTiles("https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
               group = "Map") %>%
      addPolygons(
        fillOpacity = 0.1, weight = 2.5,
        group = "Orbits"
      ) %>%
      addCircleMarkers(
        data = rv$orbit_centre_sf,
        # label = ~orbitNum,
        # labelOptions = labelOptions(
        #   textOnly  = TRUE, direction = 'top', #permanent  = TRUE,
        #   style = list("color" = "white", "font-weight" = "bold")
        # ),
        group = "Orbits"
      ) %>%
      leaflet::addLayersControl(
        baseGroups = c("Ortophoto", "Map"),
        overlayGroups = c("Orbits"),
        options = layersControlOptions(collapsed = TRUE)
      )
      
    map
  })
  
  
}