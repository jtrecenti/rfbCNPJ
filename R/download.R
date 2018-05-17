rfb_get_links <- function(ufs = NULL) {
  url_base <- glue::glue(
    "http://idg.receita.fazenda.gov.br",
    "/orientacao/tributaria/cadastros/",
    "cadastro-nacional-de-pessoas-juridicas-cnpj/",
    "dados-abertos-do-cnpj"
  )
  all_links <- url_base %>%
    httr::GET() %>%
    xml2::read_html() %>%
    xml2::xml_find_all("//a[@class='external-link']") %>%
    xml2::xml_attr("href") %>%
    stringr::str_subset("cadastro")

  if (!is.null(ufs)) {
    re_ufs <- paste(ufs, "$", sep = "", collapse = "|")
    all_links <- stringr::str_subset(all_links, re_ufs)
  }
  all_links
}

rfb_download_file <- function(link, path, verbose = TRUE) {
  file_name <- link %>%
    basename() %>%
    stringr::str_extract("[^.]+$") %>%
    fs::path(ext = "txt")
  file_name <- stringr::str_c(path, file_name, sep = "/")
  if (verbose) {
    message(basename(file_name))
  }
  if (!file.exists(file_name)) {
    httr::GET(
      link,
      httr::write_disk(file_name, overwrite = TRUE),
      httr::progress()
    )
  }
  file_name
}

#' Download RFB files
#'
#' Downloads RFB fixed width files from selected UFs.
#'
#' @param ufs character vector of UFs to download. If \code{NULL} (default), downloads all UFs.
#' @param path path to download the files.
#' @param verbose print status messages
#'
#' @return character vector containing full paths of downloaded files.
#'
#' This function needs internet connection. It does not overwrite existing files.
#'
#' @export
#'
#' @examples
#'
#' \donttest{
#' rfb_download("AC", path = file.path(tempdir(), "txt_files"))
#' rfb_download(c("AC", "RR"), path = file.path(tempdir(), "txt_files"))
#' }
rfb_download <- function(ufs = NULL, path, verbose = TRUE) {
  fs::dir_create(path)
  links <- rfb_get_links(ufs)
  purrr::map_chr(links, rfb_download_file, path = path, verbose = verbose)
}


#' Import data from binary files
#'
#' Downloads and reads data directly from Kaggle Datasets, where we have uploaded parsed data.
#'
#' @param type if \code{type="all"}, download list-column tibble containing all data. If \code{type="empresas"}, downloads rectangular database of companies. If \code{type="socios"}, downloads rectangular database of partners.
#' @param path directory name to save temporary files.
#' @param remove remove temporary files? Default is TRUE.
#'
#' @export
#'
#' @examples
#' \donttest{
#' empresas <- rfb_import("empresas", path = file.path(tempdir(), "rds_files"))
#' }
rfb_import <- function(type = c("all", "empresas", "socios"),
                       path, remove = TRUE) {
  fs::dir_create(path)
  type <- match.arg(type)
  link <- switch(
    type,
    all = "https://www.dropbox.com/s/js3lvm0ogpxcjch/rfb.rds?dl=1",
    empresas = "https://www.dropbox.com/s/9h06mn9rzml4d2h/rfb_empresas.rds?dl=1",
    socios = "https://www.dropbox.com/s/67rs8fiv77gu73f/rfb_socios.rds?dl=1"
  )
  tmp <- tempfile(pattern = paste0(type, "_"), fileext = ".rds", tmpdir = path)
  httr::GET(link, httr::write_disk(tmp, overwrite = TRUE), httr::progress())
  message("Download finished. Loading data into R...")
  d <- readRDS(tmp)
  file.remove(tmp)
  d
}
