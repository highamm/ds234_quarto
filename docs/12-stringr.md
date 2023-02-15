# Text Data with `tidytext` and `stringr`

__Goals__:

* use functions in the `stringr` package and in the `tidytext` package to analyze text data.
* introduce some of the issues with manipulating strings that don't pertain to numeric or factor data.
* perform a basic sentiment analysis.

## Text Analysis

Beyonce is a legend. For this example, we will work through a text analysis on lyrics from songs from Beyonce's albums, utilizing functions from both `stringr` to parse strings and `tidytext` to convert text data into a tidy format. To begin, read in a data set of Beyonce's lyrics:


```r
library(tidyverse)
library(here)
beyonce <- read_csv(here("data/beyonce_lyrics.csv"))
head(beyonce)
```

We will be most focused on the `line` variable, as each value for this variable contains a line from a Beyonce song. There's other variables present as well, such as the `song_name` and the `artist_name` (the data set originally came from a data set with artists other than Beyonce).

You can look at the first 4 values of `line` with


```r
beyonce$line[1:4]
#> [1] "If I ain't got nothing, I got you"                       
#> [2] "If I ain't got something, I don't give a damn"           
#> [3] "'Cause I got it with you"                                
#> [4] "I don't know much about algebra, but I know 1+1 equals 2"
```

Our end goal is to construct a plot that shows the most popular words in Beyonce's albums. This is much more challenging than it sounds because we will have to deal with the nuances of working with text data.

The `tidytext` package makes it a lot easier to work with text data in many regards. Let's use the `unnest_tokens()` functions from `tidytext` to separate the lines into individual words. We'll name this new data set `beyonce_unnest`:


```r
library(tidytext)
beyonce_unnest <- beyonce |> unnest_tokens(output = "word", input = "line")
beyonce_unnest
#> # A tibble: 164,740 × 6
#>    song_id song_name artist_id artist_name song_line word   
#>      <dbl> <chr>         <dbl> <chr>           <dbl> <chr>  
#>  1   50396 1+1             498 Beyoncé             1 if     
#>  2   50396 1+1             498 Beyoncé             1 i      
#>  3   50396 1+1             498 Beyoncé             1 ain't  
#>  4   50396 1+1             498 Beyoncé             1 got    
#>  5   50396 1+1             498 Beyoncé             1 nothing
#>  6   50396 1+1             498 Beyoncé             1 i      
#>  7   50396 1+1             498 Beyoncé             1 got    
#>  8   50396 1+1             498 Beyoncé             1 you    
#>  9   50396 1+1             498 Beyoncé             2 if     
#> 10   50396 1+1             498 Beyoncé             2 i      
#> # … with 164,730 more rows
#> # ℹ Use `print(n = ...)` to see more rows
```

We'll want to make sure that either all words are capitalized or no words are capitalized, for consistency (remember that `R` is case-sensitive). To that end, we'll modify the `word` variable and use `stringr`'s `str_to_lower()` to change all letters to lower-case:


```r
beyonce_unnest <- beyonce_unnest |> mutate(word = str_to_lower(word))
```

Let's try counting up Beyonce's most popular words from the data set we just made:


```r
beyonce_unnest |> group_by(word) |>
  summarise(n = n()) |>
  arrange(desc(n))
#> # A tibble: 6,469 × 2
#>    word      n
#>    <chr> <int>
#>  1 you    7693
#>  2 i      6669
#>  3 the    4719
#>  4 me     3774
#>  5 to     3070
#>  6 it     2999
#>  7 a      2798
#>  8 my     2676
#>  9 and    2385
#> 10 on     2344
#> # … with 6,459 more rows
#> # ℹ Use `print(n = ...)` to see more rows
```

What's the issue here?

To remedy this, we can use what are called __stop words__: words that are very common and carry little to no meaningful information. For example _the_, _it_, _are_, etc. are all __stop words__. We need to eliminate these from the data set before we continue on. Luckily, the `tidytext` package also provides a data set of common stop words in a data set named `stop_words`:


```r
head(stop_words)
#> # A tibble: 6 × 2
#>   word      lexicon
#>   <chr>     <chr>  
#> 1 a         SMART  
#> 2 a's       SMART  
#> 3 able      SMART  
#> 4 about     SMART  
#> 5 above     SMART  
#> 6 according SMART
```

