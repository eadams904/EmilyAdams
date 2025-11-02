#customer segmentation using regression analysis and RFM
##what channels affect RFM (recency, frequency, monetary): email, social, paids ads, and/or referrals
library(dplyr)

# Suppose marketing_data already has rfm_score
marketing_data <- marketing_data %>%
  mutate(segment = case_when(
    rfm_score > quantile(rfm_score, 0.75) ~ "High",
    rfm_score > quantile(rfm_score, 0.50) ~ "Medium",
    TRUE ~ "Low"
  ))

# Convert to factor
marketing_data$segment <- factor(marketing_data$segment, levels = c("Low","Medium","High"))

# Multiple regression with interaction terms
model_interaction <- lm(rfm_score ~ email*social + paid_ads*referral, data = marketing_data)

summary(model_interaction)

##predicts categorical segment
library(nnet)

# Multinomial logistic regression
multinom_model <- multinom(segment ~ email + social + paid_ads + referral, data = marketing_data)

summary(multinom_model)

# Predict probabilities
pred_probs <- predict(multinom_model, type = "probs")

# Add to dataframe
marketing_data <- cbind(marketing_data, pred_probs)

head(marketing_data)
