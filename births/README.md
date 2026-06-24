# DATA

Data source: [Quality of Government Standard Dataset][qog] (Jan 2026).

Female educational attainment from [Barro & Lee][bl], all other variables from the [World Bank Development Indicators][wdi], except continents, which were added through the [`countrycode`][countrycode] package.

See the [Quality of Government codebook][qog-codebook] for more details.

[bl]: https://barrolee.github.io/BarroLeeDataSet/BLv3.html
[countrycode]: https://vincentarelbundock.github.io/countrycode/
[qog]: https://www.gu.se/en/quality-government/qog-data/data-downloads/standard-dataset
[qog-codebook]: https://www.qogdata.pol.gu.se/data/codebook_std_jan26.pdf
[wdi]: https://databank.worldbank.org/source/world-development-indicators

## R code to produce the extract

```r
library(tidyverse)

df <- "https://www.qogdata.pol.gu.se/data/qog_std_ts_jan26.csv" %>%
  read_csv(guess_max = 10^5)

# available years
group_by(df, year) %>%
  summarise(n_edu = sum(!is.na(bl_asyf)),
            n_births = sum(!is.na(wdi_fertility))) %>%
  filter(n_edu > 0, n_births > 0)

# export, with additional variables
filter(df, year %in% seq(1960, 2015, by = 5)) %>% 
  transmute(iso3c = ccodealp, year,
            births = wdi_fertility, schooling = bl_asyf, population = wdi_pop,
            continent = countrycode::countrycode(iso3c, "iso3c", "continent"),
            skilled = wdi_birthskill, hexp = wdi_chexppgdp) %>% 
  write_tsv("data/qog_std_ts_jan26-extract.tsv")
```
