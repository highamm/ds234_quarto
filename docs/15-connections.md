# Connections to STAT 113, STAT 213, and CS 140

## STAT 113

In this section, we discuss how what we have learned in this data science course connects to some concepts that you learned about in STAT 113. As a quick refresher, a few concepts that you learned about in STAT 113 are:

* exploring data through numerical and graphical summaries. The connection to what we have been doing in this class is fairly straightforward: we've learned a lot about how to actually compute those numerical summaries and make appropriate graphics for potentially messy data.
* explaining what sampling distributions are and how they relate to confidence intervals and hypothesis tests. This topic is probably the least connected to what we have learned so far in this class.
* conducting hypothesis tests and creating confidence intervals to answer questions of interest. We will focus on this third general objective in this section.

The example we will use is an experiment  designed to assess the effects of race and sex on whether or not an employee received a callback for a job. In order to conduct the experiment, researchers randomly assigned names to resumes with each name associated with a particular race and gender, sent the resumes to employers, and recorded whether or not the resume received a callback. In addition to race, sex, and whether or not an employee received a callback, a few more variables were collected, like resume quality, whether or not the applicant had computer skills, years of experience, etc. A `1` for the `received_callback` indicates that the applicant received a callback.

You may recall this example from STAT 113: we used it to introduce a chi-square test of association. In that example and others like it, an appropriate graphic and summary statistics were provided. Here, we create these ourselves.

The data set is called `resume` in the `openintro` package: you'll need to install this package with `install.packages("openintro")`. Then, load in the data with


```r
library(openintro)
#> Loading required package: airports
#> Loading required package: cherryblossom
#> Loading required package: usdata
resume
#> # A tibble: 4,870 × 30
#>    job_ad_id job_c…¹ job_i…² job_t…³ job_f…⁴ job_e…⁵ job_o…⁶
#>        <dbl> <chr>   <chr>   <chr>     <dbl>   <dbl> <chr>  
#>  1       384 Chicago manufa… superv…      NA       1 unknown
#>  2       384 Chicago manufa… superv…      NA       1 unknown
#>  3       384 Chicago manufa… superv…      NA       1 unknown
#>  4       384 Chicago manufa… superv…      NA       1 unknown
#>  5       385 Chicago other_… secret…       0       1 nonpro…
#>  6       386 Chicago wholes… sales_…       0       1 private
#>  7       386 Chicago wholes… sales_…       0       1 private
#>  8       385 Chicago other_… secret…       0       1 nonpro…
#>  9       386 Chicago wholes… sales_…       0       1 private
#> 10       386 Chicago wholes… sales_…       0       1 private
#> # … with 4,860 more rows, 23 more variables:
#> #   job_req_any <dbl>, job_req_communication <dbl>,
#> #   job_req_education <dbl>, job_req_min_experience <chr>,
#> #   job_req_computer <dbl>, job_req_organization <dbl>,
#> #   job_req_school <chr>, received_callback <dbl>,
#> #   firstname <chr>, race <chr>, gender <chr>,
#> #   years_college <int>, college_degree <dbl>, …
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

### Chi-square Test of Association

Our goal is to assess whether there is evidence of racial discrimination in the study. In other words, are the variables `race` and `received_callback` associated?

__Prepare__. Let's start by writing the null and alternative hypotheses. 

$H_0:$ There is no association between `race` and `received_callback`.

$H_a:$ There is an association between `race` and `received_callback`.

Next, we can construct a summary graphic. One graphic to explore two categorical variables is a stacked bar plot.


```r
library(tidyverse)
#> ── Attaching packages ─────────────────── tidyverse 1.3.2 ──
#> ✔ ggplot2 3.3.6     ✔ purrr   0.3.4
#> ✔ tibble  3.1.8     ✔ dplyr   1.0.9
#> ✔ tidyr   1.2.0     ✔ stringr 1.4.0
#> ✔ readr   2.1.2     ✔ forcats 0.5.1
#> ── Conflicts ────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
resume_sum <- resume |> 
  mutate(received_callback = received_callback) |>
           group_by(race, received_callback) |>
  summarise(count = n())
#> `summarise()` has grouped output by 'race'. You can
#> override using the `.groups` argument.
ggplot(data = resume_sum, aes(x = race, y = count)) +
  geom_col(aes(fill = received_callback)) +
  scale_fill_viridis_c()
```

<img src="15-connections_files/figure-html/unnamed-chunk-2-1.png" width="672" />

What do you notice about the `recieved_callback` variable scale? How could we fix that?


```r
resume <- resume |>
  mutate(received_callback = as.factor(received_callback))
resume_sum <- resume |> 
           group_by(race, received_callback) |>
  summarise(count = n())
#> `summarise()` has grouped output by 'race'. You can
#> override using the `.groups` argument.
ggplot(data = resume_sum, aes(x = race, y = count)) +
  geom_col(aes(fill = received_callback)) +
  scale_fill_viridis_d()
```

<img src="15-connections_files/figure-html/unnamed-chunk-3-1.png" width="672" />

We might also want to generate a two-way table:


```r
resume |> group_by(race, received_callback) |>
  summarise(count = n()) |>
  pivot_wider(names_from = c("race"),
              values_from = "count")
