#' @title Read PRISMA orbit XML files
#' @description Read XML files containing the PRISMA orbit propagations
#'  (the format of this XML files is fixed and defined by Telespazio).
#' @param xmlpath Character value with the path of the input XML file.
#' @param format (optional) One of the following options, determining the 
#'  output format:
#'  - `data.frame`: a data frame containing the information in tabular format;
#'  - `polygon`: a `sf POLYGON` spatial object with the geometry of the tile;
#'  - `point`: a `sf POINT` spatial object with the geometry of the reference 
#'      positions.
#' @return The input orbit information (see argument `format`).
#' @export
#' @seealso \code{\link{prismagui}} to read XML files from the GUI.
#' @author Luigi Ranghetti, phD (2020) <ranghetti.l@irea.cnr.it>
#' @importFrom sf st_cast st_multipoint st_point st_sfc st_sf
#' @importFrom XML saveXML xmlChildren xmlParse xmlRoot xmlToDataFrame
read_prisma_orbit <- function(xmlpath, format = "data.frame") {

  if (!format %in% c("data.frame", "polygon", "point")) {
    stop("Argument 'format' is not recognised.")
  }
  
  xml <- xmlParse(xmlpath)
  xml_list <- xmlChildren(xmlRoot(xml)[["DTOList"]])
  xml_df <- xmlToDataFrame(nodes = xml_list)

  xml_out <- data.frame(
    DTOCode = as.character(xml_df$DTOCode),
    backgroundCode = as.character(xml_df$backgroundCode),
    userId = as.character(xml_df$userId),
    priorityLevel = as.integer(as.character(xml_df$priorityLevel)),
    PRType = as.character(xml_df$PRType),
    timeStart = as.POSIXct(
      sapply(xml_list, function(x) {
        saveXML(xmlChildren(x[["SensingTimeWindow"]][["timeStart"]])$text)
      }),
      format = "%Y-%m-%dT%H:%M:%OSZ"
    ),
    timeStop = as.POSIXct(
      sapply(xml_list, function(x) {
        saveXML(xmlChildren(x[["SensingTimeWindow"]][["timeStop"]])$text)
      }),
      format = "%Y-%m-%dT%H:%M:%OSZ"
    ),
    ReferencePosition = NA,
    Polygon = NA,
    rollAngle = as.numeric(as.character(xml_df$rollAngle)),
    pitchAngle = as.numeric(as.character(xml_df$pitchAngle)),
    solarZenithAngle = as.numeric(as.character(xml_df$solarZenithAngle)),
    orbitDirection = as.character(xml_df$orbitDirection),
    orbitNum = as.integer(as.character(xml_df$orbitNum)),
    cloudCoveragePerc = as.numeric(as.character(xml_df$cloudCoveragePerc))
  )
  
  xml_out$ReferencePosition <- lapply(xml_list, function(x) {
    sf::st_sfc(
      sf::st_point(c(
        as.numeric(saveXML(xmlChildren(x[["ReferencePosition"]][["longitude"]])$text)),
        as.numeric(saveXML(xmlChildren(x[["ReferencePosition"]][["latitude"]])$text))
      )),
      crs = 4326
    )
  })
  xml_out$Polygon <- lapply(xml_list, function(x) {
    sf::st_sfc(
      sf::st_cast(sf::st_multipoint(
        t(sapply(xmlChildren(x[["Polygon"]]), function(y) {
          c(
            as.numeric(saveXML(xmlChildren(y[["longitude"]])$text)),
            as.numeric(saveXML(xmlChildren(y[["latitude"]])$text))
          )
        }))
      ), "POLYGON"),
      crs = 4326
    )
  })
  
  switch(
    format,
    data.frame = xml_out,
    polygon = st_sf(
      "geometry" = do.call(c, xml_out$Polygon),
      xml_out[,which(!names(xml_out) %in% c("ReferencePosition", "Polygon"))]
    ),
    point = st_sf(
      "geometry" = do.call(c, xml_out$ReferencePosition),
      xml_out[,which(!names(xml_out) %in% c("ReferencePosition", "Polygon"))]
    )
  )

}
