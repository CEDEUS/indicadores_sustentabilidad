# Funcion para identificar la palabra más cercana entre una palabra y un vector
# de palabras.

ClosestMatch = function(string, stringVector , dist){
  
  stringVector[stringdist::amatch(string, stringVector, maxDist = dist)]
  
}

# Una extensión de ClosestMatch para identificar la palabra más parecida en un
# set. La adaptación se hizo para filtrar nombres de comunas abreviadas en text.

match_name <- function(string1, string2) {
  first_letter <- stringr::str_extract(string1, "^\\D")
  words <- stringr::str_split(string1, " ") %>% unlist
  last_word <- words[length(words)]
  
  # Seleccionar aquellas palabras que empiecen igual que el original
  starting1 <- grep(paste0("^", first_letter, ""), x = string2, ignore.case = T)
  # O seleccionar aquellas palabras que contengan al menos la última palabra
  starting2 <- grep(last_word, x = string2, ignore.case = T)
  # Unir ambos casos
  starting <- c(starting1, starting2)
  # Filtrar las palabras según los criterios anteriores
  target_word <- string2[starting]
  # Calcualr la palabra más parecida a la original
  ClosestMatch(last_word, target_word, dist = 10)
}



