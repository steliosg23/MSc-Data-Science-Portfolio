# 🧠 Text Analytics - MSc Data Science AUEB 2024–2025  

This repository includes all completed assignments for the **Text Analytics** course, featuring implementations in classic NLP (e.g., N-gram models) and modern deep learning (CNNs, RNNs, Transformers) for text classification tasks. Each assignment explores various techniques, models, and evaluation metrics relevant to Natural Language Processing.

---

## 📁 Assignments Overview

### 🔹 Assignment 1: N-Gram Language Models  
> Language Modeling, Perplexity, and Spelling Correction

- **Corpus**: NLTK Reuters
- **Techniques**:
  - Bigram and Trigram models
  - Laplace & Additive-α smoothing
  - Perplexity and Cross-Entropy calculation
  - Auto-completion with nucleus sampling
  - Context-aware spelling correction with Levenshtein Distance + Beam Search
- **Evaluation**:
  - Word Error Rate (WER)
  - Character Error Rate (CER)

📎 Report: `1st assignment F3352405-F3352410 (N-gram language models).pdf`  
📓 Code: [Colab Notebook](https://colab.research.google.com/drive/1QPik6-YpZnA_pQxvZbSN6fxChK3B2BDV)

---

### 🔹 Assignment 2: MLP for Fake News Classification  
> Implementing a Multilayer Perceptron from Scratch

- **Dataset**: FakeNewsNet (Fake.csv, True.csv)
- **Baseline**: DummyClassifier & Logistic Regression
- **Models**:
  - Custom MLPs with TF-IDF, Word2Vec, GloVe embeddings
  - Dropout, Batch Normalization, ReLU
- **Metrics**:
  - Precision, Recall, F1, PR AUC (per class and macro-averaged)
  - Training/Validation loss curves

📎 Report: `2nd assignment F3352405-F3352410.pdf`

---

### 🔹 Assignment 3: Bidirectional RNNs with Attention  
> Deep Recurrent Models for Text Classification

- **Architecture**:
  - Bi-directional GRU/LSTM (stacked)
  - Self-attention layer (MLP or Dense)
  - Optional character-level RNN embedding
- **Comparison**:
  - Dummy, MLP (Assignment 2), Probabilistic Baseline
  - RNN vs GRU vs LSTM vs LSTM+GMP
- **Outcome**:
  - LSTM_GMP and RandomInit achieved perfect performance
  - High interpretability via attention scores

📎 Report: `PDFText_Analytics_Assignment_3.pdf`

---

### 🔹 Assignment 4: CNNs for Text Classification  
> Stacked CNNs with n-gram filters and residual connections

- **Model Variants**:
  - BigramCNN, TrigramCNN, FourgramCNN
  - Attention-enhanced CNNs
  - Random initialization vs frozen pre-trained embeddings
  - Global Max Pooling (GMP)
- **Best Model**: `FourgramCNN_GMP`
  - Accuracy/F1/PR AUC: 100% across all subsets
- **Bonus**: Ensemble strategies discussed (majority voting, temporal averaging)

📎 Report: `Report.pdf`

---

### 🔹 Assignment 5: Fine-Tuned BERT & Transformers  
> Transfer Learning for Sentiment Classification

- **Models**:
  - `bert-base-uncased`
  - `distilroberta-base`
  - `xlm-roberta-base`
- **Training**:
  - Used HuggingFace Transformers
  - Performance monitored on dev set for early stopping
- **Results**:
  - Accuracy, F1, and PR AUC ≥ 99.9%
  - BERT-like models outperform all previous baselines

📎 Report: (Final pages of) `Report.pdf`

---

## 🔧 Technologies Used

- Python, PyTorch, Keras/TensorFlow
- Scikit-learn, Gensim, NLTK, HuggingFace Transformers
- Google Colab for execution & training
- Matplotlib & Seaborn for visualization

---

## 📊 Evaluation Metrics

Each model was evaluated using:
- Accuracy
- Precision / Recall / F1 (per class and macro)
- PR AUC (per class and macro)
- Word Error Rate (Assignment 1)
- Character Error Rate (Assignment 1)

---

## 📚 Authors

- **Stylianos Giagkos** ([@steliosg23](https://github.com/steliosg23))  
- **Nikolaos Vitsentzatos**

---
