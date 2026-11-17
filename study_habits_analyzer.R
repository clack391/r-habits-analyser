# ==================================
#  Study Habits Analyzer
#  CSE 310 - Module 1: Language R
#  Author: Praise Enato
#
#  Reads a CSV log of my study sessions, cleans it, works out
#  statistics for each subject, prints a report, saves a summary
#  CSV, and draws a bar chart.
#
#  Run it with:  Rscript study_habits_analyzer.R
# ===================================

library(ggplot2)

# Settings. R works out the type from the value, so there is no
# "int x = 5" like in Java. The L makes a whole number an integer.
DATA_FILE    <- "data/study_sessions.csv"      # character
SUMMARY_FILE <- "output/subject_summary.csv"   # character
CHART_FILE   <- "output/hours_by_subject.png"  # character
TARGET_HOURS <- 40.0                           # numeric
GOOD_FOCUS   <- 4L                             # integer
LINE_WIDTH   <- 60


# Prints a title between two lines of "=" so the report is readable.
print_header <- function(title) {
  cat("\n")
  cat(strrep("=", LINE_WIDTH), "\n", sep = "")
  cat("  ", title, "\n", sep = "")
  cat(strrep("=", LINE_WIDTH), "\n", sep = "")
}


# Reads the CSV into a data frame. Returns NULL if the file is missing.
load_data <- function(path) {
  if (!file.exists(path)) {
    cat("ERROR: could not find the file:", path, "\n")
    return(NULL)
  }
  sessions <- read.csv(path, stringsAsFactors = FALSE)
  cat("Loaded", nrow(sessions), "rows from", path, "\n")
  return(sessions)
}


# Tidies the text, converts each column to its proper type, and drops
# rows with missing or impossible values. Each line changes a whole
# column at once with no loop, which R calls vectorization.
clean_data <- function(sessions) {
  rows_before <- nrow(sessions)

  sessions$subject  <- toupper(trimws(sessions$subject))
  sessions$location <- as.factor(trimws(sessions$location))

  # Blank values become NA, which is R's word for missing.
  sessions$hours        <- suppressWarnings(as.numeric(sessions$hours))
  sessions$focus_rating <- suppressWarnings(as.integer(sessions$focus_rating))
  sessions$date         <- as.Date(sessions$date)

  # One TRUE or FALSE per row. The & means AND.
  good_rows <- !is.na(sessions$hours) & sessions$hours > 0 &
               !is.na(sessions$focus_rating) &
               sessions$focus_rating >= 1 & sessions$focus_rating <= 5

  clean <- sessions[good_rows, ]
  cat("Kept", nrow(clean), "of", rows_before, "rows,",
      rows_before - nrow(clean), "dropped as bad\n")
  return(clean)
}


# Shows one example of each R data type the program uses.
show_data_types <- function(sessions) {
  print_header("THE R DATA TYPES I USED")
  cat(sprintf("  1. character : %-12s (subject name)\n",  sessions$subject[1]))
  cat(sprintf("  2. numeric   : %-12s (hours studied)\n", sessions$hours[1]))
  cat(sprintf("  3. integer   : %-12s (focus rating)\n",  sessions$focus_rating[1]))
  cat(sprintf("  4. logical   : %-12s (was focus good?)\n",
              sessions$focus_rating[1] >= GOOD_FOCUS))
  cat(sprintf("  5. factor    : %-12s (a location)\n",
              as.character(sessions$location[1])))
  cat(sprintf("  6. Date      : %-12s (session date)\n", format(sessions$date[1])))
}


# Compares a subject's hours to the target using if / else if / else.
get_status <- function(hours) {
  if (hours >= TARGET_HOURS) {
    return("ON TRACK")
  } else if (hours >= TARGET_HOURS * 0.75) {
    return("ALMOST THERE")
  } else {
    return("BEHIND")
  }
}


# Works out the numbers for one subject and returns them in a list,
# which is how a function returns more than one value in R.
subject_stats <- function(sessions, subject_name) {
  rows  <- sessions[sessions$subject == subject_name, ]
  total <- sum(rows$hours)
  return(list(subject = subject_name,
              count   = nrow(rows),
              total   = round(total, 2),
              average = round(mean(rows$hours), 2),
              longest = max(rows$hours),
              focus   = round(mean(rows$focus_rating), 2),
              status  = get_status(total)))
}


