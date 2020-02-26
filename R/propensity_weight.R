#' Perform propensity weighting.
#' 
#' Computes the inverse propensity that each sample observation
#' was included in the sample as opposed to being from the population.
#' @param sample_df dataframe
#' @param synthetic_population dataframe
#' @param model string ('rf', 'logreg')
#' @param factor_cols vector
#' @param predictor_cols vector
#' @return weighted_sample (dataframe)
#' @export
propensity_weight <- function(sample_df, synthetic_population, model='logreg',
                              factor_cols=NA, predictor_cols=NA) {
  
  # combine into one dataframe with column for label
  model_df <- combine_sample_synthetic(sample_df, synthetic_population, factor_cols, predictor_cols)
  
  # fit model and get predictions
  if (model == 'rf') {
    warning("Method currently unstable. Analyze results with caution. For better results, use 'logreg'.")
    require(randomForest)
    model <- randomForest(label ~ ., data = model_df)
    scores <- predict(model, model_df, type='prob')[,2]
  }
  else if (model == 'logreg') {
    model = glm(label ~ ., data = model_df, family = binomial(link='logit'))
    scores <- predict(model, model_df, type='response')
  }
  else {
    stop('Invalid model type.')
  }
  
  # store scores for only the sample rows
  n_syn <- nrow(synthetic_population)
  n_sample <- nrow(sample_df)
  relevant_inds <- (n_syn+1):(n_syn+n_sample) # corresponds to rows from sample
  relevant_scores <- scores[relevant_inds]
  
  # calculate weights from scores
  weights <- relevant_scores / (1 - relevant_scores)
  
  # rescale weights
  rescaled_weights <- n_sample * (weights / sum(weights))
  
  # append to dataframe column
  weighted_sample <- sample_df %>% mutate(weight = rescaled_weights)
  
  return(weighted_sample)
}