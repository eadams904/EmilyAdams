# -----------------------------
# Load libraries
# -----------------------------
library(dplyr)
library(ggplot2)
library(cluster)
library(factoextra)  # for cluster visualization

# -----------------------------
# Sample customer data
# -----------------------------
set.seed(123)
customer_data <- data.frame(
  customer_id = 1:1000,
  recency = runif(1000, 1, 365),
  frequency = sample(1:50, 1000, replace = TRUE),
  monetary = runif(1000, 50, 1000)
)

# -----------------------------
# Step 1: Normalize the data
# -----------------------------
customer_scaled <- customer_data %>%
  select(recency, frequency, monetary) %>%
  scale()

# -----------------------------
# Step 2: Determine optimal number of clusters
# -----------------------------
# Using Elbow method
fviz_nbclust(customer_scaled, kmeans, method = "wss") + 
  ggtitle("Elbow Method for Optimal k")

# Using Silhouette method
fviz_nbclust(customer_scaled, kmeans, method = "silhouette") + 
  ggtitle("Silhouette Method for Optimal k")

# -----------------------------
# Step 3: Apply K-means clustering
# -----------------------------
# Suppose we choose 3 clusters based on above plots
set.seed(123)
kmeans_result <- kmeans(customer_scaled, centers = 3, nstart = 25)

# Add cluster labels to original data
customer_data$cluster <- factor(kmeans_result$cluster)

# -----------------------------
# Step 4: Summarize clusters
# -----------------------------
cluster_summary <- customer_data %>%
  group_by(cluster) %>%
  summarise(
    count = n(),
    avg_recency = mean(recency),
    avg_frequency = mean(frequency),
    avg_monetary = mean(monetary)
  )
print(cluster_summary)

# -----------------------------
# Step 5: Visualize clusters
# -----------------------------
fviz_cluster(kmeans_result, data = customer_scaled,
             geom = "point",
             ellipse.type = "norm",
             palette = "jco",
             ggtheme = theme_minimal())