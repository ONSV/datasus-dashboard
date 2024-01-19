library(tidyverse)
library(geobr)
library(here)
library(readODS)

# salvar dados geospaciais

estados <- read_state()
municipality <- read_municipality()
municipios <- mutate(municipality, 
                     code_muni = str_sub(as.character(code_muni),1,6))
regioes <- read_region()

save(estados, file = here("data", "estados.rda"))
save(municipios,file = here("data", "municipios.rda"))
save(regioes,file = here("data", "regioes.rda"))

# salvando rtdeaths para melhorar performance

library(roadtrafficdeaths)
save(rtdeaths, file = here("data","rtdeaths.rda"))

# salvando códigos de municípios IBGE

lista_municipios <- read_ods(here("data-raw","ibge_cod_municipios.ods")) |> 
  rename(code_muni = `Código.Município.Completo`, name_muni = Nome_Município,
         uf = Nome_UF) |> 
  select(code_muni, name_muni, uf)
save(lista_municipios, file = here("data","lista_municipios.rda"))