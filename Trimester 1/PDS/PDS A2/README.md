---
# Master in Data Science AUEB 2024-2025
## SemEval 2025 Task 9 - The Food Hazard Detection Challenge
### Practical Data Science - Assignment 2
### Stylianos Giagkos f3352410

---
![Project Workflow](Plots%20and%20Schemas/Infographic.png)


---
This repository contains the solution for the **Food Hazard Detection Challenge**. The challenge involves classifying food safety-related incidents based on short titles and long descriptions. The solution leverages both **Finetuned Pretrained Bert Models** and **LightGBM (LGBM)** models for classification into hazard-category, product-category, hazard, and product classifications.

### ⬛ **Insights**

The use of pretrained BERT models in this project stems from my **MEng thesis** at Democritus University of Thrace, titled **"Creation of Datasets Using Biological Databases and Application of Machine Learning Algorithms to Them."** .The thesis focused on a comparative study of **pretrained BERT** models in correlating genes and metabolites within medical literature. This experience laid the groundwork for applying BERT-based models to the Food Hazard Detection Challenge, which led to the decision to switch from PubMedBERT to **SciBERT** and  **BioBERT** due to the stacking loss observed in the product class. This change resulted in significantly lower loss values for all classes, indicating better generalization, as evidenced by the best submission results in the entire project: **0.75 Macro F1** for Hazard-category, Product-category, and **0.47 Macro F1** for Hazard, Product.

---
## ℹ️ Systems methodology

#### 🟢 Advanced Model Method : Fine-tuning Pretrained BERT Models

This method involves a two-step process:
1. **Pretraining**: BERT models like PubMedBERT, SciBERT, or BioBERT are pretrained on large corpora using the masked language modeling objective. This helps the model learn contextual embeddings by predicting missing words in sentences.
2. **Fine-tuning**: The pretrained model is then fine-tuned on domain-specific data, such as food hazard datasets. A classifier is added on top of BERT to adapt it for specific tasks, like hazard-category or product-category classification. During this stage, both the classifier and BERT layers are updated to optimize task-specific performance.

![Fine-tuning Pretrained BERT Models](Plots%20and%20Schemas/finetuning_schema.png)


#### 🟢 Basic Model Method : LightGBM

LightGBM is a gradient-boosting framework based on decision trees:
- It builds trees sequentially, where each tree attempts to correct the errors made by the previous ones.
- The framework uses histogram-based computation and a leaf-wise growth strategy to optimize training speed and memory usage.
- By focusing on minimizing residuals and aggregating predictions across all trees, LightGBM achieves high accuracy and efficiency, making it suitable for large-scale classification problems.

![LightGBM](Plots%20and%20Schemas/LightGBM_schema.png)

---
## ℹ️ Overview

### Project Workflow:
1. **Exploratory Data Analysis (EDA)**: Data cleaning, exploration, and visualization.
2. **Modeling**: Three different approaches are used for classification:
   - **Finetuned SciBERT**: SciBERT is a BERT model trained on scientific text, the model is now Fine-tuned on the dataset to classify food hazard-related texts..
   - **Finetuned BioBERT**: While pretrained on different biomedical corpora, the model is now Fine-tuned on the dataset to classify food hazard-related texts.
   - **Finetuned PubMedBERT**: Model was pretrained on large PubMed abstracts, and is now Fine-tuned on the dataset to classify food hazard-related texts.
   - **LightGBM**: A gradient boosting model for classification based on features derived from the data.
4. **Evaluation**: All models are evaluated on performance metrics such as accuracy, precision, recall, and F1-score.
5. **Training and Submission**: Generation of final predictions based on the final optimal model and submission in the required format on CodaLab competition.

### Subtasks (Performed Separately for Title and Text):
#### 🟢 Subtask 1:
- **Classify hazard-category**: Classifies the general hazard type.
- **Classify product-category**: Classifies the general product type.

#### 🟢 Subtask 2:
- **Classify hazard**: Classifies the specific hazard type.
- **Classify product**: Classifies the specific product type.
---
## ℹ️ Repository Files Description:

