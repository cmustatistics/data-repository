## Clean the police bias dataset
##
## https://osf.io/vfdrt/overview
##
## The dataset is provided in several files in both wide and long format, but
## they don't match each other perfectly -- some variables are only in one, some
## names are different, etc.
##
## Script by Nynke Niezink, Victoria Sagasta Pereira, and Alex Reinhart

library(dplyr)

## Cohort 2, the COVID online cohort.

# Unfortunately the data is spread across multiple overlapping files in
# different formats, rather than there being one primary file with all the data
# from which all variants are produced. Problems we need to solve:
#
# 1. The matched data in cohort2-long-t1t2t3.csv only contains 53 officers who
# took all 3 surveys. However, TODO
#
# 2. The files use different ID formats for the officers, so some cannot be
# matched. Files with IDs like s1234: cohort2-wide-t1t2, cohort2-wide-t1t2t3,
# cohort2-long-t1t2t3, cohort2-long-t1t2.
#
# Files with IDs like 1-2-3-4-5-ab: cohort2-wide-t1t3, cohort2-long-t1t3.
cohort2_wide_t1t3 <- read.csv("cohort2-wide-t1t3.csv")
cohort2_wide_t1t2 <- read.csv("cohort2-wide-t1t2.csv")
cohort2_wide_t1t2t3 <- read.csv("cohort2-wide-t1t2t3.csv")
cohort2_long_t1t2t3 <- read.csv("cohort2-long-t1t2t3.csv")
cohort2_long_t1t2 <- read.csv("cohort2-long-t1t2.csv")
cohort2_long_t1t3 <- read.csv("cohort2-long-t1t3.csv")

# To solve problem 2, find matching column names so we can identify what string
# matches each ID. Match two data files with overlapping officers by value, so
# we can see how the IDs match up.
colss <- intersect(colnames(cohort2_wide_t1t2), colnames(cohort2_wide_t1t3))
t1t3t2t3 <- cohort2_wide_t1t3 |>
  full_join(cohort2_wide_t1t2, by = colss[-c(1, 11, 14)]) |>
  select(id.x, id = id.y) |>
  na.omit()

# These are the IDs that are in both the t1t2 and t1t3 files, but not the t1t2t3
# file.
key <- as.data.frame(anti_join(t1t3t2t3, cohort2_wide_t1t2t3, by = "id"))

cohort2_long_t1t3 <- as.data.frame(rename(cohort2_long_t1t3, "id.x" = "id"))
cohort2_wide_t1t3 <- as.data.frame(rename(cohort2_wide_t1t3, "id.x" = "id"))

# apply key to t1t3 data with only strings for IDs
keyt1t3l <- key |> left_join(cohort2_long_t1t3, by = "id.x")
keyt1t3w <- key |> left_join(cohort2_wide_t1t3, by = "id.x")

# get t1 and t2 entries for the IDs in the key
longt1t2 <- key[,] |> left_join(cohort2_long_t1t2, by = "id")
widet1t2 <- key[,] |> left_join(cohort2_wide_t1t2, by = "id")

# remove race and education since it's not defined the same as in other data
widet1t2 <- widet1t2[, -c(which(names(widet1t2) == "education"), which(names(widet1t2) == "race"))]

# find matching column names to correctly join data
colsl <- intersect(colnames(keyt1t3l), colnames(longt1t2))
colsw <- intersect(colnames(keyt1t3w), colnames(widet1t2))

# modify long data
translated_t1t3l <- keyt1t3l |> full_join(longt1t2, by = colsl[-c(5:7)])
translated_t1t3l <- as.data.frame(translated_t1t3l)
translated_t1t3l$strat_know <- coalesce(as.vector(translated_t1t3l[,29]), as.vector(translated_t1t3l[,5]))
translated_t1t3l$strat_efficacy <- coalesce(as.vector(translated_t1t3l[,30]), as.vector(translated_t1t3l[,6]))
translated_t1t3l$strat_mot <- coalesce(as.vector(translated_t1t3l[,31]), as.vector(translated_t1t3l[,7]))

