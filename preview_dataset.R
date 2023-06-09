#' Produce a nice preview table of the chosen dataset
#'
#' Reads the name of the data file from the `datafile` attribute of the page
#' metadata.
#'
#' @param n Number of rows of data to include in the table. This should not be
#'   so large that the web page contains megabytes of data, but should contain
#'   enough rows that readers can understand the format of the data.
#' @param dataset Name of file (in `data/` directory) to load and preview.
#'   Defaults to the `datafile` attribute of the page metadata.
#' @return A `paged_df` object that is automatically formatted by R Markdown as
#'   a nice table.
preview_dataset <- function(n = 20, dataset = rmarkdown::metadata$datafile) {
  read.csv(paste0("../data/", dataset)) |>
    head(n = n) |>
    rmarkdown::paged_table(options = list(rownames.print = FALSE))
}

preview_datasets <- function(n = 20, datasets = rmarkdown::metadata$data$files) {
  for (dataset in datasets) {
    url <- paste0("https://cmustatistics.github.io/data-repository/data/",
                  dataset)
    cat("<h4><a href=\"", url, "\">", dataset, "</a></h4>\n")
    cat(rmarkdown:::print.paged_df(preview_dataset(n, dataset)))
  }
}
