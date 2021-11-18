# Funciones asociadas a webscrapping.
# Usadas por el indicador de accesibilidad a ferias libres

# Funcion para extraer elementos de una url.
# Usada para sacar las comunas disponibles en asof
extract_attr_from_elements <- function(url, elements, attribute){
  url %>% 
    rvest::html_elements(elements) %>% 
    rvest::html_attr(attribute) %>% 
    na.omit()
}
# Funcion para extraer los ids de los kmz de las ferias de asof
extract_kmz_id <- function(url, xpath, attribute){
  url %>% 
    rvest::html_nodes(xpath = xpath) %>%
    rvest::html_attr(attribute) %>% 
    na.omit() %>%
    str_extract("[-_0-9A-Za-z]+$")
}
# Funcion que descarga las ferias libres desde la asof.
webscrape_ferias <- function(region, download_folder) {
  print(region)
  # Hacer un scrapping de las ferias para obtener los links de las ferias
  # En las comunas de la región
  
  # La RM (Region 13) sale como "rm"
  region_code <- if (region == 13) "rm" else glue("regiones/{region}")
  
  region_html <- rvest::read_html(glue("http://www.asof.cl/apps/mapaferias/{region_code}.php"))
  
  ferias_urls <- extract_attr_from_elements(region_html, "option", "value")
  
  # Un sapply que hace un scrap de las urls de los mapas de cada comuna
  
  if (region == 13) {
    comuna_cod <- ferias_urls 
    } else if (region == 15){
    comuna_cod <- glue("{region_code}.php") 
    } else { 
    comuna_cod <- glue("regiones/{ferias_urls}")
    }
  
  feria_maps <- sapply(comuna_cod, function(x) {
    print(x)
    get_maps("http://www.asof.cl/apps/mapaferias/", x)
    })
  
  feria_maps <- feria_maps %>% discard(is.null)
  
  # Un sapply que extrae los ids de los archivos kml de cada comuna
  
  ids <- sapply(feria_maps, function(x) {
    print(paste("Extrayendo kmzs desde:", x))
    get_kmzs("", x)
    })
  
  # Descarga los kml de cada comuna en la region
  for (mapid in ids) {
    namess <- gsub("/", "_", names(ids[ids == mapid]))
    namess <- gsub(".php", "", namess)
    dirname <- glue("{download_folder}kml/region_{region}")

    if (!dir.exists(dirname)) dir.create(dirname, recursive = TRUE)
    filename <- glue("{dirname}/region_{region}_{mapid}.kmz")
    
    download.file(paste0("https://www.google.com/maps/d/u/0/kml?mid=",mapid,"&forcekml=1"), filename)
  }
}



get_maps <- function(origin_url, id) {
  url <- glue("{origin_url}{id}")
  html <- tryCatch({
    rvest::read_html(url) %>% extract_attr_from_elements("iframe", "src")  
    },
    error = function(cond) {
      message(paste("URL caused a warning:", url))
      message("Here's the original warning message:")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    warning=function(cond) {
      message(paste("URL caused a warning:", url))
      message("Here's the original warning message:")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    })
  }

get_kmzs <- function(origin_url, id) {
  url <- glue("{origin_url}{id}")
  html <- tryCatch({
    rvest::read_html(url) %>% extract_kmz_id('//meta[@itemprop="url"]', "content") 
  },
  error = function(cond) {
    message(paste("URL caused a warning:", url))
    message("Here's the original warning message:")
    message(cond)
    # Choose a return value in case of warning
    return(NULL)
  },
  warning=function(cond) {
    message(paste("URL caused a warning:", url))
    message("Here's the original warning message:")
    message(cond)
    # Choose a return value in case of warning
    return(NULL)
  })
}


# Función para transformar puntos kmz de asof a puntos sf

From_Kmz_to_Shp_Points <- function(KMZs, dest, name_output){
  # Las carpetas no necesariamente van a existir. En ese caso la función las crea.
  if (!dir.exists(dest)) dir.create(dest, recursive = TRUE)
  
  
  LonLat <- data.frame()
  # Lee los kmz y los escribe. Tiene un error handling en caso de que no funcionen.
  for (i in seq(KMZs)){
    tmp <- tryCatch({
      maptools::getKMLcoordinates(KMZs[i], ignoreAltitude = T)
      },
      error = function(cond) {
        message(paste("Archivo da problemas", KMZs[i]))
        message("Here's the original warning message:")
        message(cond)
        return(NA)
        }
      )
    
    if (class(tmp) == "matrix" | length(tmp) == 1) {print(KMZs[i]);next()}
    tmp <- do.call(rbind, tmp)
    colnames(tmp) <- c("lon", "lat")
    LonLat <- rbind(LonLat, tmp)
  }
  LonLat <- LonLat[!is.na(LonLat$lon),]
  #sp <- SpatialPointsDataFrame(LonLat, LonLat)
  
  sp <- st_as_sf(x = LonLat,                         
                 coords = c("lon", "lat"),
                 crs = 4326) %>%
    mutate(region = name_output,
           lon = LonLat$lon,
           lat = LonLat$lat,
           lonlat = paste(lat, lon, sep = ","))
  
  st_write(sp, glue("{dest}{name_output}.shp"),
           driver = "ESRI Shapefile", 
           delete_layer = TRUE)
}


