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