The following files are included in the repository:

### 🟢 Submission Notebooks

These notebooks serve as the primary notebooks for this project. After conducting some benchmarks to evaluate the effectiveness of using the "title" versus the "text" feature as the main input, we decided to train the model using the "text" feature along with additional features such as 'year', 'month', 'day', and 'country'. Following the training, the model is used to make predictions on the unlabeled contest data.

- ✅ **[Submission_Model_Finetuned_SciBERT_PDS_A2_Food_Hazard_Detection.ipynb]**

  **-- Best performing model for Sub Task 1 Hazard-Caterogry, Product-Category--**

  **Sub Task1 : Macro F1: 75%**
  
  Pretrained model switched to SciBERT due to stacking loss issues in the product class.
  SciBERT, a pretrained language model based on BERT, was developed to overcome the lack of high-quality labeled scientific data. By leveraging unsupervised pretraining on a large multi-domain corpus of scientific publications, SciBERT improves performance on downstream scientific NLP tasks. For the Food Hazard Detection Challenge, SciBERT was trained on the initial dataset and refined using early stopping and a learning rate scheduler, achieving better results by addressing these challenges effectively.

- ✅ **[Submission_Model_Finetuned_BioBERT_PDS_A2_Food_Hazard_Detection.ipynb]**

  **-- Best performing model for Sub Task 2 Hazard, Product--**
  
  **Sub Task 2:Macro F1: 47%**

  Pretrained model switched to BioBERT due to stacking loss issues in the product class. BioBERT, which is specifically designed for biomedical text, provided better results by addressing these issues more effectively. The model was trained on **intial training set** and was further refined using methods like early stopping and learning rate scheduler to optimize performance, ultimately aiming to deliver the best possible submission for the Food Hazard Detection Challenge.
  
- **[Submission Model Finetuned PubMedBERT PDS A2 Food Hazard Detection.ipynb]**  
  Submission notebook for a model finetuned with more methods (eg early stopping, learning rate scheduler) on the **initial training set** using PubMedBERT.
  The model was initiated from the benchmark model and is developed further in order to make the best submission possible for the **Food Hazard Detection Challenge**.

Regarding the previously mentioned issue with stacking loss, please refer to the diagram below for further clarification.

It can be observed that the average loss for the SciBERT and BioBERT models decreases towards zero, indicating better generalization. This is further supported by the performance scores achieved on the unlabeled validation data.

![Average loss in "Product" class for Bert Models](Plots%20and%20Schemas/average_loss_comparison_all_models.png)


- **[AnB_Submission_PubMedBERT.ipynb]**  
  Submission notebook for a model finetuned on an **augmented training set** using PubMedBERT.


- **[Submission Model LGBM PDS A2 Food Hazard Detection.ipynb]**  
  Submission notebook for LightGBM models trained on the **initial training set**.




### 🟢 Benchmarks Notebooks

These specific notebooks represent an initial approach to training models, aimed at evaluating their performance based on the text feature they use ("title" or "text").

- **[Benchmark Models Finetuned PubMedBERT PDS A2 Food Hazard Detection.ipynb]**  
  Notebook for running and evaluating benchmark models using PubMedBERT with the **initial training set**.
  The specific version is actually a simplified version in order to investigate the influence of title or text
  as main text feature, in the classification task. The submission model is much more advance fro the scope of techniques in finetuning.
  
- **[Benchmark Models LGBM PDS A2 Food Hazard Detection.ipynb]**  
  Notebook for experimenting with LightGBM models for food hazard detection using the **initial training set**.

- **[AnB_Benchmark_PubMedBERT.ipynb]**  
  Notebook for evaluating benchmark models using an **augmented training set** with PubMedBERT.After indications of overfitting the specific method is excluded as possible optimization solution.


### 🟢 Extra Notebooks
- **[EDA Notebook PDS A2 Food Hazard Detection.ipynb]**  
  Notebook for performing Exploratory Data Analysis (EDA) on the **initial training set** cocluded to evidence of extremely imbalanced classes.

