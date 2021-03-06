% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{get_sample_distribution}
\alias{get_sample_distribution}
\title{Compute weighted or unweighted sample distribution.}
\usage{
get_sample_distribution(df, attribute, weight = TRUE)
}
\arguments{
\item{df}{dataframe}

\item{attribute}{string}

\item{weight}{boolean}
}
\value{
marginals (dataframe)
}
\description{
Compute weighted or unweighted sample distribution.
If weighted, requires column named 'weight'.
}
