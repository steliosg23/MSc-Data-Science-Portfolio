# Numerical Optimization and Large Scale Linear Algebra

This directory contains the coursework and assignments for the *Numerical Optimization and Large Scale Linear Algebra* course in the MSc in Data Science program.

## Assignment 1 – Matrix Conditioning and Conjugate Gradient Method

In this assignment, we explored the effect of matrix conditioning on numerical solutions and implemented the Conjugate Gradient (CG) method. Tasks included:

- Investigating condition numbers of various matrices (Hilbert, Toeplitz, random).
- Comparing performance of CG vs. direct solvers.
- Solving large linear systems efficiently using preconditioned CG.

### Key Skills
- Linear system solvers
- Condition number analysis
- Python + NumPy/SciPy implementation

## Assignment 2 – QR Decomposition, Least Squares, and Logistic Regression

This project covered:

- Solving linear least squares problems using QR decomposition.
- Applying logistic regression with gradient descent to real datasets.
- Visualizing convergence behavior and model decision boundaries.

### Key Skills
- QR decomposition
- Logistic regression from scratch
- Model evaluation and visualization

## Assignment 3 – PageRank via Power Method and Gauss-Seidel

This assignment focused on computing PageRank for the Stanford Web using two approaches:

- **Power Method:** Iterative eigenvector computation.
- **Gauss-Seidel Solver:** Solving the corresponding linear system.

Both methods were benchmarked for speed and accuracy under:
- Damping factor α = 0.85 and α = 0.99
- Detailed comparison of node rankings and convergence rates

### Key Insights
- Gauss-Seidel converged in fewer iterations but similar runtime.
- Higher α leads to significantly slower convergence.
- Top 50 nodes were nearly identical between methods.

### Tools Used
- Sparse matrices (CSR)
- NetworkX for visualization
- Timing and convergence evaluation

---

Each report includes code, implementation details, and extensive performance analysis.