Let's join the Beyonce lyrics data set to the stop words data set and elminate any stop words:


```r
beyonce_stop <- anti_join(beyonce_unnest, stop_words, by = c("word" = "word"))
```

Then, we can re-make the table with the stop words removed:


```r
beyonce_sum <- beyonce_stop |> group_by(word) |>
  summarise(n = n()) |>
  arrange(desc(n)) |>
  print(n = 25)
#> # A tibble: 5,937 × 2
#>    word        n
#>    <chr>   <int>
#>  1 love     1362
#>  2 baby     1024
#>  3 girl      592
#>  4 wanna     564
#>  5 hey       499
#>  6 boy       494
#>  7 yeah      491
#>  8 feel      488
#>  9 time      452
#> 10 uh        408
#> 11 halo      383
#> 12 check     366
#> 13 tonight   342
#> 14 girls     341
#> 15 ya        327
#> 16 run       325
#> 17 crazy     308
#> 18 world     301
#> 19 body      287
#> 20 ooh       281
#> 21 ladies    269
#> 22 top       241
#> 23 gotta     240
#> 24 beyoncé   238
#> 25 night     213
#> # … with 5,912 more rows
#> # ℹ Use `print(n = ...)` to see more rows
beyonce_sum
#> # A tibble: 5,937 × 2
#>    word      n
#>    <chr> <int>
#>  1 love   1362
#>  2 baby   1024
#>  3 girl    592
#>  4 wanna   564
#>  5 hey     499
#>  6 boy     494
#>  7 yeah    491
#>  8 feel    488
#>  9 time    452
#> 10 uh      408
#> # … with 5,927 more rows
#> # ℹ Use `print(n = ...)` to see more rows
```

Looking through the list, there are __still__ some stop words in there that were not picked up on in the `stop_words` data set. We will address these, as well as make a plot, in the exercises.

### Exercises {#exercise-12-1}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-12).

1. Look at the remaining words. Do any of them look like stop words that were missed with the stop words from the `tidytext` package? Create a tibble with a few of the remaining stop words (like `ooh`, `gotta`, `ya`, `uh`, and `yeah`) not picked up by the `tidytext` package, and use a join function to drop these words from the data set.

2. With the new data set, construct a point plot or a bar plot that shows the 20 most common words Beyonce uses, as well as the number of times each word is used.

3. Use the `wordcloud()` function in the `wordcloud` library and the code below to make a wordcloud of Beyonce's words.


```r
## install.packages("wordcloud")
library(wordcloud)
#> Loading required package: RColorBrewer
beyonce_small <- beyonce_sum |> filter(n > 50)
wordcloud(beyonce_small$word, beyonce_small$n, 
          colors = brewer.pal(8, "Dark2"), scale = c(5, .2),
          random.order = FALSE, random.color = FALSE)
```

Then, use `?wordcloud` to read about what the various arguments like `random.order`, `scale`, and `random.color` do.

If you want to delve into text data more, you'll need to learn about _regular expressions_ , or _regexes_. If interested, you can read more in the <a href="https://r4ds.had.co.nz/strings.html#matching-patterns-with-regular-expressions" target="_blank">R4DS textbook</a>. Starting out is not too bad, but learning about escaping special characters in `R` can be much more challenging!

We analyzed a short text data set, but, you can imagine extending this type of analysis to things like:

* song lyrics, if you have the lyrics to all of the songs from an artist <https://rpubs.com/RosieB/taylorswiftlyricanalysis>
* book analysis, if you have the text of an entire book or series of books
* tv analysis, if you have the scripts to all episodes of a tv show

If you were doing one of these analyses, there are lots of cool functions in `tidytext` to help you out! We will do one more example, this time looking at Donald Trump's twitter account in 2016.

## Basic Sentiment Analysis

We will use a provided .qmd file to replicate a sentiment analysis on Trump's twitter account from 2016. This analysis was used in conjunction with a major news story that hypothesized that Trump himself wrote tweets from an Android device while his campaign staff wrote tweets for him from an iPhone device. We will investigate what properties of his tweets led the author to believe this.

