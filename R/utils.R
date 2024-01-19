library(tidyverse)
library(here)
library(sf)
library(leaflet)

load(here("data","estados.rda"))
load(here("data","municipios.rda"))
load(here("data","regioes.rda"))
load(here("data","rtdeaths.rda"))


# script para pirâmide
prep_pyramid <- function(data, year, cod) {
  res <- 
    tibble(data) |> 
    rename(code_muni = cod_municipio_ocor) |> 
    relocate(code_muni) |>  
    filter(ano_ocorrencia == year) |> 
    count(code_muni, faixa_etaria_vitima, sexo_vitima, name = "mortes") |> 
    filter(code_muni == cod) |> 
    complete(sexo_vitima, 
             faixa_etaria_vitima = unique(data$faixa_etaria_vitima),
             fill = list(mortes = 0)) |> 
    select(-code_muni)
    
  return(res)
}
