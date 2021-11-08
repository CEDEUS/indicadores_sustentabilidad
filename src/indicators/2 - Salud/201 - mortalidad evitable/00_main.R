#### 201 - Mortalidad Evitable ####

# Autor: Rodrigo Villegas Salgado
# version: 05-11-21
# email: rdvillegas@uc.cl
# status: development
# rol: main script

library(glue)
library(here)

# Indicador
indicator <- "2 - Salud/201 - mortalidad evitable"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)


# Ejecutar scripts de trabajo

source(glue("{dirs@srcdir}/01_clean.R"), encoding = "utf-8")
source(glue("{dirs@srcdir}/02_process.R"), encoding = "utf-8")
source(glue("{dirs@srcdir}/03_export.R"), encoding = "utf-8")
source(glue("{dirs@srcdir}/04_spatialize.R"), encoding = "utf-8")
