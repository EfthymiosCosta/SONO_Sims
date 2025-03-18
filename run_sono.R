source("src/sono.R")
source("src/helper_funs.R")

# Read processed data
# dataset_name can be any of: breastcancer, flare, lymphography, thyroid
# Using "breastcancer" as an example
dataset_name <- "breastcancer"
dataset_path <- paste0("data/processed/", dataset_name, "_processed.rds")
dataset <- readRDS(dataset_path)
dataset <- as.data.frame(dataset)
# Convert columns to factors
for (i in 1:ncol(dataset)){
  dataset[, i] <- as.factor(dataset[, i])
}

# Create probability vectors
prob_vecs <- list()
for (i in 1:ncol(dataset)){
  lvls <- length(unique(dataset[, i]))
  prob_vecs[[i]] <- rep(1/lvls, lvls)
}

# Setting MAXLEN = 0 yields automated MAXLEN selection
# Set MAXLEN to a positive integer to force its value
sono_out <- sono(data = dataset, 
                 probs = prob_vecs,
                 alpha = 0.05,
                 r = 1, 
                 MAXLEN = 0,
                 frequent = FALSE)

saveRDS(sono_out, file = paste0('output/', dataset_name, '_sono.rds'))
