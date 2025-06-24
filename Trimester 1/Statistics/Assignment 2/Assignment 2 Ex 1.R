# Load data
cholesterol_data <- read.table("cholesterol.txt", header = TRUE)

# 1. (a) 99% Confidence Interval for Cholesterol values
cholesterol_values <- cholesterol_data$Cholesterol
mean_cholesterol <- mean(cholesterol_values)
std_error <- sd(cholesterol_values) / sqrt(length(cholesterol_values))

# Calculate 99% Confidence Interval
z_score <- qnorm(0.995) # for 99% confidence
ci_lower <- mean_cholesterol - z_score * std_error
ci_upper <- mean_cholesterol + z_score * std_error
cat("99% Confidence Interval for Cholesterol: [", ci_lower, ",", ci_upper, "]\n")

# Plot for Cholesterol values
hist(cholesterol_values, main = "Cholesterol Levels Distribution", xlab = "Cholesterol Levels", col = "lightblue", border = "black")

# 2. (b) 95% Confidence Interval for Cholesterol values for drugs A and B
cholesterol_A <- cholesterol_data$Cholesterol[cholesterol_data$Drug == "A"]
cholesterol_B <- cholesterol_data$Cholesterol[cholesterol_data$Drug == "B"]

# Calculate 95% CI for Cholesterol values after receiving drug A and B
ci_A <- t.test(cholesterol_A, conf.level = 0.95)$conf.int
ci_B <- t.test(cholesterol_B, conf.level = 0.95)$conf.int
cat("95% Confidence Interval for Cholesterol (Drug A):", ci_A, "\n")
cat("95% Confidence Interval for Cholesterol (Drug B):", ci_B, "\n")

# Plot for Cholesterol levels by Drug
boxplot(cholesterol_A, cholesterol_B, names = c("Drug A", "Drug B"), main = "Cholesterol Levels by Drug", ylab = "Cholesterol Levels", col = c("lightgreen", "lightcoral"))

# 3. (c) 90% Confidence Interval for the mean difference in Cholesterol values
cholesterol_diff <- cholesterol_A - cholesterol_B
mean_diff <- mean(cholesterol_diff)
std_error_diff <- sd(cholesterol_diff) / sqrt(length(cholesterol_diff))

# Calculate Confidence Interval
z_score_90 <- qnorm(0.95) # for 90% confidence
ci_diff_lower <- mean_diff - z_score_90 * std_error_diff
ci_diff_upper <- mean_diff + z_score_90 * std_error_diff
cat("90% Confidence Interval for the mean difference in Cholesterol: [", ci_diff_lower, ",", ci_diff_upper, "]\n")

# Plot for Cholesterol difference
hist(cholesterol_diff, main = "Cholesterol Difference Distribution (Drug A - Drug B)", xlab = "Cholesterol Difference", col = "lightyellow", border = "black")

# 4. (d) Hypothesis Test for H0: µA = µB, H1: µA < µB
t_test_result <- t.test(cholesterol_A, cholesterol_B, alternative = "less")
cat("Hypothesis Test (p-value):", t_test_result$p.value, "\n")

# Plot for Hypothesis Test (T-test result)
plot(density(cholesterol_A), main = "T-test: Drug A vs Drug B", xlab = "Cholesterol Levels", col = "blue")
lines(density(cholesterol_B), col = "red")
legend("topright", legend = c("Drug A", "Drug B"), col = c("blue", "red"), lwd = 2)

# 5. (e) Test for Equality of Variances of Glucose Levels
glucose_A <- cholesterol_data$Glucose[cholesterol_data$Drug == "A"]
glucose_B <- cholesterol_data$Glucose[cholesterol_data$Drug == "B"]

var_test_result <- var.test(glucose_A, glucose_B, alternative = "two.sided")
cat("Test for Equality of Variances (p-value):", var_test_result$p.value, "\n")

