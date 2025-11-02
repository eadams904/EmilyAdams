## multiple regression on marketing channels for customer segmentation

# Example dataset
set.seed(123)
marketing_data <- data.frame(
  customer_id = 1:100,
  recency = sample(1:100, 100, replace = TRUE),       # days since last purchase
  frequency = sample(1:20, 100, replace = TRUE),     # number of purchases
  monetary = sample(50:1000, 100, replace = TRUE),   # total spend
  email = sample(0:10, 100, replace = TRUE),         # number of email interactions
  social = sample(0:10, 100, replace = TRUE),        # number of social interactions
  paid_ads = sample(0:10, 100, replace = TRUE),      # number of paid ads exposures
  referral = sample(0:5, 100, replace = TRUE)        # number of referrals
)

marketing_data <- marketing_data %>%
  mutate(rfm_score = 0.3*recency + 0.4*frequency + 0.3*monetary)

# Multiple regression
model <- lm(rfm_score ~ email + social + paid_ads + referral, data = marketing_data)

# Summary of results
summary(model)

#Checks linearity, normality of residuals, Homoscedasticity, Outliers/influential points
par(mfrow=c(2,2))
plot(model)

marketing_data$predicted_rfm <- predict(model, marketing_data)

# Example: segment based on predicted RFM
marketing_data <- marketing_data %>%
  mutate(predicted_segment = case_when(
    predicted_rfm > quantile(predicted_rfm, 0.75) ~ "High Value",
    predicted_rfm > quantile(predicted_rfm, 0.50) ~ "Medium Value",
    TRUE ~ "Low Value"
  ))

table(marketing_data$predicted_segment)


