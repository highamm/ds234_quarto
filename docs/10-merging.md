# Merging with `dplyr`

__Goals:__

* use `bind_rows()` to stack two data sets and `bind_cols()` to merge two data sets.

* identify __keys__ in two related data sets.

* use the mutating join functions in `dplyr` to merge two data sets by a key.

* use the filtering join functions in `dplyr` to filter one data set by values in another data set.

* apply the appropriate `join()` function for a given problem and context.

## Stacking Rows and Appending Columns

### Stacking with `bind_rows()`

First, we will talk about combining two data sets by "stacking" them on top of each other to form one new data set. The `bind_rows()` function can be used for this purpose __if__ the two data sets have identical column names.

A common instance where this is useful is if two data sets come from the same source and have different locations or years, but the same exact column names.

For example, examine the following website and notice how there are .csv files given for each year of matches in the ATP (Association of (men's) Tennis Professionals). <a href="https://github.com/JeffSackmann/tennis_atp" target="_blank">https://github.com/JeffSackmann/tennis_atp</a>.

Then, read in the data sets, and look at how many columns each has.


```r
library(tidyverse)
library(here)
atp_2019 <- read_csv(here("data/atp_matches_2019.csv"))
atp_2018 <- read_csv(here("data/atp_matches_2018.csv"))
head(atp_2019) 
head(atp_2018)
```

To combine results from both data sets,


```r
atp_df <- bind_rows(atp_2018, atp_2019)
#> Error in `bind_rows()`:
#> ! Can't combine `winner_seed` <double> and `winner_seed` <character>.
```

What happens? Can you fix the error? __Hint__: run


```r
spec(atp_2018)
```

to get the full column specifications and use your `readr` knowledge to change a couple of the column types. We also did not discuss this, but, when using the `col_type` argument in `read_csv()`, you don't need to specify all of the column types. Just specifying the ones that you want to change works too. The following code forces the seed variables in the 2018 data set to be characters.


```r
atp_2018 <- read_csv(here("data/atp_matches_2018.csv"),
                     col_types = cols(winner_seed = col_character(),
                                      loser_seed = col_character()))
```

We can try combining the data sets now.


```r
atp_df <- bind_rows(atp_2018, atp_2019)
atp_df
```

Do a quick check to make sure the number of rows in `atp_2018` plus the number of rows in `atp_2019` equals the number of rows in `atp_df`.

It might seem a little annoying, but, by default `bind_rows()` will only combine two data sets by stacking rows if the data sets have __identical__ column names and __identical__ column classes, as we saw in the previous example. 

Now run the following and look at the output.


```r
df_test2a <- tibble(xvar = c(1, 2))
df_test2b <- tibble(xvar = c(1, 2), y = c(5, 1))
bind_rows(df_test2a, df_test2b)
#> # A tibble: 4 × 2
#>    xvar     y
#>   <dbl> <dbl>
#> 1     1    NA
#> 2     2    NA
#> 3     1     5
#> 4     2     1
```

Is this the behavior you would expect?

<br>

### Binding Columns with `bind_cols()`

We won't spend much time talking about how to bind together columns because it's generally a little dangerous. 

We will use a couple of test data sets, `df_test1a` and `df_test1b`, to see it in action:


```r
df_test1a <- tibble(xvar = c(1, 2), yvar = c(5, 1))
df_test1b <- tibble(x = c(1, 2), y = c(5, 1))
bind_cols(df_test1a, df_test1b)
#> # A tibble: 2 × 4
#>    xvar  yvar     x     y
#>   <dbl> <dbl> <dbl> <dbl>
#> 1     1     5     1     5
#> 2     2     1     2     1
```

For a larger data set, why might this be a dangerous way to combine data? What must you be sure of about the way the data was collected in order to combine data in this way?

### Exercises {#exercise-10-1}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-10).

1. \* Run the following and explain why `R` does not simply stack the rows. Then, fix the issue with the `rename()` function.


```r
df_test1a <- tibble(xvar = c(1, 2), yvar = c(5, 1))
df_test1b <- tibble(x = c(1, 2), y = c(5, 1))
bind_rows(df_test1a, df_test1b)
#> # A tibble: 4 × 4
#>    xvar  yvar     x     y
#>   <dbl> <dbl> <dbl> <dbl>
#> 1     1     5    NA    NA
#> 2     2     1    NA    NA
#> 3    NA    NA     1     5
#> 4    NA    NA     2     1
```

## Mutating Joins

If the goal is to combine two data sets using some common variable(s) that both data sets have, we need different tools than simply stacking rows or appending columns. When merging together two or more data sets, we need to have a matching identification variable in each data set. This variable is commonly called a __key__. A key can be an identification number, a name, a date, etc, but must be present in both data sets. 

As a simple first example, consider


```r
library(tidyverse)
df1 <- tibble(name = c("Emily", "Miguel", "Tonya"), fav_sport = c("Swimming", "Football", "Tennis"))
df2 <- tibble(name = c("Tonya", "Miguel", "Emily"),
              fav_colour = c("Robin's Egg Blue", "Tickle Me Pink", "Goldenrod"))
```

Our goal is to combine the two data sets so that the people's favorite sports and favorite colours are in one data set.

Identify the `key` in the example above. Why can we no longer use `bind_cols()` here?

### Keep All Rows of Data Set 1 with `left_join()`

Consider the `babynames` `R` package, which has the following data sets:

* `lifetables`: cohort life tables for different `sex` and different `year` variables, starting at the year 1900.
* `births`: the number of births in the United States in each year, since 1909
* `babynames`: popularity of different baby names per year and sex since the year 1880.


```r
##install.packages("babynames")
library(babynames)
life_df <- babynames::lifetables
birth_df <- babynames::births
babynames_df <- babynames::babynames
head(babynames)
head(births)
head(lifetables)
```

Read about each data set with `?babynames`, `?births` and `?lifetables`.

Suppose that you want to combine the `births` data set with the `babynames` data set, so that each row of `babynames` now has the total number of births for that year. We first need to identify the key in each data set that we will use for the joining. In this case, each data set has a `year` variable, and we can use `left_join()` to keep all observations in `babynames_df`, even for years that are not in the `births_df` data set.


```r
combined_left <- left_join(babynames_df, birth_df, by = c("year" = "year"))
head(combined_left)
#> # A tibble: 6 × 6
#>    year sex   name          n   prop births
#>   <dbl> <chr> <chr>     <int>  <dbl>  <int>
#> 1  1880 F     Mary       7065 0.0724     NA
#> 2  1880 F     Anna       2604 0.0267     NA
#> 3  1880 F     Emma       2003 0.0205     NA
#> 4  1880 F     Elizabeth  1939 0.0199     NA
#> 5  1880 F     Minnie     1746 0.0179     NA
#> 6  1880 F     Margaret   1578 0.0162     NA
tail(combined_left)
#> # A tibble: 6 × 6
#>    year sex   name       n       prop  births
#>   <dbl> <chr> <chr>  <int>      <dbl>   <int>
#> 1  2017 M     Zyhier     5 0.00000255 3855500
#> 2  2017 M     Zykai      5 0.00000255 3855500
#> 3  2017 M     Zykeem     5 0.00000255 3855500
#> 4  2017 M     Zylin      5 0.00000255 3855500
#> 5  2017 M     Zylis      5 0.00000255 3855500
#> 6  2017 M     Zyrie      5 0.00000255 3855500
```

Why are `births` missing in `head(combined_left)` but not in `tail(combined_left)`?

### Keep All Rows of Data Set 2 with `right_join()`

Recall from the accompanying handout that there is no need to ever use `right_join()` because it is the same as using a `left_join()` with the first two data set arguments switched:


```r
## these will always do the same exact thing
right_join(babynames_df, birth_df, by = c("year" = "year"))
#> # A tibble: 1,839,952 × 6
#>     year sex   name          n   prop  births
#>    <dbl> <chr> <chr>     <int>  <dbl>   <int>
#>  1  1909 F     Mary      19259 0.0523 2718000
#>  2  1909 F     Helen      9250 0.0251 2718000
#>  3  1909 F     Margaret   7359 0.0200 2718000
#>  4  1909 F     Ruth       6509 0.0177 2718000
#>  5  1909 F     Dorothy    6253 0.0170 2718000
#>  6  1909 F     Anna       5804 0.0158 2718000
#>  7  1909 F     Elizabeth  5176 0.0141 2718000
#>  8  1909 F     Mildred    5054 0.0137 2718000
#>  9  1909 F     Marie      4301 0.0117 2718000
#> 10  1909 F     Alice      4170 0.0113 2718000
#> # … with 1,839,942 more rows
#> # ℹ Use `print(n = ...)` to see more rows
left_join(birth_df, babynames_df, by = c("year" = "year"))
#> # A tibble: 1,839,952 × 6
#>     year  births sex   name          n   prop
#>    <dbl>   <int> <chr> <chr>     <int>  <dbl>
#>  1  1909 2718000 F     Mary      19259 0.0523
#>  2  1909 2718000 F     Helen      9250 0.0251
#>  3  1909 2718000 F     Margaret   7359 0.0200
#>  4  1909 2718000 F     Ruth       6509 0.0177
#>  5  1909 2718000 F     Dorothy    6253 0.0170
#>  6  1909 2718000 F     Anna       5804 0.0158
#>  7  1909 2718000 F     Elizabeth  5176 0.0141
#>  8  1909 2718000 F     Mildred    5054 0.0137
#>  9  1909 2718000 F     Marie      4301 0.0117
#> 10  1909 2718000 F     Alice      4170 0.0113
#> # … with 1,839,942 more rows
#> # ℹ Use `print(n = ...)` to see more rows
```

Therefore, it's usually easier to just always use `left_join()` and ignore `right_join()` completely. 

### Keep All Rows of Both Data Sets with `full_join()`

A `full_join()` will keep all rows in data set 1 that don't have a matching key in data set 2, and will also keep all rows in data set 2 that don't have a matching key in data set 1, filling in `NA` for missing values when necessary. For our example of merging `babynames_df` with `birth_df`,


```r
full_join(babynames_df, birth_df, by = c("year" = "year"))
```

### Keep Only Rows with Matching Keys with `inner_join()`

We can also keep only rows with matching keys with `inner_join()`. For this join, any row in data set 1 without a matching key in data set 2 is dropped, and any row in data set 2 without a matching key in data set 1 is also dropped.


```r
inner_join(babynames_df, birth_df, by = c("year" = "year"))
#> # A tibble: 1,839,952 × 6
#>     year sex   name          n   prop  births
#>    <dbl> <chr> <chr>     <int>  <dbl>   <int>
#>  1  1909 F     Mary      19259 0.0523 2718000
#>  2  1909 F     Helen      9250 0.0251 2718000
#>  3  1909 F     Margaret   7359 0.0200 2718000
#>  4  1909 F     Ruth       6509 0.0177 2718000
#>  5  1909 F     Dorothy    6253 0.0170 2718000
#>  6  1909 F     Anna       5804 0.0158 2718000
#>  7  1909 F     Elizabeth  5176 0.0141 2718000
#>  8  1909 F     Mildred    5054 0.0137 2718000
#>  9  1909 F     Marie      4301 0.0117 2718000
#> 10  1909 F     Alice      4170 0.0113 2718000
#> # … with 1,839,942 more rows
#> # ℹ Use `print(n = ...)` to see more rows
```

<br>

### Which `xxxx_join()`?

Which join function we use will depend on the context of the data and what questions you will be answering in your analysis. Most importantly, if you're using a `left_join()`, `right_join()` or `inner_join()`, you're potentially cutting out some data. It's important to be aware of what data you're omitting. For example, with the `babynames` and `births` data, we would want to keep a note that a `left_join()` removed all observations before 1909 from joined data set. 

### The Importance of a Good Key

The key variable is very important for joining and is not always available in a "perfect" form. Recall the college majors data sets we have, called `slumajors_df`, which information on majors at SLU. Another data set, `collegemajors_df`, has different statistics on college majors nationwide. There's lots of interesting variables in these data sets, but we'll focus on the `Major` variable here. Read in and examine the two data sets with:


```r
slumajors_df <- read_csv(here("data/SLU_Majors_15_19.csv"))
collegemajors_df <- read_csv(here("data/college-majors.csv"))
head(slumajors_df)
#> # A tibble: 6 × 3
#>   Major                        nfemales nmales
#>   <chr>                           <dbl>  <dbl>
#> 1 Anthropology                       34     15
#> 2 Art & Art History                  65     11
#> 3 Biochemistry                       14     11
#> 4 Biology                           162     67
#> 5 Business in the Liberal Arts      135    251
#> 6 Chemistry                          26     14
head(collegemajors_df)
#> # A tibble: 6 × 12
#>   Major    Total   Men Women Major…¹ Emplo…² Full_…³ Part_…⁴
#>   <chr>    <dbl> <dbl> <dbl> <chr>     <dbl>   <dbl>   <dbl>
#> 1 PETROLE…  2339  2057   282 Engine…    1976    1849     270
#> 2 MINING …   756   679    77 Engine…     640     556     170
#> 3 METALLU…   856   725   131 Engine…     648     558     133
#> 4 NAVAL A…  1258  1123   135 Engine…     758    1069     150
#> 5 CHEMICA… 32260 21239 11021 Engine…   25694   23170    5180
#> 6 NUCLEAR…  2573  2200   373 Engine…    1857    2038     264
#> # … with 4 more variables: Unemployed <dbl>, Median <dbl>,
#> #   P25th <dbl>, P75th <dbl>, and abbreviated variable
#> #   names ¹​Major_category, ²​Employed, ³​Full_time,
#> #   ⁴​Part_time
#> # ℹ Use `colnames()` to see all variable names
```

The most logical key for joining these two data sets is `Major`,  but joining the data sets won't actually work. The following is an attempt at using `Major` as the key.


```r
left_join(slumajors_df, collegemajors_df, by = c("Major" = "Major"))
#> # A tibble: 27 × 14
#>    Major    nfema…¹ nmales Total   Men Women Major…² Emplo…³
#>    <chr>      <dbl>  <dbl> <dbl> <dbl> <dbl> <chr>     <dbl>
#>  1 Anthrop…      34     15    NA    NA    NA <NA>         NA
#>  2 Art & A…      65     11    NA    NA    NA <NA>         NA
#>  3 Biochem…      14     11    NA    NA    NA <NA>         NA
#>  4 Biology      162     67    NA    NA    NA <NA>         NA
#>  5 Busines…     135    251    NA    NA    NA <NA>         NA
#>  6 Chemist…      26     14    NA    NA    NA <NA>         NA
#>  7 Compute…      21     47    NA    NA    NA <NA>         NA
#>  8 Conserv…      38     20    NA    NA    NA <NA>         NA
#>  9 Economi…     128    349    NA    NA    NA <NA>         NA
#> 10 English      131     54    NA    NA    NA <NA>         NA
#> # … with 17 more rows, 6 more variables: Full_time <dbl>,
#> #   Part_time <dbl>, Unemployed <dbl>, Median <dbl>,
#> #   P25th <dbl>, P75th <dbl>, and abbreviated variable
#> #   names ¹​nfemales, ²​Major_category, ³​Employed
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

Why did the `collegemajors_df` give only `NA` values when we tried to merge by major?

This example underscores the importance of having a key that matches __exactly__. Some, but not all, of the issues involved in joining these two data sets can be solved with functions in the `stringr` package (discussed in a few weeks). For example, the capitalization issue can be solved with the `str_to_title()` function, which converts that all-caps majors in `collegemajors_df` to majors where only the first letter of each word is capitalized:


```r
collegemajors_df <- collegemajors_df |>
  mutate(Major = str_to_title(Major))
left_join(slumajors_df, collegemajors_df)
#> Joining, by = "Major"
#> # A tibble: 27 × 14
#>    Major nfema…¹ nmales  Total    Men  Women Major…² Emplo…³
#>    <chr>   <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <chr>     <dbl>
#>  1 Anth…      34     15     NA     NA     NA <NA>         NA
#>  2 Art …      65     11     NA     NA     NA <NA>         NA
#>  3 Bioc…      14     11     NA     NA     NA <NA>         NA
#>  4 Biol…     162     67 280709 111762 168947 Biolog…  182295
#>  5 Busi…     135    251     NA     NA     NA <NA>         NA
#>  6 Chem…      26     14  66530  32923  33607 Physic…   48535
#>  7 Comp…      21     47 128319  99743  28576 Comput…  102087
#>  8 Cons…      38     20     NA     NA     NA <NA>         NA
#>  9 Econ…     128    349 139247  89749  49498 Social…  104117
#> 10 Engl…     131     54     NA     NA     NA <NA>         NA
#> # … with 17 more rows, 6 more variables: Full_time <dbl>,
#> #   Part_time <dbl>, Unemployed <dbl>, Median <dbl>,
#> #   P25th <dbl>, P75th <dbl>, and abbreviated variable
#> #   names ¹​nfemales, ²​Major_category, ³​Employed
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

As we can see, this solves the issue for some majors but others still have different naming conventions in the two data sets.

### Exercises {#exercise-10-2}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-10).

1. Examine the following two joins that we've done, and explain why one resulting data set has fewer observations (rows) than the other.


```r
left_join(babynames_df, birth_df, by = c("year" = "year"))
#> # A tibble: 1,924,665 × 6
#>     year sex   name          n   prop births
#>    <dbl> <chr> <chr>     <int>  <dbl>  <int>
#>  1  1880 F     Mary       7065 0.0724     NA
#>  2  1880 F     Anna       2604 0.0267     NA
#>  3  1880 F     Emma       2003 0.0205     NA
#>  4  1880 F     Elizabeth  1939 0.0199     NA
#>  5  1880 F     Minnie     1746 0.0179     NA
#>  6  1880 F     Margaret   1578 0.0162     NA
#>  7  1880 F     Ida        1472 0.0151     NA
#>  8  1880 F     Alice      1414 0.0145     NA
#>  9  1880 F     Bertha     1320 0.0135     NA
#> 10  1880 F     Sarah      1288 0.0132     NA
#> # … with 1,924,655 more rows
#> # ℹ Use `print(n = ...)` to see more rows
left_join(birth_df, babynames_df, by = c("year" = "year"))
#> # A tibble: 1,839,952 × 6
#>     year  births sex   name          n   prop
#>    <dbl>   <int> <chr> <chr>     <int>  <dbl>
#>  1  1909 2718000 F     Mary      19259 0.0523
#>  2  1909 2718000 F     Helen      9250 0.0251
#>  3  1909 2718000 F     Margaret   7359 0.0200
#>  4  1909 2718000 F     Ruth       6509 0.0177
#>  5  1909 2718000 F     Dorothy    6253 0.0170
#>  6  1909 2718000 F     Anna       5804 0.0158
#>  7  1909 2718000 F     Elizabeth  5176 0.0141
#>  8  1909 2718000 F     Mildred    5054 0.0137
#>  9  1909 2718000 F     Marie      4301 0.0117
#> 10  1909 2718000 F     Alice      4170 0.0113
#> # … with 1,839,942 more rows
#> # ℹ Use `print(n = ...)` to see more rows
```

2. Evaluate whether the following statement is true or false: an `inner_join()` will always result in a data set with the same or fewer rows than a `full_join()`.

3. Evaluate whether the following statement is true or false: an `inner_join()` will always result in a data set with the same or fewer rows than a `left_join()`.

## Filtering Joins

Filtering joins (`semi_join()` and `anti_join()`) are useful if you would only like to keep the variables in one data set, but you want to filter out observations by a variable in the second data set.

Consider again the two data sets on men's tennis matches in 2018 and in 2019.


```r
atp_2019 <- read_csv(here("data/atp_matches_2019.csv"))
atp_2018 <- read_csv(here("data/atp_matches_2018.csv"))
atp_2019
#> # A tibble: 2,781 × 49
#>    tourney…¹ tourn…² surface draw_…³ tourn…⁴ tourn…⁵ match…⁶
#>    <chr>     <chr>   <chr>     <dbl> <chr>     <dbl>   <dbl>
#>  1 2019-M020 Brisba… Hard         32 A        2.02e7     300
#>  2 2019-M020 Brisba… Hard         32 A        2.02e7     299
#>  3 2019-M020 Brisba… Hard         32 A        2.02e7     298
#>  4 2019-M020 Brisba… Hard         32 A        2.02e7     297
#>  5 2019-M020 Brisba… Hard         32 A        2.02e7     296
#>  6 2019-M020 Brisba… Hard         32 A        2.02e7     295
#>  7 2019-M020 Brisba… Hard         32 A        2.02e7     294
#>  8 2019-M020 Brisba… Hard         32 A        2.02e7     293
#>  9 2019-M020 Brisba… Hard         32 A        2.02e7     292
#> 10 2019-M020 Brisba… Hard         32 A        2.02e7     291
#> # … with 2,771 more rows, 42 more variables:
#> #   winner_id <dbl>, winner_seed <chr>, winner_entry <chr>,
#> #   winner_name <chr>, winner_hand <chr>, winner_ht <dbl>,
#> #   winner_ioc <chr>, winner_age <dbl>, loser_id <dbl>,
#> #   loser_seed <chr>, loser_entry <chr>, loser_name <chr>,
#> #   loser_hand <chr>, loser_ht <dbl>, loser_ioc <chr>,
#> #   loser_age <dbl>, score <chr>, best_of <dbl>, …
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
atp_2018
#> # A tibble: 2,889 × 49
#>    tourney…¹ tourn…² surface draw_…³ tourn…⁴ tourn…⁵ match…⁶
#>    <chr>     <chr>   <chr>     <dbl> <chr>     <dbl>   <dbl>
#>  1 2018-M020 Brisba… Hard         32 A        2.02e7     271
#>  2 2018-M020 Brisba… Hard         32 A        2.02e7     272
#>  3 2018-M020 Brisba… Hard         32 A        2.02e7     273
#>  4 2018-M020 Brisba… Hard         32 A        2.02e7     275
#>  5 2018-M020 Brisba… Hard         32 A        2.02e7     276
#>  6 2018-M020 Brisba… Hard         32 A        2.02e7     277
#>  7 2018-M020 Brisba… Hard         32 A        2.02e7     278
#>  8 2018-M020 Brisba… Hard         32 A        2.02e7     279
#>  9 2018-M020 Brisba… Hard         32 A        2.02e7     280
#> 10 2018-M020 Brisba… Hard         32 A        2.02e7     282
#> # … with 2,879 more rows, 42 more variables:
#> #   winner_id <dbl>, winner_seed <dbl>, winner_entry <chr>,
#> #   winner_name <chr>, winner_hand <chr>, winner_ht <dbl>,
#> #   winner_ioc <chr>, winner_age <dbl>, loser_id <dbl>,
#> #   loser_seed <dbl>, loser_entry <chr>, loser_name <chr>,
#> #   loser_hand <chr>, loser_ht <dbl>, loser_ioc <chr>,
#> #   loser_age <dbl>, score <chr>, best_of <dbl>, …
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

### Filtering with `semi_join()` 

Suppose that we only want to keep matches in 2019 where the winning player had 10 or more wins in 2018. This might be useful if we want to not consider players in 2018 that only played in a couple of matches, perhaps because they got injured or perhaps because they received a special wildcard into the draw of only one event.

To accomplish this, we can first create a data set that has the names of all of the players that won 10 or more matches in 2018, using functions that we learned from `dplyr` earlier in the semester:


```r
win10 <- atp_2018 |> group_by(winner_name) |>
  summarise(nwin = n()) |> 
  filter(nwin >= 10)
win10
#> # A tibble: 93 × 2
#>    winner_name       nwin
#>    <chr>            <int>
#>  1 Adrian Mannarino    26
#>  2 Albert Ramos        21
#>  3 Alex De Minaur      29
#>  4 Alexander Zverev    58
#>  5 Aljaz Bedene        19
#>  6 Andreas Seppi       24
#>  7 Andrey Rublev       20
#>  8 Benoit Paire        27
#>  9 Borna Coric         40
#> 10 Cameron Norrie      19
#> # … with 83 more rows
#> # ℹ Use `print(n = ...)` to see more rows
```

Next, we apply `semi_join()`, which takes the names of two data sets (the second is the one that contains information about how the first should be "filtered"). The third argument gives the name of the key (`winner_name`) in this case.


```r
tennis_2019_10 <- semi_join(atp_2019, win10,
                            by = c("winner_name" = "winner_name"))
tennis_2019_10$winner_name
```

Note that this only keeps the matches in 2019 where the __winner__ had 10 or more match wins in 2018. It drops any matches where the __loser__ lost against someone who did not have 10 or more match wins in 2018. So this isn't yet perfect and would take a little more thought into which matches we actually want to keep for a particular analysis.

### Filtering with `anti_join()`

Now suppose that we want to only keep the matches in 2019 where the winning player did not have __any__ wins in 2018. We might think of these players as "emerging players" in 2019, players who are coming back from an injury, etc.. To do this, we can use `anti_join()`, which only keeps the rows in the first data set that do __not__ have a match in the second data set.


```r
new_winners <- anti_join(atp_2019, atp_2018,
                         by = c("winner_name" = "winner_name")) 
new_winners$winner_name
```

We can then examine how many wins each of these "new" (or perhaps previously injured) players had in 2019:


```r
new_winners |> group_by(winner_name) |>
  summarise(nwin = n()) |>
  arrange(desc(nwin))
#> # A tibble: 59 × 2
#>    winner_name           nwin
#>    <chr>                <int>
#>  1 Christian Garin         32
#>  2 Juan Ignacio Londero    22
#>  3 Miomir Kecmanovic       22
#>  4 Hugo Dellien            12
#>  5 Attila Balazs            7
#>  6 Cedrik Marcel Stebe      7
#>  7 Janko Tipsarevic         7
#>  8 Jannik Sinner            7
#>  9 Soon Woo Kwon            7
#> 10 Gregoire Barrere         6
#> # … with 49 more rows
#> # ℹ Use `print(n = ...)` to see more rows
```

The filtering join functions are useful if you want to filter out observations by some criterion in a different data set.

### Exercises {#exercise-10-3}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-10).

1. Take the `semi_join()` tennis example, but now suppose that we want to keep only the matches in 2019 where __either__ the winning player or the losing player had 10 or more match wins in 2018. How can you modify the code to achieve that goal?


```r
tennis_2019_10 <- semi_join(atp_2019, win10,
                            by = c("winner_name" = "winner_name"))
tennis_2019_10$winner_name
```

2. \* Take the `semi_join()` tennis example, but now suppose that we want to keep only the matches in 2019 where __both__ the winning player and the losing player had 10 or more match wins in 2018. How can you modify the code to achieve that goal?


```r
tennis_2019_10 <- semi_join(atp_2019, win10,
                            by = c("winner_name" = "winner_name"))
tennis_2019_10$winner_name
```

## Chapter Exercises {#chapexercise-10}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-10).

1. \* Read in the gun violence data set, and suppose that you want to add a row to this data set that has the statistics on gun ownership and mortality rate in the District of Columbia (Washington D.C., which is in the NE region, has 16.7 deaths per 100,000 people, and a gun ownership rate of 8.7%). To do so, create a `tibble()` that has a single row representing D.C. and then combine your new `tibble` with the overall gun violence data set. Name this new data set `all_df`.


```r
library(tidyverse)
mortality_df <- read_csv(here("data/gun_violence_us.csv"))
```



2. Explain why each attempt at combining the D.C. data with the overall data doesn't work or is incorrect.


```r
test1 <- tibble(state = "Washington D.C.", mortality_rate = 16.7,
                ownership_rate = 8.7, region = "NE")
bind_rows(mortality_df, test1)

test2 <- tibble(state = "Washington D.C.", mortality_rate = 16.7,
       ownership_rate = 0.087, region = NE)
#> Error in eval_tidy(xs[[j]], mask): object 'NE' not found
bind_rows(mortality_df, test2)
#> Error in list2(...): object 'test2' not found

test3 <- tibble(state = "Washington D.C.", mortality_rate = "16.7",
       ownership_rate = "0.087", region = "NE")
bind_rows(mortality_df, test3)
#> Error in `bind_rows()`:
#> ! Can't combine `mortality_rate` <double> and `mortality_rate` <character>.
```

3. Examine the following data sets that are in `R`'s base library on demographic statistics about the U.S. states and state abbreviations:


```r
df1 <- as_tibble(state.x77)
df2 <- as_tibble(state.abb)
df1
#> # A tibble: 50 × 8
#>    Population Income Illiteracy Life …¹ Murder HS Gr…² Frost
#>         <dbl>  <dbl>      <dbl>   <dbl>  <dbl>   <dbl> <dbl>
#>  1       3615   3624        2.1    69.0   15.1    41.3    20
#>  2        365   6315        1.5    69.3   11.3    66.7   152
#>  3       2212   4530        1.8    70.6    7.8    58.1    15
#>  4       2110   3378        1.9    70.7   10.1    39.9    65
#>  5      21198   5114        1.1    71.7   10.3    62.6    20
#>  6       2541   4884        0.7    72.1    6.8    63.9   166
#>  7       3100   5348        1.1    72.5    3.1    56     139
#>  8        579   4809        0.9    70.1    6.2    54.6   103
#>  9       8277   4815        1.3    70.7   10.7    52.6    11
#> 10       4931   4091        2      68.5   13.9    40.6    60
#> # … with 40 more rows, 1 more variable: Area <dbl>, and
#> #   abbreviated variable names ¹​`Life Exp`, ²​`HS Grad`
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
df2
#> # A tibble: 50 × 1
#>    value
#>    <chr>
#>  1 AL   
#>  2 AK   
#>  3 AZ   
#>  4 AR   
#>  5 CA   
#>  6 CO   
#>  7 CT   
#>  8 DE   
#>  9 FL   
#> 10 GA   
#> # … with 40 more rows
#> # ℹ Use `print(n = ...)` to see more rows
```

Combine the two data sets with `bind_cols()`. What are you assuming about the data sets in order to use this function? 



4. \* Combine the columns of the states data set you made in Exercise 3 with the mortality data set __without__ Washington D.C.



5. \* Use a join function to combine the mortality data set (`all_df`) __with__ D.C. with the states data set from Exercise 3 (`states_df`). For this exercise, keep the row with Washington D.C., having it take on `NA` values for any variable not observed in the states data.



6. \* Repeat Exercise 5, but now drop Washington D.C. in your merging process. Practice doing this __with a join function__ (as opposed to `slice()`-ing it out explicitly).



7. \* Use `semi_join()` to create a subset of `states_df` that are in the `NE` region. __Hint__: You will need to filter `all_df` first to contain only states in the `NE` region.



8. \* Do the same thing as Exercise 7, but this time, use `anti_join()`. __Hint__: You'll need to filter `all_df` in a different way to achieve this.



9. Examine the following data sets (the first is `df1` and the second is `df2`) and then, without running any code, answer the following questions.


-----------
 id   xvar 
---- ------
 A     1   

 B     2   

 C     3   

 E     1   

 F     2   
-----------


-----------
 id   yvar 
---- ------
 A     2   

 C     1   

 D     2   

 E     1   

 G     1   

 H     4   
-----------

a. How many rows would be in the data set from `left_join(df1, df2, by = c("id" = "id"))`?



b. How many rows would be in the data set from `left_join(df2, df1, by = c("id" = "id"))`?



c. How many rows would be in the data set from `full_join(df1, df2, by = c("id" = "id"))`?



d. How many rows would be in the data set from `inner_join(df1, df2, by = c("id" = "id"))`?



e. How many rows would be in the data set from `semi_join(df1, df2, by = c("id" = "id"))`?



f. How many rows would be in the data set from `anti_join(df1, df2, by = c("id" = "id"))`?



## Exercise Solutions {#solutions-10}

### `bind_rows()` and `bind_cols()` S

1. \* Run the following and explain why `R` does not simply stack the rows. Then, fix the issue with the `rename()` function.


```r
df_test1a <- tibble(xvar = c(1, 2), yvar = c(5, 1))
df_test1b <- tibble(x = c(1, 2), y = c(5, 1))
bind_rows(df_test1a, df_test1b)
#> # A tibble: 4 × 4
#>    xvar  yvar     x     y
#>   <dbl> <dbl> <dbl> <dbl>
#> 1     1     5    NA    NA
#> 2     2     1    NA    NA
#> 3    NA    NA     1     5
#> 4    NA    NA     2     1
```


```r
## This doesn't stack rows because the columns are named differently
## in the two data sets. If xvar is the same variable as x and 
## yvar is the same variable as y, then we can rename the columns in
## one of the data sets:

df_test1a <- df_test1a |> rename(x = "xvar", y = "yvar")
bind_rows(df_test1a, df_test1b)
#> # A tibble: 4 × 2
#>       x     y
#>   <dbl> <dbl>
#> 1     1     5
#> 2     2     1
#> 3     1     5
#> 4     2     1
```

### Mutating Joins S

### Filtering Joins S

2. \* Take the `semi_join()` tennis example, but now suppose that we want to keep only the matches in 2019 where __both__ the winning player and the losing player had 10 or more match wins in 2018. How can you modify the code to achieve that goal?


```r
tennis_2019_10 <- semi_join(atp_2019, win10,
                            by = c("winner_name" = "winner_name"))
tennis_2019_10$winner_name
```


```r
## There are many ways to do this, and this solution gives just one way
## A first step would be to create a data set that keeps only
## the katches with losing players with 10 or more wins in 2018
tennis_2019_10_lose <- semi_join(atp_2019, win10,
                            by = c("loser_name" = "winner_name"))

## Using `bind_rows()` would result in many duplicate matches. A way
## to avoid duplicates with joining functions is

tennis_temp <- anti_join(tennis_2019_10_lose, tennis_2019_10)
#> Joining, by = c("tourney_id", "tourney_name", "surface",
#> "draw_size", "tourney_level", "tourney_date", "match_num",
#> "winner_id", "winner_seed", "winner_entry", "winner_name",
#> "winner_hand", "winner_ht", "winner_ioc", "winner_age",
#> "loser_id", "loser_seed", "loser_entry", "loser_name",
#> "loser_hand", "loser_ht", "loser_ioc", "loser_age",
#> "score", "best_of", "round", "minutes", "w_ace", "w_df",
#> "w_svpt", "w_1stIn", "w_1stWon", "w_2ndWon", "w_SvGms",
#> "w_bpSaved", "w_bpFaced", "l_ace", "l_df", "l_svpt",
#> "l_1stIn", "l_1stWon", "l_2ndWon", "l_SvGms", "l_bpSaved",
#> "l_bpFaced", "winner_rank", "winner_rank_points",
#> "loser_rank", "loser_rank_points")
tennis_temp
## there are 383 matches in the lose data set that aren't in the 
## win data set. Now, we can bind_rows():

final_df <- bind_rows(tennis_2019_10, tennis_temp)
```

### Chapter Exercises S {#chapexercise-10-S}

1. \* Read in the gun violence data set, and suppose that you want to add a row to this data set that has the statistics on gun ownership and mortality rate in the District of Columbia (Washington D.C., which is in the NE region, has 16.7 deaths per 100,000 people, and a gun ownership rate of 8.7%). To do so, create a `tibble()` that has a single row representing D.C. and then combine your new `tibble` with the overall gun violence data set. Name this new data set `all_df`.


```r
library(tidyverse)
mortality_df <- read_csv(here("data/gun_violence_us.csv"))
#> Rows: 50 Columns: 4
#> ── Column specification ────────────────────────────────────
#> Delimiter: ","
#> chr (2): state, region
#> dbl (2): mortality_rate, ownership_rate
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```


```r
dc_df <- tibble(state = "Washington D.C.", mortality_rate = 16.7,
       ownership_rate = 0.087, region = "NE")
all_df <- bind_rows(mortality_df, dc_df)
```

4. \* Combine the columns of the states data set you made in Section A Exercise 3 with the mortality data set __without__ Washington D.C.


```r
bind_cols(mortality_df, states_df)
```

5. \* Use a join function to combine the mortality data set __with__ D.C. with the states data set from Exercise 3. For this exercise, keep the row with Washington D.C., having it take on `NA` values for any variable not observed in the states data.


```r
left_join(all_df, states_df, by = c("state" = "value"))
#> # A tibble: 51 × 12
#>    state mortality_r…¹ owner…² region Popul…³ Income Illit…⁴
#>    <chr>         <dbl>   <dbl> <chr>    <dbl>  <dbl>   <dbl>
#>  1 AL             16.7   0.489 South     3615   3624     2.1
#>  2 AK             18.8   0.617 West       365   6315     1.5
#>  3 AZ             13.4   0.323 West      2212   4530     1.8
#>  4 AR             16.4   0.579 South     2110   3378     1.9
#>  5 CA              7.4   0.201 West     21198   5114     1.1
#>  6 CO             12.1   0.343 West      2541   4884     0.7
#>  7 CT              4.9   0.166 NE        3100   5348     1.1
#>  8 DE             11.1   0.052 NE         579   4809     0.9
#>  9 FL             11.5   0.325 South     8277   4815     1.3
#> 10 GA             13.7   0.316 South     4931   4091     2  
#> # … with 41 more rows, 5 more variables: `Life Exp` <dbl>,
#> #   Murder <dbl>, `HS Grad` <dbl>, Frost <dbl>, Area <dbl>,
#> #   and abbreviated variable names ¹​mortality_rate,
#> #   ²​ownership_rate, ³​Population, ⁴​Illiteracy
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
## or
full_join(all_df, states_df, by = c("state" = "value"))
#> # A tibble: 51 × 12
#>    state mortality_r…¹ owner…² region Popul…³ Income Illit…⁴
#>    <chr>         <dbl>   <dbl> <chr>    <dbl>  <dbl>   <dbl>
#>  1 AL             16.7   0.489 South     3615   3624     2.1
#>  2 AK             18.8   0.617 West       365   6315     1.5
#>  3 AZ             13.4   0.323 West      2212   4530     1.8
#>  4 AR             16.4   0.579 South     2110   3378     1.9
#>  5 CA              7.4   0.201 West     21198   5114     1.1
#>  6 CO             12.1   0.343 West      2541   4884     0.7
#>  7 CT              4.9   0.166 NE        3100   5348     1.1
#>  8 DE             11.1   0.052 NE         579   4809     0.9
#>  9 FL             11.5   0.325 South     8277   4815     1.3
#> 10 GA             13.7   0.316 South     4931   4091     2  
#> # … with 41 more rows, 5 more variables: `Life Exp` <dbl>,
#> #   Murder <dbl>, `HS Grad` <dbl>, Frost <dbl>, Area <dbl>,
#> #   and abbreviated variable names ¹​mortality_rate,
#> #   ²​ownership_rate, ³​Population, ⁴​Illiteracy
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

6. \* Repeat Exercise 5, but now drop Washington D.C. in your merging process. Practice doing this __with a join function__ (as opposed to `slice()` ing it out explictly).


```r
inner_join(all_df, states_df, by = c("state" = "value"))
#> # A tibble: 50 × 12
#>    state mortality_r…¹ owner…² region Popul…³ Income Illit…⁴
#>    <chr>         <dbl>   <dbl> <chr>    <dbl>  <dbl>   <dbl>
#>  1 AL             16.7   0.489 South     3615   3624     2.1
#>  2 AK             18.8   0.617 West       365   6315     1.5
#>  3 AZ             13.4   0.323 West      2212   4530     1.8
#>  4 AR             16.4   0.579 South     2110   3378     1.9
#>  5 CA              7.4   0.201 West     21198   5114     1.1
#>  6 CO             12.1   0.343 West      2541   4884     0.7
#>  7 CT              4.9   0.166 NE        3100   5348     1.1
#>  8 DE             11.1   0.052 NE         579   4809     0.9
#>  9 FL             11.5   0.325 South     8277   4815     1.3
#> 10 GA             13.7   0.316 South     4931   4091     2  
#> # … with 40 more rows, 5 more variables: `Life Exp` <dbl>,
#> #   Murder <dbl>, `HS Grad` <dbl>, Frost <dbl>, Area <dbl>,
#> #   and abbreviated variable names ¹​mortality_rate,
#> #   ²​ownership_rate, ³​Population, ⁴​Illiteracy
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
## or
left_join(states_df, all_df, by = c("value" = "state"))
#> # A tibble: 50 × 12
#>    Population Income Illiteracy Life …¹ Murder HS Gr…² Frost
#>         <dbl>  <dbl>      <dbl>   <dbl>  <dbl>   <dbl> <dbl>
#>  1       3615   3624        2.1    69.0   15.1    41.3    20
#>  2        365   6315        1.5    69.3   11.3    66.7   152
#>  3       2212   4530        1.8    70.6    7.8    58.1    15
#>  4       2110   3378        1.9    70.7   10.1    39.9    65
#>  5      21198   5114        1.1    71.7   10.3    62.6    20
#>  6       2541   4884        0.7    72.1    6.8    63.9   166
#>  7       3100   5348        1.1    72.5    3.1    56     139
#>  8        579   4809        0.9    70.1    6.2    54.6   103
#>  9       8277   4815        1.3    70.7   10.7    52.6    11
#> 10       4931   4091        2      68.5   13.9    40.6    60
#> # … with 40 more rows, 5 more variables: Area <dbl>,
#> #   value <chr>, mortality_rate <dbl>,
#> #   ownership_rate <dbl>, region <chr>, and abbreviated
#> #   variable names ¹​`Life Exp`, ²​`HS Grad`
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

7. \* Use `semi_join()` to create a subset of `states_df` that are in the `NE` region. __Hint__: You will need to filter `all_df` first to contain only states in the `NE` region.


```r
ne_df <- all_df |> filter(region == "NE")
semi_join(states_df, ne_df, by = c("value" = "state"))
#> # A tibble: 10 × 9
#>    Popul…¹ Income Illit…² Life …³ Murder HS Gr…⁴ Frost  Area
#>      <dbl>  <dbl>   <dbl>   <dbl>  <dbl>   <dbl> <dbl> <dbl>
#>  1    3100   5348     1.1    72.5    3.1    56     139  4862
#>  2     579   4809     0.9    70.1    6.2    54.6   103  1982
#>  3    1058   3694     0.7    70.4    2.7    54.7   161 30920
#>  4    4122   5299     0.9    70.2    8.5    52.3   101  9891
#>  5    5814   4755     1.1    71.8    3.3    58.5   103  7826
#>  6     812   4281     0.7    71.2    3.3    57.6   174  9027
#>  7    7333   5237     1.1    70.9    5.2    52.5   115  7521
#>  8   18076   4903     1.4    70.6   10.9    52.7    82 47831
#>  9     931   4558     1.3    71.9    2.4    46.4   127  1049
#> 10     472   3907     0.6    71.6    5.5    57.1   168  9267
#> # … with 1 more variable: value <chr>, and abbreviated
#> #   variable names ¹​Population, ²​Illiteracy, ³​`Life Exp`,
#> #   ⁴​`HS Grad`
#> # ℹ Use `colnames()` to see all variable names
```

8. \* Do the same thing as Exercise 7, but this time, use `anti_join()`. __Hint__: You'll need to filter `all_df` in a different way to achieve this.


```r
notne_df <- all_df |> filter(region != "NE")
anti_join(states_df, notne_df, by = c("value" = "state"))
#> # A tibble: 10 × 9
#>    Popul…¹ Income Illit…² Life …³ Murder HS Gr…⁴ Frost  Area
#>      <dbl>  <dbl>   <dbl>   <dbl>  <dbl>   <dbl> <dbl> <dbl>
#>  1    3100   5348     1.1    72.5    3.1    56     139  4862
#>  2     579   4809     0.9    70.1    6.2    54.6   103  1982
#>  3    1058   3694     0.7    70.4    2.7    54.7   161 30920
#>  4    4122   5299     0.9    70.2    8.5    52.3   101  9891
#>  5    5814   4755     1.1    71.8    3.3    58.5   103  7826
#>  6     812   4281     0.7    71.2    3.3    57.6   174  9027
#>  7    7333   5237     1.1    70.9    5.2    52.5   115  7521
#>  8   18076   4903     1.4    70.6   10.9    52.7    82 47831
#>  9     931   4558     1.3    71.9    2.4    46.4   127  1049
#> 10     472   3907     0.6    71.6    5.5    57.1   168  9267
#> # … with 1 more variable: value <chr>, and abbreviated
#> #   variable names ¹​Population, ²​Illiteracy, ³​`Life Exp`,
#> #   ⁴​`HS Grad`
#> # ℹ Use `colnames()` to see all variable names
```

## Non-Exercise `R` Code {#rcode-10}


```r
library(tidyverse)
library(here)
atp_2019 <- read_csv(here("data/atp_matches_2019.csv"))
atp_2018 <- read_csv(here("data/atp_matches_2018.csv"))
head(atp_2019) 
head(atp_2018)
spec(atp_2018)
atp_2018 <- read_csv(here("data/atp_matches_2018.csv"),
                     col_types = cols(winner_seed = col_character(),
                                      loser_seed = col_character()))
atp_df <- bind_rows(atp_2018, atp_2019)
atp_df
df_test2a <- tibble(xvar = c(1, 2))
df_test2b <- tibble(xvar = c(1, 2), y = c(5, 1))
bind_rows(df_test2a, df_test2b)
df_test1a <- tibble(xvar = c(1, 2), yvar = c(5, 1))
df_test1b <- tibble(x = c(1, 2), y = c(5, 1))
bind_cols(df_test1a, df_test1b)
library(tidyverse)
df1 <- tibble(name = c("Emily", "Miguel", "Tonya"), fav_sport = c("Swimming", "Football", "Tennis"))
df2 <- tibble(name = c("Tonya", "Miguel", "Emily"),
              fav_colour = c("Robin's Egg Blue", "Tickle Me Pink", "Goldenrod"))
##install.packages("babynames")
library(babynames)
life_df <- babynames::lifetables
birth_df <- babynames::births
babynames_df <- babynames::babynames
head(babynames)
head(births)
head(lifetables)
combined_left <- left_join(babynames_df, birth_df, by = c("year" = "year"))
head(combined_left)
tail(combined_left)
## these will always do the same exact thing
right_join(babynames_df, birth_df, by = c("year" = "year"))
left_join(birth_df, babynames_df, by = c("year" = "year"))
full_join(babynames_df, birth_df, by = c("year" = "year"))
inner_join(babynames_df, birth_df, by = c("year" = "year"))
slumajors_df <- read_csv(here("data/SLU_Majors_15_19.csv"))
collegemajors_df <- read_csv(here("data/college-majors.csv"))
head(slumajors_df)
head(collegemajors_df)
left_join(slumajors_df, collegemajors_df, by = c("Major" = "Major"))
collegemajors_df <- collegemajors_df |>
  mutate(Major = str_to_title(Major))
left_join(slumajors_df, collegemajors_df)
atp_2019 <- read_csv(here("data/atp_matches_2019.csv"))
atp_2018 <- read_csv(here("data/atp_matches_2018.csv"))
atp_2019
atp_2018
win10 <- atp_2018 |> group_by(winner_name) |>
  summarise(nwin = n()) |> 
  filter(nwin >= 10)
win10
tennis_2019_10 <- semi_join(atp_2019, win10,
                            by = c("winner_name" = "winner_name"))
tennis_2019_10$winner_name
new_winners <- anti_join(atp_2019, atp_2018,
                         by = c("winner_name" = "winner_name")) 
new_winners$winner_name
new_winners |> group_by(winner_name) |>
  summarise(nwin = n()) |>
  arrange(desc(nwin))
```


