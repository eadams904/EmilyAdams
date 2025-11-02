# Logistic Regression Assumption Checks in R

# Install if missing
# install.packages(c("car","ResourceSelection","pROC"))

library(car)
library(ResourceSelection)
library(pROC)

# ---------------------------
# Example dataset
# ---------------------------
data("mtcars")
df <- mtcars
df$am <- as.factor(df$am)  # binary outcome

# 1. Fit Logistic Regression
model <- glm(am ~ mpg + hp + wt, data=df, family=binomial)
summary(model)

# 2. Check binary outcome
table(df$am)

# 3. Linearity of log-odds (Box-Tidwell test)
boxTidwell(am ~ mpg + hp, data=df)

# 4. Multicollinearity (VIF)
vif(model)

# 5. Sample size check (EPV rule of thumb)
events <- sum(df$am == 1)
nonevents <- sum(df$am == 0)
cat("Events:", events, "Non-events:", nonevents, "\n")

# 6. Model fit (Hosmer-Lemeshow test + ROC AUC)
hoslem.test(model$y, fitted(model), g=10)

roc_curve <- roc(df$am, fitted(model))
plot(roc_curve, col="blue")
auc(roc_curve)