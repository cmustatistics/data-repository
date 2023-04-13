preview_dataset <- function(n = 20) {
  read.csv(paste0("../data/", rmarkdown::metadata$datafile)) |>
    head(n = 20) |>
    rmarkdown::paged_table()
}
