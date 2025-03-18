source('src/sono.R')
source('src/helper_funs.R')
source('src/eval_funs.R')

res_SONO_df <- data.frame('Seed' = numeric(),
                          'numVars' = numeric(),
                          'numObs' = numeric(),
                          'numLvls' = numeric(),
                          'probs' = character(),
                          'Method' = character(),
                          'AvgRuntime' = numeric(),
                          'MAXLEN' = numeric(),
                          'OutsAvgRank' = numeric(),
                          stringsAsFactors = FALSE)

ncols <- c(3, 5, 7)
nrows <- c(200, 500, 1000)
nlvls <- c(2, 3, 5)
p <- 0.1
q <- 0.05
n_reps <- 25
seed_nums <- c(1:100)
count <- 1

for (cols in ncols){
  for (rows in nrows){
    for (lvls in nlvls){
      for (seed in seed_nums){
        set.seed(seed)
        true_prob_vecs <- list(c(p, rep((1-p)/(lvls-1), lvls-1)),
                               c(q, rep((1-q)/(lvls-1), lvls-1)))
        for (i in 3:cols){
          true_prob_vecs[[i]] <- rep(1/lvls, lvls)
        }
        X <- cbind(sample(c(1:lvls), size = rows, prob = true_prob_vecs[[1]], replace = TRUE),
                   sample(c(1:lvls), size = rows, prob = true_prob_vecs[[2]], replace = TRUE))
        for (i in 1:(cols-2)){
          X <- cbind(X, sample(c(1:lvls), size = rows, prob = true_prob_vecs[[i+2]], replace = TRUE))
        }
        
        res_SONO_df[(count):(count+4), 1] <- seed
        res_SONO_df[(count):(count+4), 2] <- cols
        res_SONO_df[(count):(count+4), 3] <- rows
        res_SONO_df[(count):(count+4), 4] <- lvls
        
        X <- as.data.frame(X)
        for (i in 1:ncol(X)){
          X[, i] <- as.factor(X[, i])
        }
        outs <- which(X[, 1]==1 | X[, 2] == 1)
        # Equal probabilities
        res_SONO_df[(count):(count+2), 5] <- "Equal"
        prob_vecs <- list()
        for (i in 1:ncol(X)){
          prob_vecs[[i]] <- rep(1/lvls, lvls)
        }
        # Repeat Experiment 25 times and record the time
        ### SONO
        times_SONO <- replicate(n_reps,
                                {time <- system.time(
                                  sono_out <- sono(data = X,
                                                   prob_vecs,
                                                   alpha = 0.05,
                                                   r = 1,
                                                   MAXLEN = 0,
                                                   frequent = FALSE)
                                  )})
        sono_out <- sono(data = X,
                         prob_vecs,
                         alpha = 0.05,
                         r = 1,
                         MAXLEN = 0,
                         frequent = FALSE)
        res_SONO_df[count, 6] <- "SONO"
        res_SONO_df[count, 7] <- mean(times_SONO[3,])
        res_SONO_df[count, 8] <- sono_out$MAXLEN
        res_SONO_df[count, 9] <- avg_rank_fun(scores = sono_out$`Discrete Scores`[,2],
                                              outs = outs)
        saveRDS(res_SONO_df, file = 'res_df_SONO_full.RDS')
        ### FPOF
        times_FPOF <- replicate(n_reps,
                                {time <- system.time(
                                  fpof_out <- fpmoutliers::FPOF(data = X,
                                                                minSupport = 1/lvls,
                                                                mlen = sono_out$MAXLEN)
                                )})
        fpof_out <- fpmoutliers::FPOF(data = X,
                                      minSupport = 1/lvls,
                                      mlen = sono_out$MAXLEN,
                                      noCores = 2)
        res_SONO_df[(count+1), 6] <- "FPOF"
        res_SONO_df[(count+1), 7] <- mean(times_FPOF[3,])
        res_SONO_df[(count+1), 8] <- sono_out$MAXLEN
        res_SONO_df[(count+1), 9] <- avg_rank_fun(scores = 1-fpof_out$scores,
                                                     outs = outs)
        saveRDS(res_SONO_df, file = 'res_df_SONO_full.RDS')
        ### FPI
        times_FPI <- replicate(n_reps,
                                {time <- system.time(
                                  fpi_out <- fpmoutliers::FPI(data = X,
                                                              minSupport = 1/lvls,
                                                              mlen = sono_out$MAXLEN)
                                )})
        fpi_out <- fpmoutliers::FPI(data = X,
                                    minSupport = 1/lvls,
                                    mlen = sono_out$MAXLEN)
        res_SONO_df[(count+2), 6] <- "FPI"
        res_SONO_df[(count+2), 7] <- mean(times_FPI[3,])
        res_SONO_df[(count+2), 8] <- sono_out$MAXLEN
        res_SONO_df[(count+2), 9] <- avg_rank_fun(scores = fpi_out$scores,
                                               outs = outs)
        saveRDS(res_SONO_df, file = 'res_df_SONO_full.RDS')
        cat('Prob = Equal for seed', seed, 'complete.\n')
        # Ture probabilities
        res_SONO_df[(count+3), 5] <- "True"
        prob_vecs <- true_prob_vecs
        # Repeat Experiment 25 times and record the time
        ### SONO
        times_SONO <- replicate(n_reps,
                                {time <- system.time(
                                  sono_out <- sono(data = X,
                                                   prob_vecs,
                                                   alpha = 0.05,
                                                   r = 1,
                                                   MAXLEN = 0,
                                                   frequent = FALSE)
                                )})
        sono_out <- sono(data = X,
                         prob_vecs,
                         alpha = 0.05,
                         r = 1,
                         MAXLEN = 0,
                         frequent = FALSE)
        res_SONO_df[(count+3), 6] <- "SONO"
        res_SONO_df[(count+3), 7] <- mean(times_SONO[3,])
        res_SONO_df[(count+3), 8] <- sono_out$MAXLEN
        res_SONO_df[(count+3), 9] <- avg_rank_fun(scores = sono_out$`Discrete Scores`[,2],
                                                     outs = outs)
        saveRDS(res_SONO_df, file = 'res_df_SONO_full.RDS')
        cat('Prob = True for seed', seed, 'complete.\n')
        # Slightly off probabilities
        res_SONO_df[(count+4), 5] <- "Off"
        prob_vecs <- list(c(p/2, rep((1-p/2)/(lvls-1), lvls-1)),
                          c(q/2, rep((1-q/2)/(lvls-1), lvls-1)))
        for (i in 3:cols){
          prob_vecs[[i]] <- rep(1/lvls, lvls)
        }
        # Repeat Experiment 25 times and record the time
        ### SONO
        times_SONO <- replicate(n_reps,
                                {time <- system.time(
                                  sono_out <- sono(data = X,
                                                   prob_vecs,
                                                   alpha = 0.05,
                                                   r = 1,
                                                   MAXLEN = 0,
                                                   frequent = FALSE)
                                )})
        sono_out <- sono(data = X,
                         prob_vecs,
                         alpha = 0.05,
                         r = 1,
                         MAXLEN = 0,
                         frequent = FALSE)
        res_SONO_df[(count+4), 6] <- "SONO"
        res_SONO_df[(count+4), 7] <- mean(times_SONO[3,])
        res_SONO_df[(count+4), 8] <- sono_out$MAXLEN
        res_SONO_df[(count+4), 9] <- avg_rank_fun(scores = sono_out$`Discrete Scores`[,2],
                                                     outs = outs)
        cat('Prob = Off for seed', seed, 'complete.\n')
        saveRDS(res_SONO_df, file = 'res_df_SONO_full.RDS')
	count <- count + 5
        cat('Seed', seed, 'complete.\n')
	cat('Count=',count,'\n')
      }
    }
  }
}
