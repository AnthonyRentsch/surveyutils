#' Perform raking. 
#' 
#' Rakes sample_df to populations_params. 
#' If initialize_weights == FALSE, df must have a column named weight.
#' @param sample_df dataframe
#' @param population_params list of lists of style list(attribute=list(val1=x, val2=y, ...), ...)
#' @param iterations int
#' @param initialize_weights boolean
#' @return sample_df (dataframe)
#' @export
rake <- function(sample_df, population_params, iterations=1, initialize_weights=TRUE) {
  
  # initialize new weight column, if specified
  if (initialize_weights) {
    sample_df$weight <- 1
  }
  else {
    if (!'weight' %in% names(sample_df)) {
      stop('weight column not present in sample_df and not initialized.')
    }
  }

  # loop for as many iterations as specified
  for (i in 1:iterations) {
    
    # loop through variables
    for (attribute in names(population_params)) {
      
      # get weighted sample distribution for that variable
      marginals <- get_sample_distribution(sample_df, attribute, weight=TRUE)
      
      # loop through unique values 
      unique_attribute_vals <- unique(marginals[[attribute]])
      for (val in unique_attribute_vals) {
        
        # compute new weight
        sample_margin <- marginals$pct[marginals[[attribute]] == val]
        cur_weight <- sample_df$weight[sample_df[[attribute]]==val]
        pop_margin <- population_params[[attribute]][[val]]
        new_weight <- cur_weight * pop_margin / sample_margin
        
        # update weight in df for observations with the current value of the current variable
        sample_df$weight[sample_df[[attribute]]==val] <- new_weight
      }
    }
  }
  return(sample_df)
}