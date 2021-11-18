context("Identificar Ferias")
library(stringdist); library(dplyr)
library(testthat)

source("src/functions/pattern_matching.R")

region1 <-  c("iquique.php", "alto.php", "pozo.php")
region4 <- c("serena.php", "coquimbo.php", "andacollo.php", "vicuna.php", 
             "Ovalle.php", "combarbala.php", "montepatria.php", "losvilos.php", 
             "salamanca.php", "canela.php", "illapel.php")
region13 <- c("rm/buin.php", "rm/caleratango.php", "rm/cerrillos.php", 
              "rm/Cerronavia.php", "rm/colina.php", "rm/conchali.php", "rm/laflorida.php", 
              "rm/elbosque.php", "rm/lagranja.php", "rm/ecentral.php", "rm/huechuraba.php", 
              "rm/independencia.php", "rm/imaipo.php", "rm/curacavi.php", "rm/lacisterna.php", 
              "rm/lapintana.php", "rm/lareina.php", "rm/lampa.php", "rm/lascondes.php", 
              "rm/barnechea.php", "rm/loespejo.php", "rm/loprado.php", "rm/macul.php", 
              "rm/maipu.php", "rm/melipilla.php", "rm/nunoa.php", "rm/phurtado.php", 
              "rm/pacerda.php", "rm/penaflor.php", "rm/panalolen.php", "rm/providencia.php", 
              "rm/Pudahuel.php", "rm/palto.php", "rm/pomaire.php", "rm/quilicura.php", 
              "rm/quintanormal.php", "rm/recoleta.php", "rm/renca.php", "rm/sbernardo.php", 
              "rm/sjoaquin.php", "rm/smiguel.php", "rm/sramon.php", "rm/santiago.php", 
              "rm/talagante.php", "rm/vitacura.php")

test_that("dos palabras empiecen y terminen con las mismas letras", {
  expect_equal(object = check_firstlast(string1 = "Pedro Aguirre Cerda",
                                        string2 = "pacerda"),
               expected = TRUE)
  
  expect_equal(object = check_firstlast(string1 = "Alto Hospicio",
                                        string2 = "Alto"),
               expected = TRUE)
})


test_that("identifica correctamente nombres abreviados", {
  expect_equal(object = match_name(
                          string1 = "Pedro Aguirre Cerda", 
                          string2 = region13 ),
               expected = "rm/pacerda.php")
  
  expect_equal(object = match_name(
    string1 = "San Bernardo", 
    string2 = region13),
    expected = "rm/sbernardo.php")
  

  
  expect_equal(object = match_name(
    string1 = "quinta normal", 
    string2 = region13),
    expected = "rm/quintanormal.php")
  
  expect_equal(object = match_name(
    string1 = "penalolen", 
    string2 = region13),
    expected = "rm/panalolen.php")
  
  expect_equal(object = match_name(
    string1 = "cerro navia", 
    string2 = region13),
    expected = "rm/Cerronavia.php")
  
  expect_equal(object = match_name(
    string1 = "alto hospicio", 
    string2 = region1),
    expected = "alto.php")
  
  expect_equal(object = match_name(
    string1 = "la serena", 
    string2 = region4),
    expected = "serena.php")
  
  
})

