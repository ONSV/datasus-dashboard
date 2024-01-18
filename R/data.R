library(tidyverse)
library(roadtrafficdeaths)
library(geobr)
library(leaflet)
library(sf)
library(here)

# base de municípios
geobr <- read_municipality(year = 2022)

municipios <- geobr |> 
  mutate(code_muni = str_sub(as.character(code_muni),1,6))

mortes_munic <- rtdeaths |> 
  select(cod_modal, modal_vitima, data_ocorrencia, ano_ocorrencia,
         idade_vitima, faixa_etaria_vitima, sexo_vitima,
         raca_vitima, cod_municipio_ocor) |> 
  rename(code_muni = cod_municipio_ocor)

geodf_munic <- left_join(municipios, mortes_munic, by = "code_muni")

save(geodf_munic, file = here("data","geodf_munic.rda"))

# base de estados
geobr <- read_state(year = 2020)

estados <- geobr |> 
  rename(uf = name_state)

mortes_estado <- rtdeaths |> 
  select(cod_modal, modal_vitima, data_ocorrencia, ano_ocorrencia,
         idade_vitima, faixa_etaria_vitima, sexo_vitima,
         raca_vitima, nome_uf_ocor) |> 
  rename(uf = nome_uf_ocor)

geodf_estado <- left_join(mortes_estado, estados, by = "uf")