# 6. (f) Test for statistically significant side effect on Glucose levels
paired_t_test_result <- t.test(glucose_A, glucose_B, paired = TRUE)
cat("Paired t-test for Glucose levels (p-value):", paired_t_test_result$p.value, "\n")

# Plot for Paired t-test (Glucose levels)
plot(glucose_A, glucose_B, main = "Glucose Levels: Paired t-test", xlab = "Glucose (Drug A)", ylab = "Glucose (Drug B)", col = "purple", pch = 16)

# 7. (g) 95% Confidence Interval for Proportion of Myalgia Symptoms
myalgia_data <- cholesterol_data$Myalgia
myalgia_yes <- sum(myalgia_data == "Yes")
myalgia_no <- sum(myalgia_data == "No")
proportion_myalgia <- myalgia_yes / (myalgia_yes + myalgia_no)

# Confidence Interval for Proportion
se_proportion <- sqrt(proportion_myalgia * (1 - proportion_myalgia) / (myalgia_yes + myalgia_no))
ci_proportion_lower <- proportion_myalgia - qnorm(0.975) * se_proportion
ci_proportion_upper <- proportion_myalgia + qnorm(0.975) * se_proportion
cat("95% Confidence Interval for Proportion of Myalgia Symptoms: [", ci_proportion_lower, ",", ci_proportion_upper, "]\n")

# Plot for Myalgia Proportion
barplot(c(proportion_myalgia, 1 - proportion_myalgia), names.arg = c("Myalgia", "No Myalgia"), main = "Proportion of Myalgia Symptoms", col = c("skyblue", "salmon"))

# 8. (h) Hypothesis Test for Myalgia Proportion Greater than 5%
prop_test_result <- prop.test(myalgia_yes, myalgia_yes + myalgia_no, alternative = "greater", p = 0.05)
cat("Hypothesis Test for Myalgia Proportion > 5% (p-value):", prop_test_result$p.value, "\n")

# 9. (i) Test for Independence between Drug and Myalgia Symptoms
# Create contingency table for Drug and Myalgia Symptoms
table_drug_myalgia <- table(cholesterol_data$Drug, cholesterol_data$Myalgia)

# Chi-Square Test for Independence between Drug and Myalgia Symptoms
chi_square_test_result <- chisq.test(table_drug_myalgia)

# Display Chi-Square Test p-value
cat("Chi-Square Test for Independence (p-value):", chi_square_test_result$p.value, "\n")

# Plot for Chi-Square Test (Drug vs Myalgia Symptoms)
barplot(table_drug_myalgia, beside = TRUE, col = c("lightgreen", "lightcoral"), legend = TRUE, main = "Drug vs Myalgia Symptoms", xlab = "Drug", ylab = "Count")

# 10. (j) 95% Confidence Interval for Mean Difference in Glucose Levels (Myalgia Yes vs No)
glucose_myalgia_yes <- glucose_A[myalgia_data == "Yes"]
glucose_myalgia_no <- glucose_A[myalgia_data == "No"]

#Use t-test to compare the two groups' glucose levels:
t_test_glucose_result <- t.test(glucose_myalgia_yes, glucose_myalgia_no)
cat("T-test for Mean Difference in Glucose Levels (p-value):", t_test_glucose_result$p.value, "\n")

# 95% Confidence Interval for the mean difference
ci_glucose_lower <- t_test_glucose_result$conf.int[1]
ci_glucose_upper <- t_test_glucose_result$conf.int[2]
cat("95% Confidence Interval for Mean Difference in Glucose Levels (Myalgia Yes vs No): [", ci_glucose_lower, ",", ci_glucose_upper, "]\n")

# Plot for Glucose Levels Difference
boxplot(glucose_myalgia_yes, glucose_myalgia_no, names = c("Myalgia Yes", "Myalgia No"), main = "Glucose Levels by Myalgia Symptoms", ylab = "Glucose Levels", col = c("lightgreen", "lightcoral"))