#> `summarise()` has grouped output by 'race'. You can
#> override using the `.groups` argument.
#> # A tibble: 2 × 3
#>   received_callback black white
#>   <fct>             <int> <int>
#> 1 0                  2278  2200
#> 2 1                   157   235
```

__Check__: The two assumptions for the test are independence of observations and that all expected counts are larger than 5. We don't have time to discuss these in detail but we will assume that they are satisfied here.

__Calculate__: We next want to calculate a p-value for the hypothesis test. The core `tidyverse` packages do not offer functionality for hypothesis testing. Instead, there are some functions in base `R` that perform the various tests. You may have used the `lm()` function in STAT 213 to perform hypothesis testing in the regression context. `t.test()` and `chisq.test()` are a couple of other functions that can perform a one and two-sample t-test (`t.test()`) or a chi-square goodness-of-fit test and chi-square test of association `chisq.test()`. 
The arguments to `chisq.test()` for a test of association are two vectors. Because the arguments are not `data.frame`s, we need to specify the appropriate vectors directly with `resume$race` and `resume$received_callback`.


```r
chisq.test(x = resume$race, y = resume$received_callback)
#> 
#> 	Pearson's Chi-squared test with Yates' continuity
#> 	correction
#> 
#> data:  resume$race and resume$received_callback
#> X-squared = 16.449, df = 1, p-value = 4.998e-05
```

The output of `chisq.test()` gives a p-value of 0.00004998 with a chi-square statistic of 16.449 and 1 degree of freedom.

__Conclude__. Finally, we write a conclusion in context of the problem.

There is strong evidence that `race` and `callback` are associated. The graph shows that `white` applicants receive a callback more often than `black` applicants do and the hypothesis test shows that this is statistically significant.

### Additional Analysis

In addition to carrying out the steps of a statistical hypothesis test, we can also use the skills we have learned in this course to provide further information about the study. Some questions we might answer include:

* what is the distribution of job types `job_type` and job industries `job_industry` in the study?

* do some of the first names (`firstname`) used have more bias than other first names?

* what other variables are associated with whether or not the applicant received a callback?

To answer the question about the distribution of job types and job industries used in the study, we can make a simple bar plot:


```r
ggplot(data = resume, aes(x = fct_rev(fct_infreq(job_type)))) +
  geom_bar() +
  coord_flip() +
  labs(x = "Job Type")
```

<img src="15-connections_files/figure-html/unnamed-chunk-6-1.png" width="672" />

In the code, `fct_infreq()` orders the levels of `job_type` from the highest count/frequency to the lowest. `fct_rev()` reverses the order so that, on the resulting bar plot, the level with the highest count appears first.


```r
ggplot(data = resume, aes(x = fct_rev(fct_infreq(job_industry)))) +
  geom_bar() +
  coord_flip() +
  labs(x = "Job Industry")
```

<img src="15-connections_files/figure-html/unnamed-chunk-7-1.png" width="672" />


To answer the question about whether some first names are more biased than others, we might make a graph of the proportion of resumes that received a callback for each first name.


```r
resume_firstname <- resume |>
  group_by(firstname) |>
  summarise(propcallback = mean(received_callback == "1"),
            gender = unique(gender),
            race = unique(race)) |>
  arrange(desc(propcallback)) |>
  unite("gender_race", c(gender, race))

ggplot(data = resume_firstname, aes(x = gender_race, y = propcallback)) +
  geom_point()
```

<img src="15-connections_files/figure-html/unnamed-chunk-8-1.png" width="672" />

We can the label the name with the lowest callback rate and the name with the highest callback rate.


```r
library(ggrepel)
label_df <- resume_firstname |> 
  filter(propcallback == max(propcallback) |
           propcallback == min(propcallback))

ggplot(data = resume_firstname, aes(x = gender_race, y = propcallback)) +
  geom_point() +
  geom_label_repel(data = label_df, aes(label = firstname))
```

<img src="15-connections_files/figure-html/unnamed-chunk-9-1.png" width="672" />

### Exercises {#exercise-15-1}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-15).

1. Construct a graphic or make a table that explores whether one of the other variables in the data set is associated with whether the applicant receives a callback for the job. Other variables include `gender`, `years_college`, `college_degree`, `honors`, `worked_during_school`, `years_experience`, `computer_skills`, `special_skills`, `volunteer`, `military`, `employment_holes`, and `resume_quality`.

2. Construct a graphic or make a table that explores one of the other variables in the data set is associated with whether the applicant receives a callback for the job. If your variable in Exercise 1 was categorical, choose a quantitative variable for this exercise. If your variable in Exercise 1 was quantitative, choose a categorical variable for this exercise.

3. For the categorical variable that you chose, conduct a Chi-square test of association to see if there is statistical evidence that the variable is associated with `received_callback`. In your test, (a), write the null and alternative hypotheses, run the test in `chisq.test()` and make a note of whether or not you get a warning about assumptions for the test, and write a conclusion in context of the problem.

## STAT 213

Much of the same concepts in connecting STAT 113 to this course hold for connecting STAT 213 with this course. We can still use what we have learned to explore a data set, conduct a hypothesis test, and perform further analysis and exploration on the data set.

For this section, however, we will focus more on a tidy approach to modeling. In particular, we will use the `broom` package to return `tibble`s with model summary information that we can then use for further analysis, plotting, or presentation.

We will use the `coffee_ratings` data set, which contains observations on ratings of various coffees throughout the world. The data was obtained from the Github account (<https://github.com/rfordatascience/tidytuesday/blob/master/data/2020/2020-07-07/readme.md>). 

 A description of each variable in the data set is given below.

* `total_cup_points`, the score of the coffee by a panel of experts (our response variable for this section)
* `species`, the species of the coffee bean (Arabica or Robusta)
* `aroma`, aroma (smell) grade
* `flavor`, flavor grade
* `aftertaste`, aftertaste grade
* `acidity`, acidity grade
* `body`, body grade
* `balance`, balance grade
* `uniformity`, uniformity grade
* `clean_cup`, clean cup grade
* `sweetness`, sweetness grade
* `moisture`, moisture grade
* `category_one_defects`, count of category one defects
* `quakers`, quakers
* `category_two_defects`, the number of category two defects

### `broom` Package Functions

The `broom` package consists of three primary functions: `tidy()`, `glance()`, and `augment()`. 

__`tidy()`__

`tidy()` is analagous to `summary()` for a linear model object. Let's start by fitting a linear model with `lm()` with `total_cup_points` as the response and `species`, `aroma`, `flavor`, `sweetness`, and `moisture` as predictors.

Read in the data, load the `broom` package (and install it with `install.packages("broom")`), and fit the model with


```r
library(broom)
library(here)
#> here() starts at /Users/highamm/Desktop/datascience234
coffee_df <- read_csv(here("data/coffee_ratings.csv"))
#> Rows: 1339 Columns: 43
#> ── Column specification ────────────────────────────────────
#> Delimiter: ","
#> chr (24): species, owner, country_of_origin, farm_name, ...
#> dbl (19): total_cup_points, number_of_bags, aroma, flavo...
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
coffee_mod <- lm(total_cup_points ~ species + aroma + flavor +
                   sweetness + moisture,
   data = coffee_df)
