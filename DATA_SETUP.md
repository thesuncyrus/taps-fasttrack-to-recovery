# Data setup

Use an authorized copy of the Purdue Data4Good 2024 survey files. No survivor records are distributed here. Put local files under ignored `data/` or pass absolute paths.

Training CSV: unique, complete `Id`; fields `q1`–`q22`; and one explicitly named target column containing labels `1`–`6`. Inference CSV needs the same inputs without the target. Run `Rscript run.R data/examples.csv outputs TARGET_COLUMN` if the target is not named `y`.

| Fields | Representation |
| --- | --- |
| q1, q2 | Nominal answers; missing/unseen values handled explicitly |
| q3–q6 | Integers 0–2 or missing |
| q7–q8 | Integers 0–4 or missing |
| q9–q20 | Integers 0–3 or missing |
| q21, q22 | UTF-8 English/Spanish text; blanks treated as missing |
| target | One of 1, 2, 3, 4, 5, 6; no missing labels |

At least five examples per stage are needed for the default split and three-fold validation. Missing ordinal answers use training medians; text vocabulary and IDF use training rows only. Do not infer the target by column position.

The current reconstruction was integration-tested on synthetic fixtures because labelled project survey data was not supplied in the available package. Obtaining the original labelled examples and exact competition split is necessary to verify historical scores. Keep generated token counts, fitted vocabularies/models, predictions and fold IDs local; they can contain sensitive information.
