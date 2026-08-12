library(dplyr)
library(readr)

raw <- read_csv("model_price_summary_2026_q3.csv", show_col_types = FALSE)

stopifnot(nrow(raw) == 43)
stopifnot(sum(raw$configurations_tracked) == 251)

teaching_data <- raw |>
  transmute(
    model,
    source_row_count,
    configurations_tracked,
    listed_price_low_usd,
    listed_price_high_usd,
    median_listed_price_usd,
    snapshot_date,
    release_quarter
  )

write_csv(teaching_data, "../../data/dji-listed-prices-q3-2026.csv")