```

In STAT 213, you likely used `summary()` to look at the model output:


```r
summary(coffee_mod)
#> 
#> Call:
#> lm(formula = total_cup_points ~ species + aroma + flavor + sweetness + 
#>     moisture, data = coffee_df)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -9.5132 -0.3705  0.0726  0.5610  5.5844 
#> 
#> Coefficients:
#>                Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)     7.04039    0.77377   9.099  < 2e-16 ***
#> speciesRobusta  2.85365    0.26861  10.624  < 2e-16 ***
#> aroma           1.95188    0.14575  13.392  < 2e-16 ***
#> flavor          5.09440    0.14042  36.281  < 2e-16 ***
#> sweetness       2.23956    0.06553  34.173  < 2e-16 ***
#> moisture       -1.88033    0.67368  -2.791  0.00533 ** 
#> ---
#> Signif. codes:  
#> 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 1.168 on 1333 degrees of freedom
#> Multiple R-squared:  0.8891,	Adjusted R-squared:  0.8887 
#> F-statistic:  2137 on 5 and 1333 DF,  p-value: < 2.2e-16
```

However, there are a few inconveniences involving `summary()`. First, it's just not that nice to look at: the output isn't formatted in a way that is easy to look at. Second, it can be challenging to pull items from the summary output with code. For example, if you want to pull the p-value for `moisture`, you would need to write something like:


```r
summary(coffee_mod)$coefficients["moisture", 4]
#> [1] 0.005327594
```

`tidy()` is an alternative that puts the model coefficients, standard errors, t-stats, and p-values in a tidy tibble:


```r
tidy(coffee_mod)
#> # A tibble: 6 × 5
#>   term           estimate std.error statistic   p.value
#>   <chr>             <dbl>     <dbl>     <dbl>     <dbl>
#> 1 (Intercept)        7.04    0.774       9.10 3.23e- 19
#> 2 speciesRobusta     2.85    0.269      10.6  2.31e- 25
#> 3 aroma              1.95    0.146      13.4  1.82e- 38
#> 4 flavor             5.09    0.140      36.3  4.73e-201
#> 5 sweetness          2.24    0.0655     34.2  2.41e-184
#> 6 moisture          -1.88    0.674      -2.79 5.33e-  3
```

The advantage of this format of output is that we can now use other `tidyverse` functions on the output. To pull the p-values,


```r
tidy(coffee_mod) |> select(p.value)
#> # A tibble: 6 × 1
#>     p.value
#>       <dbl>
#> 1 3.23e- 19
#> 2 2.31e- 25
#> 3 1.82e- 38
#> 4 4.73e-201
#> 5 2.41e-184
#> 6 5.33e-  3
```

or, to grab the output for a particular variable of interest:


```r
tidy(coffee_mod) |> filter(term == "aroma")
#> # A tibble: 1 × 5
#>   term  estimate std.error statistic  p.value
#>   <chr>    <dbl>     <dbl>     <dbl>    <dbl>
#> 1 aroma     1.95     0.146      13.4 1.82e-38
```

__`glance()`__

`glance()` puts some model summary statistics into a tidy tibble. For example, if we run


```r
glance(coffee_mod)
#> # A tibble: 1 × 12
#>   r.squared adj.r…¹ sigma stati…² p.value    df logLik   AIC
#>       <dbl>   <dbl> <dbl>   <dbl>   <dbl> <dbl>  <dbl> <dbl>
#> 1     0.889   0.889  1.17   2137.       0     5 -2105. 4224.
#> # … with 4 more variables: BIC <dbl>, deviance <dbl>,
#> #   df.residual <int>, nobs <int>, and abbreviated variable
#> #   names ¹​adj.r.squared, ²​statistic
#> # ℹ Use `colnames()` to see all variable names
```

you should notice a lot of statistics that you are familiar with from STAT 213, including `r.squared`, `adj.r.squared`, `sigma` (the residual standard error), `statistic` (the overall F-statistic), `AIC`, and `BIC`.

__`augment()`__ 

`augment()` is my personal favourite of the three. The function returns a `tibble` that contains all of the variables used to fit the model appended with commonly used diagnostic statistics like the fitted values (`.fitted)`, cook's distance (`.cooksd)`, `.hat` values for leverage, and residuals (`.resid`).


```r
augment(coffee_mod)
#> # A tibble: 1,339 × 12
#>    total_cup_…¹ species aroma flavor sweet…² moist…³ .fitted
#>           <dbl> <chr>   <dbl>  <dbl>   <dbl>   <dbl>   <dbl>
#>  1         90.6 Arabica  8.67   8.83   10       0.12    91.1
#>  2         89.9 Arabica  8.75   8.67   10       0.12    90.5
#>  3         89.8 Arabica  8.42   8.5    10       0       89.2
#>  4         89   Arabica  8.17   8.58   10       0.11    88.9
#>  5         88.8 Arabica  8.25   8.5    10       0.12    88.6
#>  6         88.8 Arabica  8.58   8.42   10       0.11    88.9
#>  7         88.8 Arabica  8.42   8.5    10       0.11    89.0
#>  8         88.7 Arabica  8.25   8.33    9.33    0.03    86.4
#>  9         88.4 Arabica  8.67   8.67    9.33    0.03    89.0
#> 10         88.2 Arabica  8.08   8.58   10       0.1     88.7
#> # … with 1,329 more rows, 5 more variables: .resid <dbl>,
#> #   .hat <dbl>, .sigma <dbl>, .cooksd <dbl>,
#> #   .std.resid <dbl>, and abbreviated variable names
#> #   ¹​total_cup_points, ²​sweetness, ³​moisture
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

