# Factors with `forcats`

__Goals:__

* Use the `forcats` package to change the levels of factors, or to re-order levels of factors in a way that makes tables and graphs easier to read.

## Change Factor Levels

__The Data__: The `pokemon_allgen.csv` data set contains observations on Pokemon from the first 6 Generations (the first 6 games). There are 20 variable in this data set, but, of particular interest for this chapter are

* `Type 1`, the first Type characteristic of the Pokemon (a factor with 13 levels)
* `Type 2`, the second Type characteristic of the Pokemon (a factor with 13 levels, `NA` if the Pokemon only has one type)
* `Generation`, the generation the Pokemon first appeared in (a factor with 6 levels)

Read in the data set with `read_csv()`. Then, use a `mutate()` statement to make a `Generation_cat` variable that is a factor.


```r
library(tidyverse)
library(here)
pokemon_df <- read_csv(here("data/pokemon_allgen.csv")) |>
  mutate(Generation_cat = factor(Generation))
```

One easy way to get a quick summary of a `factor` variable is to use `group_by()` and `n()` within a `summarise()` statement:


```r
pokemon_df |> group_by(`Type 1`) |>
  summarise(counttype = n())
#> # A tibble: 18 × 2
#>    `Type 1` counttype
#>    <chr>        <int>
#>  1 Bug             75
#>  2 Dark            31
#>  3 Dragon          41
#>  4 Electric        90
#>  5 Fairy           18
#>  6 Fighting        27
#>  7 Fire            56
#>  8 Flying           6
#>  9 Ghost           58
#> 10 Grass           73
#> 11 Ground          42
#> 12 Ice             24
#> 13 Normal         108
#> 14 Poison          30
#> 15 Psychic         73
#> 16 Rock            47
#> 17 Steel           29
#> 18 Water          119
```

<br>

### `fct_recode()` to Rename Levels

Now, let's make a bar plot that examines how many `Legendary` Pokemon first appear in each generation, using `dplyr` commands that we've used and a simple `geom_col()`:


```r
pokemon_legend <- pokemon_df |> filter(Legendary == TRUE) |>
  group_by(Generation_cat) |>
  summarise(nlegend = n())
ggplot(data = pokemon_legend, aes(x = Generation_cat, y = nlegend)) +
  geom_col()
```

<img src="07-forcats_files/figure-html/unnamed-chunk-3-1.png" width="672" />

We've discussed how to change many aspects of `ggplot2` graphs, but we haven't discussed how to rename the labels of levels of a categorical variable, whether those appear in the x-axis or in a separate legend. The easiest way to do this is to rename the levels in the factor itself using `fct_recode()`. Suppose, for example, that we want to relabel the Generation number with the actual region corresponding to each game (Kanto, Johto, Hoenn, Sinnoh, Unova, and Kalos). The function `fct_recode()` takes the name of a factor already present in the data set as its first argument and then a series of renaming schemes (new_name = "old_name") as its remaining arguments.


```r
pokemon_legend <- pokemon_legend |>
  mutate(Generation_cat2 = fct_recode(Generation_cat, Kanto = "1",
                                      Johto = "2", Hoenn = "3",
                                      Sinnoh = "4", Unova = "5",
                                      Kalos = "6")) |>
  select(Generation_cat2, everything())
head(pokemon_legend)
#> # A tibble: 6 × 3
#>   Generation_cat2 Generation_cat nlegend
#>   <fct>           <fct>            <int>
#> 1 Kanto           1                    6
#> 2 Johto           2                    5
#> 3 Hoenn           3                   34
#> 4 Sinnoh          4                   17
#> 5 Unova           5                   27
#> 6 Kalos           6                   13
ggplot(data = pokemon_legend,
       aes(x = Generation_cat2, y = nlegend)) +
  geom_col()
```

<img src="07-forcats_files/figure-html/unnamed-chunk-4-1.png" width="672" />

### Collapsing Many Levels Into Fewer Levels with `fct_collapse()`

