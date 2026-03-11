# 02_analysis_figures.R
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

dir.create("outputs/figures", showWarnings = FALSE, recursive = TRUE)

national <- readr::read_csv("data_clean/national_csection_trend_1973_2023.csv", show_col_types = FALSE)
regional_trend <- readr::read_csv("data_clean/regional_csection_2019_2023.csv", show_col_types = FALSE)
regional_detail <- readr::read_csv("data_clean/regional_csection_detail_2023.csv", show_col_types = FALSE)

p1 <- ggplot(national, aes(x = year, y = csection_total_pct)) +
  geom_line(linewidth = 0.9) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  labs(title = "Cesarean section deliveries in Sweden, 1973-2023", x = NULL, y = "Cesarean sections (%)") +
  theme_minimal(base_size = 12)
ggsave("outputs/figures/figure1_national_trend.png", p1, width = 8, height = 4.8, dpi = 300)

p2 <- ggplot(regional_trend, aes(x = year, y = csection_total_pct, group = region)) +
  geom_line(alpha = 0.5) +
  scale_x_continuous(breaks = 2019:2023) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  labs(title = "Regional cesarean section trends, Sweden, 2019-2023", x = NULL, y = "Cesarean sections (%)") +
  theme_minimal(base_size = 12)
ggsave("outputs/figures/figure2_regional_trends.png", p2, width = 8, height = 5, dpi = 300)

plot_2023 <- regional_detail %>% arrange(csection_total_pct) %>% mutate(region = factor(region, levels = region))
p3 <- ggplot(plot_2023, aes(x = csection_total_pct, y = region)) +
  geom_point(size = 2.5) +
  scale_x_continuous(labels = label_number(suffix = "%")) +
  labs(title = "Regional variation in cesarean section deliveries, 2023", x = "Cesarean sections (%)", y = NULL) +
  theme_minimal(base_size = 12)
ggsave("outputs/figures/figure3_regional_rank_2023.png", p3, width = 8, height = 6, dpi = 300)

plot_ep <- regional_detail %>%
  select(region, csection_emergency_pct, csection_planned_pct) %>%
  pivot_longer(cols = c(csection_emergency_pct, csection_planned_pct), names_to = "type", values_to = "pct") %>%
  mutate(type = recode(type, csection_emergency_pct = "Emergency", csection_planned_pct = "Planned"))
p4 <- ggplot(plot_ep, aes(x = pct, y = reorder(region, pct), shape = type)) +
  geom_point(size = 2.4) +
  scale_x_continuous(labels = label_number(suffix = "%")) +
  labs(title = "Emergency and planned cesarean sections by region, 2023", x = "Percent of deliveries", y = NULL, shape = NULL) +
  theme_minimal(base_size = 12)
ggsave("outputs/figures/figure4_emergency_planned_2023.png", p4, width = 8, height = 6, dpi = 300)
