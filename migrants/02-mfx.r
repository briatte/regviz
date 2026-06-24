
# Quantilille 2026 --------------------------------------------------------
#
# Visualization of regression models
# Part 2.2: marginal effects
#
# ------------------------------ see the README file for the data source --

# required packages

library(haven) # needs to be explicitly loaded for labelled variables
library(marginaleffects)
library(patchwork)
library(texreg)
library(tidyverse)

# load saved datasets and models ------------------------------------------

load("models.rda")

# visualizing the predictions ---------------------------------------------

# code lifted from the {marginaleffects} docs:
# https://marginaleffects.com/chapters/predictions.html

# France, by sex and birth
marginaleffects::predictions(m1_fr) %>%
  ggplot() +
  geom_density(aes(estimate, fill = born), alpha = 1/2) +
  scale_fill_grey() +
  labs(x = "Pr(outcome = 1)", fill = "born") +
  facet_grid(age ~ female, scales = "free_y") +
  theme_linedraw()

# France, ECDF by subjective income
ecdf_fr <- marginaleffects::predictions(m1_fr) %>%
  ggplot() +
  stat_ecdf(aes(estimate, colour = factor(subjinc))) +
  labs(x = "Pr(outcome = 1)",
       y = "Cumulative Probability",
       colour = "subjinc") +
  coord_equal() +
  theme(legend.position = "bottom")

ecdf_de <- marginaleffects::predictions(m1_de) %>%
  ggplot() +
  stat_ecdf(aes(estimate, colour = factor(subjinc))) +
  labs(x = "Pr(outcome = 1)",
       y = "Cumulative Probability",
       colour = "subjinc") +
  coord_equal() +
  theme(legend.position = "bottom")

# assemble with {patchwork}
ecdf_fr + ecdf_de

# marginal (and conditional) predictions ----------------------------------

# average predicted probabilities across age
marginaleffects::avg_predictions(m1_fr, by = "age")

# plot AME with a categorical predictor
marginaleffects::plot_predictions(m1_fr, by = c("age", "female"))

# plot AME with a continuous predictor
marginaleffects::plot_predictions(m1_fr, by = c("rightwing", "born"))

# same plot against an equally spaced prediction grid
marginaleffects::plot_predictions(m1_fr, condition = c("rightwing", "born")) +
  labs(y = "Predicted Pr(Y = 1)")

mfx1 <- last_plot()

# slope of the effect (partial derivative)
marginaleffects::plot_slopes(m1_fr, variables = "rightwing",
                             condition = c("rightwing", "born")) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_x_continuous(breaks = 0:10) +
  labs(y = "Slope (dY/dX)")

mfx2 <- last_plot()

# assemble with {patchwork}
mfx1 / mfx2

# more on predictions vs slopes:
# https://marginaleffects.com/chapters/slopes.html

# interactions ------------------------------------------------------------

# model a continuous-by-continuous interaction
m2_fr <- glm(no_migrants ~ age + female + incdecile * rightwing + born,
             data = df_fr, family = binomial(link = "logit"))

m2_de <- glm(no_migrants ~ age + female + incdecile * rightwing + born,
             data = df_de, family = binomial(link = "logit"))

# compare subjective income to income deciles (moderator effect)
texreg::screenreg(list(m1_fr, m2_fr, m1_de, m2_de))

# predicted outcome at deciles 1, 5, 10 of the moderator
list("rightwing",  "incdecile" = c(1, 5, 10)) %>%
  marginaleffects::plot_predictions(m2_fr, condition = .) +
  theme(legend.position = "bottom")

# moving up one notch to the right produces 0.06 more aversion to migrants ...
marginaleffects::avg_slopes(m2_fr, variables = "rightwing")

# ... but moving up an income decile produces 0.02 less aversion to migrants
marginaleffects::avg_slopes(m2_fr, variables = "incdecile")

# the effect exists across all income deciles, yet with varying returns
# depending on sex and origin
marginaleffects::plot_slopes(m2_fr, variables = "rightwing",
                             condition = c("incdecile", "female", "born")) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_x_continuous(breaks = 0:10) +
  labs(y = "Slope (dY/dX)")

# as always, check the {marginaleffects} docs for more:
# https://marginaleffects.com/chapters/interactions.html

# kthxbye
