#' Compute similarity matrix from random forest. 
#' 
#' This method is described in this Pew article:
#' https://www.pewresearch.org/methods/2018/01/26/how-different-weighting-methods-work/.
#' @param: sample_df dataframe
#' @param synthetic_population dataframe
#' @param factor_cols vector
#' @param predictor_cols vector
#' @return similarity_matrix (dataframe)
random_forest_similarity <- function(sample_df, synthetic_population, factor_cols, predictor_cols) {
  
  # combine into one dataframe with column for label
  model_df <- combine_sample_synthetic(sample_df, synthetic_population, factor_cols, predictor_cols)
  
  # fit model
  model <- randomForest(label ~ ., data = model_df, proximity = TRUE)
  
  # calculate similarity matrix
  similarity_matrix <- predict(model, model_df, proximity = TRUE)[2]$proximity
  
  return(similarity_matrix)
}

#' Return index of most similar column in distance matrix. 
#' 
#' Does not consider target column, breaks ties at random,
#' and only consider rows that have not been matched to yet.
#' @param ix int
#' @param mat matrix
#' @param relevant_inds vector
#' @param used_inds vector
#' @return original_col (int)
get_most_similar <- function(ix, mat, relevant_inds, used_inds) {
  
  if (length(used_inds) > 0) {
    unused_inds <- setdiff(relevant_inds, used_inds)
    mat_unused <- mat[unused_inds, ix]
  }
  else {
    mat_unused <- mat[relevant_inds, ix]
  }
  
  most_sim <- rank(mat_unused, ties.method = 'random')
  most_sim_ind <- which.max(most_sim)
  original_col <- as.integer(names(most_sim_ind))
  return(original_col)
}

#' Perform matching.
#' 
#' Takes synthetic population dataset and matches 
#' sample cases to observations in that synthetic dataset.
#' @param sample_df dataframe
#' @param synthetic_population dataframe
#' @param similarity_method string
#' @param factor_cols vector
#' @param predictor_cols vector
#' @param quietly boolean
#' @return matched_sample (dataframe)'
#' @export
match_sample <- function(sample_df, synthetic_population, similarity_method='rf',
                         factor_cols=NA, predictor_cols=NA, quietly=FALSE) {
  
  # calculate similarity matrix
  if (similarity_method == 'rf') {
    if (quietly) {
      suppressMessages(require(randomForest))
    }
    else {
      require(randomForest)
    }
    sim_mat <- random_forest_similarity(sample_df, synthetic_population, factor_cols, predictor_cols)
  }
  else {
    stop('Invalid similarity_method.')
  }
  
  # find most similar sample row for each synthetic population row
  # set up
  n_syn <- nrow(synthetic_population)
  n_sample <- nrow(sample_df)
  relevant_inds <- (n_syn+1):(n_syn+n_sample) # corresponds to rows from sample
  matched_inds <- c()
  
  # iterate through synthetic rows and find most similar sample row
  for (i in 1:n_syn) {
    col <- get_most_similar(ix=i, mat=sim_mat, relevant_inds=relevant_inds, used_inds=matched_inds)
    matched_inds <- c(matched_inds, col)
  }
  
  # subset matched rows from sample
  shifted_matched_inds <- matched_inds - n_syn
  matched_sample <- sample_df[shifted_matched_inds,]
  
  return(matched_sample)
}