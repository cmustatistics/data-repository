# Reproduce the exact fixed files submitted to the CMU S&DS Data Repository.
# Run from the repository root with: Rscript cleaning-scripts/philippines-pcso-draw-results/prepare.R

results_url <- paste0(
  "https://raw.githubusercontent.com/remo65588-boop/",
  "lottolens-ph-public-data/v2.0.1/data/",
  "verified-pcso-draw-results-snapshot.csv"
)
schedule_url <- paste0(
  "https://raw.githubusercontent.com/remo65588-boop/",
  "lottolens-ph-public-data/v2.0.1/data/pcso-draw-schedule.csv"
)

expected_md5 <- c(
  results = "c443a48a555051bae2ee52506aaf83e4",
  schedule = "1395ed41eccee4451c1733cc4e892dd4"
)

tmp <- c(results = tempfile(fileext = ".csv"),
         schedule = tempfile(fileext = ".csv"))
on.exit(unlink(tmp), add = TRUE)

download.file(results_url, tmp[["results"]], mode = "wb", quiet = FALSE)
download.file(schedule_url, tmp[["schedule"]], mode = "wb", quiet = FALSE)

actual_md5 <- unname(tools::md5sum(tmp))
stopifnot(identical(actual_md5, unname(expected_md5)))

results <- read.csv(tmp[["results"]], colClasses = "character",
                    check.names = FALSE, na.strings = character())
schedule <- read.csv(tmp[["schedule"]], colClasses = "character",
                     check.names = FALSE, na.strings = character())

result_columns <- c(
  "lottery_slug", "draw_date", "draw_time", "winning_numbers",
  "jackpot_amount", "status", "published_at", "source_name", "source_url"
)
schedule_columns <- c(
  "game_slug", "game_name", "game_type", "result_format",
  "normal_draw_days", "normal_draw_times_pht", "timezone",
  "official_source", "reference_page"
)

stopifnot(
  identical(names(results), result_columns),
  identical(names(schedule), schedule_columns),
  nrow(results) == 13457L,
  nrow(schedule) == 9L,
  all(nzchar(results$winning_numbers)),
  all(nzchar(results$source_url)),
  identical(unique(results$status), "published"),
  all(results$draw_date >= "2022-01-02"),
  all(results$draw_date <= "2026-07-20")
)

result_keys <- paste(results$lottery_slug, results$draw_date,
                     results$draw_time, sep = "|")
stopifnot(!anyDuplicated(result_keys))

dir.create("data", showWarnings = FALSE, recursive = TRUE)
stopifnot(
  file.copy(tmp[["results"]],
            "data/philippines-pcso-draw-results-2022-2026.csv",
            overwrite = TRUE),
  file.copy(tmp[["schedule"]],
            "data/philippines-pcso-draw-schedule.csv",
            overwrite = TRUE)
)

message("Verified and wrote 13,457 draw-result rows and 9 schedule rows.")