The .qmd file used for this is posted on Canvas. We will see more uses of `stringr` for this particular analysis. For this entire section, you should be able to follow along and understand what each line of code is doing. However, unlike all previous sections, you will not be expected to do a sentiment analysis on your own.

<!-- see below: sentiment analysis for the friends package -->

<!-- https://amirdjv.netlify.app/post/rating-and-sentiment-analysis-for-friends/ -->

<!-- additional resource: https://www.tidytextmining.com/tidytext.html -->

## Introduction to `stringr`

In the previous examples, the string data that we had consisted primarily of __words__. The tools in `tidytext` make working with data consisting of words not too painful. However, some data exists as strings that are __not__ words. For a non-trivial example, consider data sets obtained from <https://github.com/JeffSackmann/tennis_MatchChartingProject>, a repository for professional tennis match charting put together by Jeff Sackmann. Some of the following code was modified from a project completed by James Wolpe in a data visualization course.

From this repository, I have put together a data set on one particular tennis match to make it a bit easier for us to get started. The match I have chosen is the 2021 U.S. Open Final between Daniil Medvedev and Novak Djokovic. Why this match? This was arguably the most important match of Djokovic's career: if he won, he would win all four grand slams in a calendar year. I don't like Djokovic and he lost so looking back at the match brings me joy. Read in the data set with:


