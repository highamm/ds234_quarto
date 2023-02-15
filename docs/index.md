---
title: "STAT 234: Data Science"
author: "Matt Higham"
date: "2022-09-14"
site: bookdown::bookdown_site
documentclass: book
bibliography: [book.bib, packages.bib]
url: https://highamm.github.io/datascience234/
# cover-image: path to the social sharing image like images/cover.jpg
description: "This book contains examples for SLU's Introduction to Data Science course."
biblio-style: apalike
csl: chicago-fullnote-bibliography.csl
---

# Syllabus and Course Information

## General Information

**Instructor Information**

-   Professor: Matt Higham
-   Office: Bewkes 123
-   Email: [mhigham\@stlawu.edu](mailto:mhigham@stlawu.edu){.email}
-   Semester: Fall 2022
-   Sections:
    -   MW 2:30 - 4:00
-   Office Hours: 15 minute slots bookable at <a href="https://calendly.com/mhigham/prof-higham-office-hours" target="_blank">my calendly page</a>.
    -   Note that you must book a time for office hours at least 12 hours in advance to guarantee that I am present and available at that time.

**Course Materials**

-   <a href="https://highamm.github.io/datascience234/" target="_blank">STAT 234 Materials Bundle</a>. This will be our primary source of materials.
-   Textbooks (only used as references):
    -   Modern Data Science with `R` by Baumer, Kaplan, and Horton, found <a href="https://mdsr-book.github.io/mdsr2e/" target="_blank">here</a> in a free online version.
    -   R for Data Science by Grolemund and Wickham, found <a href="https://r4ds.had.co.nz/" target="_blank">here</a> in a free online version.
-   Computer with Internet access.

------------------------------------------------------------------------

------------------------------------------------------------------------

## Course Information

Welcome to STAT 234! The overall purpose of this course is learn the data science skills necessary to complete large-scale data analysis projects. The tool that we will be using to achieve this goal is the statistical software language `R`. We will work with a wide variety of interesting data sets throughout the semester to build our `R` skills. In particular, we will focus on the Data Analysis Life Cycle (Grolemund and Wickham 2020):

![](data-science.png)

We will put more emphasis on the *Import, Tidy, Transform, Visualize, and Communicate* parts of the cycle, as an introduction to *Modeling* part is covered in STAT 213.

### Use of `R` and `RStudio`

We will use the statistical software `R` to construct graphs and analyze data. A few notes:

-   `R` and `RStudio` are both free to use.
-   We will primarily be using the SLU `R Studio` server at first: <a href="rstudio.stlawu.local:8787" target="_blank">rstudio.stlawu.local:8787</a>.
-   Additionally, we will be using `RMarkdown` for data analysis reports. *Note*: It's always nice to start assignments and projects as early as possible, but this is particularly important to do for assignments and projects involving `R`. It's no fun to try and figure out why code is not working at the last minute. If you start early enough though, you will have plenty of time to seek help and therefore won't waste a lot of time on a coding error.

------------------------------------------------------------------------

------------------------------------------------------------------------

## General Course Outcomes

1.  *Import* data of a few different types into `R` for analysis.

2.  *Tidy* data into a form that can be more easily visualized, summarised, and modeled.

3.  *Transform*, *Wrangle*, and *Visualize* variables in a data set to assess patterns in the data.

4.  *Communicate* the results of your analysis to a target audience with a written report, or, possibly an oral presentation.

5.  Practice reproducible statistical practices through the use of `Quarto` for data analysis projects.

6.  Explain why it is ethically important to consider the context that a data set comes in.

7.  Develop the necessary skills to be able to ask and answer future data analysis questions on your own, either using `R` or another program, such as Python.

To paraphrase the *R for Data Science* textbook, about 80% of the skills necessary to do a complete data analysis project can be learned through coursework in classes like this one. But, 20% of any particular project will involve learning new things that are specific to that project. Achieving Goal \# 6 will allow you to learn this extra 20% on your own.

------------------------------------------------------------------------

------------------------------------------------------------------------

## How You Will Be Assessed

The components to your grade are described below:

-   Modules

Each week, you will submit a 60-point Module, consisting of the following:

-   an **Exercise Set** (10 points): Due Mondays and usually from our <a href="https://highamm.github.io/datascience234/" target="_blank">STAT 234 Materials Bundle</a>. Exercises are graded for completion only and solutions are typically provided after you submit to Canvas. Collaboration is allowed.
-   a **Take-Home Quiz** (20 points): Due Wednesdays. Take-Home quizzes are graded for correctness. Collaboration is allowed.
-   an **In-Class Quiz** (30 points): Given on Wednesdays at the start of class. In-Class quizzes are graded for correctness. Collaboration is not allowed. Some questions on the in-class quiz will be based on exercises we complete in class, the exercise sets you complete, and the take-home quiz questions.

