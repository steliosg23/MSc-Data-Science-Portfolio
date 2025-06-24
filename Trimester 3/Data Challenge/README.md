# Data Science Challenge – INF342: Product Classification on Amazon

**Course**: Practical Data Science  
**Program**: MSc in Data Science, Athens University of Economics and Business  
**Project**: INF342 – Product Classification Challenge

---

## 🧠 Project Overview

The goal of the project was to develop a classification model for Amazon sports products using **graph structure**, **textual descriptions**, and **metadata**. The dataset included product relationships (co-viewed graph), product titles, descriptions, prices, and category labels.

---

## 🔧 Methodology

The classification task was approached using:

- **Text Preprocessing**: TF-IDF vectorization of product descriptions and titles.
- **Graph Features**: Computation of centrality metrics and PageRank from the product co-viewed network.
- **Dimensionality Reduction**: Truncated SVD for compressing text embeddings.
- **Feature Engineering**: Merging graph-based and textual features.
- **Modeling**: Training ensemble classifiers (Random Forest, XGBoost) and logistic regression for multi-class classification.
- **Evaluation**: Using accuracy, macro-F1, and confusion matrix to assess performance.

---

## 📊 Results

- Best model achieved:
  - **Accuracy**: ~82%
  - **Macro F1-score**: ~0.79

The combination of **graph embeddings + textual features** yielded superior results compared to using either individually.

---

## 🗂️ Project Structure

- `product_graph.ipynb`: Constructs and analyzes the product co-viewed graph.
- `text_vectorization.ipynb`: TF-IDF, SVD, and cosine similarity visualizations.
- `feature_fusion_modeling.ipynb`: Combines all features and performs final classification.
- `final_predictions.csv`: File with predicted product categories for the test set.
- `report.pdf`: Contains the methodology, results, and key visualizations.

---

## 📦 Tools & Libraries

- `scikit-learn`, `xgboost`, `networkx`, `matplotlib`, `seaborn`, `pandas`, `numpy`, `nltk`

---

## 📌 Conclusion

By combining textual understanding and network science, this project effectively addressed a real-world e-commerce classification challenge. The methodology is robust, scalable, and interpretable, with room for extension into deep learning or BERT-based text embeddings in future work.

---

## 📚 Authors

- **Stylianos Giagkos** ([@steliosg23](https://github.com/steliosg23))  
- **Kazantzis Gerasimos**
- **Vougioukos Dimitris**

---
