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

# Rutas de trabajo
dirs <- getDirs(indicator)

# Cargar datos
load(glue("{dirs@cleandatadir}/mortprev_com.RDS"))
load(glue("{dirs@cleandatadir}/mortprev_city.RDS"))
load(glue("{dirs@cleandatadir}/mortprev_pmc.RDS"))

# Identificar años de datos
agnos <- unique(mortprev_com$agno)

#### Exportar datos ####
indiname <- str_split(string =  indicator, pattern =  "/")[[1]][2] %>%
  paste0("_")

# Nivel Comunal
lapply(agnos, function(x){
  print(paste("Exportando a nivel Comunal. Año: ", x))
  filename <- paste0(indiname,x, ".csv")
  tmp <- mortprev_com %>%
    filter(agno == x)
  write.csv2(tmp, glue("{dirs@outdircom}/{filename}"), row.names = F)
})

# Nivel ciudad
lapply(agnos, function(x){
  print(paste("Exportando a nivel Ciudad. Año: ", x))
  filename <- paste0(indiname,x, ".csv")
  tmp <- mortprev_city %>%
    filter(agno == x)
  write.csv2(tmp, glue("{dirs@outdircty}{filename}"), row.names = F)
})

# Nivel pmc
lapply(agnos, function(x){
  print(paste("Exportando datos para PMC. Año: ", x))
  filename <- paste0(indiname,x, ".csv")
  tmp <- mortprev_pmc %>%
    filter(agno == x) %>%
    select( -agno)
  write.csv(tmp, glue("{dirs@outdirpmc}{filename}"), row.names = F)
})