There are 13 modules in total. In three modules, you will complete a 50-point Project instead of the two quizzes. The Project which will have some tasks for you to complete for a particular data set. The lowest module will be dropped from your grade so the total number of points available is `12 * 60 = 720` points.

Additionally, for one module, you are permitted to take the in-class quiz as a take-home and turn it in the following Monday.

Finally, if you choose to take the (optional) in-person final exam (described below), the score that you earn on that final will replace your second and third-lowest module scores.

-   Class

Class participation will be assessed three times throughout the semester in a 20 point rubric for a total of 60 points. The rubric used will be shared on the first day of class.

-   Final Project

There is one final project, worth 100 points. The primary purpose of the final project is to give you an opportunity to assemble topics throughout the course into one coherent data analysis. You will be able to choose the data set you use for your final project, so you might begin thinking about a particular topic or data set you are interested in exploring. The final project will be presented in a format to be decided later in the semester.

-   Final Exam

There is an optional Final Exam, worth 120 points total, consisting of 20 points of Exercises (graded for completeness), 40 points for a take-home portion, and 60 points for the in-class portion. You **must** be on campus for our final exam time to take the final exam.

There are two options for the final exam:

-   Option 1: Skip the final exam (skip all components: exercises, take-home, and in-class) and assign the average percentage of your 12 highest modules to be your percentage score for the 120 point final. For example, suppose your 13 module scores are: `60, 60, 59, 58, 57, 53, 53, 53, 53, 45, 43, 30, 0`. Then, you would drop your lowest score (the `0`) and your score for the final would be: `(60 + 60 + 59 + 58 + 57 + 53 + 53 + 53 + 53 + 45 + 43 + 30 + 30) / 720 * 120` = `109 / 120` points.

-   Option 2: Take the final exam, which consists of 20 points of Exercises, a 30 point Take-Home portion, and a 50 point In-Class portion. Your score on these items will be used for the 100 points devoted to the final exam. Additionally, if your final exam score is better than your 2nd and 3rd lowest module grades, the will be replaced with your final exam score. For example, suppose your 13 module scores are: `60, 60, 59, 58, 57, 53, 53, 53, 53, 45, 43, 30, 0`. You take the final exam and score a `110 / 120`. Then, your score for the final is `110 / 120` points and your new module scores would be: `60, 60, 59, 58, 57, 53, 53, 53, 53, 45, 55, 55, 0`. The `0` would still be dropped as your lowest module score.

### Breakdown

-   720 points for Modules
-   60 points for Class Participation
-   100 points for the Final Project
-   120 points for the (optional) in-person Final Exam

Points add up to 1000 so your grade at the end of the semester will be the number of points you've earned across all categories divided by 1000.

### Grading Scale

The following is a *rough* grading scale. I reserve the right to make any changes to the scale if necessary.

| Grade  | 4.0      | 3.75    | 3.5     | 3.25    | 3.0     | 2.75    | 2.5     | 2.25    | 2.0     | 1.75    | 1.5     | 1.25    | 1.0     | 0.0   |
|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Points | 950-1000 | 920-949 | 890-919 | 860-889 | 830-859 | 810-829 | 770-809 | 750-769 | 720-749 | 700-719 | 670-699 | 640-669 | 600-639 | 0-599 |

------------------------------------------------------------------------

------------------------------------------------------------------------

## Collaboration, Diversity, Accessibility, and Academic Integrity

### Rules for Collaboration

Collaboration with your classmates on exercises, take-home quizzes, and projects is encouraged, but you must follow these guidelines:

-   you must state the name(s) of who you collaborated with at the top of each assessment.
-   all work must be your own. This means that you should **never** send someone your code via email or let someone directly type code off of your screen. Instead, you can talk about strategies for solving problems and help or ask someone about a coding error.
-   you may use the Internet and StackExchange, but you also should not copy paste code directly from the website, without citing that you did so.
-   this isn't a rule, but keep in mind that collaboration is not permitted on quizzes, exams, and very limited collaboration will be permitted on the final project. Therefore, when working with someone, make sure that you are both really learning so that you both can have success on the non-collaborative assessments.

------------------------------------------------------------------------

------------------------------------------------------------------------

### Diversity Statement

Diversity encompasses differences in age, colour, ethnicity, national origin, gender, physical or mental ability, religion, socioeconomic background, veteran status, sexual orientation, and marginalized groups. The interaction of different human characteristics brings about a positive learning environment. Diversity is both respected and valued in this classroom.

