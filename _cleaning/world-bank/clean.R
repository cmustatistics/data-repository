# Process the data exported from the World Bank DataBank into a tidy form.

# Warning for future updates: CLASS.csv comes from a different World Bank
# dataset, and uses slightly different country names (e.g. Czech Republic
# instead of Czechia). This version of CLASS.csv has been manually edited to
# ensure they match up. This provides income ratings for countries and their
# region, and presence in CLASS.csv is used to check if a row represents a
# country or a region/grouping. So upon updating CLASS.csv, check the rows with
# IsCountry == 0 and verify that there are no countries in there.

library(dplyr)
library(readr)
library(tidyr)

# We'll want to rename variables from the original terse codes
variable_names <- read.csv("variable-rename-map.csv")

d <- read_csv("286692b4-6216-4655-be71-a299fe59245a_Data.csv",
              na = c("", "NA", ".."))

# Last few rows contain a Last Updated date and source information, but no data
d <- d[1:(nrow(d) - 5), ]

long_d <- d |>
  pivot_longer(contains("[YR"),
               names_to = "Year") |>
  mutate(Year = as.numeric(substring(Year, 1, 4)))

# Rename all the Series Codes according to our rules
long_d$varname <- NA_character_
for (series in unique(long_d$`Series Code`)) {
  new_name <- variable_names |>
    filter(variable == series) |>
    pull(name)

  stopifnot(length(new_name) == 1)

  long_d$varname[long_d$`Series Code` == series] <- new_name
}

# Now make one column per variable, one row per year
wide_d <- long_d |>
  select(-`Series Code`, -`Series Name`) |>
  pivot_wider(names_from = varname,
              values_from = value)

# Now incorporate income group.
wb_income <- read_csv("CLASS.csv") |>
  select(Economy, `Income group`, Region) |>
  mutate(`Income group` = ifelse(`Income group` == "", NA, `Income group`))

wide_d <- wide_d |>
  left_join(wb_income, by = c("Country Name" = "Economy")) |>
  mutate(IsCountry = ifelse(is.na(Region), 0, 1)) |>
  relocate(`Country Name`, `Country Code`, Region, IsCountry, `Income group`, Year)

# Save the data
write_csv(wide_d, "world-bank.csv")

# Finally, write out a Markdown-style table of all the relabeled variables we
# produced with their official World Bank descriptions, so we don't mix them up
vars <- long_d |>
  select(`Series Name`, `Series Code`, varname) |>
  group_by(varname, `Series Name`, `Series Code`) |>
  summarize(n = n())

for (row in seq_len(nrow(vars))) {
  cat("| ", vars[[row, "varname"]], " | ", vars[[row, "Series Name"]], " (",
      vars[[row, "Series Code"]], ") |\n", sep = "")
}