Sometimes, you might want to collapse the levels of two or more factors into a single level. With the Pokemon data set, there isn't an example where this really makes sense, but, in the exercises, you'll see a good use for this function with the social survey data set. For practice, we can collapse the `Ice` and `Dark` type Pokemon into a new level called `Coolest` and we can collapse the `Poison`, `Fighting`, and `Fire` type Pokemon into a new level called `Least_Cool`. 


```r
pokemon_long <- pokemon_df |> pivot_longer(c(`Type 1`, `Type 2`),
                            names_to = "Number",
                            values_to = "Type")
pokemon_long |>
  mutate(new_type = fct_collapse(Type, Coolest = c("Ice", "Dark"),
                                 Least_Cool = c("Fire", "Fighting", "Poison"))) |>
  select(new_type, Type, everything())
#> # A tibble: 1,894 × 22
#>    new_type   Type     `#` Name   Total    HP Attack Defense
#>    <fct>      <chr>  <dbl> <chr>  <dbl> <dbl>  <dbl>   <dbl>
#>  1 Grass      Grass      1 Bulba…   318    45     49      49
#>  2 Least_Cool Poison     1 Bulba…   318    45     49      49
#>  3 Grass      Grass      2 Ivysa…   405    60     62      63
#>  4 Least_Cool Poison     2 Ivysa…   405    60     62      63
#>  5 Grass      Grass      3 Venus…   525    80     82      83
#>  6 Least_Cool Poison     3 Venus…   525    80     82      83
#>  7 Grass      Grass      3 Venus…   525    80     82      83
#>  8 Least_Cool Poison     3 Venus…   525    80     82      83
#>  9 Least_Cool Fire       4 Charm…   309    39     52      43
#> 10 <NA>       <NA>       4 Charm…   309    39     52      43
#> # … with 1,884 more rows, and 14 more variables:
#> #   `Sp. Atk` <dbl>, `Sp. Def` <dbl>, Speed <dbl>,
#> #   Generation <dbl>, Legendary <lgl>, id <chr>,
#> #   identifier <chr>, height <dbl>, weight <dbl>,
#> #   base_experience <dbl>, order <dbl>, is_default <dbl>,
#> #   Generation_cat <fct>, Number <chr>
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

What happens to the levels that aren't being re-specified?

<br>

### Exercises {#exercise-7-1}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-7).

1. What `dplyr` function(s) could you also use to create the new levels that were created with `fct_collapse()`? Why might it be a little easier to use `fct_collapse()`? 

