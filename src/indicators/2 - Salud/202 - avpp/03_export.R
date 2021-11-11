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
source("src/functions/write_files.R", encoding = "utf-8")
# Rutas de trabajo
dirs <- getDirs(indicator)

# Cargar datos
load(glue("{dirs@cleandatadir}/avpp_com.RDS"))
load(glue("{dirs@cleandatadir}/avpp_city.RDS"))
load(glue("{dirs@cleandatadir}/avpp_pmc.RDS"))

# Identificar años de datos
agnos <- unique(avpp_com$agno)

#### Exportar datos ####
# Nombre de exportación
indicator_name <- str_split(string =  indicator, pattern =  "/")[[1]][2]

# Exportar csvs
write_indicator(avpp_com, indicator_name, ind_scale = "com", 
                outdir = dirs@outdircom)

write_indicator(avpp_city, indicator_name, ind_scale = "cty", 
                outdir = dirs@outdircty)

write_indicator(avpp_pmc, indicator_name, ind_scale = "pmc", 
                outdir = dirs@outdirpmc)

# Exportar shp
write_shp(avpp_com, indicator_name, "AVPP", "comunas_dpa2017.shp")
