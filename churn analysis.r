## churn analysis

# Install packages if you don't have them
install.packages(c("tidyverse", "caret", "caTools", "ROCR"))

library(tidyverse)
library(caret)
library(caTools)
library(ROCR)

# Load your data
# Replace with your CSV file or data source
customer_data <- read.csv("customer_data.csv")

# Quick look
head(customer_data)
str(customer_data)

##cleaning/preprocessing data
# Convert churn to factor
customer_data$churn <- as.factor(customer_data$churn)

# Handle missing values (simple example: remove rows with NA)
customer_data <- na.omit(customer_data)

# Optionally, scale numeric variables
num_vars <- c("tenure", "monthly_spend", "num_emails_opened", "last_login_days")
customer_data[num_vars] <- scale(customer_data[num_vars])

##splitting data into test/train sets
set.seed(123)  # For reproducibility
split <- sample.split(customer_data$churn, SplitRatio = 0.7)
train <- subset(customer_data, split == TRUE)
test <- subset(customer_data, split == FALSE)

##buidling a logistic regression model
model <- glm(churn ~ tenure + monthly_spend + num_emails_opened + last_login_days,
             data = train, family = binomial)

summary(model)

##making predictions
# Predict probabilities
pred_probs <- predict(model, newdata = test, type = "response")

# Convert probabilities to class (threshold = 0.5)
pred_class <- ifelse(pred_probs > 0.5, 1, 0)
pred_class <- as.factor(pred_class)

##evaluating the model
# Confusion matrix
confusionMatrix(pred_class, test$churn)

# ROC curve and AUC
pred <- prediction(pred_probs, test$churn)
perf <- performance(pred, "tpr", "fpr")
plot(perf, col="blue", main="ROC Curve")
abline(a=0, b=1, lty=2, col="red")

auc <- performance(pred, "auc")
auc <- auc@y.values[[1]]
print(paste("AUC:", round(auc, 3)))

## checking assumptions
# Logistic regression coefficients indicate importance
coef(model)
exp(coef(model))  # Odds ratios