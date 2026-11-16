# Validation

Verified on 2026-11-16 with R 4.5.3.

`Rscript tests.R` passed input range/key checks, stratified split isolation, per-fold class coverage, held-out vocabulary exclusion, missing/unseen-category transformation, known multiclass metrics, all nine reconstructed classifiers, model serialization and one-row inference. It also exercised the EDA, chart and prediction-export command-line scripts and checked output IDs.

All integration inputs were explicitly synthetic. Synthetic scores were deleted with temporary outputs and are not application evidence. Historical Kaggle scores require the actual labelled survey files and experiment configuration to reproduce. All active R files parse successfully.
