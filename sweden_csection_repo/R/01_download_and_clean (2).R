# 01_download_and_clean.R
library(readxl)
library(dplyr)
library(stringr)
library(tidyr)
library(readr)

dir.create("data_raw", showWarnings = FALSE, recursive = TRUE)
dir.create("data_clean", showWarnings = FALSE, recursive = TRUE)

source_url <- "https://www.socialstyrelsen.se/contentassets/107f91a644d84643838ec94d77eb8391/2024-12-9357-tabeller.xlsx"
raw_file   <- "data_raw/socialstyrelsen_2023_tables.xlsx"
download.file(source_url, destfile = raw_file, mode = "wb")

clean_year <- function(x) {
  out <- stringr::str_extract(as.character(x), "\\d{4}")
  as.integer(out)
}

is_region_row <- function(x) {
  x <- as.character(x)
  dplyr::case_when(
    x %in% c("RIKET*", "RIKET", "Uppgift saknas") ~ FALSE,
    stringr::str_starts(x, "Region ") ~ TRUE,
    stringr::str_starts(x, "Västra Götalandsregionen") ~ TRUE,
    TRUE ~ FALSE
  )
}

national <- readxl::read_excel(raw_file, sheet = "9.1 Förlossningssätt - detalj", skip = 3) %>%
  mutate(year = clean_year(`År`)) %>%
  filter(!is.na(year)) %>%
  transmute(
    year,
    csection_total_n = `Samtliga kejsarsnitt, antal`,
    csection_total_pct = `Samtliga kejsarsnitt, %`,
    csection_emergency_n = `Akut kejsarsnitt, antal`,
    csection_emergency_pct = `Akut kejsarsnitt, %`,
    csection_planned_n = `Planerat kejsarsnitt, antal`,
    csection_planned_pct = `Planerat kejsarsnitt, %`,
    instrumental_vaginal_n = `Instrumentell vaginal förlossning, antal`,
    instrumental_vaginal_pct = `Instrumentell vaginal förlossning, %`
  ) %>% arrange(year)
readr::write_csv(national, "data_clean/national_csection_trend_1973_2023.csv")

regional_deliveries <- readxl::read_excel(raw_file, sheet = "6.2 Förlossningar - region", skip = 3) %>%
  rename(
    region = Region,
    deliveries_n = `Antal förlossningar`,
    births_n = `Antal födda barn`,
    singleton_deliveries_n = `Antal enkelbörder`,
    multiple_deliveries_n = `Antal flerbörder`,
    girls_pct = `Flickor, %`,
    boys_pct = `Pojkar, %`
  ) %>%
  filter(is_region_row(region)) %>%
  mutate(region = str_replace_all(region, "\\*", ""), year = 2023L, .before = deliveries_n)
readr::write_csv(regional_deliveries, "data_clean/regional_deliveries_2023.csv")

regional_detail_raw <- readxl::read_excel(raw_file, sheet = "9.3 Förl.ssätt - sjukhus 2023", skip = 3, col_names = FALSE)
names(regional_detail_raw) <- c("location","csection_total_n","csection_total_pct","csection_emergency_n","csection_emergency_pct","csection_planned_n","csection_planned_pct","csection_unknown_type_n","csection_unknown_type_pct","instrumental_vaginal_n","instrumental_vaginal_pct")
regional_detail <- regional_detail_raw %>%
  filter(is_region_row(location)) %>%
  mutate(region = str_replace_all(location, "\\*", ""), year = 2023L, .before = csection_total_n) %>%
  select(-location)
readr::write_csv(regional_detail, "data_clean/regional_csection_detail_2023.csv")

regional_trend_raw <- readxl::read_excel(raw_file, sheet = "9.4 Förl.ssätt - sjukh. 2019-23", skip = 3, col_names = FALSE)
names(regional_trend_raw) <- c("location","n_2019","pct_2019","n_2020","pct_2020","n_2021","pct_2021","n_2022","pct_2022","n_2023","pct_2023")
regional_trend <- regional_trend_raw %>%
  filter(is_region_row(location)) %>%
  mutate(region = str_replace_all(location, "\\*", "")) %>%
  select(-location) %>%
  pivot_longer(cols = -region, names_to = c(".value","year"), names_pattern = "(n|pct)_(\\d{4})") %>%
  rename(csection_total_n = n, csection_total_pct = pct) %>%
  mutate(year = as.integer(year)) %>%
  arrange(region, year)
readr::write_csv(regional_trend, "data_clean/regional_csection_2019_2023.csv")

regional_2023_merged <- regional_detail %>%
  left_join(regional_deliveries %>% select(region, year, deliveries_n, births_n, singleton_deliveries_n, multiple_deliveries_n), by = c("region","year"))
readr::write_csv(regional_2023_merged, "data_clean/regional_csection_with_deliveries_2023.csv")
