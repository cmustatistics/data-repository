library(cli)

default_csv_loader <- function(dataset_name) {
  readr::read_csv(file.path("../data", dataset_name), guess_max = Inf,
           show_col_types = FALSE)
}

#' Produce a nice preview table of the chosen dataset
#'
#' Reads the name of the data file from the `datafile` attribute of the page
#' metadata.
#'
#' @param n Number of rows of data to include in the table. This should not be
#'   so large that the web page contains megabytes of data, but should contain
#'   enough rows that readers can understand the format of the data.
#' @param dataset Either a dataframe or the name of a CSV file (in `data/`
#'   directory) to load and preview. Defaults to the `datafile` attribute of the
#'   page metadata.
#' @return A `paged_df` object that is automatically formatted by R Markdown as
#'   a nice table.
preview_dataset <- function(n = 20, dataset = rmarkdown::metadata$datafile) {
  if (is.character(dataset)) {
    if (tolower(tools::file_ext(dataset)) == "csv") {
      df <- default_csv_loader(dataset)
    } else {
      cli_abort(c("Preview by filename is only implemented for CSV files",
                  x = "Unable to load {.path {dataset}}"))
    }
  } else if (is.data.frame(dataset)) {
    df <- dataset
  } else {
    cli_abort("Invalid dataset type; must be a string or a data frame")
  }
  df |>
    head(n = n) |>
    rmarkdown::paged_table(options = list(rownames.print = FALSE))
}

preview_datasets <- function(n = 20, datasets = rmarkdown::metadata$data$files) {
  # datasets can be either a named list of dataframes, or a character vector
  if (!is.list(datasets)) {  #case where only a vector of names is provided
    datasets <- sapply(datasets, function(d) { preview_dataset(n, d) },
                       simplify = FALSE)
  }

  # datasets is now a named list of dataframes
  for (d in names(datasets)) {
    url <- paste0("https://cmustatistics.github.io/data-repository/data/", d)
    cat("<h4><a href=\"", url, "\">", d, "</a></h4>\n")
    cat(rmarkdown:::print.paged_df(datasets[[d]]))
  }
}
