library(tidyverse)
library(geobr)
library(sf)
library(here)

# salvar dados geospaciais

estados <- read_state()
municipios <- read_municipality()
regioes <- read_region()

save(estados, file = here("data", "estados.rda"))
save(municipios,file = here("data", "municipios.rda"))
save(regioes,file = here("data", "regioes.rda"))
