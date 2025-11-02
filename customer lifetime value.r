##customer lifetime value 
library(dplyr)
library(lubridate)

set.seed(123)
transactions <- data.frame(
  customer_id = sample(1:5, 20, replace = TRUE),
  purchase_date = sample(seq(as.Date("2022-01-01"), as.Date("2023-12-31"), by="day"), 20, replace = TRUE),
  purchase_amount = round(runif(20, 20, 200), 2)
)

head(transactions)

ltv_data <- transactions %>%
  group_by(customer_id) %>%
  summarise(
    total_revenue = sum(purchase_amount),
    avg_purchase_value = mean(purchase_amount),
    purchase_frequency = n() / as.numeric(difftime(max(purchase_date), min(purchase_date), units="weeks")/52.25 + 1),
    lifespan_years = as.numeric(difftime(max(purchase_date), min(purchase_date), units="weeks")/52.25 + 1)
  )

ltv_data <- ltv_data %>%
  mutate(
    LTV = avg_purchase_value * purchase_frequency * lifespan_years
  )

ltv_data


mean(ltv_data$LTV)

##segments into high medium low spenders

head(ltv_data)


ltv_data <- ltv_data %>%
  mutate(
    segment = case_when(
      LTV >= quantile(LTV, 0.75) ~ "High Spender",
      LTV >= quantile(LTV, 0.50) ~ "Medium Spender",
      TRUE ~ "Low Spender"
    )
  )


segment_summary <- ltv_data %>%
  group_by(segment) %>%
  summarise(
    avg_LTV = mean(LTV),
    total_revenue = sum(total_revenue),
    customers = n()
  )

segment_summary


library(ggplot2)

ggplot(ltv_data, aes(x = segment, y = LTV, fill = segment)) +
  geom_boxplot(alpha = 0.6) +
  labs(title = "Customer Segments by LTV", y = "Lifetime Value") +
  theme_minimal()
