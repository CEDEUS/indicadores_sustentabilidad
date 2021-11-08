# Importar constantes de archivos

# Definir una clase para las clases de directorios

setClass(Class="workDirs",
         representation(
           cleandatadir = "character",
           outdircom   = "character",
           outdircty   = "character",
           outdirpmc   = "character",
           dpadir      = "character",
           shpdir      = "character",
           srcdir      = "character"
         )
)

# Definir una función que define automáticamente las carpetas de trabajo en función del indicador

getDirs <- function(indicator) {

  return( new("workDirs", 
              cleandatadir = here(glue("data/temp/{indicator}/")),
              outdircom = glue(here("output"), "/comuna/{indicator}/"),
              outdircty = glue(here("output"), "/ciudad/{indicator}/"),
              outdirpmc = glue(here("output"), "/pmc/{indicator}/"),
              dpadir =  here("data/raw/common/dpa/") ,
              shpdir = glue(here("output/shp/{indicator}/")),
              srcdir = glue(here("src/indicators/{indicator}/"))
              )
          )
  
  
}


