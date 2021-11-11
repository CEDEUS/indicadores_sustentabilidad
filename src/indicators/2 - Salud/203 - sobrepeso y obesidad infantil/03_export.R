#### 203 - Salud Infantil ####

# Autor: Rodrigo Villegas Salgado
# version: 03-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: shape converter

# Librerías

library(tidyverse)
library(here)
library(glue)


# Indicador
indicator <- "2 - Salud/203 - sobrepeso y obesidad infantil"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")
source("src/functions/write_files.R", encoding = "utf-8")

# Rutas de trabajo
dirs <- getDirs(indicator)

# Cargar datos
load(glue("{dirs@cleandatadir}/diagnutr_com.RDS"))
load(glue("{dirs@cleandatadir}/diagnutr_city.RDS"))
load(glue("{dirs@cleandatadir}/diagnutr_pmc.RDS"))


# Identificar años de datos
agnos <- unique(diagnutr_com$agno)

#### Exportar datos ####
# Nombre de exportación
indicator_name <- str_split(string =  indicator, pattern =  "/")[[1]][2]

# Exportar csvs
write_indicator(diagnutr_com, indicator_name, ind_scale = "com", 
                outdir = dirs@outdircom)

write_indicator(diagnutr_city, indicator_name, ind_scale = "cty", 
                outdir = dirs@outdircty)

write_indicator(diagnutr_pmc, indicator_name, ind_scale = "pmc", 
                outdir = dirs@outdirpmc)

# Exportar shp
write_shp(diagnutr_com, indicator_name, "percent", "comunas_dpa2017.shp")

