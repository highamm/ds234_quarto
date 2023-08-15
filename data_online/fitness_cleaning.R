




## fitness cleaning

library(tidyverse)
library(lubridate)
library(here)
fitness <- read_csv(here("data_online/fitness_data_23_08.csv"))

fitness |> View()
fitness <- fitness |> mutate(Start = mdy_hm(Start)) |>
  mutate(Start = as.Date(Start)) |>
  mutate(month = month(Start, label = TRUE),
         weekday = wday(Start, label = TRUE),
         dayofyear = yday(Start)) |>
  rename(distance = `Distance (mi)`,
         steps = `Steps (count)`,
         flights = `Flights Climbed (count)`,
         active_cals = `Active Calories (kcal)`) |>
  mutate(stepgoal = if_else(steps >= 10000, true = 1, false = 0)) |>
  select(-Finish)

ggplot(data = fitness, aes(x = Start, y = steps)) +
  geom_line() +
  geom_smooth(se = FALSE)

ggplot(data = fitness, aes(x = month, y = steps)) +
  geom_boxplot()


write_csv(fitness, here("data_online/higham_fitness_clean.csv"))



fitness <- read_csv("data_online/fitness_data_23_08.csv")

fitness_notclean <- fitness |> mutate(Start = mdy_hm(Start)) |>
  mutate(month = month(Start),
         weekday = wday(Start),
         dayofyear = yday(Start)) |>
  rename(distance = `Distance (mi)`,
         steps = `Steps (count)`,
         flights = `Flights Climbed (count)`,
         active_cals = `Active Calories (kcal)`) |>
  mutate(stepgoal = if_else(steps >= 10000, true = 1, false = 0)) |>
  select(-Finish) |>
  mutate(Start = as.character(Start))

write_csv(fitness_notclean, here("data/higham_fitness_notclean.csv"))
