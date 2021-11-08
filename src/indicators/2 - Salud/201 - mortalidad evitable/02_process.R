#### 201 - Mortalidad Evitable ####

# Autor: Rodrigo Villegas Salgado
# version: 05-11-21
# email: rdvillegas@uc.cl
# status: production
# rol: data processing

# Librerías
library(here)
library(tidyverse)
library(glue)

# Indicador
indicator <- "2 - Salud/201 - mortalidad evitable"

# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

# Importar datos limpios
load(file = glue("{dirs@cleandatadir}/clean.RDS"))
defsout <- defsout %>%
  rename(agno = año)


# Defunciones a nivel comunal
mortprev_com <- defsout %>%
  mutate(TEM = defs / pop,
         Def_esp = TEM * popgrunat) %>%
  group_by(agno, city, comuna) %>%
  summarise(tasa = sum(Def_esp, na.rm = T)/unique(popnat)*100000)

# Defunciones a nivel ciudad
mortprev_city <- defsout %>%
  group_by(agno, city, sexo, edad_grupo) %>%
  summarise(defs = sum(defs),
            pop = sum(pop),
            popgrunat = unique(popgrunat),
            popnat = unique(popnat)) %>%
  mutate(TEM = defs / pop,
         Def_esp = TEM * popgrunat) %>%
  group_by(agno, city) %>%
  summarise(tasa = sum(Def_esp, na.rm = T)/unique(popnat)*100000)

# Defunciones a nivel pmc
mortprev_pmc <- defsout %>%
  mutate(TEM = defs / pop,
         Def_esp = TEM * popgrunat)  %>%
  group_by(agno, comuna) %>%
  summarise(dato = (sum(Def_esp, na.rm = T)/unique(popnat)*100000) %>% round(2) ) %>%
  rename(codcomuna = comuna) %>%
  ungroup


# Guardar resultados

save(mortprev_com, file = glue("{dirs@cleandatadir}/mortprev_com.RDS"))
save(mortprev_city, file = glue("{dirs@cleandatadir}/mortprev_city.RDS"))
save(mortprev_pmc, file = glue("{dirs@cleandatadir}/mortprev_pmc.RDS"))

