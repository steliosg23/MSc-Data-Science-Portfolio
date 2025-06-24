# Numerical Optimization and Large-Scale Linear Algebra
### MSc in Data Science – Athens University of Economics and Business  
**Author**: Stelios Giagkos (f3352410)

---

## 📘 Assignment Overview

This repository contains three assignments for the course **Numerical Optimization and Large-Scale Linear Algebra**, focusing on practical applications of numerical methods in optimization, machine learning, and network analysis.

---

## 🟦 Assignment 1: Illumination Optimization using Least Squares

### 📌 Objective
Determine the optimal power levels for 10 ceiling-mounted lamps to achieve uniform illumination across a 25×25 grid (625 pixels) using linear least squares.

### ⚙️ Methodology
- **Formulation**: Solve the least squares problem \( \hat{p} = \arg\min_p \|Ap - l_{des}\|_2^2 \), where A is the illumination matrix.
- **Implementation**:
  - Compute 3D distance matrix between lamps and pixels.
  - Construct illumination matrix using inverse-square law.
  - Compare three strategies:
    - All lamps at power 1.
    - Unconstrained least squares.
    - Constrained least squares with total power budget.
- **RMSE Evaluation**: Root Mean Squared Error used to compare lighting patterns.

### 📊 Results
| Method                          | Total Power | RMSE   |
|---------------------------------|-------------|--------|
| All Lamps at Power 1            | 10.0        | 0.246  |
| Least Squares (Unconstrained)   | 10.86       | 0.146  |
| Least Squares (Constrained, p ≥ 0, ∑p=10) | 10.0        | 0.160  |

### 🧠 Advanced
- Optimization of lamp **positions** using random sampling and RMSE minimization to improve lighting uniformity.

---

## 🟨 Assignment 2: Classification of Handwritten Digits using SVD

### 📌 Objective
Develop a classification model for handwritten digits (0–9) using **Singular Value Decomposition (SVD)** and analyze how many singular vectors are needed per digit.

### ⚙️ Methodology
- Split dataset into training and test sets.
- For each digit class:
  - Perform SVD on training samples.
  - Classify test samples by computing residual errors from projections.
- **Tune** number of singular vectors (from 5 to 20).
- Apply **kernel transformations** (RBF, Gaussian, Laplacian) to enhance features.

### 📈 Results
- Best accuracy: **94%** on the test set using **20 singular vectors**.
- Individual digit accuracy varied: digit 5 was the hardest to classify, while 0, 1, and 6 were easier.
- Confusion matrix and classification report included.
- Kernelized SVD also explored with visualization and tuning of vector count.

---

## 🟥 Assignment 3: PageRank Computation and Method Comparison

### 📌 Objective
Compute the **PageRank vector** of Stanford web pages using:
1. The **Power Method**
2. A **Linear System Solver (Gauss-Seidel)**

### ⚙️ Methodology
- Use damping factor \( \alpha = 0.85 \) and later \( \alpha = 0.99 \).
- Apply stopping threshold \( \tau = 10^{-8} \).
- Construct sparse matrix representations and rank top-50 nodes.

### ⏱ Performance Comparison
| Method        | α = 0.85 | α = 0.99 |
|---------------|----------|----------|
| Power Method  | 91 iterations, ~6.35s avg | 1392 iterations, ~108.1s avg |
| Gauss-Seidel  | 62 iterations, ~6.26s avg | 968 iterations, ~79.6s avg  |

### 🔍 Observations
- Both methods yield nearly identical PageRank vectors.
- Gauss-Seidel converges faster (fewer iterations).
- Ranking shifts observed when α changes from 0.85 to 0.99, highlighting sensitivity.

---

