# Data Ethics

__Goals:__

* explain why data ethics is an important issue in data science using a couple of examples.
* describe a few issues with data privacy and explain why, just because  data doesn't have an individual's name doesn't necessarily make the data truly anonymous.
* explain the difference between _hypothesis confirmation_ and _hypothesis exploration_ and why the distinction matters.

## Ethical Examples

We've tried to interweave issues of ethics throughout many examples used already in this course, but the purpose of this section is to put data ethics in direct focus.

Some questions to consider for any data collected, especially data collected on human subjects:

* who gets to use data and for what purposes? 

* who collected the data and does that organization have any conflicts of interest?

* is presentation of an analysis harmful to a particular person or group of people? Are there benefits of an analysis?

* have the subjects of a data collection procedure been treated respectfully and have they given consent to their information being collected?

    - When is consent needed and when is it not? For example, we have looked at data on professional athletes. Do they need to provide consent or is consent inherent in being in the spotlight?
    
    - We've also scraped data from SLU's athletics website to look at data pertaining to some of you! Is that ethical? Is there a line you wouldn't cross pertaining to data collected on named, individual people?
    
### Exercises {#exercise-9-1}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-9).

1. Read Sections 8.1 - 8.3 in <a href="https://mdsr-book.github.io/mdsr2e/" target="_blank">Modern Data Science with R</a>. Then, write a one paragraph summary of the reading and how it might pertain to the way you use or interpret data.

2. _Data Feminism_ is related to data ethics, though the two terms are certainly not synonymous. Recently, Catherine D’Ignazio and Lauren F. Klein published a book called _Data Feminism_ <a href="https://datafeminism.io/" target="_blank">https://datafeminism.io/ </a>

Read the following blog post on Data Feminism, focusing on the section on Missing Data. <a href="https://teachdatascience.com/datafem/" target="_blank">https://teachdatascience.com/datafem/ </a>.

Pick one example from the bulleted list and write a 2 sentence explanation that explains why it might be important to acknowledge the missing data in an analysis.

3. Choose __1__ of the following two articles to read

* <a href="https://www.theguardian.com/world/2017/sep/08/ai-gay-gaydar-algorithm-facial-recognition-criticism-stanford" target="_blank">https://www.theguardian.com/world/2017/sep/08/ai-gay-gaydar-algorithm-facial-recognition-criticism-stanford </a> on the use of data in the LGBTQIA+ community
* <a href="https://towardsdatascience.com/5-steps-to-take-as-an-antiracist-data-scientist-89712877c214" target="_blank">https://towardsdatascience.com/5-steps-to-take-as-an-antiracist-data-scientist-89712877c214 </a> on anti-racist data practices.

a. For the LGBTQIA+ article, write a two sentence summary for the side of the argument that research in facial recognition software to identify members of the LGBTQ+ community should __not__ occur, even if this viewpoint isn't your own. 

Then, write a two sentence summary for the side of the argument that research in facial recognition software to identify members of the LGBTQ+ community is okay as long as the results are used responsibly, even if this viewpoint isn't your own.

b. For the anti-racist data science article, under Step 2, pick a News Article and read the first few paragraphs. Describe, in 2-3 sentences, what your article's example of bias is and why the incidence of bias matters.

## Data Privacy

Related to data ethics is the idea of _data privacy_. 

* What data is private and what data is public? For some examples, this may seem obvious, but for others (e.g. data on a government agency that collects data on people), the answer might not be as clear cut.
* Is anonymous data truly anonymous?
* What type of consent should be provided before collecting data on someone?

We will explore some of these issues in the following exercises.

### Exercises {#exercise-9-2}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-9).

1. Recall the course evaluations data set, which you used for Mini-Project 2. This might have been obvious, but the course evaluations were my course evaluations from last year, so I felt that it was ethically okay for me to share them. But, data privacy is not always a cut-and-dry issue. Consider the following course evaluation formats, and think about whether or not you would consider it ethically okay for me to share the evaluation information with you:

a. I not only gave you the course averages, but I also give you PDFs of each student's written responses. The PDFs are anonymous, but they do have the student's sex, year, and whether they took the course for a Major, Minor, Distribution Requirement, etc. Assume that you also can obtain the class roster for each class.

b. I not only gave you the course averages and the PDFs in (a), but I also give you the __grade__ each student received in the course on their PDF list of responses (but they are still anonymous and you can still obtain the class roster).

c. Another professor at SLU posts her evaluation averages in a table on a personal website. I scrape the data table and give it to you all, along with the professor's name and courses. I don't ask for permission, but the website that the tables are on is public.

2. Suppose that I collect data on students in __this__ Data Science class. In each setting (a) through (d), suppose that I give you a data set with the following variables collected on each student in the class. Which option, if any, would it be ethically okay for me to share the data with all students in the class. 

a. current grade and time spent on the `R Studio` server

b. current grade, class year, and whether or not the student is a stat major

c. favorite R package, whether or not the student took STAT 213, whether or not the student took CS 140, and Major

d. favorite R package, whether or not the student took STAT 213, whether or not the student took CS 140, and current grade in the course

3. How anonymous are SLU's course evaluations? We will do an in-class activity to investigate this.

## Hypothesis Generation vs. Confirmation 

We have focused on _hypothesis generation_ for all data sets in this particular course. Read the following two articles that explain the difference between _hypothesis generation_ and _hypothesis confirmation_:

Read the following two very short articles, one from our textbook and one from another source:

* <a href="https://r4ds.had.co.nz/model-intro.html#hypothesis-generation-vs.-hypothesis-confirmation" target="_blank">https://r4ds.had.co.nz/model-intro.html#hypothesis-generation-vs.-hypothesis-confirmation</a>
* <a href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6718169/" target="_blank">https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6718169/</a>

### Exercises {#exercise-9-3}

Exercises marked with an \* indicate that the exercise has a solution at the end of the chapter at \@ref(solutions-9).

1. Explain the difference between hypothesis generation and hypothesis confirmation.

2. How many times can you use a single observation for hypothesis generation? for hypothesis confirmation?

3. Which of the following questions, pertaining to someone's fitness, sound more suitable to be answered with Hypothesis Exploration? Which with Hypothesis Confirmation?

a. You want to know if, on average, this person exercises more on weekends or more on weekdays, with no other questions of interest.

b. You want to look at general trends in the person's step count and try to determine if various events influenced the step count.

c. You want to know if the person exercises more in winter or more in summer, and you would also like to investigate other seasonal trends.

__Note__: Prediction is different from hypothesis confirmation, because you typically don't really care which variables are associated with your response. You only want a model that gives the "best" predictions. Because of this, if your goal is prediction, you typically have a lot more freedom with how many times you can "use" a single observation. We will talk a little more about prediction later in the semester.

## Chapter Exercises {#chapexercise-9}

There are no chapter exercises for this chapter.

## Exercise Solutions {#solutions-9}

There are no exercise solutions for this chapter.