- **[data_augmentation.ipynb]**  
  Notebook for applying data augmentation using back translation to incident descriptions and titles, oversampling and undersampling , creating an **augmented training set** for imbalanced classes especially in categories of ```hazard``` and ```product```.

---
## ℹ️ Requirements
Make sure to install the required dependencies before running the code. You can use the following pip command to install the necessary packages:
```bash
pip install torch lightgbm pandas scikit-learn matplotlib tqdm transformers nltk numpy
```
---
## ℹ️ How to Re-run the Solution

### ➡️ Step 1: Data Preparation
Ensure that the dataset is correctly placed in the expected directory. Adjust file paths if necessary.

### ➡️ Step 2: Exploratory Data Analysis
Run `EDA PDS A2 Food Hazard Detection.ipynb` to clean and visualize the data.

### ➡️ Step 3: Model Benchmarks on Text or title Feature
You can choose between:

- **Finetuned PubMedBERT on initial data**: Run `BENCHMARKS Finetuned PubMedBERT PDS A2 Food Hazard Detection.ipynb`.
- **LightGBM**: Run `BENCHMARKS LGBM PDS A2 Food Hazard Detection .ipynb`.
- **Finetuned PubMedBERT on Augmented and Balanced Dataset**: Run `AnB_Benchmark_PubMedBERT.ipynb`.

### ➡️ Step 4: Model Evaluation
Both models evaluate accuracy, precision, recall, and F1-score.

### ➡️ Step 5: Retraining for Submission
Retrain using the submission notebooks to create final submissions for competitions based on the best model of the respective benchmarks notebooks:

- **For SciBERT on initial data**: Run `Submission Model Finetuned SciBERT PDS A2 Food Hazard Detection.ipynb`.
- **For BioBERT on initial data**: Run `Submission Model Finetuned BioBERT PDS A2 Food Hazard Detection.ipynb`.
- **For PubMedBERT on initial data**: Run `Submission Model Finetuned PubMedBERT PDS A2 Food Hazard Detection.ipynb`.
- **For LightGBM**: Run `Sumission Model LGBM  PDS A2 Food Hazard Detection.ipynb`.
- **Finetuned PubMedBERT on Augmented and Balanced Dataset**: Run `AnB_Submission_PubMedBERT.ipynb`.

---
## ℹ️ SemEval 2025 Task 9 - The Food Hazard Detection Challenge Results

### Competition Results for Subtask 1 (Hazard-category, Product-category)

**Leaderboard: https://codalab.lisn.upsaclay.fr/competitions/19955#results**

The following shows the F1 Macro Scores for hazard-category and product-category tasks for Subtask 1:


![F1 Macro Scores for Subtask 1 (Hazard-category, Product-category)](Plots%20and%20Schemas/subtask1_results_with_legend_and_values.png)

| Submission File                         | Score         | Status   | 
|-----------------------------------------|---------------|----------|
| ✅ submission_scibert.zip	             | 0.7529  | Finished | 
|  submission_fintuned_BioBERT.zip	      | 0.7354	 | Finished | 
| submission_finetuned_PubMedBERT v4.zip	| 0.7128	 | Finished | 
| AnB Data Finetuned PubMedBERT.zip       | 0.6876  | Finished | 
| submission.zip (LGBM)                   | 0.6428  | Finished | 

**While the submission notebook introduces notable improvements in training methodology and evaluation fairness, these refinements result in only marginal performance gains in the Codalab contest compared to the benchmarks.**


### Competition Results for Subtask 2 (Hazard, Product)

The following shows the F1 Macro Scores for hazard and product tasks for Subtask 1:

![F1 Macro Scores for Subtask 2 (Hazard, Product)](Plots%20and%20Schemas/subtask2_results_with_legend_and_values.png)


- ✅ ***Rating shows for Sub Task 2 a score of 0.4755  for submission_fintuned_BioBERT.zip*** 

