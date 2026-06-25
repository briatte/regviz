
# Quantilille 2026 --------------------------------------------------------
#
# Visualization of regression models
# Part 2.3: survey weights
#
# ------------------------------ see the README file for the data source --

# required packages

library(modelsummary)
library(srvyr)
library(survey)
library(tidyverse)

# load saved datasets and models ------------------------------------------

load("models.rda")

# weighted survey design --------------------------------------------------

svy_fr <- df_fr %>%
  srvyr::as_survey_design(ids = idno,
                          strata = cntry,
                          nest = TRUE,
                          weights = pspwght)

# weighted means/proportions
svy_fr %>%
  group_by(impcntr) %>%
  summarise(prop = srvyr::survey_mean())

# passed on to a bar plot
svy_fr %>%
  group_by(impcntr, female, age) %>%
  summarise(prop = srvyr::survey_mean(vartype = "ci")) %>%
  filter(!is.na(age)) %>%
  ggplot(aes(y = 100 * prop, x = age)) +
    geom_col(fill = "grey75") +
    geom_errorbar(aes(ymin = prop_low * 100,
                      ymax = prop_upp * 100), width = 0.1, color = "grey50") +
    facet_grid(female ~ impcntr)

# survey-weighted regression estimates ------------------------------------

# recall initial model
summary(m1_fr)

# compare unweighted and weighted models
survey::svyglm(m1_fr$formula, design = svy_fr,
               family = quasibinomial(link = "logit")) %>%
  list("unweighted" = m1_fr, "weighted" = .) %>%
  ggstats::ggcoef_compare(variable_labels = c("age" = "Age",
                                              "female" = "Sex",
                                              "born" = "Born in country",
                                              "subjinc" = "Subjective income"),
                          add_reference_rows = FALSE)

# for a short read on survey weighting, check Andi Fugard's tutorial:
# https://inductivestep.github.io/R-notes/complex-surveys.html

# for a longer read, check Zimmer, Powell and Velásquez's excellent handbook:
# https://tidy-survey-r.github.io/tidy-survey-book/

# kthxbye
