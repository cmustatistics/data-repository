library(haven)
library(readr)

# haven::as_factor converts columns with Stata labels to ordinary R factors, so
# the data file contains labels by name
d <- as_factor(read_dta("Data_Regional-Studies_GLH-MH-CC.dta"))

write_csv(d, "european-ham.csv")
