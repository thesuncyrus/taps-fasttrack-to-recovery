# FastTrack to Recovery — Survivor Survey Classification

Purdue University, September–November 2024. Partner: Tragedy Assistance Program for Survivors (TAPS). Team: Christian Leidholm, Raina Kunder, Alec Walter and Chau Nguyen; faculty mentor Matthew A. Lanham.

## Research question
How can survey responses support classification into six grief-journey stages, and can fewer inputs preserve classification quality? The project compares structured prediction, text exploration and backward variable selection to support staff review.

## Methods
The structured classifier uses q4–q20, zero-variance filtering, Yeo–Johnson and range preprocessing, and caret leave-one-out cross-validation with Accuracy selection. The method argument selects glmnet or Random Forest. The project poster identifies Random Forest with range and Yeo–Johnson preprocessing as the leading model. Text analysis separately covers language detection, optional translation, tokenization, stop-word removal and word frequencies.

## Results
The project poster reports a best Random Forest Kaggle score of **0.889**, followed by 0.888. Selected text-mining variants score 0.812/0.815; variable-selection variants score 0.821/0.799. These are poster-reported competition scores, distinct from the script's training confusion matrix.

![Model comparison](results/figures/comparison.svg)

## Run
```sh
Rscript setup.R
Rscript src/grief_stage_classification.R data/examples.csv data/test.xlsx glmnet outputs
Rscript src/grief_stage_classification.R data/examples.csv data/test.xlsx rf outputs-rf
Rscript src/survey_text_exploration.R data/examples.csv
Rscript tests.R
```
Run commands from the repository root. Survey records are not included. Input requirements are in data/README.md. Translation requires an explicit opt-in flag because it sends text to an external translation service. The tests use synthetic survey items to check constant predictors and stage-label conversion.

`kaggle-predictions.csv` exports the original stage labels 1–6 and preserves test-record IDs. `label-map.csv` records their correspondence to the internal model labels X1–X6.

Preprocessing is fitted within each cross-validation training fold. For competition predictions, caret applies the final model's training transformations to the test records. The training confusion matrix is resubstitution, not held-out performance. The project demonstrates classification and workflow possibilities; it does not establish a measured operational improvement or clinical outcome.

[Portfolio case study](https://chau-nguyen-research.gabledmango1.chatgpt.site/taps.html)
