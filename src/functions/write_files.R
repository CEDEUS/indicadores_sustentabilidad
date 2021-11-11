# Función para escribir los datos a formato csv.

write_indicator <- function(datos, ind_name, ind_scale, outdir){
  
  agnos <- unique(datos$agno)
  
  for (agno in agnos){
    print(glue("Exportando datos para {ind_scale} Año: {agno}"))
    filename <- paste0(indicator_name, "_", agno, ".csv")
    
    tmp <- datos %>%
      ungroup() %>%
      filter(agno == agno) %>%
      select(-agno)
    
    write.csv(tmp, glue("{outdir}{filename}"), 
              row.names = FALSE)
  }
  
}

# Funcion para escribir shp del indicador con columnas por año

write_shp <- function(datos, ind_name, variable, dpa_shp){
  
  datos_wide <- datos %>% 
    mutate(comuna = as.character(comuna)) %>%
    pivot_wider(names_from = agno, values_from = {{ variable }}) 
  
  datos_shp <- datos_wide %>%
    left_join(sf::read_sf(glue("{dirs@dpadir}/{dpa_shp}"))) 
  
  sf::write_sf(datos_shp, glue("{dirs@shpdir}/{ind_name}.shp"), 
               driver = "ESRI Shapefile")
}