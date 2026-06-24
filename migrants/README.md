# README

Data source: [European Social Survey][ess] (Wave 11, 2023-2024).

[ess]: https://europeansocialsurvey.org/

## R code to produce the data extract

```r
haven::read_dta("ESS11e04_1.zip") %>% 
  filter(cntry %in% c("FR", "DE")) %>%
  transmute(idno, cntry, dweight, pspwght, anweight,
            age = cut(agea, c(14, 24, 34, 44, 54, 64, Inf),
                      labels = c("15-24", "25-34", "35-44", "45-54",
                                 "55-64", "65+")),
            female = factor(gndr == 2, c(FALSE, TRUE), c("Male", "Female")),
            rightwing = lrscale,
            incdecile = hinctnta,
            subjinc = factor(if_else(hincfel == 4, 3, hincfel),
                             labels = c("Comfortable", "Coping", "Difficult")),
            born = as.logical(brncntr == 1),
            impcntr = haven::zap_labels(impcntr) %>% 
              factor(labels = c("Many", "Some", "Few", "None")),
            no_migrants = as.integer(impcntr == "Few" | impcntr == "None")) %>% 
  readr::write_rds("data/ess11e04-extract.rds")
```