```r
library(here)
library(tidyverse)
med_djok_df <- read_csv(here("data/med_djok.csv"))
#> Rows: 182 Columns: 46
#> ── Column specification ────────────────────────────────────
#> Delimiter: ","
#> chr (19): point, Serving, match_id, Pts, Gm#, 1st, 2nd, ...
#> dbl (19): Pt, Set1, Set2, Gm1, Gm2, TbSet, TB?, Svr, Ret...
#> lgl  (8): TBpt, isAce, isUnret, isRallyWinner, isForced,...
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
head(med_djok_df)
#> # A tibble: 6 × 46
#>   point  Serving match…¹    Pt  Set1  Set2   Gm1   Gm2 Pts  
#>   <chr>  <chr>   <chr>   <dbl> <dbl> <dbl> <dbl> <dbl> <chr>
#> 1 4f2d@  ND      202109…     1     0     0     0     0 0-0  
#> 2 6d     ND      202109…     2     0     0     0     0 15-0 
#> 3 6b29f… ND      202109…     3     0     0     0     0 15-15
#> 4 4b28f… ND      202109…     4     0     0     0     0 30-15
#> 5 5b37b… ND      202109…     5     0     0     0     0 40-15
#> 6 6f28f… ND      202109…     6     0     0     0     0 40-30
#> # … with 37 more variables: `Gm#` <chr>, TbSet <dbl>,
#> #   `TB?` <dbl>, TBpt <lgl>, Svr <dbl>, Ret <dbl>,
#> #   `1st` <chr>, `2nd` <chr>, Notes <chr>, `1stSV` <dbl>,
#> #   `2ndSV` <dbl>, `1stIn` <dbl>, `2ndIn` <dbl>,
#> #   isAce <lgl>, isUnret <lgl>, isRallyWinner <lgl>,
#> #   isForced <lgl>, isUnforced <lgl>, isDouble <lgl>,
#> #   PtWinner <dbl>, isSvrWinner <dbl>, rallyCount <dbl>, …
#> # ℹ Use `colnames()` to see all variable names
```

The observations of the data set correspond to points played (so there is one row per point). There are a ton of variables in this data set, but the most important variable is the first variable, `point`, which contains a string with information about the types of shots that were played during the point. The coding of the `point` variable includes:

* `4` for serve out wide, `5` for serve into the body, and `6` for a serve "down the t (center)".
* `f` for forehand stroke, `b` for backhand stroke.
* `1` to a right-hander's forehand side, `2` for down the middle of the court, and `3` to a right-hander's backhand side.
* `d` for a ball hit deep, `w` for a ball hit wide, and `n` for a ball hit into the net
* `@` symbol at the end if the point ended in an unforced error
* and there's lots of other numbers and symbols that correspond to other things (volleys, return depths, hitting the top of the net, etc.)

For example, Djokovic served the 7th point of the match, which has a `point` value of `4f18f1f2b3b2f1w@`. This reads that 

* `4`: Djokovic served out wide,
* `f18`: Medvedev hit a forehand cross-court to Djokovic's forehand side
* `f1`: Djokovic hit a forehand cross-court to Medvedev's forehand side
* `f2`: Medvedev hit a forehand to the center of the court
* `b3`: Djokovic hit a backhand to Medvedev's backhand side
* `b2`: Medvedev hit a backhand to the center of the court
* `f1w@`: Djokovic hit a forehand to Medvedev's forehand side, but the shot landed wide and was recorded as an unforced error.

Clearly, there is a lot of data encoded in the `point` variable. We are going to introduce `stringr` by answering a relatively simple question: what are the serving patterns of Medvedev and Djokovic during this match?

### Regular Expressions

A __regex__, or __regular expression__, is a string used to identify particular patterns in string data. Regular expressions are used in __many__ languages (so, if you google something about a regular expression, you do not need to limit yourself to just looking at resources pertaining to `R`). 

Regex's can be used with the functions in the `stringr` package. The functions in the `stringr` package begin with `str_()`, much like the functions in `forcats` began with `fct_()`. We will first focus on the `str_detect()` function, which detects whether a particular regex is present in a string variable. `str_detect()` takes the name of the string as its first argument and the regex as the second argument. For example,


```r
str_detect(med_djok_df$point, pattern = "f")
#>   [1]  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
#>  [10] FALSE FALSE FALSE  TRUE FALSE FALSE  TRUE  TRUE  TRUE
#>  [19]  TRUE FALSE FALSE FALSE FALSE FALSE  TRUE FALSE FALSE
#>  [28] FALSE FALSE  TRUE FALSE FALSE  TRUE  TRUE  TRUE FALSE
#>  [37]  TRUE  TRUE FALSE  TRUE FALSE  TRUE FALSE  TRUE FALSE
#>  [46]  TRUE FALSE  TRUE FALSE  TRUE FALSE FALSE FALSE FALSE
#>  [55]  TRUE  TRUE FALSE FALSE  TRUE FALSE  TRUE  TRUE FALSE
#>  [64]  TRUE FALSE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE
#>  [73] FALSE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE FALSE  TRUE
#>  [82]  TRUE  TRUE  TRUE  TRUE FALSE  TRUE FALSE FALSE  TRUE
#>  [91]  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE FALSE
#> [100]  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE
#> [109] FALSE  TRUE FALSE  TRUE FALSE  TRUE FALSE FALSE  TRUE
#> [118] FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE
#> [127]  TRUE FALSE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE
#> [136]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE FALSE
#> [145] FALSE  TRUE FALSE FALSE  TRUE  TRUE FALSE  TRUE FALSE
#> [154] FALSE  TRUE  TRUE  TRUE FALSE  TRUE FALSE  TRUE FALSE
#> [163] FALSE  TRUE FALSE FALSE FALSE  TRUE FALSE FALSE  TRUE
#> [172]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
#> [181] FALSE FALSE
```

returns a `TRUE` if the letter `f` appears anywhere in the string and a `FALSE` if it does not. So, we can examine how many points a forehand was hit in the Medvedev Djokovic match. As a second example,


```r
str_detect(med_djok_df$point, pattern = "d@")
```

returns `TRUE` if `d@` appears in a string and `FALSE` if not. Note that `d@` must appear __together__ and __in that order__ to return a `TRUE`. This lets us examine how many points a ball is hit deep and is recorded an unforced error. It looks like


```r
sum(str_detect(med_djok_df$point, pattern = "d@"))
#> [1] 21
```

points ended in an unforced error where the ball was hit deep,


```r
sum(str_detect(med_djok_df$point, pattern = "w@"))
#> [1] 19
```

points ended in an unforced error where the ball was hit wide, and


```r
sum(str_detect(med_djok_df$point, pattern = "n@"))
#> [1] 22
```

points ended in an unforced error where the ball was hit into the net.

### `stringr` Functions with `dplyr`

We can combine the `stringr` functions with `dplyr` functions that we already know and love. For example, if we are only interested in points the end in an unforced error (so points that have the `@` symbol in them), we can filter out the points that don't have an `@`:


```r
med_djok_df |> filter(str_detect(point, pattern = "@") == TRUE)
#> # A tibble: 63 × 46
#>    point Serving match…¹    Pt  Set1  Set2   Gm1   Gm2 Pts  
#>    <chr> <chr>   <chr>   <dbl> <dbl> <dbl> <dbl> <dbl> <chr>
#>  1 4f2d@ ND      202109…     1     0     0     0     0 0-0  
#>  2 6b29… ND      202109…     3     0     0     0     0 15-15
#>  3 5b37… ND      202109…     5     0     0     0     0 40-15
#>  4 4f18… ND      202109…     7     0     0     0     0 40-40
#>  5 5b28… ND      202109…     8     0     0     0     0 40-AD
#>  6 6b27… DM      202109…    13     0     0     0     1 40-15
#>  7 6b38… ND      202109…    14     0     0     0     2 0-0  
#>  8 5b28… ND      202109…    16     0     0     0     2 0-30 
#>  9 6f38… ND      202109…    17     0     0     0     2 15-30
#> 10 5b1w@ ND      202109…    28     0     0     1     3 30-0 
#> # … with 53 more rows, 37 more variables: `Gm#` <chr>,
#> #   TbSet <dbl>, `TB?` <dbl>, TBpt <lgl>, Svr <dbl>,
#> #   Ret <dbl>, `1st` <chr>, `2nd` <chr>, Notes <chr>,
#> #   `1stSV` <dbl>, `2ndSV` <dbl>, `1stIn` <dbl>,
#> #   `2ndIn` <dbl>, isAce <lgl>, isUnret <lgl>,
#> #   isRallyWinner <lgl>, isForced <lgl>, isUnforced <lgl>,
#> #   isDouble <lgl>, PtWinner <dbl>, isSvrWinner <dbl>, …
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

