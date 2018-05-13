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

#' Download rfb files
#'
#' Downloads rfb fixed width files from selected UFs.
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
#' \dontrun{
#' rfb_download("AC")
#' rfb_download(c("AC", "RR"))
#' }
rfb_download <- function(ufs = NULL, path = ".", verbose = TRUE) {
  fs::dir_create(path)
  links <- rfb_get_links(ufs)
  purrr::map_chr(links, rfb_download_file, path = path, verbose = verbose)
}
