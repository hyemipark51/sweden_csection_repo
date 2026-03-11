# Sweden cesarean section trends

A reproducible epidemiology portfolio project using publicly available Swedish official statistics to describe national trends and regional variation in cesarean section deliveries.

## Research question

How have cesarean section rates changed over time in Sweden, and how much do they vary across regions?

## Data source

This repository uses tables published by Socialstyrelsen:

- Main source page: https://www.socialstyrelsen.se/statistik-och-data/statistik/alla-statistikamnen/graviditeter-forlossningar-och-nyfodda/
- 2023 publication page: https://www.socialstyrelsen.se/publikationer/statistik-om-graviditeter-forlossningar-och-nyfodda-barn-2023-2024-12-9357/
- 2023 appendix tables used in this repo:
  https://www.socialstyrelsen.se/contentassets/107f91a644d84643838ec94d77eb8391/2024-12-9357-tabeller.xlsx

## Repo structure

```text
data_raw/
  socialstyrelsen_2023_tables.xlsx
data_clean/
  national_csection_trend_1973_2023.csv
  regional_csection_2019_2023.csv
  regional_csection_detail_2023.csv
  regional_deliveries_2023.csv
  regional_csection_with_deliveries_2023.csv
R/
  01_download_and_clean.R
  02_analysis_figures.R
report/
  analysis.Rmd
```

## Suggested analyses

1. Long-term national trend in total cesarean sections, 1973-2023
2. Regional trends in total cesarean sections, 2019-2023
3. Ranked regional comparison for 2023
4. Emergency versus planned cesarean sections across regions in 2023

## Limitations

- This is descriptive epidemiology, not causal inference.
- Public summary tables do not allow individual-level confounder adjustment.
- Some 2023 regional data have missingness noted by Socialstyrelsen.

## How to run

```r
source("R/01_download_and_clean.R")
source("R/02_analysis_figures.R")
rmarkdown::render("report/analysis.Rmd")
```

## [Full report](report/analysis.md)
