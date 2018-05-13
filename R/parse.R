rfb_read_one <- function(file_name, remove_temp_files = TRUE) {
  # nomes dos arquivos
  file_names <- fs::path_ext_remove(file_name) %>%
    paste0("_tipo", 1:2, ".txt")
  # linhas to arquivo
  lines <- readr::read_lines(file_name)
  # separa as linhas em tipos e salva arquivos separados no computador
  purrr::map(c("^01", "^02"), ~ stringr::str_subset(lines, .x)) %>%
    purrr::walk2(file_names, readr::write_lines)
  # tamanhos das colunas igual aparece no site
  positions <- list(
    tipo1 = c(tipo = 2L, cnpj = 14L, nome_empresarial = 150L),
    tipo2 = c(
      tipo = 2L, cnpj = 14L, indicador_cpf_cnpj = 1L,
      cpf_cnpj_socio = 14L, qualificacao = 2L, nome = 150L
    )
  ) %>%
    purrr::map(~ readr::fwf_widths(.x, names(.x)))
  # le os dados e guarda numa lista de data.frames acessar cada bd com
  # dados$empresa ou dados$socio
  sizes <- purrr::map_int(positions, nrow) %>%
    purrr::map_chr(~ stringr::str_dup("c", .x))
  emp <- readr::read_fwf(file_names[1], positions[[1]], col_types = sizes[1])
  soc <- readr::read_fwf(file_names[2], positions[[2]], col_types = sizes[2])
  if (remove_temp_files) {
    fs::file_delete(file_names)
  }
  tibble::tibble(empresa = list(emp), socio = list(soc))
}

#' Read CNPJ files
#'
#' Read CNPJ files from previously downloaded fixed width files, obtained
#'   from \code{\link{rfb_download}}
#'
#' @param file_name character string containing full paths of the files.
#' @param remove_temp_files remove temporary fixed width files
#'
#' @return list-column tibble containing data of companies and partners
#' @export
rfb_read <- function(file_name, remove_temp_files = TRUE) {
  pb <- progress::progress_bar$new(total = length(file_name))
  file_name %>%
    purrr::set_names(basename(file_name)) %>%
    purrr::map_dfr(~ {
      pb$tick()
      rfb_read_one(.x)
    }, .id = "file")
}

#' Parse directory
#'
#' Lists all files in directory and read them
#'
#' @param dir_name path to directory where text files are
#' @rdname rfb_read
#'
#' @export
rfb_read_dir <- function(dir_name, remove_temp_files = TRUE) {
  rfb_read(fs::dir_ls(dir_name, regexp = "txt$"))
}
