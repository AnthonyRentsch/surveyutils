#' Compute weighted or unweighted sample distribution.
#' 
#' Compute weighted or unweighted sample distribution.
#' If weighted, requires column named 'weight'.
#' @importFrom magrittr %>%
#' @param df dataframe
#' @param attribute string
#' @param weight boolean
#' @return marginals (dataframe)
#' @export
get_sample_distribution <- function(df, attribute, weight=TRUE) {
  
  attribute_eval <- rlang::sym(attribute)
  if (weight) { 
    marginals <- df %>% group_by(!!attribute_eval) %>% 
      summarise(n = sum(weight)) %>% 
      mutate(pct = n / sum(n))
  }
  else {
    marginals <- df %>% group_by(!!attribute_eval) %>% 
      summarise(n = n()) %>% 
      mutate(pct = n / sum(n))
  }
  return(marginals)
}

#' Combine sample and synthetic dataframes into one for modeling.
#' @importFrom magrittr %>%
#' @param sample_df dataframe
#' @param synthetic_population dataframe
#' @param factor_cols vector
#' @param predictor_cols vector
#' @return model_df dataframe
combine_sample_synthetic <- function(sample_df, synthetic_population, 
                                     factor_cols=NA, predictor_cols=NA) {

  
  # add label column
  syn_pop <- synthetic_population %>% mutate(label = 1)
  samp <- sample_df %>% mutate(label = 0)
  
  # keep similar columns
  keep_cols <- c(predictor_cols, 'label')
  syn_pop <- syn_pop[keep_cols]
  samp <- samp[keep_cols]
  
  # concatenate the two and set up modeling dataframe
  model_df <- dplyr::bind_rows(syn_pop, samp)
  model_df[factor_cols] <- lapply(model_df[factor_cols], factor)
  model_df$label <- as.factor(model_df$label)
  
  return(model_df)
}

#' Create wide dataframe to compare results of various methods.
#' 
#' Intended to be used to simplify tutorial notebook.
#' @param df_list named list of dataframes of style list(col_name=sample_distribution_df, ...)
#' @param attribute string
#' @return comparison_df dataframe
#' @export
create_comparison_df <- function(df_list, attribute) {
    
    # function to drop n column and rename pct column to name of method for comparison
    process_columns <- function(x, first_col=attribute) {
        df_list[[x]] <- df_list[[x]][,-2]
        names(df_list[[x]]) <- c(first_col, x)
        return(df_list[[x]])
    }
    df_list_to_bind <- lapply(names(df_list), process_columns)
    
    # specify columns of interest
    cols <- c(attribute, names(df_list))
    
    # create comparison dataframe
    comparison_df <- dplyr::bind_cols(df_list_to_bind) %>% select_(.dots = cols)
    
    return(comparison_df)
}