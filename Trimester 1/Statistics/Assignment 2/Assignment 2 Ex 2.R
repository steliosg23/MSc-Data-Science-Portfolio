# Load necessary libraries
library(ggplot2)
library(GGally)

# Load the data
data <- read.table("data2.txt", header = TRUE)

# Check for missing values and data structure
cat("\nChecking structure of data and missing values:\n")
str(data)
sum(is.na(data))  # Check for missing values

# If there are NA values, we can remove them or handle them
data <- na.omit(data)

# (a) Run the parametric one-way ANOVA for each of the continuous variables on the categorical variable W.

# (i) Graphical representation using boxplots
# Create boxplots for each continuous variable against W
ggplot(data, aes(x = W, y = Y)) + 
  geom_boxplot() + labs(title = "Boxplot of Y vs W", x = "W", y = "Y")
ggplot(data, aes(x = W, y = X1)) + 
  geom_boxplot() + labs(title = "Boxplot of X1 vs W", x = "W", y = "X1")
ggplot(data, aes(x = W, y = X2)) + 
  geom_boxplot() + labs(title = "Boxplot of X2 vs W", x = "W", y = "X2")
ggplot(data, aes(x = W, y = X3)) + 
  geom_boxplot() + labs(title = "Boxplot of X3 vs W", x = "W", y = "X3")

# Ensure X4 is being plotted correctly, check if it is numeric
cat("\nChecking the structure of X4:\n")
str(data$X4)  # Check if X4 is numeric

# If X4 is numeric, proceed with plotting
if (is.numeric(data$X4)) {
  ggplot(data, aes(x = W, y = X4)) + 
    geom_boxplot() + labs(title = "Boxplot of X4 vs W", x = "W", y = "X4")
} else {
  cat("\nX4 is not numeric. Please check the data format.\n")
}

# (ii) Perform ANOVA for each continuous variable
anova_Y <- aov(Y ~ W, data = data)
anova_X1 <- aov(X1 ~ W, data = data)
anova_X2 <- aov(X2 ~ W, data = data)
anova_X3 <- aov(X3 ~ W, data = data)
anova_X4 <- aov(X4 ~ W, data = data)

# Display ANOVA summaries for each variable
cat("\nANOVA results for Y\n")
summary(anova_Y)
cat("\nANOVA results for X1\n")
summary(anova_X1)
cat("\nANOVA results for X2\n")
summary(anova_X2)
cat("\nANOVA results for X3\n")
summary(anova_X3)
cat("\nANOVA results for X4\n")
summary(anova_X4)

# (iii) Check the assumptions (normality and homogeneity of variances)
cat("\nChecking assumptions for ANOVA\n")
par(mfrow = c(2, 2))
plot(anova_Y, which = 1:2)  # Normality check (Q-Q plot, residuals)
plot(anova_Y, which = 3)  # Homogeneity of variances (Residuals vs Fitted)

# (b) Scatter-plot matrix of Y, X1, X2, X3, X4 with different levels of W using color
cat("\nScatter-plot matrix of Y, X1, X2, X3, X4 by W\n")
ggpairs(data, mapping = aes(color = W)) + 
  labs(title = "Scatter Plot Matrix of Y, X1, X2, X3, X4 by W")

# (c) Regression model of Y on X4
cat("\nRegression model of Y on X4\n")
model_Y_X4 <- lm(Y ~ X4, data = data)
summary(model_Y_X4)

# (d) Regression model of Y on all variables, including interactions with W
cat("\nRegression model of Y on all variables (including interactions with W)\n")
model_Y_all <- lm(Y ~ X1 * W + X2 * W + X3 * W + X4 * W, data = data)
summary(model_Y_all)

# (e) Examine the regression assumptions
cat("\nExamining regression assumptions\n")
par(mfrow = c(2, 2))
plot(model_Y_all)  # Residuals plots for checking assumptions

# Normality of residuals test using Shapiro-Wilk
shapiro_test <- shapiro.test(residuals(model_Y_all))
cat("\nShapiro-Wilk normality test for residuals:\n")
shapiro_test

# (f) Stepwise regression approach using AIC
cat("\nStepwise regression approach using AIC\n")
stepwise_model <- step(model_Y_all)
summary(stepwise_model)

# (g) Point estimate and 95% confidence interval for the prediction of Y when:
# (X1, X2, X3, X4, W) = (120, 30, 10, 90, B)
cat("\nPoint estimate and 95% confidence interval for the prediction of Y\n")
new_data <- data.frame(X1 = 120, X2 = 30, X3 = 10, X4 = 90, W = "B")
predict(stepwise_model, new_data, interval = "confidence")

# (h) Create a categorical variable Z based on the quantiles of X4, and provide the contingency table
cat("\nCreating a categorical variable Z based on the quantiles of X4\n")
data$Z <- cut(data$X4, breaks = quantile(data$X4, probs = 0:3 / 3), labels = c("Low", "Medium", "High"))
cat("\nContingency table of Z and W:\n")
table(data$Z, data$W)

# (i) Run the parametric two-way ANOVA of Y on W and Z, including the interaction term
cat("\nRunning two-way ANOVA of Y on W and Z, including the interaction term\n")
anova_two_way <- aov(Y ~ W * Z, data = data)
summary(anova_two_way)

# Check the assumptions of the two-way ANOVA
cat("\nChecking assumptions of two-way ANOVA\n")
par(mfrow = c(2, 2))
plot(anova_two_way)
