#### 203 - Salud Infantil ####

# Autor: Rodrigo Villegas Salgado
# version: 03-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: data export

# Librerías

library(tidyverse)
library(here)
library(glue)


# Indicador
indicator <- "2 - Salud/203 - Salud Infantil"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# Cargar datos
load(glue("{dirs@cleandatadir}/diagnutr_com.RDS"))
load(glue("{dirs@cleandatadir}/diagnutr_city.RDS"))
load(glue("{dirs@cleandatadir}/diagnutr_pmc.RDS"))

# Identificar años de datos
agnos <- unique(diagnutr_com$agno)

#### Exportar datos ####
indiname <- str_split(string =  indicator, pattern =  "/")[[1]][2] %>%
  paste0("_")

# Nivel Comunal
lapply(agnos, function(x){
  print(paste("Exportando a nivel Comunal. Año: ", x))
  filename <- paste0(indiname,x, ".csv")
  tmp <- diagnutr_com %>%
    filter(agno == x)
  write.csv2(tmp, glue("{dirs@outdircom}/{filename}"), row.names = F)
})

# Nivel ciudad
lapply(agnos, function(x){
  print(paste("Exportando a nivel Ciudad. Año: ", x))
  filename <- paste0(indiname,x, ".csv")
  tmp <- diagnutr_city %>%
    filter(agno == x)
  write.csv2(tmp, glue("{dirs@outdircty}{filename}"), row.names = F)
})

# Nivel pmc
lapply(agnos, function(x){
  print(paste("Exportando datos para PMC. Año: ", x))
  filename <- paste0(indiname,x, ".csv")
  tmp <- diagnutr_pmc %>%
    filter(agno == x) %>%
    select(-agno)
  write.csv(tmp, glue("{dirs@outdirpmc}{filename}"), row.names = F)
})