- ***Rating shows for Sub Task 2 a score of 0.43  for submission_fintuned_SciBERT.zip*** 

- ***Rating shows for Sub Task 2 a score of 0.3376 for submission_finetuned_PubMedBERT v4.zip***


| Submission File                         | Score         | Status   | 
|-----------------------------------------|---------------|----------|
| submission_scibert.zip                  |0.43           | Finished |
|✅submission_fintuned_BioBERT.zip        | 0.4755        | Finished |
| submission_finetuned_PubMedBERT v4.zip  | 0.3376        | Finished |
| AnB Data Finetuned PubMedBERT.zip	      | 0.2486        | Finished | 
| submission.zip (LGBM)                   | 0.2057        | Finished | 





---
## ℹ️ Benchmark Results

Benchmark results are based on the initial versions of each model—Basic and Advanced—due to computational limitations preventing the repetition of benchmarks for every optimized version. As such, these benchmarks serve as a guideline for selecting features (such as titles or text) and adopting appropriate metrics moving forward. These initial results led to a focus on the **text** feature, as it consistently produced better performance across various models, particularly in the classification tasks. Additionally, the **text** feature provided more comprehensive information for the BERT models, leading to improved classification results.

**Any other optimized versions, particularly for fine-tuning BERT models, have only been explored at the submission level. Therefore, their training is based on the conclusions drawn from the initial benchmark models as a preliminary guideline.**


### 🟢 Finetuned PubMedBERT Model on initial Data (Title-based):

| Task                        | F1-Score |
|-----------------------------|----------|
| hazard-category (Title)     | 0.8288   |
| product-category (Title)    | 0.7494   |
| hazard (Title)              | 0.5899   |
| product (Title)             | 0.2172   |

### 🟢 Finetuned PubMedBERT Model on intial data (Text-based):

| Task                        | F1-Score |
|-----------------------------|----------|
| hazard-category (Text)      | 0.9459   |
| product-category (Text)     | 0.7583   |
| hazard (Text)               | 0.8166   |
| product (Text)              | 0.2331   |

![PubmedBenchmark](Plots%20and%20Schemas/PubmedBenchmark.png)


### 🟢 LightGBM Model (Title-based):

| Task                        | F1-Score |
|-----------------------------|----------|
| hazard-category (Title)     | 0.7614   |
| product-category (Title)    | 0.5926   |
| hazard (Title)              | 0.5533   |
| product (Title)             | 0.0798   |

### 🟢 LightGBM Model (Text-based):

| Task                        | F1-Score |
|-----------------------------|----------|
| hazard-category (Text)      | 0.9129   |
| product-category (Text)     | 0.6682   |
| hazard (Text)               | 0.7671   |
| product (Text)              | 0.0479   |

![LightGBM_Benchmark](Plots%20and%20Schemas/LightGBMBenchmark.png)



### 🟢 Finetuned PubMedBERT Model on augmented and balanced Data (Title-based):

| Task               | F1-Score |
|--------------------|----------|
| hazard-category    | 0.9598   |
| product-category   | 0.9710   |
| hazard             | 0.8381   |
| product            | 0.6066   |

### 🟢 Finetuned PubMedBERT Model on augmented and balanced data (Text-based):

| Task               | F1-Score |
|--------------------|----------|
| hazard-category    | 0.9566   |
| product-category   | 0.9393   |
| hazard             | 0.8370   |
| product            | 0.5500   |

![AugmentedandBalancedTrainsetPubmedBenchmark](Plots%20and%20Schemas/AnBPubmedBenchmark.png)


---
## ℹ️ Overfitting Indications in some experiments from Competition Results

The competition results suggest potential overfitting in the models. The scores for the `submission_finetuned_PubMedBERT.zip` and `AnB Data Finetuned PubMedBERT.zip` file were significantly higher for the training set compared to the test set, which may indicate that the model is overfitting to the training data. To mitigate this, I attempted data augmentation in the **data_augmentation.ipynb** file. The benchmark results using the augmented training data are as follows:

