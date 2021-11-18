#### 204 - Accesibilidad a ferias ####

# Autor: Rodrigo Villegas Salgado
# version: 05-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: data cleaning

# Librerías
library(here)
library(dplyr)
library(glue)
library(stringr)
library(sf)


# Indicador
indicator <- "2 - Salud/204 - accesibilidad a ferias libres"

# Definir rutas de datos brutos

whdir <- readLines("data/raw/warehouselink.txt")

datadirs <- read.csv2("data/raw/datasources.csv", encoding = "UTF-8") %>%
  filter(indice == 204)
rawdatadir <- glue("{whdir}{datadirs$folder}")

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")
source("src/functions/pattern_matching.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# importar codigos de ciudad
source("src/functions/citycodes_import.R")
# importar limite urbano
limurbano <- readRDS("data/other/limurbano/limurbano.RDS")

# añadir padding de 5 digitos a codigos
citycodes <- citycodes %>%
  select(nom_com, city, cod_2017) %>%
  mutate(region = str_pad(cod_2017,width = 5, pad = "0") %>% 
                   str_extract("^\\d{2}") %>% as.numeric(),
         region = if_else(region == 16, 8, region))

# leer ferias en una lista, y transformar crs 
ferias_shps <- list.files(rawdatadir, pattern = ".shp", 
                          recursive = TRUE, full.names = TRUE)

ferias <- lapply(ferias_shps, read_sf) %>%
  do.call(rbind, .) %>%
  st_transform(st_crs(limurbano))

# Loop para iterar por cada region y seleccionar las ferias dentro de 
# áreas urbanas
ferias_clean <- st_intersection(ferias, limurbano) %>%
  rowid_to_column() %>%
  st_transform(4326)

# Exportar los datos para procesamiento
saveRDS(ferias_clean, file = glue("{dirs@cleandatadir}/clean.RDS"))


