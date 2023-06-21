# Make a CSV of all datasets, for searching/sorting by advanced users

# Only run when we're rendering the entire site, not an individual data file
# (e.g. during preview). Don't run on GitHub Actions, as it does not have R
# packages installed.
if (!nzchar(Sys.getenv("QUARTO_PROJECT_RENDER_ALL")) ||
      nzchar(Sys.getenv("CI"))) {
  quit()
}

library(jsonlite)
suppressMessages(library(dplyr))
library(readr)
library(fs)

meta <- stream_in(file("metadata.json"))

extract_info <- function(row) {
  metadata <- meta[row, "metadata"][1, ]

  if (is.na(metadata$data$year)) {
    # not a data listing; skip
    return(NULL)
  }

  # get output link. filename is initially absolute path to Qmd file
  filename <- meta[row, "filename"]

  filename <- path_rel(filename)
  url <- paste0("https://cmustatistics.github.io/data-repository/",
                path_ext_remove(filename),
                ".html")
  subject_area <- path_dir(filename)

  list(
    # ISO 8601 date
    date = format(strptime(metadata$date, "%B %d, %Y"), "%F"),
    datayear = metadata$data$year,
    title = metadata$title,
    description = metadata$description,
    subject = subject_area,
    categories = paste(metadata$categories[[1]], collapse = ", "),
    url = url
  )
}

# Construct a data frame
out <- bind_rows(Map(extract_info, seq_len(nrow(meta))))

write_csv(out, "cmu-statds-datasets.csv")