# Prints the report block for one subject, lined up with sprintf.
print_subject <- function(stats) {
  cat(strrep("-", LINE_WIDTH), "\n", sep = "")
  cat(sprintf("  %-14s %s\n", stats$subject, stats$status))
  cat(strrep("-", LINE_WIDTH), "\n", sep = "")
  cat(sprintf("    Sessions       : %d\n", stats$count))
  cat(sprintf("    Total hours    : %.2f  (target is %.0f)\n",
              stats$total, TARGET_HOURS))
  cat(sprintf("    Average length : %.2f hours\n", stats$average))
  cat(sprintf("    Longest session: %.2f hours\n", stats$longest))
  cat(sprintf("    Average focus  : %.2f out of 5\n\n", stats$focus))
}


# Loops through the array of subjects, prints each report, and
# collects the results into a data frame sorted by total hours.
make_summary <- function(sessions) {
  subjects   <- unique(sessions$subject)
  all_names  <- character(0)
  all_counts <- numeric(0)
  all_totals <- numeric(0)
  all_focus  <- numeric(0)
  all_status <- character(0)

  for (subject in subjects) {
    stats <- subject_stats(sessions, subject)
    print_subject(stats)
    all_names  <- c(all_names,  stats$subject)
    all_counts <- c(all_counts, stats$count)
    all_totals <- c(all_totals, stats$total)
    all_focus  <- c(all_focus,  stats$focus)
    all_status <- c(all_status, stats$status)
  }

  summary <- data.frame(subject = all_names, sessions = all_counts,
                        total_hours = all_totals, avg_focus = all_focus,
                        status = all_status, stringsAsFactors = FALSE)
  summary <- summary[order(-summary$total_hours), ]
  rownames(summary) <- NULL
  return(summary)
}


# Prints the grand totals, then loops over the locations to draw a
# simple bar of # characters for each one.
print_totals <- function(sessions, summary) {
  print_header("OVERALL TOTALS")
  cat(sprintf("  Subjects tracked   : %d\n", nrow(summary)))
  cat(sprintf("  Sessions logged    : %d\n", nrow(sessions)))
  cat(sprintf("  Total hours studied: %.2f\n", sum(sessions$hours)))
  cat(sprintf("  Most studied       : %s\n", summary$subject[1]))
  cat(sprintf("  Needs most work    : %s\n", summary$subject[nrow(summary)]))

  cat("\n  Where I studied:\n")
  for (place in levels(sessions$location)) {
    count <- sum(sessions$location == place)
    cat(sprintf("    %-9s %2d  %s\n", place, count, strrep("#", count)))
  }
}


# Saves the summary as a CSV and the bar chart as a PNG. ggplot2
# builds a chart by adding layers together with the + sign.
save_results <- function(summary) {
  dir.create("output", showWarnings = FALSE)
  write.csv(summary, SUMMARY_FILE, row.names = FALSE)

  chart <- ggplot(summary, aes(x = subject, y = total_hours, fill = status)) +
    geom_col() +
    labs(title = "Total study hours by subject",
         x = "Subject", y = "Total hours")
  ggsave(CHART_FILE, chart, width = 7, height = 4)

  cat("\n  Saved summary to:", SUMMARY_FILE, "\n")
  cat("  Saved chart to  :", CHART_FILE, "\n")
}


# Runs the whole program in order.
main <- function() {
  print_header("STUDY HABITS ANALYZER")
  cat(sprintf("  Today is %s\n\n", format(Sys.Date(), "%d %B %Y")))

  sessions <- load_data(DATA_FILE)
  if (is.null(sessions)) return(invisible(NULL))

  sessions <- clean_data(sessions)
  if (nrow(sessions) == 0) {
    cat("ERROR: no good rows left to analyse.\n")
    return(invisible(NULL))
  }

  show_data_types(sessions)
  print_header("REPORT FOR EACH SUBJECT")
  summary <- make_summary(sessions)
  print_totals(sessions, summary)

  print_header("SUMMARY TABLE")
  print(summary)
  save_results(summary)
  print_header("FINISHED")
}

main()
