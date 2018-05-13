[![Travis-CI Build Status](https://travis-ci.org/jtrecenti/rfbCNPJ.svg?branch=master)](https://travis-ci.org/jtrecenti/rfbCNPJ)

# rfbCNPJ

## Installation

You can install rfbCNPJ from github with:

``` r
# install.packages("devtools")
devtools::install_github("jtrecenti/rfbCNPJ")
```

## Download

Você pode baixar o arquivo `.txt` bruto para cada UF usando o comando 
`rfb_download()`. Por padrão, temos `ufs = NULL`, que baixará os arquivos
de todas as UFs. Esses arquivos somam aproximadamente 4.8 GB em disco.

``` r
rfb_download(ufs = c("AC", "RR"), path = "caminho/da/pasta")
```

## Parse

A partir de uma pasta contendo os arquivos txt, você pode carregar as bases
de dados rodando `rfb_read()` com os caminhos dos arquivos ou `rfb_read_dir()`
diretamente para ler todos os arquivos da pasta. Certifique-se de que a pasta
que contém os arquivos a serem lidos contém apenas os arquivos baixados 
em `.txt`.

``` r
path <- "caminho/da/pasta"
all_files <- fs::dir_ls(path)

dados <- rfb_read(all_files)
dados <- rfb_read_fir(path) # equivalente
```

## Carregando dados

Os dados são carregados numa tabela complexa com duas *list-columns*. A primeira
coluna complexa mostra dados das empresas, e a segunda mostra dados dos sócios.
Para carregar uma dessas listas, use `tidyr::unnest()`.

Empresas: (nesse caso, `dados` representa a base completa da receita).

``` r
library(magrittr)

empresas <- dados %>% 
  dplyr::select(file, empresa) %>% 
  tidyr::unnest(empresa)
  
empresas
```

```
# A tibble: 9,048,917 x 4
   file         tipo  cnpj           nome_empresarial                    
   <chr>        <chr> <chr>          <chr>                               
 1 D71214AC.txt 01    07398403000180 BOI GORDO AGROPECUARIA COMERCIO E R…
 2 D71214AC.txt 01    03173169000131 CONSELHO ESCOLAR BOM JESUS          
 3 D71214AC.txt 01    07399184000153 D & A SOLUCOES INFORMATICA LTDA - ME
 4 D71214AC.txt 01    07399188000131 SOCIEDADE AGRICOLA POERINHA         
 5 D71214AC.txt 01    03300047000169 ASSOCIACAO MAO AMIGA DE PRODUTORES …
 6 D71214AC.txt 01    04940648000107 ASSOCIACAO DOS PRODUTORES RURAIS E …
 7 D71214AC.txt 01    04940653000101 CONSELHO ESCOLAR POLO HORTIGRANJEIRO
 8 D71214AC.txt 01    04940654000156 CONSELHO ESCOLAR CENTRO EDUCACIONAL…
 9 D71214AC.txt 01    03301098000105 ASSOCIACAO AGROEXTRATIVISTA SANTOS …
10 D71214AC.txt 01    01653480000152 DENEVS - TERCEIRIZACAO LTDA         
# ... with 9,048,907 more rows

```

Sócios:

``` r
socios <- dados %>% 
  dplyr::select(file, socio) %>% 
  tidyr::unnest(socio)
  
socios
```

```
# A tibble: 17,780,860 x 7
   file   tipo  cnpj  indicador_cpf_c… cpf_cnpj_socio qualificacao nome  
   <chr>  <chr> <chr> <chr>            <chr>          <chr>        <chr> 
 1 D7121… 02    0739… 2                NA             49           SELMA…
 2 D7121… 02    0739… 2                NA             22           MARCE…
 3 D7121… 02    0317… 2                NA             16           MARIA…
 4 D7121… 02    0739… 2                NA             49           DILSO…
 5 D7121… 02    0739… 2                NA             22           ANGEL…
 6 D7121… 02    0739… 2                NA             16           RAIMU…
 7 D7121… 02    0330… 2                NA             16           MOISE…
 8 D7121… 02    0494… 2                NA             16           RAIMU…
 9 D7121… 02    0494… 2                NA             16           MARIA…
10 D7121… 02    0494… 2                NA             16           EUCLI…
# ... with 17,780,850 more rows

```

## Download de arquivos binários

Você pode baixar os dados dos arquivos binários em `.rds` aqui:

- [base_completa.rds (list-column)](https://www.dropbox.com/s/js3lvm0ogpxcjch/rfb.rds?dl=1)
- [empresas](https://www.dropbox.com/s/9h06mn9rzml4d2h/rfb_empresas.rds?dl=1)
- [socios](https://www.dropbox.com/s/67rs8fiv77gu73f/rfb_socios.rds?dl=1)

Para ler um desses arquivos, basta rodar

``` r
dados <- readRDS("caminho/para/dados.rds")
```

## Observação

Você pode fazer filtros da base por UF. Basta olhar o nome do arquivo 
na coluna `file`:

``` r
dados_com_uf <- dados %>% 
  dplyr::mutate(uf = stringr::str_extract(file, "([A-Z]{2})(?=\\.txt)"))
```

# License

MIT

