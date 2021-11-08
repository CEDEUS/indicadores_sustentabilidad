#### 202 - Años de vida potencialmente perdidos ####

# Autor: Rodrigo Villegas Salgado
# version: 08-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: data export

# Librerías

library(tidyverse)
library(here)
library(glue)
library(sf)

# Indicador
indicator <- "2 - Salud/202 - avpp"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# Cargar datos
load(glue("{dirs@cleandatadir}/avpp_com.RDS"))

# Leer datos y separar por año
datos <- avpp_com %>%
  pivot_wider(names_from = agno, values_from = AVPP)

# Pasar a shp
dpa <- read_sf(glue("{dirs@dpadir}/comunas_dpa2017.shp"))

# Nombre de indicador (para exportar)
indiname <- str_split(string = indicator, pattern =  "/")[[1]][2]

final <- datos %>%
  mutate(comuna = as.character(comuna)) %>%
  left_join(dpa)
# Exportar datos
write_sf(final, glue("{dirs@shpdir}/{indiname}.shp"), driver = "ESRI Shapefile")


