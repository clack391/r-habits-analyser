# Overview

I am working to become a software engineer who can pick up a new language and
become useful in it quickly, rather than one who only knows two or three. R is
the language I decided to learn. I had seen a little R before in an IBM Data
Science course on Coursera, but I had never written a full program in it. R is
worth learning because it was built around data from the very beginning. Tables,
statistics and charts are part of the language itself instead of extra libraries
added on later, so the normal way to write R looks different from how I would
write the same thing in Python or Java.

The software I wrote is a command line program called **Study Habits Analyzer**.
It reads a CSV file that holds a log of my study sessions. Every row has a date,
a subject, how many hours I studied, a focus rating from 1 to 5, and where I
studied. The program cleans the data and throws away rows with missing or
impossible values, works out statistics for each subject, and prints a report to
the screen showing whether each subject is ON TRACK, ALMOST THERE, or BEHIND. It
then saves a summary as a new CSV file and draws a bar chart of total hours per
subject.

My purpose in writing it was to learn R's syntax on a real problem instead of a
toy example, and to see the parts of R that are genuinely different from the
languages I already know. The clearest one is that R works on a whole column at
once. A line like `sessions$hours <- as.numeric(sessions$hours)` converts every
value in that column without any loop at all, which took me a while to get used
to. I also learned R's `<-` assignment arrow, that a list lets a function return
more than one value at a time, that a factor is R's type for a category, that R
counts from 1 instead of 0, and how ggplot2 builds a chart by adding layers with
the `+` sign.

[Software Demo Video](https://youtu.be/MqGQ7sqFIwk?si=K20EpvdhxJbgM3oB)

# Development Environment

I developed this on macOS using Visual Studio Code with the R extension, which
gives syntax highlighting and lets me send single lines to a live R session to
try them out. I installed R itself with Homebrew and ran the finished program
from the terminal with `Rscript`. I used Git for version control and GitHub to
publish the repository.

The program is written in **R 4.6.1**. It uses one package from CRAN:

* **ggplot2** — draws the bar chart and saves it as a PNG with `ggsave()`

Everything else is built into R and needs nothing installed: `read.csv()`,
`write.csv()`, `sum()`, `mean()`, `max()`, `round()`, `data.frame()`, `sprintf()`
and `cat()`.

### How to run it

```bash
# only needed once, if ggplot2 is not installed yet
Rscript -e 'install.packages("ggplot2", repos = "https://cloud.r-project.org")'

# run the program from the project folder
Rscript study_habits_analyzer.R
```

Running the program creates an `output/` folder holding `subject_summary.csv`
and `hours_by_subject.png`.

The data file has four bad rows in it on purpose: one with a blank hours value,
one with negative hours, one with a missing focus rating, and one with a focus
rating of 9 when the scale only goes up to 5. I put them there so the cleaning
part of the program had something real to catch. When it runs it reports that it
kept 71 of the 75 rows and says how many it dropped, instead of quietly ignoring
them or crashing.

# Useful Websites

* [An Introduction to R (official CRAN manual)](https://cran.r-project.org/doc/manuals/r-release/R-intro.html)
* [R for Data Science, 2nd Edition](https://r4ds.hadley.nz/)
* [W3Schools R Tutorial](https://www.w3schools.com/r/)
* [Quick-R: Data Types and Data Frames](https://www.statmethods.net/)
* [ggplot2 Reference](https://ggplot2.tidyverse.org/reference/)
* [RDocumentation search](https://www.rdocumentation.org/)
