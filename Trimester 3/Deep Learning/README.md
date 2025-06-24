# 🎓 Respiratory Sound Recognition Using Deep Learning

**Author**: Giagkos Stylianos  
**Program**: MSc in Data Science, Athens University of Economics and Business (AUEB)  
**Supervisor**: Professor Themos Stafylakis  

---

## 🧠 Abstract

This project investigates the automated classification of respiratory sounds using deep learning. It evaluates three architectures—**CustomCNN**, **ResNet50**, and **DenseNet121**—on spectrogram representations of auscultation recordings. Despite promising general performance from transfer learning models, the results highlight ongoing challenges in class imbalance and rare class detection.

---

## ⚙️ Methodology

### 🔊 Preprocessing Pipeline
- **Resampling**: All audio signals downsampled to 4kHz.
- **Baseline Removal**: DFT-based filtering (K=8) removes low-frequency noise.
- **Windowing**: 5-second segments with 50% overlap.
- **Augmentation**: White noise injection, pitch shift, time shift.
- **Spectrograms**: Log-mel spectrograms of size 224×224.

### 🧩 Models
- **CustomCNN**: 3-layer convolutional network trained from scratch.
- **ResNet50**: Pretrained on ImageNet, adapted for 1-channel inputs.
- **DenseNet121**: Pretrained with dense blocks and feature reuse.
- **CORAL** (optional): Domain adaptation via covariance alignment.

### 🏋️ Training & Evaluation
- Loss: Weighted `CrossEntropyLoss`
- Optimizer: `AdamW` or `SGD`
- Scheduler: `ReduceLROnPlateau`
- Metrics: Accuracy, Macro F1-score, ROC AUC
- Early Stopping: after 6 epochs of stagnation

---

## 📊 Results Summary

### Baseline Experiment (AdamW)
| Model       | Accuracy | Macro F1 | ROC AUC |
|-------------|----------|----------|---------|
| CustomCNN   | 59%      | 0.56     | 0.32    |
| ResNet50    | 71%      | 0.62     | 0.28    |
| DenseNet121 | 72%      | 0.59     | 0.33    |

### Fine-tuning with SGD & Regularization
| Model       | Accuracy | Macro F1 | ROC AUC |
|-------------|----------|----------|---------|
| CustomCNN   | 52%      | 0.46     | 0.54    |
| ResNet50    | 74%      | 0.67     | 0.57    |
| DenseNet121 | 66%      | 0.61     | 0.32    |

### CORAL Domain Adaptation
| Model       | Accuracy | Macro F1 | ROC AUC |
|-------------|----------|----------|---------|
| CustomCNN   | 61%      | 0.55     | 0.28    |
| ResNet50    | 68%      | 0.52     | 0.37    |
| DenseNet121 | 67%      | 0.41     | **0.81** |

---

## 💡 Recommendations

- Apply **focal loss** or **class-balanced loss** to improve rare class detection.
- Introduce **GANs** or **SMOTE** for data augmentation in underrepresented classes.
- Explore **threshold calibration** and **DANN** (adversarial domain adaptation).
- For deployment, consider **model compression** and **quantization**.

---

## ℹ️ Acknowledgements

Special thanks to Professor Themos Stafylakis for his guidance.  
Editorial and technical assistance by OpenAI's ChatGPT.  
This work was conducted as part of the MSc in Data Science program at AUEB.

---
