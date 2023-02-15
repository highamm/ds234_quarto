# Introduction to SQL with `dbplyr`

__Goals:__

* explain what a __database__ is, how it is different from a data set, and why you might use a database.
* use the `dbplyr` to translate `R` code with `dplyr` to `SQL` queries on database tables.
* draw parallels between `dplyr` functions and the syntax used in `SQL`.

All of the `dplyr` functions we've used (both the ones from early in the semester and from the `xxxx_join()` family more recently) have corresponding components in `SQL`. `SQL` stands for Structured Query Language and is a very common language used with databases. Compared to `dplyr`, in general, `SQL` code is much harder to read, as SQL isn't designed specifically for data analysis like `dplyr` is. In this section, we will introduce databases and give a brief introduction to `SQL` for analyzing data from a database.

## What is a Database

The _R for Data Science_ textbook defines a database as "a collection of data frames," each called a __database table__. There a few key differences between a data frame (what we've been using the entire semester) and a database table. They are summarised from _R for Data Science_ here as:

* a database table can be larger and is stored on disk while a data frame is stored in memory so their size is more limited.
* a database table usually indices while data frames do not.
* many , but not all, data base tables are "row-oriented" while tidy data frames are "column-oriented."

Databases are run through Database Management Systems. The _R for Data Science_ textbook divides Database Management Systems into 3 types:

* __client-server__ like PostgreSQL and SQL Server
* __Cloud-based__ like Amazon's Redshift
* __In-process__ like SQLite

We won't really discuss these any further, but an advanced course in database systems through the CS department would give more information about Database Management Systems (and databases in general).

How to connect to a database from `R` depends on the type of database management system. There is an `R` package for most major Database Management Systems. For our purposes, because how to connect to a Database management system depends so heavily on the type, we will focus on a database management system that is contained in the `R` package `duckdb`.

We also need a database interface to connect to the database tables in `duckdb` in the `DBI` package.

__Note__: This section on connecting to a database management systems may be confusing, particularly if you do not have a computer science background. But don't let that derail your learning for this rest of this chapter, which will consist of primarily of `R` code from here on! The take-home message is that we need a way to connect to the system within `R`. It's challenging to give specific directions because the connection depends on the type of system, so we are avoiding most of that by connecting to a database management system in the `duckdb` `R` package using functions from the `DBI` package.

https://r4ds.hadley.nz/databases.html
SQL is short from Structured Query Language.
We first load in the `duckdb` and `DBI` libraries and make a connection to the database management system, which we will name `con`:


```r
library(DBI)
library(duckdb)
con <- DBI::dbConnect(duckdb::duckdb())
```

We can type in `con` to see what it stores:


```r
con
#> <duckdb_connection 9cd00 driver=<duckdb_driver 09a40 dbdir=':memory:' read_only=FALSE>>
```

We've created a brand-new database, so we can next add some data tables with the `duckdb_read_csv()` function. Compared to `read_csv()` from the `readr` package, `duckdb_read_csv()` has a couple of extra arguments: a `conn` argument giving the database management connection and a `name` argument giving the name that we want to give to the data table:


```r
library(here)
#> here() starts at /Users/highamm/Desktop/datascience234
duckdb_read_csv(conn = con, name = "tennis2018", 
                files = here("data/atp_matches_2018.csv"))
duckdb_read_csv(conn = con, name = "tennis2019", 
                files = here("data/atp_matches_2019.csv"))
```

The `doListTables()` function lists the names of the data tables in the database we just created:


```r
dbListTables(con)
#> [1] "tennis2018" "tennis2019"
```

And, `dbExistsTable()` can be used to examine whether or not a data table exists in the current database:


```r
dbExistsTable(con, "tennis2019")
#> [1] TRUE
dbExistsTable(con, "tennis2020")
#> [1] FALSE
```

Note that, in many practical situations, the data tables will already exist in the database you are working with, so the step of `duckdb_read_csv()` would not be necessary.

To use raw SQL code and query the database that we just created, we can create a string of SQL code, name it `sql`, and pass it to the `dbGetQuery()` function. We also load in the `tidyverse` package here to use the `as_tibble()` function to convert the `data.frame` to a `tibble`.


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

sql <- "
  SELECT surface, winner_name, loser_name, w_ace, l_ace, minutes
  FROM tennis2019 
  WHERE minutes > 240
"
dbGetQuery(con, sql)|>
  as_tibble()
#> # A tibble: 30 × 6
#>    surface winner_name           loser…¹ w_ace l_ace minutes
#>    <chr>   <chr>                 <chr>   <int> <int>   <int>
#>  1 Hard    Joao Sousa            Guido …    19    18     241
#>  2 Hard    Jeremy Chardy         Ugo Hu…    29    20     244
#>  3 Hard    Roberto Bautista Agut Andy M…     7    19     249
#>  4 Hard    Joao Sousa            Philip…    28    20     258
#>  5 Hard    Alex Bolt             Gilles…    11    14     244
#>  6 Hard    Milos Raonic          Stan W…    39    28     241
#>  7 Hard    Marin Cilic           Fernan…     8    27     258
#>  8 Hard    Kei Nishikori         Pablo …    15     5     305
#>  9 Hard    Frances Tiafoe        David …     3    11     244
#> 10 Clay    Alexander Zverev      John M…    17     0     248
#> # … with 20 more rows, and abbreviated variable name
#> #   ¹​loser_name
#> # ℹ Use `print(n = ...)` to see more rows
```

### Exercises {#exercise-16-1}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-16).

1. \* Though we do not know SQL code, we can probably figure out what the code above is doing. Which matches are being returned from our query?

2. What is the `dplyr` equivalent function to `WHERE` in the SQL code above? What is the `dplyr` equivalent function to `SELECT` in the SQL code above?

## `dbplyr`: A Database Version of `dplyr`

`dbplyr` is a package that will allow us to continue to write `dplyr`-style code to query databases instead of writing native `SQL`, as in the code-chunk above. 

We begin by loading in the package and creating a database table object with the `tbl()` function. In this case, we create a database table with the `tennis2019` data and name it `tennis_db`:


```r
library(dbplyr)
#> 
#> Attaching package: 'dbplyr'
#> The following objects are masked from 'package:dplyr':
#> 
#>     ident, sql
tennis_db <- tbl(con, "tennis2019")
tennis_db
#> # Source:   table<tennis2019> [?? x 49]
#> # Database: DuckDB 0.3.5-dev1410 [root@Darwin 21.6.0:R 4.2.1/:memory:]
#>    tourney…¹ tourn…² surface draw_…³ tourn…⁴ tourn…⁵ match…⁶
#>    <chr>     <chr>   <chr>     <int> <chr>     <int>   <int>
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
#> # … with more rows, 42 more variables: winner_id <int>,
#> #   winner_seed <chr>, winner_entry <chr>,
#> #   winner_name <chr>, winner_hand <chr>, winner_ht <int>,
#> #   winner_ioc <chr>, winner_age <dbl>, loser_id <int>,
#> #   loser_seed <chr>, loser_entry <chr>, loser_name <chr>,
#> #   loser_hand <chr>, loser_ht <int>, loser_ioc <chr>,
#> #   loser_age <dbl>, score <chr>, best_of <int>, …
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

Examine the print for `tennis_db`, which should look similar to the print for a `tibble` or `data.frame`. Let's use some `dplyr` code to obtain only the matches that lasted longer than `240` minutes and keep only a few of the columns. We will name the result `tennis_query1`:


```r
tennis_query1 <- tennis_db |> 
  filter(minutes > 240) |> 
  select(minutes, winner_name, loser_name, minutes, tourney_name)
tennis_query1
#> # Source:   SQL [?? x 4]
#> # Database: DuckDB 0.3.5-dev1410 [root@Darwin 21.6.0:R 4.2.1/:memory:]
#>    minutes winner_name           loser_name          tourn…¹
#>      <int> <chr>                 <chr>               <chr>  
#>  1     241 Joao Sousa            Guido Pella         Austra…
#>  2     244 Jeremy Chardy         Ugo Humbert         Austra…
#>  3     249 Roberto Bautista Agut Andy Murray         Austra…
#>  4     258 Joao Sousa            Philipp Kohlschrei… Austra…
#>  5     244 Alex Bolt             Gilles Simon        Austra…
#>  6     241 Milos Raonic          Stan Wawrinka       Austra…
#>  7     258 Marin Cilic           Fernando Verdasco   Austra…
#>  8     305 Kei Nishikori         Pablo Carreno Busta Austra…
#>  9     244 Frances Tiafoe        David Goffin        Miami …
#> 10     248 Alexander Zverev      John Millman        Roland…
#> # … with more rows, and abbreviated variable name
#> #   ¹​tourney_name
#> # ℹ Use `print(n = ...)` to see more rows
```

We should note that the result is still a database object: it's not our "usual" `tibble`. One major difference between the database object and the usual `tibble` is that our `tennis_query1` does not tell us how many rows are in the data (see the `??` and the specification `with more rows`). The code that we wrote is not actually looking in the entire data set for matches that are longer than 240 minutes: it is saving time by only performing our query on part of the database table. This is very useful behaviour for database tables that are very, very large, where code might take a long time to run. 

If we want to obtain the result of our query as a `tibble`, we can use the `collect()` function:


```r
tennis_query1 |>
  collect()
#> # A tibble: 30 × 4
#>    minutes winner_name           loser_name          tourn…¹
#>      <int> <chr>                 <chr>               <chr>  
#>  1     241 Joao Sousa            Guido Pella         Austra…
#>  2     244 Jeremy Chardy         Ugo Humbert         Austra…
#>  3     249 Roberto Bautista Agut Andy Murray         Austra…
#>  4     258 Joao Sousa            Philipp Kohlschrei… Austra…
#>  5     244 Alex Bolt             Gilles Simon        Austra…
#>  6     241 Milos Raonic          Stan Wawrinka       Austra…
#>  7     258 Marin Cilic           Fernando Verdasco   Austra…
#>  8     305 Kei Nishikori         Pablo Carreno Busta Austra…
#>  9     244 Frances Tiafoe        David Goffin        Miami …
#> 10     248 Alexander Zverev      John Millman        Roland…
#> # … with 20 more rows, and abbreviated variable name
#> #   ¹​tourney_name
#> # ℹ Use `print(n = ...)` to see more rows
```

The result is a `tibble` that we can now use any `R` functions on (not just functions from `dplyr` and a few other packages).

The `show_query()` function can be used on our `tennis_query1` to give the SQL code that was executed:


```r
tennis_query1 |>
  show_query()
#> <SQL>
#> SELECT "minutes", "winner_name", "loser_name", "tourney_name"
#> FROM "tennis2019"
#> WHERE ("minutes" > 240.0)
```

To get a better idea about what `SQL` code looks like, let's make one more query with `dplyr` code and use the `show_query()` function to give the native `SQL`:


```r
medvedev_query <- tennis_db |>
  pivot_longer(c(winner_name, loser_name), names_to = "win_loss",
               values_to = "player") |>
  filter(player == "Daniil Medvedev") |>
  group_by(win_loss) |>
  summarise(win_loss_count = n())
medvedev_query
#> # Source:   SQL [2 x 2]
#> # Database: DuckDB 0.3.5-dev1410 [root@Darwin 21.6.0:R 4.2.1/:memory:]
#>   win_loss    win_loss_count
#>   <chr>                <dbl>
#> 1 winner_name             59
#> 2 loser_name              21
show_query(medvedev_query)
#> <SQL>
#> SELECT "win_loss", COUNT(*) AS "win_loss_count"
#> FROM (
#>   (
#>     SELECT
#>       "tourney_id",
#>       "tourney_name",
#>       "surface",
#>       "draw_size",
#>       "tourney_level",
#>       "tourney_date",
#>       "match_num",
#>       "winner_id",
#>       "winner_seed",
#>       "winner_entry",
#>       "winner_hand",
#>       "winner_ht",
#>       "winner_ioc",
#>       "winner_age",
#>       "loser_id",
#>       "loser_seed",
#>       "loser_entry",
#>       "loser_hand",
#>       "loser_ht",
#>       "loser_ioc",
#>       "loser_age",
#>       "score",
#>       "best_of",
#>       "round",
#>       "minutes",
#>       "w_ace",
#>       "w_df",
#>       "w_svpt",
#>       "w_1stIn",
#>       "w_1stWon",
#>       "w_2ndWon",
#>       "w_SvGms",
#>       "w_bpSaved",
#>       "w_bpFaced",
#>       "l_ace",
#>       "l_df",
#>       "l_svpt",
#>       "l_1stIn",
#>       "l_1stWon",
#>       "l_2ndWon",
#>       "l_SvGms",
#>       "l_bpSaved",
#>       "l_bpFaced",
#>       "winner_rank",
#>       "winner_rank_points",
#>       "loser_rank",
#>       "loser_rank_points",
#>       'winner_name' AS "win_loss",
#>       "winner_name" AS "player"
#>     FROM "tennis2019"
#>   )
#>   UNION ALL
#>   (
#>     SELECT
#>       "tourney_id",
#>       "tourney_name",
#>       "surface",
#>       "draw_size",
#>       "tourney_level",
#>       "tourney_date",
#>       "match_num",
#>       "winner_id",
#>       "winner_seed",
#>       "winner_entry",
#>       "winner_hand",
#>       "winner_ht",
#>       "winner_ioc",
#>       "winner_age",
#>       "loser_id",
#>       "loser_seed",
#>       "loser_entry",
#>       "loser_hand",
#>       "loser_ht",
#>       "loser_ioc",
#>       "loser_age",
#>       "score",
#>       "best_of",
#>       "round",
#>       "minutes",
#>       "w_ace",
#>       "w_df",
#>       "w_svpt",
#>       "w_1stIn",
#>       "w_1stWon",
#>       "w_2ndWon",
#>       "w_SvGms",
#>       "w_bpSaved",
#>       "w_bpFaced",
#>       "l_ace",
#>       "l_df",
#>       "l_svpt",
#>       "l_1stIn",
#>       "l_1stWon",
#>       "l_2ndWon",
#>       "l_SvGms",
#>       "l_bpSaved",
#>       "l_bpFaced",
#>       "winner_rank",
#>       "winner_rank_points",
#>       "loser_rank",
#>       "loser_rank_points",
#>       'loser_name' AS "win_loss",
#>       "loser_name" AS "player"
#>     FROM "tennis2019"
#>   )
#> ) "q01"
#> WHERE ("player" = 'Daniil Medvedev')
#> GROUP BY "win_loss"
```

The `show_query()` shows the native `SQL` code for a pivot: yikes! Remember that `SQL` was __not__ designed for data analysis, so it doesn't always look pretty. We'll do one more simpler query:


```r
over20aces <- tennis_db |> filter(w_ace > 20) |>
  select(w_ace, winner_name) |>
  group_by(winner_name) |>
  summarise(nmatch = n()) |>
  arrange(desc(nmatch))
over20aces
#> # Source:     SQL [?? x 2]
#> # Database:   DuckDB 0.3.5-dev1410 [root@Darwin 21.6.0:R 4.2.1/:memory:]
#> # Ordered by: desc(nmatch)
#>    winner_name        nmatch
#>    <chr>               <dbl>
#>  1 John Isner             15
#>  2 Reilly Opelka          14
#>  3 Milos Raonic           10
#>  4 Sam Querrey             9
#>  5 Nick Kyrgios            8
#>  6 Alexander Bublik        7
#>  7 Ivo Karlovic            6
#>  8 Jan Lennard Struff      4
#>  9 Jo-Wilfried Tsonga      4
#> 10 Alexander Zverev        4
#> # … with more rows
#> # ℹ Use `print(n = ...)` to see more rows

over20aces |> show_query()
#> <SQL>
#> SELECT "winner_name", COUNT(*) AS "nmatch"
#> FROM (
#>   SELECT "w_ace", "winner_name"
#>   FROM "tennis2019"
#>   WHERE ("w_ace" > 20.0)
#> ) "q01"
#> GROUP BY "winner_name"
#> ORDER BY "nmatch" DESC
```

Can you match some of the `SQL` code with the corresponding `dplyr` functions used?

### Exercises {#exercise-16-2}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-16).

1. \* Obtain the distribution of the `surface` variable by making a table of the total number of matches played on each surface in the 2019 season using `dplyr` functions on `tennis_db`. Then, use `show_query()` to show the corresponding `SQL` code.

2. Create a new variable that is the difference in the `winner_rank_points` and `loser_rank_points` using a `dplyr` function. Then, have your query return only the column you just created, the `winner_name` column, and the `loser_name` column. Use the `show_query()` function to show the corresponding `SQL` code.

3. Perform a query of your choosing on `tennis_db` and use the `show_query()` function to show the corresponding `SQL` code.

## SQL

The purpose of this section is to explore `SQL` syntax a little more, focusing on its connections to `dplyr`. Knowing `dplyr` is quite helpful in learning this `SQL` syntax because, while the syntax differs, the concepts are quite similar. Much of the text in this section is paraphrased from the _R for Data Science textbook_.

There are five core components of an `SQL` query. The two most basic are a `SELECT` statement (similar to `select()`, and, as discussed below, `mutate()` and `summarise()`) and a `FROM` statement (similar to the `data` argument). Using the `show_query()` function directly on `tennis_db` shows an `SQL` query that `SELECT`s all columns (denoted by the `*`), `FROM` the `tennis2019` database.


```r
tennis_db |> show_query()
#> <SQL>
#> SELECT *
#> FROM "tennis2019"
```

The `WHERE` and `ORDER BY` statements control which rows are returned (similar to `filter()`) and in what order those rows get returned (similar to `arrange()`):


```r
tennis_db |> filter(winner_hand == "L") |>
  arrange(desc(tourney_date)) |>
  show_query()
#> <SQL>
#> SELECT *
#> FROM "tennis2019"
#> WHERE ("winner_hand" = 'L')
#> ORDER BY "tourney_date" DESC
```

Finally, `GROUP BY` is used for aggregation (similar to the `dplyr` `group_by()` and `summarise()` combination).


```r
tennis_db |>
  group_by(winner_name) |>
  summarise(meanace = mean(w_ace, na.rm = TRUE)) |>
  show_query()
#> <SQL>
#> SELECT "winner_name", AVG("w_ace") AS "meanace"
#> FROM "tennis2019"
#> GROUP BY "winner_name"
```

In the above code chunk, remove the `na.rm = TRUE` argument and run the query. What do you learn?

The `SQL` syntax __must__ always follow the order `SELECT, FROM, WHERE, GROUP BY, ORDER BY`, even though the operations can be performed in a different order than what is specified. This is one aspect that makes `SQL` harder to pick up than something like `dplyr`, where we specify what we want done in the order that we want.

Below we give a little more detail about the 5 operations.

__`SELECT`__: `SELECT` covers a lot of `dplyr` functions. In the code below, we explore how it is used in `SQL` to choose which columns get returned, rename columns, and create new variables:

* `SELECT` to choose which columns to return:


```r
tennis_db |> select(1:4) |> show_query()
#> <SQL>
#> SELECT "tourney_id", "tourney_name", "surface", "draw_size"
#> FROM "tennis2019"
```

* `SELECT` to rename columns:


```r
tennis_db |> rename(tournament = tourney_name) |>
  show_query()
#> <SQL>
#> SELECT
#>   "tourney_id",
#>   "tourney_name" AS "tournament",
#>   "surface",
#>   "draw_size",
#>   "tourney_level",
#>   "tourney_date",
#>   "match_num",
#>   "winner_id",
#>   "winner_seed",
#>   "winner_entry",
#>   "winner_name",
#>   "winner_hand",
#>   "winner_ht",
#>   "winner_ioc",
#>   "winner_age",
#>   "loser_id",
#>   "loser_seed",
#>   "loser_entry",
#>   "loser_name",
#>   "loser_hand",
#>   "loser_ht",
#>   "loser_ioc",
#>   "loser_age",
#>   "score",
#>   "best_of",
#>   "round",
#>   "minutes",
#>   "w_ace",
#>   "w_df",
#>   "w_svpt",
#>   "w_1stIn",
#>   "w_1stWon",
#>   "w_2ndWon",
#>   "w_SvGms",
#>   "w_bpSaved",
#>   "w_bpFaced",
#>   "l_ace",
#>   "l_df",
#>   "l_svpt",
#>   "l_1stIn",
#>   "l_1stWon",
#>   "l_2ndWon",
#>   "l_SvGms",
#>   "l_bpSaved",
#>   "l_bpFaced",
#>   "winner_rank",
#>   "winner_rank_points",
#>   "loser_rank",
#>   "loser_rank_points"
#> FROM "tennis2019"
```

* `SELECT` to create a new variable


```r
tennis_db |> mutate(prop_first_won = w_1stIn / w_1stWon) |>
  select(prop_first_won, winner_name) |>
  show_query()
#> <SQL>
#> SELECT "w_1stIn" / "w_1stWon" AS "prop_first_won", "winner_name"
#> FROM "tennis2019"
```

* `SELECT` to create a new variable that is a summary:


```r
tennis_db |> summarise(mean_length = mean(minutes)) |>
  show_query()
#> <SQL>
#> SELECT AVG("minutes") AS "mean_length"
#> FROM "tennis2019"
```

<br>

__`GROUP BY`__: `GROUP BY` covers aggregation in a similar way as `dplyr`'s `group_by()` function:


```r
tennis_db |> group_by(winner_name) |>
  summarise(meanlength = mean(minutes)) |>
  show_query()
#> <SQL>
#> SELECT "winner_name", AVG("minutes") AS "meanlength"
#> FROM "tennis2019"
#> GROUP BY "winner_name"
```

__`WHERE`__: `WHERE` is used for `filter()`, though `SQL` uses different Boolean operators than `R` (for example, `&` becomes `AND`, `|` becomes `or`).


```r
tennis_db |> filter(winner_age > 35 | loser_age > 35) |>
  show_query()
#> <SQL>
#> SELECT *
#> FROM "tennis2019"
#> WHERE ("winner_age" > 35.0 OR "loser_age" > 35.0)
```

__`ORDER BY`__: `ORDER BY` is used for `arrange()`. This one is quite straightforward:


```r
tennis_db |> arrange(desc(winner_rank_points)) |>
  show_query()
#> <SQL>
#> SELECT *
#> FROM "tennis2019"
#> ORDER BY "winner_rank_points" DESC
```

`SQL` also has corresponding syntax for the `xxxx_join()` family of functions, but we do not have time to discuss this in detail. Note that we have really just scratched the surface of `SQL`. There are entire courses devoted to learning `SQL` syntax and more about databases in general. If you ever do find yourself in a situation where you need to learn `SQL`, either for a course or for a job, you should have a major head-start with your `dplyr` knowledge!

### Exercises {#exercise-16-3}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-16).

In much of this section, we have created code with `dplyr` and seen how that code translates to `SQL`. In these exercises, you will intead be given `SQL` code and asked to write `dplyr` code that achieves the same thing.

1. \* Examine the `SQL` code below and write equivalent `dplyr` code.


```r
SELECT * 
FROM "tennis2019"
WHERE ("tourney_name" = 'Wimbledon')
```

2. Examine the `SQL` code below and write equivalent `dplyr` code.


```r
SELECT "winner_name", "loser_name", "w_ace", "l_ace", "w_ace" - "l_ace" AS "ace_diff"
FROM "tennis2019"
ORDER BY "ace_diff" DESC
```

3. Examine the `SQL` code below and write equivalent `dplyr` code.


```r
SELECT "tourney_name", AVG("minutes") AS "mean_min"
FROM "tennis2019"
GROUP BY "tourney_name"
```

## Chapter Exercises {#chapexercise-16}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-16).

1. Run the following code:


```r
tennis_db |> slice(1000:1005) |>
  show_query()
```

Make a hypothesis about why a function like `slice()` is not compatible with `dbplyr`.

2. \* Try to run a function from `lubridate` or `forcats` on `tennis_db` with `mutate()`. Does the function work? Did you expect it to work?

3. Run the following code and write how the `!` is translated to `SQL`.


```r
tennis_db |> filter(winner_name != "Daniil Medvedev") |>
  show_query()
#> <SQL>
#> SELECT *
#> FROM "tennis2019"
#> WHERE ("winner_name" != 'Daniil Medvedev')
```

4. Run the following code and write how the `%in%` symbol is translated to `SQL`.


```r
tennis_db |>
  filter(winner_name %in% c("Daniil Medvedev", "Dominic Thiem")) |>
  show_query()
#> <SQL>
#> SELECT *
#> FROM "tennis2019"
#> WHERE ("winner_name" IN ('Daniil Medvedev', 'Dominic Thiem'))
```

## Exercise Solutions {#solutions-16}

### What is a Database S

1. \* Though we do not know SQL code, we can probably figure out what the code above is doing. Which matches are being returned from our query?

The code is keeping any matches that are longer than 240 minutes. It is also getting rid of all of the columns except for those specified in `SELECT`.

### `dbplyr`: A Database Version of `dplyr` S

1. \* Obtain the distribution of the `surface` variable by making a table of the total number of matches played on each surface in the 2019 season using `dplyr` functions on `tennis_db`. Then, use `show_query()` to show the corresponding `SQL` code.


```r
tennis_db |> group_by(surface) |> summarise(nmatch = n())
#> # Source:   SQL [3 x 2]
#> # Database: DuckDB 0.3.5-dev1410 [root@Darwin 21.6.0:R 4.2.1/:memory:]
#>   surface nmatch
#>   <chr>    <dbl>
#> 1 Hard      1626
#> 2 Clay       828
#> 3 Grass      327

tennis_db |> group_by(surface) |> summarise(nmatch = n()) |>
  show_query()
#> <SQL>
#> SELECT "surface", COUNT(*) AS "nmatch"
#> FROM "tennis2019"
#> GROUP BY "surface"
```

### SQL S

1. \* Examine the `SQL` code below and write equivalent `dplyr` code.


```r
SELECT * 
FROM "tennis2019"
WHERE ("tourney_name" = 'Wimbledon')
```


```r
tennis_db |>
  filter(tourney_name == "Wimbledon")
#> # Source:   SQL [?? x 49]
#> # Database: DuckDB 0.3.5-dev1410 [root@Darwin 21.6.0:R 4.2.1/:memory:]
#>    tourney…¹ tourn…² surface draw_…³ tourn…⁴ tourn…⁵ match…⁶
#>    <chr>     <chr>   <chr>     <int> <chr>     <int>   <int>
#>  1 2019-540  Wimble… Grass       128 G        2.02e7     100
#>  2 2019-540  Wimble… Grass       128 G        2.02e7     101
#>  3 2019-540  Wimble… Grass       128 G        2.02e7     102
#>  4 2019-540  Wimble… Grass       128 G        2.02e7     103
#>  5 2019-540  Wimble… Grass       128 G        2.02e7     104
#>  6 2019-540  Wimble… Grass       128 G        2.02e7     105
#>  7 2019-540  Wimble… Grass       128 G        2.02e7     106
#>  8 2019-540  Wimble… Grass       128 G        2.02e7     107
#>  9 2019-540  Wimble… Grass       128 G        2.02e7     108
#> 10 2019-540  Wimble… Grass       128 G        2.02e7     109
#> # … with more rows, 42 more variables: winner_id <int>,
#> #   winner_seed <chr>, winner_entry <chr>,
#> #   winner_name <chr>, winner_hand <chr>, winner_ht <int>,
#> #   winner_ioc <chr>, winner_age <dbl>, loser_id <int>,
#> #   loser_seed <chr>, loser_entry <chr>, loser_name <chr>,
#> #   loser_hand <chr>, loser_ht <int>, loser_ioc <chr>,
#> #   loser_age <dbl>, score <chr>, best_of <int>, …
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names

## check query:
tennis_db |>
  filter(tourney_name == "Wimbledon") |>
  show_query()
#> <SQL>
#> SELECT *
#> FROM "tennis2019"
#> WHERE ("tourney_name" = 'Wimbledon')
```

### Chapter Exercises S {#chapexercise-16-S}

2. \* Try to run a function from `lubridate` or `forcats` on `tennis_db` with `mutate()`. Does the function work? Did you expect it to work?


```r
tennis_db |> mutate(tourney_name_reorder = fct_reorder(tourney_name, 
                                                       draw_size))
```

The result is an error. Only functions compatible with the `dbplyr` package can be used on a database table. Functions specific to `R`, like those in `lubridate` and `forcats` cannot work until we `collect()` the database table into a data frame or tibble:


```r
tennis_db |> collect() |>
  mutate(tourney_name_reorder = fct_reorder(tourney_name, 
                                                       draw_size))
#> # A tibble: 2,781 × 50
#>    tourney…¹ tourn…² surface draw_…³ tourn…⁴ tourn…⁵ match…⁶
#>    <chr>     <chr>   <chr>     <int> <chr>     <int>   <int>
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
#> # … with 2,771 more rows, 43 more variables:
#> #   winner_id <int>, winner_seed <chr>, winner_entry <chr>,
#> #   winner_name <chr>, winner_hand <chr>, winner_ht <int>,
#> #   winner_ioc <chr>, winner_age <dbl>, loser_id <int>,
#> #   loser_seed <chr>, loser_entry <chr>, loser_name <chr>,
#> #   loser_hand <chr>, loser_ht <int>, loser_ioc <chr>,
#> #   loser_age <dbl>, score <chr>, best_of <int>, …
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

## Non-Exercise `R` Code {#rcode-16}


```r
library(DBI)
library(duckdb)
con <- DBI::dbConnect(duckdb::duckdb())
con
library(here)
duckdb_read_csv(conn = con, name = "tennis2018", 
                files = here("data/atp_matches_2018.csv"))
duckdb_read_csv(conn = con, name = "tennis2019", 
                files = here("data/atp_matches_2019.csv"))
dbListTables(con)
dbExistsTable(con, "tennis2019")
dbExistsTable(con, "tennis2020")
library(tidyverse)

sql <- "
  SELECT surface, winner_name, loser_name, w_ace, l_ace, minutes
  FROM tennis2019 
  WHERE minutes > 240
"
dbGetQuery(con, sql)|>
  as_tibble()
library(dbplyr)
tennis_db <- tbl(con, "tennis2019")
tennis_db
tennis_query1 <- tennis_db |> 
  filter(minutes > 240) |> 
  select(minutes, winner_name, loser_name, minutes, tourney_name)
tennis_query1
tennis_query1 |>
  collect()
tennis_query1 |>
  show_query()
medvedev_query <- tennis_db |>
  pivot_longer(c(winner_name, loser_name), names_to = "win_loss",
               values_to = "player") |>
  filter(player == "Daniil Medvedev") |>
  group_by(win_loss) |>
  summarise(win_loss_count = n())
medvedev_query
show_query(medvedev_query)
over20aces <- tennis_db |> filter(w_ace > 20) |>
  select(w_ace, winner_name) |>
  group_by(winner_name) |>
  summarise(nmatch = n()) |>
  arrange(desc(nmatch))
over20aces

over20aces |> show_query()
tennis_db |> show_query()
tennis_db |> filter(winner_hand == "L") |>
  arrange(desc(tourney_date)) |>
  show_query()
tennis_db |>
  group_by(winner_name) |>
  summarise(meanace = mean(w_ace, na.rm = TRUE)) |>
  show_query()
tennis_db |> select(1:4) |> show_query()
tennis_db |> rename(tournament = tourney_name) |>
  show_query()
tennis_db |> mutate(prop_first_won = w_1stIn / w_1stWon) |>
  select(prop_first_won, winner_name) |>
  show_query()
tennis_db |> summarise(mean_length = mean(minutes)) |>
  show_query()
tennis_db |> group_by(winner_name) |>
  summarise(meanlength = mean(minutes)) |>
  show_query()
tennis_db |> filter(winner_age > 35 | loser_age > 35) |>
  show_query()
tennis_db |> arrange(desc(winner_rank_points)) |>
  show_query()
```