2. \* We did not properly explore the data set before making the graphs above, and, in fact, there is some double counting of Pokemon in this data set (this is another example where being familiar with the data set you're working with is advantageous: people familiar with Pokemon know that there are fewer than 947 Pokemon in Generations 1 through 6). 

Figure out why some Pokemon are double counted. Then, create a new data set that only keeps one observation per Pokemon `#`. 

3. Create the bar plot with your non-duplicated data set. Are your results significantly changed?

<br>

## Reorder Factor Levels

### Change the Order of Levels by a Quantitative Variable with `fct_reorder()`

You might also be interested in re-ordering the x or y-axis of a particular graph so that the order of the factors correspond to, for example, the median of a quantitative variable for each level. The reason you would want to do this is easiest to see with an example. For example, suppose you want to look at the most common Pokemon types across the first 6 generations. We use the non-duplicated data set from the previous section's exercises, we pivot the data so that type is in one column, and we remove observations with missing `Type`, which correspond to the second `Type` of Pokemon that only have a single `Type`:


```r
pokemon_nodup <- pokemon_df |> group_by(`#`) |> slice(1) |>
  ungroup()
pokemon_long <- pokemon_nodup |>
  pivot_longer(c(`Type 1`, `Type 2`),
               names_to = "Number",
               values_to = "Type")
pokemon_sum <- pokemon_long |>
  group_by(Type) |>
  summarise(count_type = n()) |>
  filter(!is.na(Type))
ggplot(data = pokemon_sum, aes(x = Type,
                               y = count_type)) +
  geom_col() +
  coord_flip()  ## flips the x and y axes
```

<img src="07-forcats_files/figure-html/unnamed-chunk-6-1.png" width="672" />

How does `R` order the levels of the `Type` factor, by default? How might you like them to be ordered to make the graph more readable?

<br>

The following code creates a new factor variable called `Type_ordered` that orders type by the `count_type` variable. `fct_reorder()` takes a factor as its first argument and a numeric variable to re-order that factor by as its second argument. The bar plot is then reconstructed with this new variable.


```r
pokemon_sum <- pokemon_sum |> 
  mutate(Type_ordered = fct_reorder(.f = Type, .x = count_type))
ggplot(data = pokemon_sum, aes(x = Type_ordered,
                               y = count_type)) +
  geom_col() +
  coord_flip()
```

<img src="07-forcats_files/figure-html/unnamed-chunk-7-1.png" width="672" />

### Lollipop Plots

Lollipop plots are a popular alternative to bar plots because they often look cleaner with less ink. To make a lollipop plot in `R`, we specify two different geoms: `geom_segment()` to form the stick of the lollipop and `geom_point()` to form the pop part of the lollipop. `geom_segment()` requires 4 aesthetics: `x`, `xend`, `y`, and `yend`.


```r
ggplot(data = pokemon_sum, aes(x = Type_ordered,
                               y = count_type)) +
  geom_segment(aes(x = Type_ordered, xend = Type_ordered,
                   y = 0, yend = count_type)) +
  geom_point() +
  coord_flip()
```

<img src="07-forcats_files/figure-html/unnamed-chunk-8-1.png" width="672" />

`fct_reorder()` also works with boxplots or simple point plots that show, for example, the median response for each level of a factor. The following set of plots investigate how the `Defense` stat changes for different Pokemon types


```r
pokemon_long <- pokemon_long |>
  filter(!is.na(Type)) |>
  mutate(Type_Deford = fct_reorder(.f = Type, .x = Defense,
                                   .fun = median))
ggplot(data = pokemon_long, aes(x = Type_Deford,
                               y = Defense)) +
  geom_boxplot() + 
  coord_flip()
```

<img src="07-forcats_files/figure-html/unnamed-chunk-9-1.png" width="672" />

The following code makes a point plot that shows the median defense for each type instead of boxplots.


```r
pokemon_med <- pokemon_long |> group_by(Type_Deford) |>
  summarise(med_def = median(Defense)) |>
  mutate(Type_Deford = fct_reorder(.f = Type_Deford, .x = med_def,
                                   .fun = median))

ggplot(data = pokemon_med, aes(x = med_def, y = Type_Deford)) +
  geom_point()
```

<img src="07-forcats_files/figure-html/unnamed-chunk-10-1.png" width="672" />

Finally, we can make a lollipop plot of median defense.


```r
ggplot(data = pokemon_med, aes(x = Type_Deford, y = med_def)) +
  geom_segment(aes(xend = Type_Deford, y = 0, yend = med_def)) +
  geom_point() +
  coord_flip()
```

<img src="07-forcats_files/figure-html/unnamed-chunk-11-1.png" width="672" />


Do you have a preference between the boxplot graph, the point plot, and the lollipop plot?

<br>

__New Data__. The `gun_violence_us.csv` data set was obtained from <a href="https://www.openintro.org/book/statdata/index.php?data=gun_violence_us" target="_blank">https://www.openintro.org/book/statdata/index.php?data=gun_violence_us</a> and contains the following variables on gun violence in 2014:

* `state`, the name of the U.S. state
* `mortality_rate`, number of deaths from gun violence per 100,000 people
* `ownership_rate`, the proportion of adults who own a gun
* `region`, region of the U.S. (`South`, `West`, `NE`, and `MW`)


```r
mortality_df <- read_csv(here("data/gun_violence_us.csv")) |>
  mutate(region = factor(region))
```

### Re-Leveling By Two Quantitative Variables with `fct_reorder2()`

Suppose that we want to investigate the relationship between `mortality_rate` and `ownership_rate` using this data set. Run the following code to create a scatterplot of `mortality_rate` vs. `ownership_rate` with fitted linear regression lines for each `region` of the United States:


```r
ggplot(data = mortality_df,
       aes(x = ownership_rate, y = mortality_rate, colour = region)) +
  geom_point() +
  geom_smooth(method = "lm")
```

<img src="07-forcats_files/figure-html/unnamed-chunk-13-1.png" width="672" />

Notice the order of the levels in the legend. Most people would prefer the order to actually match up with where the lines in the plot end, not for the order to be alphabetical. To achieve this, we can use `fct_reorder2()` to change the order of the factor levels:


```r
mortality_df <- mortality_df |>
  mutate(region_2 = fct_reorder2(region,
                                 .x = ownership_rate,
                                 .y = mortality_rate))
ggplot(data = mortality_df,
       aes(x = ownership_rate, y = mortality_rate, colour = region_2)) +
  geom_point() +
  geom_smooth(method = "lm")
```

<img src="07-forcats_files/figure-html/unnamed-chunk-14-1.png" width="672" />

Did it change the order of the levels how you would expect? `fct_reorder2()` actually looks at __points__, not lines, when determining the ordering. If you want the levels to match up exactly, then we'll have to reorder the levels manually with `fct_relevel()`:

### Reordering Levels Manually with `fct_relevel()`

Factors are ordered alphabetically by default. If we want precise control over the order of the levels of a factor, we can use `fct_relevel()`, which takes a factor and a vector of the new levels as inputs:


```r
mortality_df <- mortality_df |>
  mutate(region_3 = fct_relevel(region, c("South", "West", "MW", "NE")))
ggplot(data = mortality_df,
       aes(x = ownership_rate, y = mortality_rate, colour = region_3)) +
  geom_point() +
  geom_smooth(method = "lm")
```

<img src="07-forcats_files/figure-html/unnamed-chunk-15-1.png" width="672" />

Reordering the levels of a factor manually might also be useful in fitting linear models. Recall that, by default, `R` makes the __reference group__ in a linear model the first level alphabetically. If you'd like a different reference group, you can reorder the levels of the factor:


```r
mod <- lm(mortality_rate ~ ownership_rate + region, data = mortality_df)
mod2 <- lm(mortality_rate ~ ownership_rate + region_2, data = mortality_df)
mod3 <- lm(mortality_rate ~ ownership_rate + region_3, data = mortality_df)
summary(mod)
summary(mod2)
summary(mod3)
```

### Exercises {#exercise-7-2}

1. Make the side-by-side boxplots again with the pokemon data but do not use `ungroup()` by running the following code.


```r
pokemon_nodup <- pokemon_df |> group_by(`#`) |> slice(1) ## |>
  ## ungroup()
pokemon_long <- pokemon_nodup |>
  pivot_longer(c(`Type 1`, `Type 2`),
               names_to = "Number",
               values_to = "Type")

pokemon_long <- pokemon_long |>
  filter(!is.na(Type)) |>
  mutate(Type_Deford = fct_reorder(.f = Type, .x = Defense,
                                   .fun = median))
ggplot(data = pokemon_long, aes(x = Type_Deford,
                               y = Defense)) +
  geom_boxplot() + 
  coord_flip()
```

<img src="07-forcats_files/figure-html/unnamed-chunk-17-1.png" width="672" />

Why aren't the types ordered by median defense anymore? 

2. The `.fun` argument in `fct_reorder()` controls how the `Type` factor is ordered. Change this to specify ordering by the `mean`, `max`, and `min`. What ordering makes the most sense? Why?

## Chapter Exercises {#chapexercise-7}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-7).

We will use the general social survey data set, which is in the `forcats` library in `R`. You should some of this Wikipedia page to better understand where this data comes from <a href="https://en.wikipedia.org/wiki/General_Social_Survey" target="_blank">Wikipedia</a>.

Most variables are self-explanatory, but a couple that aren't are:

* `partyid`, political leaning and 
* `denom`, religious denomination (if unfamiliar with this, you can think of it as a "more specific" subset of a particular religion).

Note that some of these exercises are from the R for Data Science textbook.

Load in the data set with


```r
library(tidyverse)
gss_cat
```

1. \* Using a `forcats` function, change the name of the level `Not str republican` to be `Weak republican` and change the name of the level `Not str democrat` to be `Weak democrat`. These names more closely match the levels `Strong republican` and `Strong democrat`. Then, create a table of counts that shows the number of respondents in each political party `partyid`. 

__Note__: Levels that aren't specified in your `forcats` function do not change.

__Note 2__: In naming something `Weak republican`, you'll need to use backticks since there is a space in the level name.

2. \* Use a `forcats` function so that `partyid` just has 4 categories: Other (corresponding to No answer, Don't know, Other party), Ind (corresponding to Ind,near rep, Independent, Ind, near dem), Rep (corresponding to Strong republican and Not str republican), and Dem (corresponding to Not str democrat and Strong democrat).

3. \* Run the code to create the following plot that shows the average number of hours of television people watch from various religions. 


```r
relig_summary <- gss_cat |>
  group_by(relig) |>
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(data = relig_summary, aes(tvhours, relig)) +
  geom_point()
```

Then, use a `forcats` function create a new variable in the data set that reorders the religion factor levels and make a lollipop plot so that the religion watches the most television, on average, is on the top, and the religion that watches the least television, on average, is on the bottom.

4. \* Run the code to make the following line plot that shows age on the x-axis, the proportion on the y-axis, and is coloured by various marital statuses (married, divorced, widowed, etc.):


```r
by_age <- gss_cat |>
  filter(!is.na(age)) |>
  count(age, marital) |>
  group_by(age) |>
  mutate(prop = n / sum(n))

ggplot(by_age, aes(age, prop,
                  colour = marital)) +
  geom_line(na.rm = TRUE) +
  labs(colour = "marital")
```

Then, use a `forcats` function to make the plot so that the legend labels line up better with the different coloured marital status lines (e.g. so that the label for widowed is the first that appears in the legend, the label for married is second, etc.).

5. We haven't talked much about creating two-way tables (or contingency tables). These are generally quite difficult to make with the `tidyverse` functions, but you can use the base `R` `table()` and `prop.table()` functions to make these.

Using data only from the year 2014, run the following code to make 4 two-way tables with the `party_small` variable that was constructed earlier and `race`:


```r
gss_cat <- gss_cat |> mutate(party_small = fct_collapse(partyid,
                                              Other = c("No answer", "Don't know", "Other party"),
                                              Ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                              Rep = c("Strong republican", "Not str republican"),
                                              Dem = c("Not str democrat", "Strong democrat")))

gss_recent <- gss_cat |> filter(year == 2014)

tab1 <- table(gss_recent$party_small, gss_recent$race)
tab1
#>        
#>         Other Black White Not applicable
#>   Other     8    12    68              0
#>   Rep      22    17   498              0
#>   Ind     152   108   828              0
#>   Dem      80   249   496              0
prop.table(tab1)
#>        
#>               Other       Black       White Not applicable
#>   Other 0.003152088 0.004728132 0.026792750    0.000000000
#>   Rep   0.008668243 0.006698188 0.196217494    0.000000000
#>   Ind   0.059889677 0.042553191 0.326241135    0.000000000
#>   Dem   0.031520883 0.098108747 0.195429472    0.000000000
prop.table(tab1, margin = 1)
#>        
#>              Other      Black      White Not applicable
#>   Other 0.09090909 0.13636364 0.77272727     0.00000000
#>   Rep   0.04096834 0.03165736 0.92737430     0.00000000
#>   Ind   0.13970588 0.09926471 0.76102941     0.00000000
#>   Dem   0.09696970 0.30181818 0.60121212     0.00000000
prop.table(tab1, margin = 2)
#>        
#>              Other      Black      White Not applicable
#>   Other 0.03053435 0.03108808 0.03597884               
#>   Rep   0.08396947 0.04404145 0.26349206               
#>   Ind   0.58015267 0.27979275 0.43809524               
#>   Dem   0.30534351 0.64507772 0.26243386
```

Use the help on `?prop.table` to figure out how each of these three tables are constructed.

Which table do you think is most informative? What conclusions does it help you to draw?

## Exercise Solutions {#solutions-7}

### Change Factor Levels S

2. \* We did not properly explore the data set before making the graphs above, and, in fact, there is some double counting of Pokemon in this data set (this is another example where being familiar with the data set you're working with is advantageous: people familiar with Pokemon know that there are fewer than 947 Pokemon in Generations 1 through 6). 

Figure out why some Pokemon are double counted. Then, create a new data set that only keeps one observation per Pokemon `#`. 


```r
pokemon_nodup <- pokemon_df |> group_by(`#`) |> slice(1) |>
  ungroup()
```

### Reorder Factor Levels S

### Chapter Exercises S {#chapexercise-7-S}

1. \* Using a `forcats` function, change the name of the level `Not str republican` to be `Weak republican` and change the name of the level `Not str democrat` to be `Weak democrat`. These names more closely match the levels `Strong republican` and `Strong democrat`. Then, create a table of counts that shows the number of respondents in each political party `partyid`. 

__Note__: Levels that aren't specified in your `forcats` function do not change.

__Note 2__: In naming something `Weak republican`, you'll need to use backticks since there is a space in the level name.


```r
gss_cat |>
  mutate(partyid_new = fct_recode(partyid,
                                  `Weak republican` = "Not str republican",
                                  `Weak democrat` = "Not str democrat")) |> group_by(partyid_new) |>
  summarise(ncount = n())
```

2. \* Use a `forcats` function so that `partyid` just has 4 categories: Other (corresponding to No answer, Don't know, Other party), Ind (corresponding to Ind,near rep, Independent, Ind, near dem), Rep (corresponding to Strong republican and Not str republican), and Dem (corresponding to Not str democrat and Strong democrat).


```r
gss_cat <- gss_cat |> mutate(party_small = fct_collapse(partyid,
                                              Other = c("No answer", "Don't know", "Other party"),
                                              Ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                              Rep = c("Strong republican", "Not str republican"),
                                              Dem = c("Not str democrat", "Strong democrat")))
```

3. \* Run the code to create the following plot that shows the average number of hours of television people watch from various religions. 


```r
relig_summary <- gss_cat |>
  group_by(relig) |>
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(data = relig_summary, aes(tvhours, relig)) +
  geom_point()
```

Then, use a `forcats` function create a new variable in the data set that reorders the religion factor levels and remake the barplot so that the religion watches the most television, on average, is on the top, and the religion that watches the least television, on average, is on the bottom.


```r
relig_summary <- relig_summary |>
  mutate(relig = fct_reorder(relig, tvhours))
ggplot(data = relig_summary, aes(x = relig, y = tvhours)) +
  geom_segment(aes(x = relig, xend = relig, y = 0, yend = tvhours)) +
  geom_point() +
  coord_flip()
```

<img src="07-forcats_files/figure-html/unnamed-chunk-26-1.png" width="672" />

4. \* Run the code to make the following line plot that shows age on the x-axis, the proportion on the y-axis, and is coloured by various marital statuses (married, divorced, widowed, etc.):


```r
by_age <- gss_cat |>
  filter(!is.na(age)) |>
  count(age, marital) |>
  group_by(age) |>
  mutate(prop = n / sum(n))

ggplot(by_age, aes(age, prop,
                  colour = marital)) +
  geom_line(na.rm = TRUE) +
  labs(colour = "marital")
```

Then, use a `forcats` function to make the plot so that the legend labels line up better with the different coloured marital status lines (e.g. so that the label for widowed is the first that appears in the legend, the label for married is second, etc.).


```r
by_age2 <- by_age |> ungroup() |>
  mutate(marital2 = fct_reorder2(marital, .x = age, .y = prop))
ggplot(by_age2, aes(age, prop,
                  colour = marital2)) +
  geom_line(na.rm = TRUE) +
  labs(colour = "marital") +
  scale_colour_viridis_d()
```

## Non-Exercise `R` Code {#rcode-7}


```r
library(tidyverse)
library(here)
pokemon_df <- read_csv(here("data/pokemon_allgen.csv")) |>
  mutate(Generation_cat = factor(Generation))
pokemon_df |> group_by(`Type 1`) |>
  summarise(counttype = n())
pokemon_legend <- pokemon_df |> filter(Legendary == TRUE) |>
  group_by(Generation_cat) |>
  summarise(nlegend = n())
ggplot(data = pokemon_legend, aes(x = Generation_cat, y = nlegend)) +
  geom_col()
pokemon_legend <- pokemon_legend |>
  mutate(Generation_cat2 = fct_recode(Generation_cat, Kanto = "1",
                                      Johto = "2", Hoenn = "3",
                                      Sinnoh = "4", Unova = "5",
                                      Kalos = "6")) |>
  select(Generation_cat2, everything())
head(pokemon_legend)
ggplot(data = pokemon_legend,
       aes(x = Generation_cat2, y = nlegend)) +
  geom_col()
pokemon_long <- pokemon_df |> pivot_longer(c(`Type 1`, `Type 2`),
                            names_to = "Number",
                            values_to = "Type")
pokemon_long |>
  mutate(new_type = fct_collapse(Type, Coolest = c("Ice", "Dark"),
                                 Least_Cool = c("Fire", "Fighting", "Poison"))) |>
  select(new_type, Type, everything())
pokemon_nodup <- pokemon_df |> group_by(`#`) |> slice(1) |>
  ungroup()
pokemon_long <- pokemon_nodup |>
  pivot_longer(c(`Type 1`, `Type 2`),
               names_to = "Number",
               values_to = "Type")
pokemon_sum <- pokemon_long |>
  group_by(Type) |>
  summarise(count_type = n()) |>
  filter(!is.na(Type))
ggplot(data = pokemon_sum, aes(x = Type,
                               y = count_type)) +
  geom_col() +
  coord_flip()  ## flips the x and y axes
pokemon_sum <- pokemon_sum |> 
  mutate(Type_ordered = fct_reorder(.f = Type, .x = count_type))
ggplot(data = pokemon_sum, aes(x = Type_ordered,
                               y = count_type)) +
  geom_col() +
  coord_flip()
pokemon_long <- pokemon_long |>
  filter(!is.na(Type)) |>
  mutate(Type_Deford = fct_reorder(.f = Type, .x = Defense,
                                   .fun = median))
ggplot(data = pokemon_long, aes(x = Type_Deford,
                               y = Defense)) +
  geom_boxplot() + 
  coord_flip()
pokemon_med <- pokemon_long |> group_by(Type_Deford) |>
  summarise(med_def = median(Defense)) |>
  mutate(Type_Deford = fct_reorder(.f = Type_Deford, .x = med_def,
                                   .fun = median))

ggplot(data = pokemon_med, aes(x = med_def, y = Type_Deford)) +
  geom_point()
mortality_df <- read_csv(here("data/gun_violence_us.csv")) |>
  mutate(region = factor(region))
ggplot(data = mortality_df,
       aes(x = ownership_rate, y = mortality_rate, colour = region)) +
  geom_point() +
  geom_smooth(method = "lm")
mortality_df <- mortality_df |>
  mutate(region_2 = fct_reorder2(region,
                                 .x = ownership_rate,
                                 .y = mortality_rate))
ggplot(data = mortality_df,
       aes(x = ownership_rate, y = mortality_rate, colour = region_2)) +
  geom_point() +
  geom_smooth(method = "lm")
mortality_df <- mortality_df |>
  mutate(region_3 = fct_relevel(region, c("South", "West", "MW", "NE")))
ggplot(data = mortality_df,
       aes(x = ownership_rate, y = mortality_rate, colour = region_3)) +
  geom_point() +
  geom_smooth(method = "lm")
mod <- lm(mortality_rate ~ ownership_rate + region, data = mortality_df)
mod2 <- lm(mortality_rate ~ ownership_rate + region_2, data = mortality_df)
mod3 <- lm(mortality_rate ~ ownership_rate + region_3, data = mortality_df)
summary(mod)
summary(mod2)
summary(mod3)
```


