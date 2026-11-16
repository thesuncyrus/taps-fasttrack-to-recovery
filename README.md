# FastTrack to Recovery: AI-Powered Survivor Journey Mapping

Purdue University · September–November 2024 · Faculty mentor: Matthew A. Lanham
Partner: Tragedy Assistance Program for Survivors (TAPS)
Team: Christian Leidholm, Raina Kunder, Alec Walter and Chau Nguyen (Cyrus Nguyen in the poster).

The project studies how structured survey responses and English/Spanish open responses can support classification into six grief-journey stages. The research compares structured predictive modeling, text mining and variable selection. Outputs support human review; this is a research prototype, not a clinical assessment tool.

## What to review

| Stage | Runnable implementation | Reviewable output |
| --- | --- | --- |
| Input validation | `pipeline.R:read_surveys` | Unique IDs, six valid labels, question ranges |
| Descriptive analysis | `eda.R` | Training class distribution, missingness, question profiles, token counts |
| Preprocessing | `fit_encoder`, `transform_encoder` | Fold-specific imputation, encoding, vocabulary, TF-IDF and scaling |
| Experiment design | `split_surveys`, `make_folds` | Disjoint 80/20 holdout and stratified training folds |
| Model comparison | `run.R`, `run_experiment` | Nine pipelines; CV accuracy, macro-F1, balanced accuracy and log loss |
| Final evaluation | `multiclass_metrics` | Held-out metrics, per-stage precision/recall/F1 and confusion matrices |
| Inference | `predict.R` | Saved-model predictions keyed by original ID |
| Visualization | `plot.R`, `poster_results.R` | Computed holdout plot and separate historical poster figure |

Structured models include Random Forest, a classification tree, elastic-net multinomial regression, Naive Bayes, k-nearest neighbors and a neural network. Text-only models use Random Forest and elastic-net multinomial regression; a combined model joins structured and text predictors. The historical and reconstructed evaluations are distinguished in [RESULTS_PROVENANCE.md](RESULTS_PROVENANCE.md).

## Quick start

Use R 4.5.3, or create the supplied Conda environment. From the repository root:

```sh
Rscript setup.R
Rscript tests.R
Rscript eda.R /path/to/examples.csv outputs y
Rscript run.R /path/to/examples.csv outputs y
Rscript plot.R outputs
Rscript predict.R outputs/evaluation-model.rds /path/to/test.csv outputs/submission.csv
```

Replace `y` with the actual target column name. The prediction export uses `Id,Prediction`; check the competition's exact submission header before submitting. Nothing is uploaded automatically. See [DATA_SETUP.md](DATA_SETUP.md).

The test suite runs every model on explicitly synthetic fixtures, checks vocabulary isolation, invalid inputs, splits, serialization and single-row inference. Its scores are not research results.

## Evaluation choices

All preprocessing is learned inside each training fold. Model selection uses mean training-CV macro-F1 before examining the outer holdout. The selected saved model is fit on outer-training rows only. IDs and stage labels never enter the features. Text is tokenized locally with Unicode letters and an explicit short English/Spanish stop-word list. There is no automatic external translation or claim of semantic equivalence across languages. Question identity is retained in token names.

A random survey holdout does not establish generalization to future cohorts or repeated responses from the same survivor. If repeated-survivor identifiers are available, grouped splitting is required before making that claim.

## Project evidence and source context

The poster reports a best structured-model Kaggle score of **0.889**. Selected text-mining scores are **0.812** and **0.815**. The approximately **67%** review-time reduction is a process estimate based on assumptions. These numbers are not produced by the new training command.

- [Original poster](documents/taps-poster.pdf)
- [Original course-based Data4Good source](original_code/Data4Good.R)
- [Lab 1 source used in the project](original_code/lab1_ans_key.R)
- [Workflow and source provenance](docs/WORKFLOW.md)
- [Portfolio case study](https://chau-nguyen-research.gabledmango1.chatgpt.site/taps.html)

The retained source establishes the survey/text workflow and includes course scaffolding. Lab 1 also contains a separate window-manufacturing exercise; it is retained with its original attribution, not represented as TAPS modeling. The runnable pipeline is a documented reconstruction prepared with AI assistance from these materials; it is not a recovered record of every original experiment. Team-wide results are credited to the team. No raw survey records or data redistribution license are included.

## Validation

See [executed checks and limits](docs/VALIDATION.md) and [result provenance](RESULTS_PROVENANCE.md).
