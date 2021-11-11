#### 201 - Mortalidad Evitable ####

# Autor: Rodrigo Villegas Salgado
# version: 08-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: data export

# Librerías

library(tidyverse)
library(here)
library(glue)


# Indicador
indicator <- "2 - Salud/201 - mortalidad evitable"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")
source("src/functions/write_files.R", encoding = "utf-8")
# Rutas de trabajo
dirs <- getDirs(indicator)

# Cargar datos
load(glue("{dirs@cleandatadir}/mortprev_com.RDS"))
load(glue("{dirs@cleandatadir}/mortprev_city.RDS"))
load(glue("{dirs@cleandatadir}/mortprev_pmc.RDS"))

# Identificar años de datos
agnos <- unique(mortprev_com$agno)

#### Exportar datos ####
# Nombre de exportación
indicator_name <- str_split(string =  indicator, pattern =  "/")[[1]][2]

# Exportar csvs
write_indicator(mortprev_com, indicator_name, ind_scale = "com", 
                outdir = dirs@outdircom)

write_indicator(mortprev_city, indicator_name, ind_scale = "cty", 
                outdir = dirs@outdircty)

write_indicator(mortprev_pmc, indicator_name, ind_scale = "pmc", 
                outdir = dirs@outdirpmc)

# Exportar shp
write_shp(mortprev_com, indicator_name, "tasa", "comunas_dpa2017.shp")