`augment()` the data set makes it really easy to do things like:

* `filter()` the data set to examine values with high cook's distance that might be influential


```r
augment_df <- augment(coffee_mod)
augment_df |> filter(.cooksd > 1)
#> # A tibble: 1 × 12
#>   total_cup_p…¹ species aroma flavor sweet…² moist…³ .fitted
#>           <dbl> <chr>   <dbl>  <dbl>   <dbl>   <dbl>   <dbl>
#> 1             0 Arabica     0      0       0    0.12    6.81
#> # … with 5 more variables: .resid <dbl>, .hat <dbl>,
#> #   .sigma <dbl>, .cooksd <dbl>, .std.resid <dbl>, and
#> #   abbreviated variable names ¹​total_cup_points,
#> #   ²​sweetness, ³​moisture
#> # ℹ Use `colnames()` to see all variable names
```

We see right away that there is a potentially influential observation with `0` `total_cup_points`. Examining this variable further, we see that it is probably a data entry error that can be removed from the data.


```r
ggplot(data = coffee_df, aes(x = total_cup_points)) +
  geom_histogram(bins = 15, fill = "white", colour = "black")
```

<img src="15-connections_files/figure-html/unnamed-chunk-19-1.png" width="672" />

We could also find observations with high leverage


```r
augment_df |> filter(.hat > 0.2)
#> # A tibble: 2 × 12
#>   total_cup_p…¹ species aroma flavor sweet…² moist…³ .fitted
#>           <dbl> <chr>   <dbl>  <dbl>   <dbl>   <dbl>   <dbl>
#> 1          59.8 Arabica   7.5   6.67    1.33    0.1    58.4 
#> 2           0   Arabica   0     0       0       0.12    6.81
#> # … with 5 more variables: .resid <dbl>, .hat <dbl>,
#> #   .sigma <dbl>, .cooksd <dbl>, .std.resid <dbl>, and
#> #   abbreviated variable names ¹​total_cup_points,
#> #   ²​sweetness, ³​moisture
#> # ℹ Use `colnames()` to see all variable names
```

or observations that are outliers:


```r
augment_df |> filter(.std.resid > 3 | .std.resid < -3)
#> # A tibble: 25 × 12
#>    total_cup_…¹ species aroma flavor sweet…² moist…³ .fitted
#>           <dbl> <chr>   <dbl>  <dbl>   <dbl>   <dbl>   <dbl>
#>  1         82.8 Arabica  8.08   8.17   10       0.12    86.6
#>  2         82.4 Arabica  5.08   7.75   10       0.11    78.6
#>  3         82.3 Arabica  7.75   8.08    6.67    0.11    78.1
#>  4         80.7 Arabica  7.67   7.5     6.67    0       75.2
#>  5         80   Arabica  7.58   7.75   10       0       83.7
#>  6         79.9 Arabica  7.83   7.67   10       0       83.8
#>  7         79.2 Arabica  7.17   7.42    6.67    0.1     73.6
#>  8         78.6 Arabica  7.92   7.58   10       0.1     83.3
#>  9         78.3 Arabica  7.17   6.08   10       0.11    74.2
#> 10         77.6 Arabica  7.58   7.67    6       0.12    74.1
#> # … with 15 more rows, 5 more variables: .resid <dbl>,
#> #   .hat <dbl>, .sigma <dbl>, .cooksd <dbl>,
#> #   .std.resid <dbl>, and abbreviated variable names
#> #   ¹​total_cup_points, ²​sweetness, ³​moisture
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

Finally, we can use our `ggplot2` skills to construct plots like a residuals versus fitted values plot (filtering out the outlying observation first):


```r
ggplot(data = augment_df |> filter(.fitted > 25), aes(x = .fitted, y = .resid)) +
  geom_point() 
```

<img src="15-connections_files/figure-html/unnamed-chunk-22-1.png" width="672" />

### Exercises {#exercise-15-2}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-15).

1. Add a couple of more predictors to the linear model that we fit earlier. Then, use `glance()` to obtain some model fit statistics. Which model is "better" according to some of the metrics you learned about in STAT 213?

2. For one of your fitted models, construct a histogram of the residuals to assess the normality assumption (using `ggplot2` and `augment()`).

3. Make a table of the 5 coffees that have the highest __predicted__ coffee rating, according to one of your models.

## CS 140

In this section, we will repeat a couple of topics from CS 140, which is in Python, in `R`. In particular we will,

* write our own function. The syntax for doing so in `R` is __very__ similar to Python.

* perform iteration to repeat a similar task multiple times.

To start, suppose that we are interested in scraping some hitting data on SLU's baseball team from the web address <https://saintsathletics.com/sports/baseball/stats/2022>. After we have the hitting data, we want to create a statistic for each player's weighted on-base-average (`wOBA`). Information on what the `wOBA` is can be found here: <https://www.mlb.com/glossary/advanced-stats/weighted-on-base-average>. Some of the following code was modified from a project completed by Jack Sylvia in a data visualization course.

Code to do such a task is given in the following chunk.


```r
library(tidyverse)
library(rvest)
#> 
#> Attaching package: 'rvest'
#> The following object is masked from 'package:readr':
#> 
#>     guess_encoding

url_SLU <- "https://saintsathletics.com/sports/baseball/stats/2022"
tab_SLU <- read_html(url_SLU) |> html_nodes("table")
SLU_Hitting <- tab_SLU[[1]] |> html_table(fill = TRUE) |>
  head(-2) |>
  select(-23) |>
  mutate(wOBA = (0.69 * BB + 0.72 * HBP + 0.89 * (H-`2B`-`3B`-`HR`) + 1.27 * `2B` + 1.62 * `3B` + 2.10 * HR) / (AB + BB + SF + HBP))
