# Scores Of Nominal Outlyingness (SONO)
This repository includes the implementation of the SONO framework for computing scores of nominal outlyingness for nominal data sets.

`data`: This directory includes 2 sub-directories with the raw and processed data used for simulation purposes. The `raw` subdirectory includes the original `.csv` files from the UCI Machine Learning Repository. The `processed` sub-directory includes the same data sets upon removing any non-nominal variables and removing missing data in `.rds` format for easier handling in `R`.

`output`: This directory includes the results of running `run_sono.R` with `dataset` being one of `breastcancer`, `flare`, `lymphography` or `thyroid` data sets.

`src`: The function `helper_funs.R` includes three manually written functions that are used in `run_sono.R`. The `sono.R` file is the main function for computing scores of nominal outlyingness, variable contribution matrix and the nominal outlyingness depth. This is calling the `sono_infreq.R` function when setting argument `frequent = FALSE`, defining outlyingness in terms of infrequent itemsets. For the alternative definition of outliers as too frequent itemsets, the function `sono_freq.R` is called instead. The `eval_funs.R` function includes implementations of evaluation metrics such as the Recall@K, average outlier rank and the ROC AUC for ranks.

`dependencies`: A list of the `R` packages used in `sono_infreq.R` and `sono_results_plots.R`.

`run_sono.R`: Script used to run the simulations.

`SONO_SimStudyScript.R`: Script used for simulation study in which SONO is compared to two alternative frequent pattern mining algorithms from the `fpmoutliers` R package [(GitHub page for package)](https://github.com/jaroslav-kuchar/fpmoutliers). See the paper by Costa E. and Papatsouma I. for more details. [(link to paper)](https://arxiv.org/abs/2408.07463)

`res_df_SONO_full.RDS`: Results file for the simulation study implemented in `SONO_SimStudyScript.R`.
