# Utility functions for survey analysis

This repository contains functions to weight and analyze weighted survey data. I wrote this code for my own learning purposes, but feel free to use it. All mistakes are my own.

Read my package tutorial [here](https://nbviewer.jupyter.org/gist/AnthonyRentsch/2f5905daa59feb02abac09ede4ca05d1#cell_weighting).

**Installation**

```
devtools::install_github('AnthonyRentsch/surveyutils')
```

**Supported techniques**
- (Un)weighted sample distributions
- Raking
- Matching
- Cell weighting
- Propensity weighting
- Combinations of matching, raking, and propensity weighting

**TODO** 
- Entropy balancing ([example](https://github.com/cran/ebal/tree/master/R))

Inspiration for this repository comes from [Pew Research Center](https://www.pewresearch.org/methods/2018/01/26/how-different-weighting-methods-work/), the [Cooperative Congressional Election Study](https://cces.gov.harvard.edu/), [Data Science for Political Campaigns](https://github.com/therriault/dsforcampaigns_fall2019_public), and the incredible [`survey` package](https://cran.r-project.org/web/packages/survey/survey.pdf).