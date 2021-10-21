#### 301 - Hacinamiento ####

# Autor: Rodrigo Villegas Salgado
# version: 04-10-21
# email: rdvillegas@uc.cl
# status: development
# rol: shape converter

# Librerías
library(glue)
library(here)
library(sf)
library(tidyverse)
# Indicador
indicator <- "3 - Equidad/301 - Hacinamiento"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# Cargar datos
load(glue("{dirs@cleandatadir}/hacinam_com.RDS"))


# Leer datos y separar por año
datos <- hacinam_com %>%
  pivot_wider(names_from = agno, values_from = Hacinados)

# Pasar a shp
dpa <- read_sf(glue("{dirs@dpadir}/comunas_dpa2017.shp"))

# Nombre de indicador (para exportar)
indiname <- "301 - Hacinamiento"

final <- datos %>%
  left_join(dpa)
# Exportar datos
write_sf(final, glue("{dirs@shpdir}/{indiname}.shp"), driver = "ESRI Shapefile")
