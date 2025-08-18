




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

ggplot(data = fitness, aes(x = factor(lubridate::year(Start)), y = steps)) +
  geom_boxplot() +
  facet_wrap(~ weekday)


fitness <- read_csv(here("data_online/fitness_data_8_7_25.csv"))
fitness_clean <- fitness |> mutate(Date = mdy_hm(Date)) |>
  mutate(Date = as.Date(Date)) |>
  mutate(month = month(Date, label = TRUE),
         weekday = wday(Date, label = TRUE),
         dayofyear = yday(Date),
         year = year(Date)) |>
  rename(distance = `Walking + Running Distance (mi)`,
         steps = `Step Count (steps)`,
         flights = `Flights Climbed (count)`,
         active_cals = `Active Energy (kcal)`) |>
  mutate(stepgoal = if_else(steps >= 10000, true = 1, false = 0)) |>
  select(-`Heart Rate [Min] (bpm)`, -`Heart Rate [Max] (bpm)`,
         -`Heart Rate [Avg] (bpm)`) |>
  filter(!(is.na(active_cals) & is.na(flights) & is.na(steps) & is.na(distance)))

ggplot(data = fitness_clean, aes(x = Date, y = steps)) +
  geom_line() +
  geom_smooth()

fitness_small <- fitness_clean |>
  filter(year == 2025 & month %in% c("Jan", "Feb", "Mar"))
ggplot(data = fitness_clean, aes(x = weekday, y = active_cals)) +
  geom_boxplot() +
  facet_wrap(~ year)

write_csv(fitness_clean, here("data_online/higham_fitness_clean.csv"))



fitness <- read_csv("data_online/fitness_data_8_7_25.csv")

fitness_notclean <- fitness |> mutate(Date = mdy_hm(Date)) |>
  mutate(Date = as.Date(Date)) |>
  mutate(month = month(Date, label = TRUE),
         weekday = wday(Date, label = TRUE),
         dayofyear = yday(Date),
         year = year(Date)) |>
  rename(distance = `Walking + Running Distance (mi)`,
         steps = `Step Count (steps)`,
         flights = `Flights Climbed (count)`,
         active_cals = `Active Energy (kcal)`) |>
  mutate(stepgoal = if_else(steps >= 10000, true = 1, false = 0)) |>
  select(-`Heart Rate [Min] (bpm)`, -`Heart Rate [Max] (bpm)`,
         -`Heart Rate [Avg] (bpm)`) |>
  filter(!(is.na(active_cals) & is.na(flights) & is.na(steps) & is.na(distance)))

write_csv(fitness_notclean, here("data/higham_fitness_notclean.csv"))
