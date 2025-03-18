# Function for Recall@K
coverage_fun <- function(grid, scores, outs){
  coverage <- c()
  for (i in grid){
    top_k_outs_num <- round(i*length(scores))
    top_k_outs <- order(scores, decreasing = TRUE)[1:top_k_outs_num]
    coverage <- c(coverage, sum(top_k_outs %in% outs)/length(outs))
  }
  return(coverage)
}

# Average rank of outliers function
avg_rank_fun <- function(scores, outs){
  ranks <- rank(-scores, ties.method = "min")
  outs_ranks <- ranks[outs]
  return(mean(outs_ranks))
}

# Sequential ROC AUC function
sequential_roc_auc <- function(scores, outlier_indices, grid){
  labels <- numeric(length(scores))
  labels[outlier_indices] <- 1
  
  ordered_indices <- order(scores, decreasing = TRUE)
  scores_ordered <- scores[ordered_indices]
  labels_ordered <- labels[ordered_indices]
  
  n <- length(scores)
  aucs <- c()
  
  for (k in grid){  
    # Use only top k scores
    subset_scores <- scores_ordered[1:ceiling(k*length(scores))]
    subset_labels <- labels_ordered[1:ceiling(k*length(scores))]
    # Compute AUC for the subset
    aucs <- c(aucs, compute_roc_auc(subset_scores, subset_labels))
  }
  return(aucs)
}

# Helper function for ROC AUC
compute_roc_auc <- function(scores, labels){
  outlier_indices <- which(labels == 1)
  inlier_indices <- which(labels == 0)
  num_outliers <- length(outlier_indices)
  num_inliers <- length(inlier_indices)
  
  total_score <- 0
  if (length(outlier_indices)==0){
    return(0)
  } else if (length(inlier_indices)==0){
    return(1)
  } else {
    for (o in outlier_indices) {
      for (i in inlier_indices) {
        if (scores[o] > scores[i]) {
          total_score <- total_score + 1
        } else if (scores[o] == scores[i]) {
          total_score <- total_score + 0.5
        }
      }
    }
  }
  roc_auc <- total_score / (num_outliers * num_inliers)
  return(roc_auc)
}
