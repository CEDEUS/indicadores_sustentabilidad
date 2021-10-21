#### 301 - Hacinamiento ####

# Autor: Rodrigo Villegas Salgado
# version: 04-10-21
# email: rdvillegas@uc.cl
# status: production
# rol: data export

# Librerías

library(tidyverse)
library(glue)
library(here)

# Indicador
indicator <- "3 - Equidad/301 - Hacinamiento"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# Cargar datos
load(glue("{dirs@cleandatadir}/hacinam_com.RDS"))
load(glue("{dirs@cleandatadir}/hacinam_cty.RDS"))
load(glue("{dirs@cleandatadir}/hacinam_pmc.RDS"))

# Identificar años de datos
agnos <- unique(hacinam_com$agno)

#### Exportar datos ####

# Nombre indicador (para exportar)
indiname <- "301 - Hacinamiento_"

# Nivel Comunal
lapply(agnos, function(x){
  print(paste("Exportando a nivel Comunal. Año: ", x))
  filename <- paste0(indiname,x, ".csv")
  tmp <- hacinam_com %>%
    filter(agno == x)
  write.csv2(tmp, glue("{dirs@outdircom}/{filename}"), row.names = F)
})

# Nivel ciudad
lapply(agnos, function(x){
  print(paste("Exportando a nivel Ciudad. Año: ", x))
  filename <- paste0(indiname,x, ".csv")
  tmp <- hacinam_cty %>%
    filter(agno == x)
  write.csv2(tmp, glue("{dirs@outdircty}{filename}"), row.names = F)
})

# Nivel pmc
lapply(agnos, function(x){
  print(paste("Exportando datos para PMC. Año: ", x))
  filename <- paste0(indiname,x, ".csv")
  tmp <- hacinam_pmc %>%
    filter(agno == x) %>%
    select(-agno)
  write.csv(tmp, glue("{dirs@outdirpmc}{filename}"), row.names = F)
})

