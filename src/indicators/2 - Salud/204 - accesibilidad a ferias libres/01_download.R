#### 204 - Accesibilidad a ferias ####

# Autor: Rodrigo Villegas Salgado
# version: 05-11-21
# email: rdvillegas@uc.cl
# status: development
# rol: data downloading

# Librerías
library(here)
library(tidyverse)
library(glue)
library(maptools)
library(sf)

# Indicador
indicator <- "2 - Salud/204 - accesibilidad a ferias libres"

# Definir rutas de datos brutos

whdir <- readLines("data/raw/warehouselink.txt")
download_folder <- glue("{whdir}asof/feriaslibres/")

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")
source("src/functions/webscrapping.R")

# importar codigos de ciudad
source("src/functions/citycodes_import.R")

# añadir padding de 5 digitos a codigos
citycodes <- citycodes %>%
  select(nom_com, city, cod_2017) %>%
  mutate(region = str_pad(cod_2017,width = 5, pad = "0") %>% 
                   str_extract("^\\d{2}") %>% as.numeric() %>% as.character(),
         region = case_when(region == "16" ~ "8",
                     TRUE ~ region))

#### Scrapping de ferias libres. ####

# Extraer los códigos de region
regiones <- unique(citycodes$region)

# Loop simple que realiza webscrap desde las páginas de la ASOF.
# Por cada región, extrae los kmz de todas las ferias de la region.
# Magallanes no tiene ferias así que no se considera.
for (i in regiones){
  if (i == 12) next()
  webscrape_ferias(region = i, download_folder = download_folder)
}

#### De kmz a shp ####

# Carpetas con los kmls
kmz_folders <- list.files(glue("{download_folder}kml/"), full.names = TRUE)

# Loop que va por cada carpeta, une los kmzs en un único shp y lo exporta en una
# carpeta propia.
for (i in kmz_folders){
  kmz_files <- list.files(i, recursive = TRUE)
  kmz_files_path <- list.files(i, recursive = TRUE, full.names = TRUE)
  
  region_name <- str_extract(kmz_files[1], "^\\D*\\d+")
  # magallanes se excluye porque no tiene ferias
  if (i == 12) next()
  From_Kmz_to_Shp_Points(KMZs = kmz_files_path,
                         name_output = region_name, 
                         dest = glue("{download_folder}shp/{region_name}/"))
}



