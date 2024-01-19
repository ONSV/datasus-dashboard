library(tidyverse)
library(here)
library(sf)
library(leaflet)

load(here("data","estados.rda"))
load(here("data","municipios.rda"))
load(here("data","regioes.rda"))
load(here("data","rtdeaths.rda"))

# prepara dados para visualização
prep_data <- function(data, year, code) {
  res <- data |> 
    tibble() |> 
    filter(ano_ocorrencia == year) |> 
    rename(code_muni = cod_municipio_ocor) |> 
    relocate(code_muni) |> 
    left_join(x = municipios, by = "code_muni") |> 
    filter(code_muni == code)
  
  return(res)
}