We can then use `mutate()` with `case_when()` to create a variable corresponding to error type and then `summarise()` the error types made from the two players.


```r
med_djok_df |> filter(str_detect(point, pattern = "@") == TRUE) |>
  mutate(error_type = case_when(str_detect(point, pattern = "d@") ~ "deep error",
                                   str_detect(point, pattern = "w@") ~ "wide error",
            str_detect(point, pattern = "n@") ~ "net error")) |>
  group_by(PtWinner, error_type) |>
  summarise(n_errors = n())
#> `summarise()` has grouped output by 'PtWinner'. You can
#> override using the `.groups` argument.
#> # A tibble: 7 × 3
#> # Groups:   PtWinner [2]
#>   PtWinner error_type n_errors
#>      <dbl> <chr>         <int>
#> 1        1 deep error        9
#> 2        1 net error         6
#> 3        1 wide error       10
#> 4        2 deep error       12
#> 5        2 net error        16
#> 6        2 wide error        9
#> 7        2 <NA>              1
```

In the output above, a `PtWinner` of `1` corresponds to points that Djokovic won (and therefore points where Medvedev made the unforced error) while a `PtWinner` of `2` corresponds to points that Medvedev won (and therefore points where Djokovic made the unforced error). So we see that, in this match, Djokovic had more unforced errors overall. Medvedev's unforced errors tended to be deep or wide while the highest proportion of Djokovic's unforced errors were balls that went into the net.

We will explore our original "service patterns" question in the exercises. To close out this section, we will just emphasize that we have done a __very__ simple introduction into regexes. These can get very cumbersome, especially as the patterns you want to extract get more complicated. Consider the examples below.

* Detect which points are aces, which are coded in the variable as `*`. Regexes have "special characters, like `\`, `*`, `.`, which, if present in the variable need to be "escaped" with a backslash. But, the backslash is a special character, so it needs to be escaped too: so we need two `\\` in front of `*` to pull the points with a `*`.


```r
str_detect(med_djok_df$point, pattern = "\\*")
```

<br>

* Detect which points start with a `4` using `^` to denote "at the beginning":


```r
str_detect(med_djok_df$point, pattern = "^4")
```

<br>

* Detect which points end with an `@` using `$` to denote "at the end" (this is safer than what we did in the code above, where we just assumed that `@` did not appear anywhere else in the string except at the end).


