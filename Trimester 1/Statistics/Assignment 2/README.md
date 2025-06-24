
# Probability and Statistics for Data Analysis

## 📌 Assignment 1

This assignment covers fundamental probability and statistics concepts through theoretical exercises:

1. **Basic Probability Calculations**
   - Conditional probabilities, intersections, unions
   - Independence verification

2. **Geometric Distribution**
   - Rolling a fair die until a specific outcome
   - Calculating expected number of trials

3. **Bayesian Inference with Communication Errors**
   - Symbol transmission errors and posterior probabilities

4. **Transformation of Continuous Distributions**
   - Validating a conditional PDF based on truncation

5. **Poisson Process Modeling**
   - Modeling customer arrivals
   - Computing exact and cumulative Poisson probabilities

6. **Sufficient Statistic**
   - Identifying sufficient statistics for Weibull-distributed variables

7. **Confidence Intervals and Hypothesis Testing**
   - Two-sample comparisons using normal assumptions
   - Interpretation of CI and significance tests

---

## 📌 Assignment 2

This assignment applies statistical methods in R using real datasets.

### 🔬 Part 1: Drug Efficacy Study (cholesterol.txt)

- **Descriptive and Inferential Statistics**
  - Confidence intervals for cholesterol (total, by drug)
  - Paired and unpaired t-tests for glucose and cholesterol
  - Proportion CI and tests for Myalgia symptoms
  - Fisher's exact test for independence

- **Key Findings**
  - Drug A lowers cholesterol more than Drug B
  - No significant glucose differences or myalgia-drug association

---

### 📊 Part 2: Multi-variable Dataset Analysis (data2.txt)

- **ANOVA**
  - Effects of categorical variable `W` on continuous variables (Y, X1–X4)
  - Only Y and X4 significantly impacted by `W`

- **Regression Modeling**
  - Simple and multiple linear regression (Y ~ X4, Y ~ X1+X2+...+W)
  - Interaction terms examined
  - Assumptions (normality, homoscedasticity) mostly satisfied

- **Model Selection**
  - Stepwise regression used to reduce model complexity
  - Final model includes significant main and interaction terms

- **Two-Way ANOVA**
  - Examines interaction of W and quantile-based Z on Y
  - Both main effects significant; no interaction effect

- **Conclusion**
  - Variable `W` affects response variables differently
  - Modeling approaches confirm predictor significance and robustness
