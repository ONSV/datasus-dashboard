### Fontes

Os dados de óbitos relacionadas à sinistros de trânsito têm como fonte o **Sistema de Informações de Mortalidade (SIM)**, do **Departamento de Informática do Sistema Único de Saúde do Brasil (DATASUS) - Ministério da Saúde**. Filtrou-se as declarações de óbito cuja causa se encontra entre os códigos CID-10 entre V01 e V89. A separação por unidade geográfica considerou o código do município de **residência** na declaração de óbito. Os dados foram coletados com auxílio do pacote [`microdatasus`](www.github.com/rfsaldanha/microdatasus) e compilados no pacote [`roadtrafficdeaths`](www.github.com/pabsantos/roadtrafficdeaths).

A classificação por modal da vítima foi realizada no seguinte formato:

- **Pedestre**: "V0 - Pedestre traumatizado em um acidente de transporte"
- **Bicicleta**: "V1 - Ciclista traumatizado em um acidente de transporte"
- **Motocicleta**: "V2 - Motociclista traumatizado em um acidente de transporte"
- **Triciclo**: "V3 - Ocupante de triciclo motorizado traumatizado em acidente de transporte"
- **Automóvel**: "V4 - Ocupante de automóvel traumatizado em um acidente de transporte" e "V5 - Ocupante de camionete traumatizado em um acidente de transporte"
- **Caminhão**: "V6 - Ocupante de um veículo de transporte pesado traumatizado em um acidente de transporte"
- **Ônibus**: "V7 - Ocupante de ônibus traumatizado em um acidente de transporte"
- **Outros**: "V8 - Outros acidentes de transporte terrestre"

A malha municipal utilizada tem como fonte o **Instituto Brasileiro de Geografia e Estatística (IBGE)**, coletada através do pacote [`geobr`](www.github.com/ipeagit/geobr), produzido pelo **Instituto de Pesquisa Econômica Aplicada (IPEA)**. A base cartográfica é oriunda do **OpenStreetMap**.

### Autoria

Esse dashboard foi desenvolvido por [João Pedro Saraiva](https://www.github.com/jotasaraiva) (joao.saraiva@onsv.org.br) e [Pedro Augusto Borges dos Santos](https://www.github.com/pabsantos) (pedro.borges@onsv.org.br). O [**Observatório Nacional de Segurança Viária**](https://www.onsv.org.br) detém os direitos autorais. O código desse dashboard pode ser acessado no [repositório do GitHub](https://github.com/onsv/datasus-dashboard) do Observatório. 

### Referências

Pereira, R.H.M.; Gonçalves, C.N.; et. all (2019) geobr: Loads Shapefiles of Official Spatial Data Sets of Brazil. GitHub repository - https://github.com/ipeaGIT/geobr.

SALDANHA, Raphael de Freitas; BASTOS, Ronaldo Rocha; BARCELLOS, Christovam. Microdatasus: pacote para download e pré-processamento de microdados do Departamento de Informática do SUS (DATASUS). Cad. Saúde Pública, Rio de Janeiro , v. 35, n. 9, e00032419, 2019. Available from http://ref.scielo.org/dhcq3y.

Santos PAB, Saraiva JPM (2023). _roadtrafficdeaths: Road Traffic Deaths Data from Brazil_. https://pabsantos.github.io/roadtrafficdeaths/, https://github.com/pabsantos/roadtrafficdeaths.