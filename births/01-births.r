
# Quantilille 2026 --------------------------------------------------------
#
# Visualization of regression models
# Part 1.1: linear models
#
# ------------------------------ see the README file for the data source --

# required packages

library(broom)
library(ggrepel)
library(patchwork)
library(texreg)
library(tidyverse)

# World Bank + Barro & Lee data -------------------------------------------

df <- read_tsv("data/qog_std_ts_jan26-extract.tsv")

group_by(df, year) %>%
  summarise(n_edu = sum(!is.na(schooling)),
            n_births = sum(!is.na(births))) %>%
  filter(n_edu > 0, n_births > 0)

df15 <- filter(df, year == 2015)

# plotting the data -------------------------------------------------------

# year 2015, with linear trend
ggplot(df15, aes(x = schooling, y = births)) +
  geom_text(aes(label = iso3c)) +
  # geom_point() +
  # ggrepel::geom_text_repel(aes(label = iso3c)) +
  geom_smooth(method = "lm")

# all years, with local polynomial
# ?loess
ggplot(df, aes(x = schooling, y = births)) +
  geom_point(alpha = 1/3, aes(size = population / 10^6)) +
  stat_smooth(method = "loess", fill = "steelblue", level = 0.90, alpha = 1/2) +
  stat_smooth(method = "loess", fill = "steelblue", level = 0.99) +
  facet_wrap(~ year) +
  scale_size_area(guide = "none")

# all years, square root transform
ggplot(df, aes(x = schooling, y = births)) +
  geom_point(alpha = 1/3) +
  geom_smooth(method = "lm", formula = y ~ sqrt(x), color = "black") +
  facet_wrap(~ year) +
  theme_linedraw() +
  theme(panel.grid = element_blank(), axis.title = element_blank())

# all years, with cubic spline
# ?mgcv::gam
ggplot(df, aes(x = schooling, y = births)) +
  geom_text(aes(label = iso3c), size = 3) +
  geom_smooth(method = "gam", formula = y ~ s(x, bs = "cs")) +
  facet_wrap(~ year)

# model estimation --------------------------------------------------------

m0 <- lm(births ~ 1, data = df15)
m1 <- lm(births ~ schooling, data = df15)
m2 <- lm(births ~ sqrt(schooling), data = df15)

texreg::screenreg(list(m0, m1, m2), include.adjrs = FALSE)

m1w <- lm(births ~ schooling, weights = population, data = df15)
m2w <- lm(births ~ sqrt(schooling), weights = population, data = df15)

texreg::screenreg(list(m0, m1, m1w, m2, m2w), include.rmse = TRUE)

# note: {modelsummary} can export results to several common formats

# model results extraction ------------------------------------------------

# with base R
str(m1)
coef(m1)

head(fitted(m1))
head(residuals(m1))

# e.g. actual - predicted fertility in Afghanistan, 2015
df15$births[1] - fitted(m1)[1]
df15$births[1] - unname(coef(m1)[1] + coef(m1)[2] * m1$model$schooling[1])

# predicted fertility across values of female schooling
range(df$schooling, na.rm = TRUE)
coef(m1)[1]
predict(m1, newdata = list("schooling" = 0:13), se.fit = TRUE) %>%
  bind_cols(x = 0:13, .)

# with {broom}

broom::tidy(m1)
broom::glance(m1)

broom::augment(m1)
broom::augment(m1, newdata = df15)

# linear regression diagnostics -------------------------------------------

# with base R

hist(resid(m1))
plot(density(resid(m1)))
# plot(m1)

# with {broom}

m1_augmented <- broom::augment(m1, newdata = df15)

# residuals as a histogram
ggplot(m1_augmented, aes(x = .resid)) +
  geom_histogram(aes(y = ..density..), binwidth = .25,
                 color = "white", fill = "grey75") +
  stat_function(fun = dnorm,
                args = list(mean = mean(m1_augmented$.resid, na.rm = TRUE),
                            sd = sd(m1_augmented$.resid, na.rm = TRUE)),
                color = "darkred", lwd = 1) +
  labs(x = "Residuals", y = "Density") +
  theme_bw()

# residuals as a density curve
ggplot(m1_augmented, aes(x = .resid)) +
  geom_density(fill = "grey75", color = "white") +
  stat_function(fun = dnorm,
                args = list(mean = mean(m1_augmented$.resid, na.rm = TRUE),
                            sd = sd(m1_augmented$.resid, na.rm = TRUE)),
                color = "darkred", lwd = 1) +
  geom_rug() +
  labs(x = "Residuals", y = "Density") +
  theme_bw()

dp1 <- last_plot() + theme_bw() + labs(title = "A. Distribution of residuals")

# residuals as a Q-Q plot
ggplot(m1_augmented, aes(sample = .resid)) +
  stat_qq() +
  stat_qq_line(lty = "dashed") +
  labs(x = "Theoretical quantiles", y = "Sample quantiles")

dp2 <- last_plot() + theme_bw() + labs(title = "B. Quantile-quantile plot")

# assemble last two plots with {patchwork}
dp1 + dp2

# residuals-versus-fitted values
ggplot(m1_augmented, aes(x = .fitted, y = .resid)) +
  geom_text(aes(label = iso3c)) +
  geom_smooth(method = "loess") +
  geom_hline(yintercept = 0, col = "tomato", lty = "dashed") +
  labs(x = expression(paste(hat(Y), " (fitted)")),
       y = expression(paste(hat(Y) - Y, " (residual)")))

# using {broom} in more complex settings ----------------------------------

# Gelman's secret weapon:
# https://statmodeling.stat.columbia.edu/2005/03/07/the_secret_weap/
# https://avehtari.github.io/ROS-Examples/NES/nes_linear.html

group_split(group_by(df, year)) %>%
  map(~ lm(births ~ schooling, data = .x) %>%
           broom::tidy(conf.int = TRUE, conf.level = .99) %>%
        add_column(year = factor(mean(.x$year)), .before = 1)) %>%
  list_rbind() %>%
  filter(term == "schooling") %>%
  ggplot(aes(year, estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange(color = "grey50") +
  # 95% confidence band
  geom_pointrange(aes(ymin = estimate - 1.96 * std.error,
                      ymax = estimate + 1.96 * std.error),
                  color = "grey50", lwd = 2) +
  geom_point() +
  labs(x = NULL)

# more on visualizing uncertainty:
# https://clauswilke.com/dataviz/visualizing-uncertainty.html

# kthxbye
