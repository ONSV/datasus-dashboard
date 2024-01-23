if("roadtrafficdeaths" %in% (.packages())) {
  detach("package:roadtrafficdeaths", unload = T)
}

load_time_1 <- system.time({
  library(roadtrafficdeaths)
  road_deaths <- rtdeaths
})

load_time_2 <- system.time({
  load(here("data","rtdeaths.rda"))
})

print(load_time_1)
print(load_time_2)