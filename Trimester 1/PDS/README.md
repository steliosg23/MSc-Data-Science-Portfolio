
# Practical Data Science – Assignment Projects

This repository contains project submissions for the *Practical Data Science* course, as part of the MSc in Data Science at AUEB. The projects reflect hands-on experience in real-world data analysis, unsupervised learning, image annotation, and advanced machine learning.

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

## 📌 Project A3 – Sidewalk Obstruction Detection via Unsupervised Learning

This project revolved around image data analysis and urban feature detection using unsupervised learning techniques. The steps included:

### A. Image Annotation
- Manual annotation of 7 sidewalk obstruction categories
  - Parked vehicles
  - Narrow sidewalks
  - Uneven pavement
  - Natural elements
  - Miscellaneous
  - Blocked crossings
  - Environmental debris

### B. Dataset Exploration & Preprocessing
- Utilized the “GSV Cities” Kaggle dataset
- Sampled and preprocessed 11,309 images
- Merged city-specific metadata
- Cleaned duplicates and visualized distributions

### C. Feature Extraction & Clustering
- Pretrained **ResNet101** for feature extraction
- PCA dimensionality reduction
- Applied **K-means clustering** and evaluated via:
  - Silhouette Score
  - Gap Statistic
- Descriptive clustering of city images
  - e.g., suburban areas, urban cores, tree-lined streets

### D. Final Evaluation
- Cohen’s Kappa used to measure agreement in annotations
- Athens images grouped with clusters representing dense urban areas (London, Osaka)
- Map visualizations and cluster interpretability included

---

## 📎 File Structure

```
📁 Project A1.pdf         # Feature Engineering and EDA Report
📁 Project A3.pdf         # Full report on Sidewalk Obstruction Clustering
📁 README.md              # This file
```
