# README

A six-hour summer module on visualizing regression model results, offered as part of the [Quantilille 2026][ql26] summer school. Please stay hydrated and use the [GitHub repository][regviz] for bug reports.

[ql26]: https://ceraps.univ-lille.fr/detail-event/quantilille-2026
[regviz]: http://github.com/briatte/regviz

## Contents

The `births` folder covers __linear regression__ by showing how to do

- scatterplots with smoothed trends
- results extraction with `broom`
- tabular visualization of coefficients
- visual inspection of the residuals

The contents above are for the `01-births.r` R script. The `02-skilled.r` R script produces a bonus [logit dotplot][mjskay] out of a logistic regression model.

[mjskay]: https://mjskay.github.io/ggdist/articles/dotsinterval.html#logit-dotplots

The `migrants` folder covers __logistic regression__ by showing how to do

- marimekko (mosaic) plots for categorical data
- visual representation of the coefficients
- predicted probabilities and marginal effects
- interaction terms

The contents above are for the `01-migrants.r` and `02-mfx.r` R scripts. The `03-svy.r` contains bonus code that uses [survey weights][gelman07].

[gelman07]: https://sites.stat.columbia.edu/gelman/research/published/STS226.pdf

For an additional demo of the `ggcoef_*` functions from the [`ggstats`][ggstats] package, see [Joseph Larmarange's tutorial on count regression models][larmarange24] (in French).

[ggstats]: https://larmarange.github.io/ggstats/
[larmarange24]: https://www.youtube.com/watch?v=T5FiU2oaxXM

For more information on the [`marginaleffects`][marginaleffects] package, watch [Vincent Arel-Bundock's guest lecture in Dirk Eddelbuettel's STAT 447 course][vab26], and read [Arel-Bundock, Greifer and Heiss 2024][abgh24] and [Rohrer and Arel-Bundock 2026][rab26].

[abgh24]: https://doi.org/10.18637/jss.v111.i09
[marginaleffects]: https://marginaleffects.com/
[rab26]: https://doi.org/10.1177/25152459261424825
[vab26]: https://www.youtube.com/watch?v=v3TX9nXHXo8

Each folder comes with a `README` file that links to the data sources, and the code includes links to tutorials, vignettes and documentation pages.

## Dependencies

On top of the [tidyverse][tidyverse], and [`ggplot2`][ggplot2] in particular:

[tidyverse]: https://tidyverse.org/
[ggplot2]: https://ggplot2.tidyverse.org/

- Manipulating model results
  - [`broom`][broom]
  - [`texreg`][texreg] · esp. `screenreg` and `plotreg`
  - [`modelsummary`][modelsummary] · esp. [`modelplot`][modelplot]
- Visualizing model results
  - [`ggstats`][ggstats] · esp. [`ggcoef_model`][ggcoef_model]
  - [`marginaleffects`][marginaleffects]

[broom]: https://broom.tidymodels.org/
[ggcoef_model]: https://larmarange.github.io/ggstats/articles/ggcoef_model.html
[modelplot]: https://modelsummary.com/vignettes/modelplot.html
[modelsummary]: https://modelsummary.com/
[texreg]: https://leifeld-lab.r-universe.dev/texreg

Some of the packages used in the background or on an occasional basis include [`broom.helpers`][broom-helpers], [`distributional`][distributional], [`ggrepel`][ggrepel], [`marimekko`][marimekko], [`patchwork`][patchwork], [`srvyr`][srvyr] and [`survey`][survey].

[broom-helpers]: https://larmarange.github.io/broom.helpers/
[distributional]: https://pkg.mitchelloharawild.com/distributional/
[ggrepel]: https://ggrepel.slowkow.com/
[marimekko]: https://cran.r-project.org/web/packages/marimekko/vignettes/getting-started.html
[patchwork]: https://patchwork.data-imaginist.com/
[srvyr]: http://gdfe.co/srvyr/
[survey]: https://cran.r-project.org/package=survey

## Handbooks

- Gelman, Hill and Vehtari, [_Regression and Other Stories_][ros]
- Healy, [_Data Visualization_][healy] (ch. 6 in particular)
- Wilke, [_Fundamentals of Data Visualization_][wilke] (ch. 16 in particular)

[healy]: https://socviz.co/
[ros]: https://avehtari.github.io/ROS-Examples/
[wilke]: https://clauswilke.com/dataviz/

## Notes
 
- not a course on regression, and we are not going to cover the [other culture][breiman01]
- many modelling packages come with their own plotting functions
  - e.g. [`bayesplot`][bayesplot] for Bayesian models
  - e.g. [`see`][see] for the [easystats][easystats] packages
- visualizing uncertainty could be a course in itself -- see esp. the [`ggdist`][ggdist] package

[breiman01]: https://doi.org/10.1214/ss/1009213726
[bayesplot]: https://mc-stan.org/bayesplot/
[easystats]: https://easystats.github.io/easystats/
[ggdist]: https://mjskay.github.io/ggdist/
[see]: https://easystats.github.io/see/
