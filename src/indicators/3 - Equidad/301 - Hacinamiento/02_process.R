#### 301 - Hacinamiento ####

# Autor: Rodrigo Villegas Salgado
# version: 04-10-21
# email: rdvillegas@uc.cl
# status: development
# rol: data processing

# TODO: añadir datos de censo 2002 y quizás 2012

# Librerías

library(tidyverse)
library(here)
library(glue)

# Nombre Indicador
indicator <- "3 - Equidad/301 - Hacinamiento"
# Importar funciones auxiliares
source("src/functions/get_workdirs.R")

# Rutas de trabajo
dirs <- getDirs(indicator)

load(file = glue("{dirs@cleandatadir}/clean.RDS"))

# Calcular hacinamiento

hacinam <- censo2017_hac %>% 
  mutate( ind_hacinam = case_when( p04 >= 1 ~ cant_per/p04,
                                   # Indice Sin dormitorios se elige de tal manera que: 
                                   # 1 persona viviendo en un estudio no presenta hacinamiento, 
                                   # 2 personas hacinamiento medio y mas de 3, hacinamiento critico (por eso se multiplica x2)
                                   p04 == 0 ~ cant_per*2),
          hacinamiento = case_when(ind_hacinam > 4.9 ~ 2,
                                   ind_hacinam > 2.4 ~ 1,
                                   ind_hacinam < 2.5 ~ 0)) %>%
  select(comuna, city, ind_hacinam, hacinamiento) 

# Calcular indicador a nivel de ciudad

hacinam_cty <- hacinam %>%
  group_by(city) %>%
  summarise(Hacinados = round(sum(hacinamiento > 0, na.rm = T)/ n()*100,1),
            agno = 2017)

# Calcular indicador a nivel de comuna

hacinam_com <- hacinam %>%
  group_by(comuna, city) %>%
  summarise(Hacinados = round(sum(hacinamiento > 0, na.rm = T)/ n()*100,1),
            agno = 2017)

# Calcular indicador a nivel de comuna y formato pmc

hacinam_pmc <- hacinam_com %>%
  rename(dato = Hacinados) %>%
  mutate(comuna = as.numeric(comuna),
         agno = 2017) %>%
  select(agno, comuna, dato) %>%
  ungroup

# Guardar resultados

save(hacinam_cty, file = glue("{dirs@cleandatadir}/hacinam_cty.RDS"))
save(hacinam_com, file = glue("{dirs@cleandatadir}/hacinam_com.RDS"))
save(hacinam_pmc, file = glue("{dirs@cleandatadir}/hacinam_pmc.RDS"))

