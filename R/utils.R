library(tidyverse)
library(here)
library(sf)
library(leaflet)
library(plotly)
library(onsvplot)

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
    left_join(x = municipios, by = "code_muni") |> 
    st_drop_geometry() |> 
    filter(code_muni == cod) |> 
    count(faixa_etaria_vitima, sexo_vitima, name = "mortes") |> 
    complete(faixa_etaria_vitima = unique(data$faixa_etaria_vitima),
             sexo_vitima = unique(data$sexo_vitima),
             fill = list(mortes = 0)) |> 
    drop_na()
  
  max_value = max(res$mortes)
  
  plot <- res |> 
    mutate(mortes = ifelse(test = sexo_vitima == "Masculino", 
                           yes = -mortes, no = mortes)) |> 
    mutate(abs_mortes = abs(mortes)) |> 
    plot_ly(x = ~mortes, y = ~faixa_etaria_vitima, 
            color = ~sexo_vitima, colors = c(onsv_palette$blue, onsv_palette$yellow)) |> 
    add_bars(orientation = 'h', hoverinfo = "text", text = ~paste(abs_mortes, "vítima(s)"),
             textposition = "none") |> 
    layout(bargap = 0.1, barmode = 'overlay',
           xaxis = list(tickmode = 'array', 
                        tickvals = c(-(max_value),-max_value/2,0,max_value/2,max_value),
                        ticktext = c(toString(max_value),
                                     toString(max_value/2),
                                     toString(0),
                                     toString(max_value/2),
                                     toString(max_value)),
                        range = c(-max_value, max_value),
                        title = ""),
           yaxis = list(title = "", ticklen = 3, tickcolor = "white"))
  return(plot)
}

# script para serie temporal

prep_ts <- function(data, year, cod) {
  res <-
    tibble(data) |> 
    rename(code_muni = cod_municipio_ocor) |> 
    filter(ano_ocorrencia == year) |> 
    left_join(x = municipios, by = "code_muni") |> 
    st_drop_geometry() |> 
    filter(code_muni == cod) |> 
    count(data_ocorrencia, name = "mortes") |> 
    arrange(data_ocorrencia) |> 
    complete(data_ocorrencia = unique(data$data_ocorrencia), 
             fill = list(mortes = 0)) |> 
    filter(year(data_ocorrencia) == year)
  
  plot <- res |> 
    plot_ly(type = 'scatter', mode = "lines") |> 
    add_trace(x = ~data_ocorrencia, y = ~mortes, fill = "tozeroy",
              line = list(color = onsv_palette$blue, width = 1),
              fillcolor = 'rgba(0, 73, 110, 0.80)', hoverinfo = 'text',
              text = ~paste(mortes,"vítima(s)")) |> 
    layout(showlegend = F,
           xaxis = list(title = ""),
           yaxis = list(title = ""))
  
  return(plot)
}

# scrips para barras (modal)

prep_bars <- function(data, year, cod) {
  res <- 
    tibble(data) |> 
    rename(code_muni = cod_municipio_ocor) |> 
    filter(ano_ocorrencia == year) |> 
    left_join(x = municipios, "code_muni") |> 
    st_drop_geometry() |> 
    filter(code_muni == cod) |> 
    count(modal_vitima, name = "mortes") |> 
    complete(modal_vitima = unique(data$modal_vitima),
             fill = list(mortes = 0))
  
  plot <- res |> 
    plot_ly(x = ~mortes, y = ~reorder(modal_vitima, mortes), 
            type = 'bar') |> 
    layout(yaxis = list(title = "", ticklen = 3, tickcolor = "white"),
           xaxis = list(title = ""))
    
  
  return(plot)
}

# script para mapa

prep_map <- function(data, year, uf) {
  res <-
    tibble(data) |> 
    rename(code_muni = cod_municipio_ocor) |> 
    filter(ano_ocorrencia == year) |> 
    count(code_muni, name = "mortes") |> 
    left_join(x = municipios, by = "code_muni") |> 
    mutate(mortes = replace_na(mortes, 0)) |> 
    filter(abbrev_state == uf) |> 
    st_transform(crs = '+proj=longlat +datum=WGS84')
  
  max_value <- max(res$mortes)
  
  pal <- colorBin(
    palette = "YlGnBu",
    bins = c(0, max_value*0.05, max_value*0.1,
             max_value*0.5, max_value*0.75, max_value)
  )
  
  plot <- 
    leaflet(res) |> 
    addTiles() |> 
    addPolygons(fillColor = ~pal(mortes), fillOpacity = 1,
                weight = 1, color = "black",
                highlightOptions = highlightOptions(color = "white",
                                                    weight = 3,
                                                    bringToFront = T,
                                                    opacity = 1),
                label = paste(res$mortes, "vítima(s)")) |>
    addLegend('bottomright', pal = pal, values = ~mortes,
              title = "Mortes", opacity = 1, 
              labFormat = labelFormat(digits = 0))
    
  return(plot)
}