
# Quantilille 2026 --------------------------------------------------------
#
# Visualization of regression models
# Part 1.2: logit dotplot (bonus)
#
# ------------------------------ see the README file for the data source --

# required packages

library(broom)
library(distributional)
library(ggdist)
library(tidyverse)

# World Bank data ---------------------------------------------------------

df <- read_tsv("data/qog_std_ts_jan26-extract.tsv")

group_by(df, year) %>%
  filter(any(!is.na(skilled))) %>%
  summarise(n_skilled = sum(!is.na(skilled)),
            n_hexp = sum(!is.na(hexp)),
            min_skilled = min(skilled, na.rm = TRUE),
            p50_skilled = median(skilled, na.rm = TRUE),
            max_skilled = max(skilled, na.rm = TRUE)) %>%
  filter(n_skilled > 0, n_hexp > 0)

df00 <- filter(df, year == 2000) %>%
  mutate(skilled = skilled > 95, hexp = log(1 + hexp)) %>%
  drop_na(skilled, hexp)

table(df00$skilled)

# model estimation --------------------------------------------------------

m <- glm(skilled ~ hexp, data = df00, family = binomial(link = "logit"))
summary(m)

# prediction grid
m_grid <- with(df00, list(hexp = seq(min(hexp), max(hexp), length.out = 100)))
exp(unlist(m_grid))

# log-odds, with base R
m_grid %>%
  bind_cols(predict(m, ., type = "link", se.fit = TRUE))

# predicted probabilities, with {broom}
as_tibble(m_grid) %>%
  broom::augment(m, newdata = ., type.predict = "response", se_fit = TRUE)

# logit dotplot -----------------------------------------------------------

# code by Matthew Kay and Ladislas Nalborczyk:
# https://mjskay.github.io/ggdist/articles/dotsinterval.html#logit-dotplots
# https://lnalborczyk.github.io/blog/2018-01-20-glm/index.html

m_grid %>%
  bind_cols(predict(m, ., se.fit = TRUE)) %>%
  mutate(
    # distribution describing uncertainty in log odds
    log_odds = distributional::dist_normal(fit, se.fit),
    # inverse-logit transform the log odds to get
    # distribution describing uncertainty in Pr(skilled > 95%)
    p_skilled = distributional::dist_transformed(log_odds, plogis, qlogis)
  ) %>%
  ggplot(aes(x = hexp)) +
  geom_dots(aes(y = as.integer(skilled), side = skilled),
            scale = 0.4, fill = "grey75", color = "white", data = df00) +
  # confidence intervals at .5, .8, .95
  # https://mjskay.github.io/ggdist/reference/stat_lineribbon.html
  stat_lineribbon(aes(ydist = p_skilled), alpha = 1/4, fill = "steelblue") +
  scale_side_mirrored(guide = "none") +
  coord_cartesian(ylim = c(0, 1)) +
  theme_ggdist() +
  labs(y = "Pr (skilled birth attendance > 95%)",
       x = "Health expenditure as % GDP (logged)")

# kthxbye
