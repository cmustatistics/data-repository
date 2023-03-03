library(haven)
library(dplyr)
library(tidyr)

# summary ratings of faces, for simple t-test and ANOVA analyses
faces <- read_sav("Male Makeup Data by Face.sav")
write.csv(faces, "male-makeup-faces.csv", row.names = FALSE)

face_info <- faces %>%
  select(FaceID, Participant_Age = Age, Participant_Race = Race)

participants <- read_sav("Male Makeup Data by Participant.sav")
participants$Rater <- seq_len(nrow(participants))

# one row per rating, for fancier hierarchical models
participants %>%
  select(-MTurkID, -AverageNoMakeup, -AverageMakeup) %>%
  rename(Rater_Sex = Sex, Rater_Age = Age, Rater_Race = Race) %>%
  pivot_longer(cols = starts_with("@"),
               names_to = c("Participant", "Makeup"),
               names_pattern = "@([[:digit:]]+)_([[:ascii:]]+)",
               values_to = "rating") %>%
  mutate(Participant = as.numeric(Participant)) %>%
  inner_join(face_info, by = c("Participant" = "FaceID")) %>%
  write.csv("male-makeup-ratings.csv", row.names = FALSE)
