# Practical Data Science – Assignment Portfolio

This repository contains the complete set of assignments submitted for the **Practical Data Science** course, part of the MSc in Data Science at Athens University of Economics and Business. Each project emphasizes a different component of the data science pipeline — from data preprocessing and feature engineering to advanced NLP modeling and unsupervised learning.

---

## 📌 Project A1 – Exploratory Data Analysis & Feature Engineering

This assignment focused on applying foundational data science techniques including:

- Exploratory data analysis (EDA)
- Handling missing data
- Data transformation and visualization
- Feature engineering and selection

Key tasks included:
- Descriptive statistics and histogram creation
- Identifying data distribution patterns
- Applying transformations (e.g., normalization)
- Encoding categorical variables
- Building a clean and enriched dataset for future modeling

---

## 📌 Project A2 – Food Hazard Detection Challenge (SemEval 2025 Task 9)

This project tackled the **Food Hazard Detection Challenge**, a real-world NLP competition requiring the classification of food safety-related incidents based on short titles and full descriptions.

### Objectives:
- Classify incidents into:
  - Hazard-category
  - Product-category
  - Specific hazard
  - Specific product

### Methods:
- **Fine-tuned Transformer Models:**
  - **SciBERT** for scientific hazard-category/product-category tasks (best Macro F1: 0.75)
  - **BioBERT** for fine-grained hazard/product tasks (best Macro F1: 0.47)
  - **PubMedBERT** for benchmarking and comparison
- **LightGBM Models** for feature-based tabular classification
- **Data Augmentation** via back translation and resampling
- **Evaluation** using classification metrics and leaderboard performance on CodaLab

### Highlights:
- Demonstrated deep transfer learning with domain-specific transformers
- Addressed class imbalance through augmentation and analysis
- Participated in SemEval competition with top Macro F1 of 0.75 (Task 1)

---

## 📌 Project A3 – Sidewalk Obstruction Detection via Unsupervised Learning

This project revolved around image data analysis and urban feature detection using unsupervised learning techniques. The steps included:

### A. Dataset Preparation & Exploration
- Used the **GSV Cities** Kaggle dataset
- Sampled and preprocessed 11,309 images across global cities
- Merged city-specific metadata and cleaned annotations

### B. Feature Extraction & Clustering
- Used pretrained **ResNet101** for deep feature extraction
- Applied **PCA** for dimensionality reduction
- Clustering via **K-Means**, evaluated with Silhouette Score and Gap Statistic

### C. Results & Interpretation
- Cohen’s Kappa used to validate annotations
- Athens images grouped with clusters representing dense urban areas
- Created map visualizations of cluster distributions across cities

---

## 📎 File Structure

```
📁 Project A1.pdf         # Feature engineering and EDA
📁 Project A2 README.md   # Food Hazard Detection NLP Challenge
📁 Project A3.pdf         # Clustering and image analysis
📁 README.md              # This file
```

---