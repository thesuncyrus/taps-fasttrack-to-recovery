# Workflow and source map

1. Frame the six-stage classification task from the project poster and course survey schema.
2. Review nominal/ordinal questions, missing text, bilingual tokens and stage imbalance.
3. Compare structured predictors, text-only predictors and their combination.
4. Learn imputation, vocabulary, IDF, scaling and feature screening inside training folds.
5. Freeze selection using cross-validation, score the held-out rows and inspect per-stage errors.
6. Save the selected training-only model and generate ID-keyed predictions for review.
7. Compare computed results with the separately attributed poster and process estimate.

`original_code/` contains the supplied course-based files and SHA-256 checksums. `Data4Good.R` at the root is the earlier portfolio copy with the personal `setwd` removed; use `run.R` for execution. Course comments and mentor/team attribution remain intact. The new pipeline repairs positional target selection, preprocessing leakage risks, inconsistent prediction schema and hard-coded machine paths. It intentionally uses explicit stratified validation instead of silently claiming the original Kaggle leaderboard experiment was recovered.

This organization shows the analytical stages supported by the sources. It does not invent weekly milestones, dated commits or individual ownership of team code.
