[![Travis-CI Build Status](https://travis-ci.org/jtrecenti/rfbCNPJ.svg?branch=master)](https://travis-ci.org/jtrecenti/rfbCNPJ) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/jtrecenti/rfbCNPJ?branch=master&svg=true)](https://ci.appveyor.com/project/jtrecenti/rfbCNPJ)[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/rfbCNPJ)](https://cran.r-project.org/package=rfbCNPJ)

# rfbCNPJ

O pacote `rfbCNPJ` baixa e lê os arquivos contendo a lista de todas as empresas do Brasil, disponibilizado pela [Receita Federal em 15 de dezembro de 2017](http://idg.receita.fazenda.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-abertos-do-cnpj). São duas tabelas por UF: i) empresas, contendo informações como CNPJ, nome da empresa e ii) socios, contendo quadro de sócios.

Como os arquivos são do tipo [fixed width](https://readr.tidyverse.org/reference/read_fwf.html), algumas pessoas podem ter dificuldade para ler e empilhar os arquivos no R. Esse pacote facilita as operações de download e leitura.

## Installation

You can install rfbCNPJ from CRAN with:

``` r
install.packages("rfbCNPJ")
```

You can install the latest version of `rfbCNPJ` from github with:

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

Os dados são carregados numa tabela complexa com duas *list-columns*. 

``` r
library(tibble)
print(dados, n = 27)
```

```
# A tibble: 27 x 3
   file         empresa                  socio                   
   <chr>        <list>                   <list>                  
 1 D71214AC.txt <tibble [15,690 × 3]>    <tibble [26,268 × 6]>   
 2 D71214AL.txt <tibble [60,067 × 3]>    <tibble [109,762 × 6]>  
 3 D71214AM.txt <tibble [64,306 × 3]>    <tibble [121,095 × 6]>  
 4 D71214AP.txt <tibble [15,941 × 3]>    <tibble [28,063 × 6]>   
 5 D71214BA.txt <tibble [422,396 × 3]>   <tibble [787,637 × 6]>  
 6 D71214CE.txt <tibble [193,654 × 3]>   <tibble [352,841 × 6]>  
 7 D71214DF.txt <tibble [194,734 × 3]>   <tibble [368,607 × 6]>  
 8 D71214ES.txt <tibble [179,150 × 3]>   <tibble [354,358 × 6]>  
 9 D71214GO.txt <tibble [328,524 × 3]>   <tibble [619,810 × 6]>  
10 D71214MA.txt <tibble [123,736 × 3]>   <tibble [201,854 × 6]>  
11 D71214MG.txt <tibble [962,930 × 3]>   <tibble [1,916,405 × 6]>
12 D71214MS.txt <tibble [102,208 × 3]>   <tibble [189,673 × 6]>  
13 D71214MT.txt <tibble [141,464 × 3]>   <tibble [262,358 × 6]>  
14 D71214PA.txt <tibble [159,079 × 3]>   <tibble [274,004 × 6]>  
15 D71214PB.txt <tibble [79,275 × 3]>    <tibble [138,596 × 6]>  
16 D71214PE.txt <tibble [224,184 × 3]>   <tibble [426,520 × 6]>  
17 D71214PI.txt <tibble [61,627 × 3]>    <tibble [105,008 × 6]>  
18 D71214PR.txt <tibble [708,109 × 3]>   <tibble [1,392,658 × 6]>
19 D71214RJ.txt <tibble [843,040 × 3]>   <tibble [1,708,931 × 6]>
20 D71214RN.txt <tibble [80,562 × 3]>    <tibble [150,411 × 6]>  
21 D71214RO.txt <tibble [62,385 × 3]>    <tibble [109,774 × 6]>  
22 D71214RR.txt <tibble [11,908 × 3]>    <tibble [21,737 × 6]>   
23 D71214RS.txt <tibble [670,093 × 3]>   <tibble [1,350,159 × 6]>
24 D71214SC.txt <tibble [498,511 × 3]>   <tibble [974,351 × 6]>  
25 D71214SE.txt <tibble [63,303 × 3]>    <tibble [114,081 × 6]>  
26 D71214SP.txt <tibble [2,730,412 × 3]> <tibble [5,585,988 × 6]>
27 D71214TO.txt <tibble [51,629 × 3]>    <tibble [89,911 × 6]>
```

A primeira coluna complexa mostra dados das empresas, e a segunda mostra dados dos sócios.
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

Você pode carregar os arquivos binários diretamente da web usando a função
`rfb_import()`. Essa função baixa os arquivos binários diretamente do
[Dropbox](https://www.dropbox.com/sh/tneczglkt11co0b/AABuRuJR02w2QcUbuhSl1XvLa?dl=0). 
Você pode baixar usando o parâmetro `type=`, com as opções "all" 
(tibble complexa com list columns), "empresas" (tibble retangular) e 
"socios" (tibble retangular).

``` r
empresas <- rfb_import("empresas")
```

Você também pode baixar os dados dos arquivos binários em `.rds` desses links
com arquivos armazenados diretamente no dropbox:

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


