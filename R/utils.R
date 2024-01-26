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
load(here("data","lista_municipios.rda"))

# script para pirâmide etária

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
            color = ~sexo_vitima, 
            colors = c(onsv_palette$blue, onsv_palette$yellow)) |> 
    add_bars(orientation = 'h', hoverinfo = "text", 
             text = ~paste(abs_mortes, "vítima(s)"),
             textposition = "none") |> 
    layout(bargap = 0.1, barmode = 'overlay',
           xaxis = list(tickmode = 'array', 
                        tickvals = c(-(max_value), -max_value/2,
                                     0, max_value/2, max_value),
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

# scrips para bar plot (modal)

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
    layout(xaxis = list(title = ""),
           yaxis = list(title = ""))
    
  
  return(plot)
}

# script para criar mapa leaflet

prep_map <- function(data, year, uf, cod) {
  res <-
    tibble(data) |> 
    rename(code_muni = cod_municipio_ocor) |> 
    filter(ano_ocorrencia == year) |> 
    count(code_muni, name = "mortes") |> 
    left_join(x = municipios, by = "code_muni") |> 
    mutate(mortes = replace_na(mortes, 0)) |> 
    filter(abbrev_state == uf) |> 
    st_transform(crs = '+proj=longlat +datum=WGS84')
  
  filter_res <- filter(res, code_muni == cod)
  
  centroid <- st_coordinates(st_centroid(filter_res))
  
  max_value <- max(res$mortes)
  
  labels <- sprintf(
    "<strong>%s</strong><br/>%g óbitos",
    lapply(res$code_muni, code_to_name_muni),
    res$mortes
  ) |> lapply(htmltools::HTML)
  
  label_filter <- sprintf(
    "<strong>%s</strong><br/>%g óbitos",
    lapply(filter_res$code_muni, code_to_name_muni),
    filter_res$mortes
  ) |> lapply(htmltools::HTML)
  
  pal <- colorBin(
    palette = "YlGnBu",
    bins = c(0, max_value*0.05, max_value*0.1,
             max_value*0.5, max_value*0.75, max_value)
  )
  
  plot <- 
    leaflet() |> 
    addTiles() |> 
    addPolygons(
      data = res, 
      fillColor = ~pal(mortes), 
      fillOpacity = 0.7,
      weight = 1, 
      color = "black",
      highlightOptions = highlightOptions(
        color = "white",
        weight = 3,
        bringToFront = T,
        opacity = 1
      ),
      label = labels
    ) |> 
    addPolygons(
      data = filter_res,
      fillColor = ~pal(mortes),
      fillOpacity = 0.7,
      weight = 3,
      color = onsv_palette$yellow,
      opacity = 0.75,
      highlightOptions = highlightOptions(
        color = "white",
        weight = 3,
        bringToFront = T,
        opacity = 1
      ),
      label = label_filter
    ) |> 
    addLegend(
      data = res,
      position = "bottomright",
      pal = pal,
      values = ~mortes,
      opacity = 1,
      title = "Óbitos",
      labFormat = labelFormat(digits = 0)
    ) |> 
    setView(lng = centroid[1], lat = centroid[2], zoom = 9)
    
  return(plot)
}

# função para atualizar de selectInput

select_filter <- function(df, uf) {
  filtered <- arrange(filter(df, abbrev_state == uf), name_muni)
  res <- setNames(as.character(filtered$code_muni), 
                  as.character(filtered$name_muni))
  
  return(res)
}

# função para traduzir código para nome de município

code_to_name_muni <- function(cod) {
  res <- filter(lista_municipios, code_muni == cod)$name_muni
  
  return(res)
}

# função para traduzir sigla de uf para nome

uf_acronym_to_name <- function(uf) {
  states <- c("Acre", "Alagoas", "Amapá", "Amazonas", "Bahia", "Ceará", "Distrito Federal", 
              "Espírito Santo", "Goiás", "Maranhão", "Mato Grosso", "Mato Grosso do Sul", 
              "Minas Gerais", "Pará", "Paraíba", "Paraná", "Pernambuco", "Piauí", "Rio de Janeiro", 
              "Rio Grande do Norte", "Rio Grande do Sul", "Rondônia", "Roraima", "Santa Catarina", 
              "São Paulo", "Sergipe", "Tocantins")
  acronyms <- c("AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", "PA", 
                "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO")
  brazil_states_df <- tibble(State = states, Acronym = acronyms)
  
  res <- select(filter(brazil_states_df, Acronym == uf), State)[[1]]
  
  return(res)
}

uf_to_region <- function(uf) {
  res <- select(filter(estados, abbrev_state == uf), name_region)[[1]]
  
  return(res)
}