# extra cohort 2 long t1t2t3 entries with the same columns as the larger long t1t2t3 data
extra_t1t2t3l <- translated_t1t3l[, c(colnames(cohort2_long_t1t2t3))]

# modify wide data
translated_t1t3w <- keyt1t3w |> full_join(widet1t2, by = colsw)
translated_t1t3w <- as.data.frame(translated_t1t3w)

# extra cohort 2 wide t1t2t3 entries with the same columns as the larger wide t1t2t3 data
extra_t1t2t3w <- translated_t1t3w[, c(colnames(cohort2_wide_t1t2t3))]


## Cohort 1, in-person pre-COVID
c1L <- read.csv("cohort1-long-t1t2.csv")
c1W <- read.csv("cohort1-wide-t1t2.csv")
c2L <- rbind(cohort2_long_t1t2t3, extra_t1t2t3l)
c2W <- rbind(cohort2_wide_t1t2t3, extra_t1t2t3w)
n1 <- nrow(c1W)
n2 <- nrow(c2W)

# strat

c1L$strat <- c(rbind(rep(NA, n1), c1W$strat.t2))
c2L$strat <- c(rbind(rep(NA, n2), c2W$strat.t2, c2W$strat.t3))

# race
c1L$race <- rep(c1W$race, each = 2)
c2L$race <- rep(c2W$race, each = 3)

# education
c1L$education <- rep(c1W$education, each = 2)
c2L$education <- rep(c2W$education, each = 3)

# substitution
c2L$substitution <- c(rbind(c2W$substitution_use, c2W$substitution_intend, c2W$substitution_used))

# perspective
c2L$perspective <- c(rbind(c2W$perspective_use, c2W$perspective_intend, c2W$perspective_used))

# exposure
c1L$exposure <- c(rbind(c1W$exposure_use, c1W$exposure_intend))
c2L$exposure <- c(rbind(c2W$exposure_use, c2W$exposure_intend, c2W$exposure_used))

# individuation
c1L$individuation <- c(rbind(c1W$individuation_use, c1W$individuation_intend))
c2L$individuation <- c(rbind(c2W$individuation_use, c2W$individuation_intend, c2W$individuation_used))

# mindful
c2L$mindful <- c(rbind(c2W$mindful_use, c2W$mindful_intend, c2W$mindful_used))

# add all strategy sub-scales
addItem <- function(name, cohort) {
  if (cohort == 1) {
    vars <- paste0(name, c(".t1", ".t2"))
    c(rbind(c1W[[vars[1]]], c1W[[vars[2]]]))
  } else {
    vars <- paste0(name, c(".t1", ".t2", ".t3"))
    c(rbind(c2W[[vars[1]]], c2W[[vars[2]]], c2W[[vars[3]]]))
  }
}

variableNames <- sub("\\..*", "", colnames(c1W)[c(49:53, 60:64)])
for (name in variableNames) {
  c1L[[name]] <- addItem(name, 1)
  c2L[[name]] <- addItem(name, 2)
}

# biasworry_white: missing in t3 for cohort 2
c1L$biasworry_white <- c(rbind(c1W$biasworry_white.t1, c1W$biasworry_white.t2))
c2L$biasworry_white <- c(rbind(c2W$biasworry_white.t1, c2W$biasworry_white.t2, rep(NA, n2)))

# add all centrality and respect sub-scales
addItem2 <- function(name, cohort) {
  if (cohort == 1) {
    rep(c1W[[name]], each = 2)
  } else {
    rep(c2W[[name]], each = 3)
  }
}

variableNames <- c(paste0("centrality", 1:3), paste0("respect", 1:4))
for (name in variableNames) {
  c1L[[name]] <- addItem2(name, 1)
  c2L[[name]] <- addItem2(name, 2)
}


# output csv data
write.csv(c1L, "police-bias-cohort1-t1t2-long.csv", row.names = FALSE)
write.csv(c2L, "police-bias-cohort2-t1t2t3-long.csv", row.names = FALSE)