```

We can make sure that the statistic was calculated with:


```r
SLU_Hitting |> select(wOBA, everything()) |> arrange(desc(wOBA))
#> # A tibble: 20 × 23
#>     wOBA   `#` Player    AVG   OPS `GP-GS`    AB     R     H
#>    <dbl> <int> <chr>   <dbl> <dbl> <chr>   <int> <int> <int>
#>  1 0.514     7 "Brink… 0.556 1.16  5-1         9     3     5
#>  2 0.497    25 "Liber… 0.379 1.16  25-19      66    19    25
#>  3 0.46      1 "Verra… 0.5   1.1   4-0         2     1     1
#>  4 0.452    13 "Butle… 0.325 1.08  35-35     126    31    41
#>  5 0.433     6 "Clark… 0.367 1.02  29-19      79    24    29
#>  6 0.425    11 "Circe… 0.252 1.00  35-33     111    27    28
#>  7 0.412     9 "Burke… 0.308 0.885 6-4        13     4     4
#>  8 0.391    30 "Watso… 0.318 0.853 35-33     110    29    35
#>  9 0.365    19 "Delan… 0.33  0.817 34-34     115    18    38
#> 10 0.358     8 "Forgi… 0.244 0.799 27-27      86    22    21
#> 11 0.356     5 "Desja… 0.284 0.741 28-20      67    23    19
#> 12 0.347    37 "Goret… 0.268 0.771 32-32      97    18    26
#> 13 0.345     3 "Haun,… 0     0.5   11-0        2     1     0
#> 14 0.335    18 "Feder… 0.275 0.733 25-7       40    13    11
#> 15 0.309    23 "Conno… 0.286 0.661 6-0         7     2     2
#> 16 0.294    22 "Court… 0.256 0.63  20-10      39     7    10
#> 17 0.292    20 "Court… 0.281 0.646 27-17      64     6    18
#> 18 0.285    41 "Comer… 0.222 0.582 31-21      72    16    16
#> 19 0.154    24 "Colan… 0.095 0.295 15-3       21     6     2
#> 20 0        36 "Boldu… 0     0     2-0         2     0     0
#> # … with 14 more variables: `2B` <int>, `3B` <int>,
#> #   HR <int>, RBI <int>, TB <int>, `SLG%` <dbl>, BB <int>,
#> #   HBP <int>, SO <int>, GDP <int>, `OB%` <dbl>, SF <int>,
#> #   SH <int>, `SB-ATT` <chr>
#> # ℹ Use `colnames()` to see all variable names
```

### Functions

Now, suppose that we might want to repeat the scraping and calculation of `wOBA` for other years at SLU or for other teams. We could, of course, obtain the new URL address and copy and paste the code that we used above, replacing the old URL address with the new one. This would be a reasonable thing to do if we only wanted to do this for _one_ other url. But, if we wanted to do this for 10, 20, 50, 1000, urls, we might consider writing a function to scrape the data and calculate the `wOBA`.

The format of a function in `R` is:


```r
name_of_function <- function(argument1, argument2, ....) {
  body_of_function ## performs various tasks with the arguments
  
  return(output) ## tells the function what to return
}
```

We have used functions throughout the entire semester, but they have always been functions that others have defined and are imported into `R` through packages. As we expand our toolbox, we might encounter situations where we want to write our own specialized functions for performing tasks that are not covered by functions that others have written.

Before we get back to our example, let's write a very simple function, called `get_sum_squares`, that computes the sum of squares from a numeric vector argument named `x_vec`. A sum of squares function would take each number in `x_vec`, square it, and then add the numbers up.


```r
get_sum_squares <- function(x_vec) {
  
  sum_of_squares <- sum(x_vec ^ 2)
  
  return(sum_of_squares)
}
```

Now, let's test our function on the numeric vector `c(2, 4, 1)`


```r
get_sum_squares(x_vec = c(2, 4, 1))
#> [1] 21
```

Now, we will move back to our example. We want to write a function called `get_hitting_data` that takes a `url_name`, scrapes the data from that url, and calculates the `wOBA` from the variables that were scraped. Note that our function will only work on urls that contain a data table formatted with the various baseball statistics as column names.

To create this function, we can simply copy and paste the code above and replace the SLU url web address with the argument `url_name` in the body of the function.


```r
get_hitting_data <- function(url_name) {
  
  tab <- read_html(url_name) |> html_nodes("table")
  
  hitting <- tab[[1]] |> html_table(fill = TRUE) |>
    head(-2) |>
    select(-23) |>
    mutate(wOBA = (0.69 * BB + 0.72 * HBP + 0.89 *
                     (H- `2B` - `3B` - `HR`) +
                     1.27 * `2B` + 1.62 * `3B` + 2.10 * HR) / 
             (AB + BB + SF + HBP),
           url_name = url_name)
  
  return(hitting)
}
```

We can then test our function on the SLU url:


```r
get_hitting_data(url_name = "https://saintsathletics.com/sports/baseball/stats/2022")
#> # A tibble: 20 × 24
#>      `#` Player    AVG   OPS `GP-GS`    AB     R     H  `2B`
#>    <int> <chr>   <dbl> <dbl> <chr>   <int> <int> <int> <int>
#>  1     6 "Clark… 0.367 1.02  29-19      79    24    29     5
#>  2    19 "Delan… 0.33  0.817 34-34     115    18    38     5
#>  3    13 "Butle… 0.325 1.08  35-35     126    31    41     9
#>  4    30 "Watso… 0.318 0.853 35-33     110    29    35     6
#>  5     5 "Desja… 0.284 0.741 28-20      67    23    19     1
#>  6    20 "Court… 0.281 0.646 27-17      64     6    18     2
#>  7    37 "Goret… 0.268 0.771 32-32      97    18    26     6
#>  8    11 "Circe… 0.252 1.00  35-33     111    27    28     9
#>  9     8 "Forgi… 0.244 0.799 27-27      86    22    21     4
#> 10    41 "Comer… 0.222 0.582 31-21      72    16    16     0
#> 11     7 "Brink… 0.556 1.16  5-1         9     3     5     0
#> 12     1 "Verra… 0.5   1.1   4-0         2     1     1     0
#> 13    25 "Liber… 0.379 1.16  25-19      66    19    25     8
#> 14     9 "Burke… 0.308 0.885 6-4        13     4     4     1
#> 15    23 "Conno… 0.286 0.661 6-0         7     2     2     0
#> 16    18 "Feder… 0.275 0.733 25-7       40    13    11     3
#> 17    22 "Court… 0.256 0.63  20-10      39     7    10     1
#> 18    24 "Colan… 0.095 0.295 15-3       21     6     2     0
#> 19     3 "Haun,… 0     0.5   11-0        2     1     0     0
#> 20    36 "Boldu… 0     0     2-0         2     0     0     0
#> # … with 15 more variables: `3B` <int>, HR <int>,
#> #   RBI <int>, TB <int>, `SLG%` <dbl>, BB <int>, HBP <int>,
#> #   SO <int>, GDP <int>, `OB%` <dbl>, SF <int>, SH <int>,
#> #   `SB-ATT` <chr>, wOBA <dbl>, url_name <chr>
#> # ℹ Use `colnames()` to see all variable names
```

### Iteration

Now suppose that we want to use our function to scrape the 2022 baseball statistics for all teams in the Liberty League. There are 10 teams in total. The websites for each team's statistics as well as the school name is given in the `tibble` below:


```r
school_df <- tibble(school_name = c("SLU", "Clarkson", "Rochester", "RIT", "Ithaca", "Skidmore", "RPI", "Union", "Bard", "Vassar"),
                    hitting_web_url = c("https://saintsathletics.com/sports/baseball/stats/2022",
                 "https://clarksonathletics.com/sports/baseball/stats/2022", 
                 "https://uofrathletics.com/sports/baseball/stats/2022",
                 "https://ritathletics.com/sports/baseball/stats/2022",
                 "https://athletics.ithaca.edu/sports/baseball/stats/2022",
                 "https://skidmoreathletics.com/sports/baseball/stats/2022",
                 "https://rpiathletics.com/sports/baseball/stats/2022",
                 "https://unionathletics.com/sports/baseball/stats/2022",
                 "https://bardathletics.com/sports/baseball/stats/2022",
                 "https://www.vassarathletics.com/sports/baseball/stats/2022"))