### Collected F1-Scores for Title-Focused Classification (Augmented Data)


### 🟢 Finetuned PubMedBERT Model on augmented and balanced Data (Title-based):

| Task               | F1-Score |
|--------------------|----------|
| hazard-category    | 0.9598   |
| product-category   | 0.9710   |
| hazard             | 0.8381   |
| product            | 0.6066   |

### 🟢 Finetuned PubMedBERT Model on augmented and balanced data (Text-based):

| Task               | F1-Score |
|--------------------|----------|
| hazard-category    | 0.9566   |
| product-category   | 0.9393   |
| hazard             | 0.8370   |
| product            | 0.5500   |

The submission file associated with this augmented training approach was **AnB_Submission_PubMedBERT.ipynb**. The leaderboard scores for this submission were:

- **ST1:** 0.6876231681 (`AnB Data Finetuned PubMedBERT.zip`) on 11/23/2024 at 23:11:21
- **ST2:** 0.0 (`AnB Data Finetuned PubMedBERT.zip`) on 11/23/2024 at 23:03:11

Despite the data augmentation efforts, there was no significant improvement in the competition leaderboard scores. For instance, ST1 achieved a score of **0.6876231681**, and the ST2 submission showed discrepancies, with the leaderboard reflecting an approximate score of **0.35**. This suggests that data augmentation did not substantially address the overfitting issue or enhance generalization performance in the competition context. Further investigation and alternative approaches may be required to improve model performance. 

### Explanation for Model Performance Despite Augmented Dataset

I am trying to explain why the augmented dataset did not improve the model's performance in the following points:

1. **Nature of Augmentation**: The augmentation techniques I applied might not have introduced enough diversity or complexity in the data. This could mean the model didn't get new, meaningful examples to improve its ability to generalize.

2. **Overfitting**: Despite using an augmented dataset with back translations and over/under sampling, the model might still was overfitting to both the original and augmented data. 

**An assumption is that the augmented data is too similar to the original, the model may memorize patterns rather than learning to generalize, leading to poor performance on unseen data.**

----
## ℹ️ Conclusion
This solution for the Food Hazard Detection Challenge integrates both Finetuned pretrained BERT models and LightGBM models to classify food safety incidents based on short titles and long descriptions. Through careful experimentation with various pretrained models and an augmented training set, the approach addresses both general and specific hazard and product classification tasks.

Key results include a significant performance boost from switching to both SciBERT and BioBERT due to better handling of scientific and biomedical text and a reduction in stacking loss, leading to stronger generalization and improved Macro F1 scores. Despite efforts in data augmentation to mitigate overfitting, the model's performance on the competition leaderboard remained constrained, indicating that further refinements may be necessary. The benchmarks and results provide a clear pathway for future improvements, such as exploring more diverse augmentation strategies and refining model hyperparameters.

This repository contains all necessary files and notebooks to reproduce the results and allows for easy retraining and submission of optimized models. It serves as a comprehensive solution to the problem of food hazard classification, incorporating state-of-the-art NLP techniques and traditional machine learning models.

The performance outcomes demonstrate the potential of fine-tuning pretrained models like SciBERT and BioBERT for domain-specific tasks and underline the importance of addressing overfitting through more innovative approaches in future iterations of the model. 

---
## ℹ️ Resources and Tools

- [Hugging Face](https://huggingface.co): For state-of-the-art machine learning models, datasets, and tools, especially in natural language processing.
- [arXiv](https://arxiv.org): For accessing research papers and preprints on data science, machine learning, and other academic fields.
- [ChatGPT](https://openai.com/chatgpt): For quick assistance, code help, debugging, and guidance on various data science topics.
- [Stack Overflow](https://stackoverflow.com): For troubleshooting and solutions to coding challenges.
- [Towards Data Science](https://towardsdatascience.com) and [Medium](https://medium.com/tag/data-science): For articles and tutorials on data science techniques and best practices.

---
## ℹ️ License

This project is licensed under the [MIT License](LICENSE.txt) - see the LICENSE.txt file for details.



