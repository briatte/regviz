
# Quantilille 2026 --------------------------------------------------------
#
# Visualization of regression models
# Part 2.1: logistic models
#
# ------------------------------ see the README file for the data source --

# required packages

library(ggstats)
library(haven) # needs to be explicitly loaded for labelled variables
library(marginaleffects)
library(marimekko)
library(modelsummary)
library(patchwork)
library(texreg)
library(tidyverse)

# European Social Survey data ---------------------------------------------

df <- readr::read_rds("data/ess11e04-extract.rds")

glimpse(df)
count(df, impcntr)

group_by(df, cntry, female, age) %>%
  summarise(no_migrants = 100 * mean(no_migrants, na.rm = TRUE)) %>%
  pivot_wider(names_from = cntry, values_from = no_migrants) %>%
  print(n = Inf)

# naive logit curves ------------------------------------------------------

ggplot(df, aes(y = no_migrants, x = rightwing, color = born, fill = born)) +
  geom_jitter(height = 0.05, alpha = 1/3) +
  geom_smooth(method = glm, method.args = list(family = binomial)) +
  scale_x_continuous(breaks = 0:10) +
  scale_y_continuous(breaks = c(0, 0.5, 1)) +
  scale_fill_brewer(palette = "Set1") +
  scale_color_brewer(palette = "Set1") +
  facet_grid(female ~ cntry) +
  theme_bw()

# marimekko (mosaic) plots ------------------------------------------------

df_complete <- drop_na(df, impcntr, age)

p_fr <- ggplot(filter(df_complete, cntry == "FR")) +
  geom_marimekko(aes(fill = forcats::fct_rev(impcntr)),
                 formula = ~ age | impcntr) +
  scale_fill_brewer(palette = "RdBu") +
  theme(legend.position = "none", axis.text = element_text(size = 12)) +
  labs(title = "France", y = NULL, x = NULL)

p_de <- ggplot(filter(df_complete, cntry == "DE")) +
  geom_marimekko(aes(fill = forcats::fct_rev(impcntr)),
                 formula = ~ age | impcntr) +
  scale_fill_brewer(palette = "RdBu") +
  theme(legend.position = "none", axis.text = element_text(size = 12)) +
  labs(title = "Germany", y = NULL, x = NULL)

# assemble with {patchwork}
p_fr + p_de

# model estimation --------------------------------------------------------

df_fr <- drop_na(filter(df, cntry == "FR"), no_migrants, born)
df_de <- drop_na(filter(df, cntry == "DE"), no_migrants, born)

eqn <- formula(no_migrants ~ age + female + rightwing + subjinc + born)

m1_fr <- glm(eqn, data = df_fr, family = binomial(link = "logit"))
m1_de <- glm(eqn, data = df_de, family = binomial(link = "logit"))

texreg::screenreg(list(m1_fr, m1_de))

# model visualization -----------------------------------------------------

# with {texreg}

texreg::plotreg(list(m1_fr, m1_de), omit.coef = "(Intercept)")

# with {modelsummary}

modelsummary::modelsummary(list(m1_fr, m1_de), stars = TRUE)

modelsummary::modelplot(list("France" = m1_fr, "Germany" = m1_de),
                        exponentiate = TRUE,
                        coef_omit = "(Intercept)") +
  geom_vline(xintercept = 1, color = "grey75", lty = "dashed")

# use `coef_map` on the model terms to rename and reorder
# modelsummary::get_estimates(m1_fr)

# check the vignette for more options:
# https://modelsummary.com/vignettes/modelplot.html

# with {ggstats}

vars <- c("age" = "Age", "female" = "Sex", "subjinc" = "Subjective income",
          "born" = "Born in country")

ggstats::ggcoef_model(m1_fr, variable_labels = vars) # model only
ggstats::ggcoef_table(m1_fr, variable_labels = vars) # model + table

# models side-by-side
ggstats::ggcoef_compare(list("France" = m1_fr, "Germany" = m1_de),
                        variable_labels = vars)

# check the vignette for more options:
# https://larmarange.github.io/ggstats/articles/ggcoef_model.html

# save datasets and models (for faster access)
save(df_fr, df_de, m1_fr, m1_de, file = "models.rda")

# kthxbye
