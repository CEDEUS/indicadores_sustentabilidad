#### 301 - Hacinamiento ####

# Autor: Rodrigo Villegas Salgado
# email: rdvillegas@uc.cl
# status: production
# rol: main script

library(glue)
library(here)

# Indicador
indicator <- "3 - Equidad/301 - Hacinamiento"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# Ejecutar scripts de trabajo

source(glue("{dirs@srcdir}/01_clean.R"))
source(glue("{dirs@srcdir}/02_process.R"))
source(glue("{dirs@srcdir}/03_export.R"))
source(glue("{dirs@srcdir}/04_spatialize.R"))