school_df
```

One option we have to obtain the hitting statistics for all 10 teams and calculating the `wOBA` (assuming that the tables are structured the same way on each web page) would be to apply our function 10 times and then bind together the results. The first three applications of the function are shown below.


```r
get_hitting_data(url_name = "https://saintsathletics.com/sports/baseball/stats/2022")
get_hitting_data(url_name = "https://clarksonathletics.com/sports/baseball/stats/2022")
get_hitting_data(url_name = "https://uofrathletics.com/sports/baseball/stats/2022")
```

For just 10 teams, this approach is certainly doable but is a bit annoying. And, what if we wanted to do this type of calculation for a league with more teams, such as the MLB (Major League Baseball)? Or, for multiple years for each team? 

A better approach is to use __iteration__ and write code to repeatedly scrape the data from each website and calculate the `wOBA` statistic with our function. In CS 140, the primary form of iteration you used was probably a `for` loop. `for` loops in `R` have very similar syntax to `for` loops in Python. However, in general, `for` loops are clunky, can take up a lot of lines of code, and can be difficult to read.

For this section, we will instead focus on a __functional programming__ approach to iteration through the `map()` function family in `purrr`. `purrr` is part of the core `tidyverse` so the package gets loaded in with `library(tidyverse)`. The `map()` function has two arguments: the first is a vector or a list and the second is a function. `map()` applies the function in the second argument to __each__ element of the vector or list in the first argument. For example, consider applying the `get_sum_squares` function we wrote earlier to a list of vectors:


```r
num_list <- list(vec1 = c(1, 4, 5), vec2 = c(9, 8, 3, 5), vec3 = 1)
map(num_list, get_sum_squares)
#> $vec1
#> [1] 42
#> 
#> $vec2
#> [1] 179
#> 
#> $vec3
#> [1] 1
```

The output is a list of sums of squares calculated with our `get_sum_squares()` function.

To apply the `map()` approach to iteration to our baseball web urls, we will create an object called `url_vec` that has the urls of each school.


```r
url_vec <- school_df$hitting_web_url
```

Then, we apply `map()` with the first argument being the `url_vec` and the second argument being the function `get_hitting_data()` that we wrote earlier.


```r
hitting_list <- map(url_vec, get_hitting_data)
hitting_list
```

Scraping and performing the `wOBA` calculation will take a few seconds. The output is a list of 10 tibbles. The `bind_rows()` function that we used to stack rows of different data frames or tibbles can also be used to stack rows of data frames or tibbles given in a list. We apply the function to the scraped data and then add the name of the school to the data frame with a `left_join()`:


```r
hitting_ll <- hitting_list |> bind_rows() |>
  left_join(school_df, by = c("url_name" = "hitting_web_url"))
hitting_ll
#> # A tibble: 213 × 25
#>      `#` Player    AVG   OPS `GP-GS`    AB     R     H  `2B`
#>    <int> <chr>   <dbl> <dbl> <chr>   <int> <int> <int> <int>
#>  1     6 "Clark… 0.367 1.02  29-19      79    24    29     5
#>  2    19 "Delan… 0.33  0.817 34-34     115    18    38     5
#>  3    13 "Butle… 0.325 1.08  35-35     126    31    41     9
#>  4    30 "Watso… 0.318 0.853 35-33     110    29    35     6
#>  5     5 "Desja… 0.284 0.741 28-20      67    23    19     1
#>  6    20 "Court… 0.281 0.646 27-17      64     6    18     2
#>  7    37 "Goret… 0.268 0.771 32-32      97    18    26     6
#>  8    11 "Circe… 0.252 1.00  35-33     111    27    28     9
#>  9     8 "Forgi… 0.244 0.799 27-27      86    22    21     4
#> 10    41 "Comer… 0.222 0.582 31-21      72    16    16     0
#> # … with 203 more rows, and 16 more variables: `3B` <int>,
#> #   HR <int>, RBI <int>, TB <int>, `SLG%` <dbl>, BB <int>,
#> #   HBP <int>, SO <int>, GDP <int>, `OB%` <dbl>, SF <int>,
#> #   SH <int>, `SB-ATT` <chr>, wOBA <dbl>, url_name <chr>,
#> #   school_name <chr>
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