------------------------------------------------------------------------

------------------------------------------------------------------------

### Accessibility Statement

If you have a specific learning profile, medical and or mental health condition and need accommodations, please be sure to contact the Student Accessibility Services Office right away so they can help you get the accommodations you require. If you need to use any accommodations in this class, please meet with your instructor early and provide them with your Individualized Educational Accommodation Plan (IEAP) letter so you can have the best possible experience this semester.

Although not required, your instructor would like to know of any accommodations that are needed at least 10 days before a quiz or test. Please be proactive and set up an appointment to meet with someone from the Student Accessibility Services Office.

**Color-Vision Deficiency:** If you are Color-Vision Deficient, the Student Accessibility Services office has on loan glasses for students who are color vision deficient. Please contact the office to make an appointment.

For more specific information about setting up an appointment with Student Accessibility Services please see the listed options below:

-   Telephone: 315.229.5537
-   Email: [studentaccessibility\@stlawu.edu](mailto:studentaccessibility@stlawu.edu){.email}

For further information about Student Accessibility Services you can check the website at: <https://www.stlawu.edu/student-accessibility-services>

------------------------------------------------------------------------

------------------------------------------------------------------------

### Academic Dishonesty

Academic dishonesty will not be tolerated. Any specific policies for this course are supplementary to the

Honor Code. According to the St. Lawrence University Academic Honor Policy,

1.  It is assumed that all work is done by the student unless the instructor/mentor/employer gives specific permission for collaboration.
2.  Cheating on examinations and tests consists of knowingly giving or using or attempting to use unauthorized assistance during examinations or tests.
3.  Dishonesty in work outside of examinations and tests consists of handing in or presenting as original work which is not original, where originality is required.

*Claims of ignorance and academic or personal pressure are unacceptable as excuses for academic dishonesty.* Students must learn what constitutes one's own work and how the work of others must be acknowledged.

For more information, refer to [www.stlawu.edu/acadaffairs/**academic**\_**honor**\_policy.pdf](../../C:%5CUsers%5Ciramler%5CAppData%5CLocal%5CTemp%5Cwww.stlawu.edu%5Cacadaffairs%5Cacademic_honor_policy.pdf).

To avoid academic dishonesty, it is important that you follow all directions and collaboration rules and ask for clarification if you have any questions about what is acceptable for a particular assignment or exam. If I suspect academic dishonesty, a score of zero will be given for the entire assignment in which the academic dishonesty occurred **for all individuals involved** and Academic Honor Council will be notified. If a pattern of academic dishonesty is found to have occurred, a grade of 0.0 for the entire course can be given.

It is important to work in a way that maximizes your learning. Be aware that students who rely too much on others for the homework and projects tend to do poorly on the quizzes and exams.

*Please note that in addition the above, any assignments in which your score is reduced due to academic dishonesty will not be dropped according to the quiz policy e.g., if you receive a zero on a quiz because of academic dishonesty, it will not be dropped from your grade.*

------------------------------------------------------------------------

------------------------------------------------------------------------

## Tentative Schedule

| Week | Date    | Topics                                                      |
|--------------|--------------|-------------------------------------------------|
| 0    | 8/24    | Introduction to `R`, `R Studio`                             |
| 1    | 8/29    | Graphics with `ggplot2`                                     |
| 2    | 9/5     | Data Wrangling and Transformation with `dplyr`              |
| 3    | 9/12    | Communication with `Quarto` and `ggplot2`                   |
| 4    | 9/19    | Soft Skills and Workflow                                    |
| 5    | 9/26\*  | Data Tidying with `tidyr`                                   |
| 6    | 10/3    | Base `R`                                                    |
|      |         |                                                             |
| 7    | 10/10   | Factors with `forcats` and Data Ethics                      |
| 8    | 10/17\* | Data Import with `readr`, `jsonlite`, `rvest`, and `tibble` |
| 9    | 10/24   | Data Merging with `dplyr`                                   |
| 10   | 10/31\* | Dates and Times with `lubridate`                            |
| 11   | 11/7    | Text Data with `tidytext` and `stringr`                     |
| 12   | 11/14   | Intro to Statistical/Machine Learning with knn              |
|      |         |                                                             |
| 13   | 11/21   | Thanksgiving Break                                          |
| 14   | 11/28   | Connections to STAT and CS                                  |
| 14   | 12/5    | Databases and SQL with `dbplyr`                             |

-   The three projects are tentatively scheduled to be due on September 28, October 19, and November 2, though these are subject to change.
