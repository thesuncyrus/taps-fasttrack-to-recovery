# Result provenance

| Claim/output | Source | Status |
| --- | --- | --- |
| Structured Random Forest 0.889 | Original poster, Model 7 | Historical reported Kaggle score |
| Text scores 0.812 and 0.815 | Original poster | Historical reported scores; not the 0.889 structured result |
| About 67% less review time | Poster process map | Assumption-based estimate, not measured deployment impact |
| `results/poster-model-comparison.csv` | Poster transcription | Used only by `poster_results.R` |
| `outputs/test-metrics.csv` | `run.R` on user-provided inputs | Computed holdout metrics for the reconstructed experiment |
| `tests.R` metrics | Artificial fixtures | Software checks only; never application evidence |

The 100,000+ figure in the poster describes survivors supported by TAPS; it does not establish the number of labelled training responses. The repository makes no 100,000-response dataset claim and no TAPS Tableau-dashboard claim.

The retained scripts and poster do not specify enough information to reproduce every historical model. The current model families, fixed settings, split seed and evaluation definitions are explicit in code. No score is hard-coded into a training or evaluation path. Historical poster tables are kept separate from computed outputs.