With this data set, we can now do things like figure out the top 3 hitters from each team, according to the `wOBA` metric:


```r
hitting_ll |> group_by(school_name) |>
  arrange(desc(wOBA)) |>
  slice(1:3) |>
  select(Player, school_name, wOBA)
#> # A tibble: 30 × 3
#> # Groups:   school_name [10]
#>    Player                                      schoo…¹  wOBA
#>    <chr>                                       <chr>   <dbl>
#>  1 "Toby, Jared\r\n                          … Bard    0.488
#>  2 "Dumper, Sam\r\n                          … Bard    0.475
#>  3 "Myers, Jordan\r\n                        … Bard    0.431
#>  4 "Cantor, Danny\r\n                        … Clarks… 0.805
#>  5 "Price, Grant\r\n                         … Clarks… 0.475
#>  6 "Doyle, Caleb\r\n                         … Clarks… 0.473
#>  7 "Shirley, Buzz\r\n                        … Ithaca  0.524
#>  8 "Fabbo, Louis\r\n                         … Ithaca  0.465
#>  9 "Fabian, Matt\r\n                         … Ithaca  0.428
#> 10 "Blackall, Patrick \r\n                   … RIT     0.399
#> # … with 20 more rows, and abbreviated variable name
#> #   ¹​school_name
#> # ℹ Use `print(n = ...)` to see more rows
```

or find the players on each team with the most at bats `AB`:


```r
hitting_ll |> group_by(school_name) |>
  arrange(desc(AB)) |>
  slice(1:3) |>
  select(Player, school_name, AB)
#> # A tibble: 30 × 3
#> # Groups:   school_name [10]
#>    Player                                      schoo…¹    AB
#>    <chr>                                       <chr>   <int>
#>  1 "Toby, Jared\r\n                          … Bard      107
#>  2 "Myers, Jordan\r\n                        … Bard      107
#>  3 "Luscher, Alex\r\n                        … Bard      101
#>  4 "Brouillette, Colby\r\n                   … Clarks…   127
#>  5 "Wilson, Kent\r\n                         … Clarks…   126
#>  6 "Doyle, Caleb\r\n                         … Clarks…   103
#>  7 "Pedersen, Connor\r\n                     … Ithaca    207
#>  8 "Cutaia, Nicholas\r\n                     … Ithaca    180
#>  9 "Merod, Gil\r\n                           … Ithaca    169
#> 10 "Reilly, Chris\r\n                        … RIT       152
#> # … with 20 more rows, and abbreviated variable name
#> #   ¹​school_name
#> # ℹ Use `print(n = ...)` to see more rows
```

### Exercises {#exercise-15-3}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-15).

The code below scrapes data from a wikipedia page listing the billboard end of year "hot 100" songs for the year 2021


```r
library(rvest)
library(tidyverse)

year_scrape <- 2021
url <- paste0("https://en.wikipedia.org/wiki/Billboard_Year-End_Hot_100_singles_of_", year_scrape)

## convert the html code into something R can read
billboard_tab <- read_html(url) |> html_nodes("table")

## grabs the tables
billboard_df <- billboard_tab[[1]] |> html_table() |>
  mutate(year = year_scrape)
billboard_df
#> # A tibble: 100 × 4
#>      No. Title                                Artist…¹  year
#>    <int> <chr>                                <chr>    <dbl>
#>  1     1 "\"Levitating\""                     Dua Lipa  2021
#>  2     2 "\"Save Your Tears\""                The Wee…  2021
#>  3     3 "\"Blinding Lights\""                The Wee…  2021
#>  4     4 "\"Mood\""                           24kGold…  2021
#>  5     5 "\"Good 4 U\""                       Olivia …  2021
#>  6     6 "\"Kiss Me More\""                   Doja Ca…  2021
#>  7     7 "\"Leave the Door Open\""            Silk So…  2021
#>  8     8 "\"Drivers License\""                Olivia …  2021
#>  9     9 "\"Montero (Call Me by Your Name)\"" Lil Nas…  2021
#> 10    10 "\"Peaches\""                        Justin …  2021
#> # … with 90 more rows, and abbreviated variable name
#> #   ¹​`Artist(s)`
#> # ℹ Use `print(n = ...)` to see more rows
```

1. Wrap the code above in a function that scrapes data from Wikipedia for a user-provided `year_scrape` argument.

2. Create either a vector of the years 2014 through 2021 or a list of the years 2014 through 2021. Use your vector or list, along with the function you wrote in Exercise 1, to scrape data tables from each year.

3. Combine the data frames you scraped in Exercise 2 and use the combined data set to figure out which artist appears the highest number of times in the billboard hot 100 list within the years 2014 through 2021.

4. \* Note that your solution to Exercise 3 is likely imperfect because of songs that feature another musical artist. Why would such songs present a problem in counting the number of songs for each artist?

## Chapter Exercises {#chapexercise-15}

There are no chapter exercises for this section on connections to STAT 113, STAT 213, and CS 140.

## Exercise Solutions {#solutions-15}

### STAT 113 S

### STAT 213 S

### CS 140 S

4. \* Note that your solution to Exercise 3 is likely imperfect because of songs that feature another musical artist. Why would such songs present a problem in counting the number of songs for each artist?

When we `group_by()` musical artist and use our counting function `n()`, the artist by themselves and the artist featuring the other musician would be counted separately in our table.

## Non-Exercise `R` Code {#rcode-15}


