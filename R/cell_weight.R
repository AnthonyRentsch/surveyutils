#' Perform cell weighting. 
#' 
#' Requires full joint distribution of covariates of interest.
#' @importFrom magrittr %>%
#' @param sample_df dataframe
#' @param attribute_col string
#' @param population_cells list of format list(joint_attribute1=x, joint_attribute2=y, ...)
#' @return weighted_sample (dataframe)
#' @export
cell_weight <- function(sample_df, attribute_col, population_cells) {
  
  # check that sample attributes must all exist in population
  if (sum(!unique(sample_df[,attribute_col]) %in% names(population_cells)) > 0) {
    stop('Found attribute combination in sample that was not in population.')
  }
  
  # get sample distribution
  sample_joint_distro <- get_sample_distribution(sample_df, attribute_col, weight=FALSE)

  # initialize weight column
  weighted_sample <- sample_df %>% dplyr::mutate(weight = NA)
  
  # calculate weight and assign it to rows with that combination of attributes
  for (attribute_combo in names(population_cells)) {
    pop_joint <- population_cells[[attribute_combo]]
    sample_joint <- sample_joint_distro$pct[sample_joint_distro[[attribute_col]]==attribute_combo]
    weight <- pop_joint / sample_joint
    weighted_sample$weight[weighted_sample[[attribute_col]]==attribute_combo] <- weight
  }
  
  return(weighted_sample)
}