```r
str_detect(med_djok_df$point, pattern = "@$")
```

<br>
* Extract all of the forehand shots that were hit with `str_extract_all()`. The regex here says to extract anything with an f followed by any number of digits before another non-digit symbol.


```r
str_extract_all(med_djok_df$point, pattern = "f[:digit:]+")
```

The purpose of these examples is just to show that things can get complicated with strings. For the purposes of assessment in this course, you are only responsible for the relatively simple cases discussed earlier in the section and in the exercises.

### Exercises {#exercise-12-1}

1. Use `str_detect()` and `dplyr` functions to create a variable for `serve_location` that is either `"wide"` if the `point` starts with a `4`, `"body"` if the `point` starts with a `5`, and `"down the center"` if the `point` starts with a `6`.

2. Use `dplyr` functions and the `Serving` variable to count the number of serve locations for each player. (i.e. for how many points did Medvedev hit a serve out wide?). 

3. Use `dplyr` functions, the `Serving` variable, and the `isSrvWinner` variable to find the proportion of points each player won for each of their serving locations (i.e. if Medvedev won 5 points while serving out wide and lost 3 points, the proportion would be 5 / 8 = `0.625`). 

Note that the `isSrvWinner` variable is coded as a `1` if the serving player won the point and `0` if the serving player lost the point.

4. The letters `v`, `z`, `i`, and `k` denote volleys (of different types). Use `str_detect()` and `dplyr` functions to figure out the proportion of points where a volley was hit.

## Chapter Exercises {#chapexercise-12}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-12).

There are no Chapter Exercises.

## Exercise Solutions {#solutions-12}

### Text Analysis S

There are no solutions.

### Basic Sentiment Analysis S

There are no solutions.

### Introduction to `stringr` S

There are no solutions.

### Chapter Exercises S {#chapexercise-12-S}

There are no solutions. 

## Non-Exercise `R` Code {#rcode-12}


```r
library(tidyverse)
library(here)
beyonce <- read_csv(here("data/beyonce_lyrics.csv"))
head(beyonce)
beyonce$line[1:4]
library(tidytext)
beyonce_unnest <- beyonce |> unnest_tokens(output = "word", input = "line")
beyonce_unnest
beyonce_unnest <- beyonce_unnest |> mutate(word = str_to_lower(word))
beyonce_unnest |> group_by(word) |>
  summarise(n = n()) |>
  arrange(desc(n))
head(stop_words)
beyonce_stop <- anti_join(beyonce_unnest, stop_words, by = c("word" = "word"))
beyonce_sum <- beyonce_stop |> group_by(word) |>
  summarise(n = n()) |>
  arrange(desc(n)) |>
  print(n = 25)
beyonce_sum
## install.packages("wordcloud")
library(wordcloud)
beyonce_small <- beyonce_sum |> filter(n > 50)
wordcloud(beyonce_small$word, beyonce_small$n, 
          colors = brewer.pal(8, "Dark2"), scale = c(5, .2),
          random.order = FALSE, random.color = FALSE)
library(here)
library(tidyverse)
med_djok_df <- read_csv(here("data/med_djok.csv"))
head(med_djok_df)
str_detect(med_djok_df$point, pattern = "f")
str_detect(med_djok_df$point, pattern = "d@")
sum(str_detect(med_djok_df$point, pattern = "d@"))
sum(str_detect(med_djok_df$point, pattern = "w@"))
sum(str_detect(med_djok_df$point, pattern = "n@"))
med_djok_df |> filter(str_detect(point, pattern = "@") == TRUE)
med_djok_df |> filter(str_detect(point, pattern = "@") == TRUE) |>
  mutate(error_type = case_when(str_detect(point, pattern = "d@") ~ "deep error",
                                   str_detect(point, pattern = "w@") ~ "wide error",
            str_detect(point, pattern = "n@") ~ "net error")) |>
  group_by(PtWinner, error_type) |>
  summarise(n_errors = n())
str_detect(med_djok_df$point, pattern = "\\*")
str_detect(med_djok_df$point, pattern = "^4")
str_detect(med_djok_df$point, pattern = "@$")
str_extract_all(med_djok_df$point, pattern = "f[:digit:]+")
```