```r
library(openintro)
resume
library(tidyverse)
resume_sum <- resume |> 
  mutate(received_callback = received_callback) |>
           group_by(race, received_callback) |>
  summarise(count = n())
ggplot(data = resume_sum, aes(x = race, y = count)) +
  geom_col(aes(fill = received_callback)) +
  scale_fill_viridis_c()
resume <- resume |>
  mutate(received_callback = as.factor(received_callback))
resume_sum <- resume |> 
           group_by(race, received_callback) |>
  summarise(count = n())
ggplot(data = resume_sum, aes(x = race, y = count)) +
  geom_col(aes(fill = received_callback)) +
  scale_fill_viridis_d()
resume |> group_by(race, received_callback) |>
  summarise(count = n()) |>
  pivot_wider(names_from = c("race"),
              values_from = "count")
chisq.test(x = resume$race, y = resume$received_callback)
ggplot(data = resume, aes(x = fct_rev(fct_infreq(job_type)))) +
  geom_bar() +
  coord_flip() +
  labs(x = "Job Type")
ggplot(data = resume, aes(x = fct_rev(fct_infreq(job_industry)))) +
  geom_bar() +
  coord_flip() +
  labs(x = "Job Industry")
resume_firstname <- resume |>
  group_by(firstname) |>
  summarise(propcallback = mean(received_callback == "1"),
            gender = unique(gender),
            race = unique(race)) |>
  arrange(desc(propcallback)) |>
  unite("gender_race", c(gender, race))

ggplot(data = resume_firstname, aes(x = gender_race, y = propcallback)) +
  geom_point()
library(ggrepel)
label_df <- resume_firstname |> 
  filter(propcallback == max(propcallback) |
           propcallback == min(propcallback))

ggplot(data = resume_firstname, aes(x = gender_race, y = propcallback)) +
  geom_point() +
  geom_label_repel(data = label_df, aes(label = firstname))
library(broom)
library(here)
coffee_df <- read_csv(here("data/coffee_ratings.csv"))
coffee_mod <- lm(total_cup_points ~ species + aroma + flavor +
                   sweetness + moisture,
   data = coffee_df)
summary(coffee_mod)
summary(coffee_mod)$coefficients["moisture", 4]
tidy(coffee_mod)
tidy(coffee_mod) |> select(p.value)
tidy(coffee_mod) |> filter(term == "aroma")
glance(coffee_mod)
augment(coffee_mod)
augment_df <- augment(coffee_mod)
augment_df |> filter(.cooksd > 1)
ggplot(data = coffee_df, aes(x = total_cup_points)) +
  geom_histogram(bins = 15, fill = "white", colour = "black")
augment_df |> filter(.hat > 0.2)
augment_df |> filter(.std.resid > 3 | .std.resid < -3)
ggplot(data = augment_df |> filter(.fitted > 25), aes(x = .fitted, y = .resid)) +
  geom_point() 
library(tidyverse)
library(rvest)

url_SLU <- "https://saintsathletics.com/sports/baseball/stats/2022"
tab_SLU <- read_html(url_SLU) |> html_nodes("table")
SLU_Hitting <- tab_SLU[[1]] |> html_table(fill = TRUE) |>
  head(-2) |>
  select(-23) |>
  mutate(wOBA = (0.69 * BB + 0.72 * HBP + 0.89 * (H-`2B`-`3B`-`HR`) + 1.27 * `2B` + 1.62 * `3B` + 2.10 * HR) / (AB + BB + SF + HBP))
SLU_Hitting |> select(wOBA, everything()) |> arrange(desc(wOBA))
get_sum_squares <- function(x_vec) {
  
  sum_of_squares <- sum(x_vec ^ 2)
  
  return(sum_of_squares)
}
get_sum_squares(x_vec = c(2, 4, 1))
get_hitting_data <- function(url_name) {
  
  tab <- read_html(url_name) |> html_nodes("table")
  
  hitting <- tab[[1]] |> html_table(fill = TRUE) |>
    head(-2) |>
    select(-23) |>
    mutate(wOBA = (0.69 * BB + 0.72 * HBP + 0.89 *
                     (H- `2B` - `3B` - `HR`) +
                     1.27 * `2B` + 1.62 * `3B` + 2.10 * HR) / 
             (AB + BB + SF + HBP),
           url_name = url_name)
  
  return(hitting)
}
get_hitting_data(url_name = "https://saintsathletics.com/sports/baseball/stats/2022")
school_df <- tibble(school_name = c("SLU", "Clarkson", "Rochester", "RIT", "Ithaca", "Skidmore", "RPI", "Union", "Bard", "Vassar"),
                    hitting_web_url = c("https://saintsathletics.com/sports/baseball/stats/2022",
                 "https://clarksonathletics.com/sports/baseball/stats/2022", 
                 "https://uofrathletics.com/sports/baseball/stats/2022",
                 "https://ritathletics.com/sports/baseball/stats/2022",
                 "https://athletics.ithaca.edu/sports/baseball/stats/2022",
                 "https://skidmoreathletics.com/sports/baseball/stats/2022",
                 "https://rpiathletics.com/sports/baseball/stats/2022",
                 "https://unionathletics.com/sports/baseball/stats/2022",
                 "https://bardathletics.com/sports/baseball/stats/2022",
                 "https://www.vassarathletics.com/sports/baseball/stats/2022"))
school_df
get_hitting_data(url_name = "https://saintsathletics.com/sports/baseball/stats/2022")
get_hitting_data(url_name = "https://clarksonathletics.com/sports/baseball/stats/2022")
get_hitting_data(url_name = "https://uofrathletics.com/sports/baseball/stats/2022")
num_list <- list(vec1 = c(1, 4, 5), vec2 = c(9, 8, 3, 5), vec3 = 1)
map(num_list, get_sum_squares)
url_vec <- school_df$hitting_web_url
hitting_list <- map(url_vec, get_hitting_data)
hitting_list
hitting_ll <- hitting_list |> bind_rows() |>
  left_join(school_df, by = c("url_name" = "hitting_web_url"))
hitting_ll
hitting_ll |> group_by(school_name) |>
  arrange(desc(wOBA)) |>
  slice(1:3) |>
  select(Player, school_name, wOBA)
hitting_ll |> group_by(school_name) |>
  arrange(desc(AB)) |>
  slice(1:3) |>
  select(Player, school_name, AB)
```
