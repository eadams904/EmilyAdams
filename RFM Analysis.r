## Recency, frequency, monetary analysis (RFM)

library(dplyr)
library(lubridate)

# Sample dataset
set.seed(123)
transactions <- data.frame(
  customer_id = sample(1:10, 100, replace = TRUE),
  purchase_date = sample(seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by="day"), 100, replace = TRUE),
  amount = round(runif(100, 20, 500), 2)
)

head(transactions)

snapshot_date <- as.Date("2024-01-01")

rfm_table <- transactions %>%
  group_by(customer_id) %>%
  summarise(
    recency = as.numeric(snapshot_date - max(purchase_date)), # days since last purchase
    frequency = n(),                                         # total transactions
    monetary = sum(amount)                                   # total spend
  )

head(rfm_table)


rfm_table <- rfm_table %>%
  mutate(
    R_score = ntile(-recency, 5),   # negative because lower recency = better
    F_score = ntile(frequency, 5),
    M_score = ntile(monetary, 5),
    RFM_score = paste0(R_score, F_score, M_score)
  )

head(rfm_table)


rfm_table <- rfm_table %>%
  mutate(
    segment = case_when(
      R_score >= 4 & F_score >= 4 & M_score >= 4 ~ "Champions",
      R_score >= 3 & F_score >= 3 & M_score >= 3 ~ "Loyal Customers",
      R_score >= 4 & F_score <= 2 ~ "At Risk",
      TRUE ~ "Others"
    )
  )

rfm_table


library(ggplot2)

ggplot(rfm_table, aes(x = segment, fill = segment)) +
  geom_bar() +
  labs(title = "Customer Segments by RFM") +
  theme_minimal()

## combining with LTV (Customer Lifetime Value)
rfm_table <- rfm_table %>%
  mutate(
    AOV = monetary / frequency  # Average Order Value
  )
## assuming gross margin and time (can adjust 2, 3, 5 years etc)
gross_margin <- 0.7
time_horizon <- 1  # year

rfm_table <- rfm_table %>%
  mutate(
    LTV = AOV * frequency * gross_margin * time_horizon
  )

head(rfm_table)


rfm_table <- rfm_table %>%
  mutate(
    LTV_segment = case_when(
      LTV >= quantile(LTV, 0.75) ~ "High LTV",
      LTV >= quantile(LTV, 0.50) ~ "Medium LTV",
      TRUE ~ "Low LTV"
    ),
    marketing_strategy = case_when(
      segment == "Champions" & LTV_segment == "High LTV" ~ "VIP – retention & loyalty rewards",
      segment == "At Risk" & LTV_segment == "High LTV" ~ "High-value churn risk – win-back campaign",
      segment == "Loyal Customers" & LTV_segment == "Medium LTV" ~ "Upsell & cross-sell",
      TRUE ~ "Engage with reactivation offers"
    )
  )

rfm_table


ggplot(rfm_table, aes(x = segment, y = LTV, fill = LTV_segment)) +
  geom_boxplot() +
  labs(title = "LTV Distribution Across RFM Segments") +
  theme_minimal()
