library(tidyverse)
library(geobr)
library(here)

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


