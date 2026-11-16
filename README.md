# FastTrack to Recovery: analysis source and project results

Purdue University, Fall 2024. Team: Christian Leidholm, Raina Kunder,
Alec Walter and Chau Nguyen (Cyrus Nguyen in the original poster).
Faculty mentor: Matthew A. Lanham. Partner: TAPS.

## Files

- Data4Good.R: retained project analysis script used for TAPS, including survey
  preparation, descriptive summaries, exploratory plots, text processing,
  regularized classification, and prediction export.
- poster_results.R: visualization code for the six model scores
  reported in Figure 6 of the original team poster.
- results/poster-model-comparison.csv: the same six reported Kaggle scores.
- figures/taps-comparison.svg: the portfolio's comparison chart.

## Analysis in Data4Good.R

1. Data preparation: read survey files; inspect structure; arrange the target;
   trim q21/q22 text; convert blank responses to NA; assign factor types.
2. Descriptive analytics: frequency tables for stage labels, attendance reasons
   (q1), and referral sources (q2).
3. Exploratory visualization: attendance counts and proportional bar charts
   relating q1 and q2 to the six stage labels.
4. Text processing: language detection, translation calls, word tokenization
   with tidytext::unnest_tokens(), stop-word removal, and frequency counts.
5. Text visualization: horizontal bar charts for common words in q21 and q22.
6. Modeling: correlation and variation checks, range scaling, caret/glmnet
   classification with leave-one-out validation, class/probability predictions,
   a confusion matrix, and Kaggle submission export.

Input filenames referenced by the script are examples.csv and test.xlsx;
the source comments describe converting Kaggle's test.csv to test.xlsx.

## Source context

Data4Good.R is the supplied course-based analysis file used in the TAPS project.
Its original course comments and analytical code are retained. The portfolio
copy replaces only the machine-specific setwd() line with a comment so input
paths are relative to the working directory. R syntax was checked when adding
this file to the portfolio. The modeling section is presented as retained
analysis source; displayed model-comparison scores are attributed to the poster.

The project poster documents the team's comparison of structured prediction,
text mining, and variable selection, together with an assumption-based process
map. Its highest reported Kaggle score is 0.889 for random forest Model 7.
The reported 67% review-time saving is a projected process benefit.

## Render the poster comparison

Install R and ggplot2, then run from this directory:

    Rscript poster_results.R outputs

This writes the score table and comparison chart from the poster values.


## Portfolio

[Project overview and visualizations](https://chau-nguyen-research.gabledmango1.chatgpt.site/taps.html) · [Chau Nguyen on LinkedIn](https://www.linkedin.com/in/chaunguyen2811)

## Supporting materials

- [Taps Poster](documents/taps-poster.pdf)
