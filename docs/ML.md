# Machine Learning — Late Delivery Prediction

## 1. Overview

The ChriLy project includes a machine learning component designed to predict whether an order is likely to experience a late delivery.

The objective is to extend the project beyond descriptive analytics and provide a predictive use case based on order, payment, geographic, product, and temporal information available around the time an order is placed.

### Business Question

> Can we predict whether an order will be delivered late using information available around the time the order is placed?

This can help identify orders with a higher risk of late delivery and support proactive logistics monitoring.

---

## 2. Problem Definition

This is a **binary classification** problem.

The target variable is:

| Value | Meaning         |
|:-----:|-----------------|
| `0`   | On-Time / Early |
| `1`   | Late            |

The target was derived from `delivery_delay_days`:

```python
late_delivery = delivery_delay_days > 0
```

Therefore:

- `delivery_delay_days > 0` → **Late**
- `delivery_delay_days <= 0` → **On-Time / Early**

---

## 3. Dataset Construction

The ML dataset was built from the PostgreSQL data platform.

A dedicated order-level dataset was created to ensure:

> **1 row = 1 order**

Order-item and payment information was aggregated to the order level before being used for modeling.

### Aggregated Information

The dataset includes:

- Total product price
- Total freight value
- Number of items per order
- Number of sellers
- Number of products
- Total payment value
- Maximum payment installments

### Additional Information

The dataset also contains:

- Customer region
- Seller region
- Product category
- Payment type
- Payment installments
- Purchase year
- Purchase month
- Purchase quarter
- Purchase weekday
- Purchase hour
- Weekend indicator
- Holiday indicator
- COD indicator

---

## 4. Feature Engineering

### Numerical Features

- `total_price`
- `total_freight`
- `total_payment_value`
- `items_per_order`
- `seller_count`
- `product_count`
- `max_payment_installments`
- `purchase_year`
- `purchase_month`
- `purchase_quarter`
- `purchase_hour`

### Categorical Features

- `payment_type`
- `payment_installments_bucket`
- `customer_state`
- `seller_state`
- `product_category_name`
- `purchase_weekday`

### Boolean Features

- `is_weekend`
- `is_holiday`
- `cod_flag`

---

## 5. Data Leakage Prevention

Preventing target leakage was an important part of the modeling process.

The following variables were excluded from the model features:

- `delivery_delay_days`
- `delivery_status`
- `order_id`

`delivery_delay_days` and `delivery_status` describe the actual delivery outcome and therefore would not be available when making a prediction.

Using these variables as predictors would allow the model to directly access information about the outcome and produce misleading results.

The final model therefore uses information that can reasonably be available before or around the time of order placement.

---

## 6. Preprocessing

A Scikit-learn preprocessing pipeline was used to ensure consistent preprocessing.

**Numerical Features**
Missing numerical values were handled using median imputation, and numerical features were standardized using `StandardScaler`.

**Categorical Features**
Missing categorical values were replaced using the most frequent value. Categorical variables were then transformed using One-Hot Encoding.

All preprocessing steps were included inside the model pipeline so that transformations were learned from the training data only.

```
Numerical Features
        ↓
Median Imputation
        ↓
Standard Scaling

Categorical Features
        ↓
Most-Frequent Imputation
        ↓
One-Hot Encoding
```

---

## 7. Train / Test Split

The dataset was divided into:

- 80% training data
- 20% testing data

A fixed random state of `42` was used for reproducibility.

A stratified split was applied to preserve the proportion of late and non-late orders in both datasets.

---

## 8. Class Imbalance

Late deliveries represent a much smaller proportion of the dataset than on-time or early deliveries.

The test set contained:

| Class            | Orders |
|------------------|-------:|
| On-Time / Early  | 17,989 |
| Late             |  1,307 |

Late deliveries therefore represented approximately **6.8%** of the test set.

Because of this class imbalance, accuracy alone is not sufficient for evaluating the model. The following metrics were therefore considered:

- Accuracy
- Precision
- Recall
- F1-score
- ROC-AUC

Particular attention was given to the performance of the Late class.

---

## 9. Models

Two classification models were evaluated.

### 9.1 Logistic Regression

Logistic Regression was used as an interpretable baseline model.

**Configuration:**

- Maximum iterations: 1000
- Class weights: balanced
- Random state: 42

### 9.2 Random Forest

A Random Forest classifier was used to capture nonlinear relationships between the features.

**Configuration:**

- Number of trees: 300
- Maximum depth: 15
- Minimum samples per leaf: 5
- Class weights: balanced
- Random state: 42
- Parallel processing enabled

---

## 10. Model Evaluation

Both models were evaluated using the same unseen test set.

| Model                | Accuracy | Precision | Recall | F1 Score | ROC-AUC   |
|-----------------------|---------:|----------:|-------:|---------:|----------:|
| Logistic Regression   |    64.1% |     10.9% |  60.2% |    18.5% |     0.667 |
| **Random Forest**     |**80.0%** | **18.5%** |**57.2%**| **27.9%**| **0.763** |

### 10.1 Best Model

The Random Forest was selected as the final model based on its higher ROC-AUC.

| Metric    |    Result |
|-----------|----------:|
| Accuracy  | **80.0%** |
| Precision | **18.5%** |
| Recall    | **57.2%** |
| F1 Score  | **27.9%** |
| ROC-AUC   | **0.763** |

The ROC-AUC of 0.763 indicates that the model has meaningful ability to distinguish higher-risk late deliveries from on-time or early deliveries.

| Class            | Precision | Recall | F1 Score |
|------------------|----------:|-------:|---------:|
| On-Time / Early  |      0.96 |   0.82 |     0.88 |
| Late             |      0.18 |   0.57 |     0.28 |

The model identified approximately 57% of late deliveries.

The relatively low precision for the late-delivery class is influenced by the strong class imbalance. Therefore, the model should be considered an analytical prototype rather than a production-ready automatic decision system.

---

## 11. Feature Importance

Feature importance was extracted from the Random Forest model to understand which variables contributed most to predictions.

### Top Features

| Rank | Feature                               | Importance |
|-----:|----------------------------------------|-----------:|
|    1 | Purchase Month                        |     20.29% |
|    2 | Purchase Quarter                      |     12.45% |
|    3 | Total Freight                         |      9.23% |
|    4 | Total Payment Value                   |      5.54% |
|    5 | Customer — Casablanca-Settat          |      5.32% |
|    6 | Total Price                           |      5.23% |
|    7 | Purchase Year                         |      4.86% |
|    8 | Customer — Rabat-Salé-Kénitra         |      4.13% |
|    9 | Purchase Hour                         |      3.38% |
|   10 | Customer — Oriental                   |      2.12% |
|   11 | Maximum Payment Installments          |      2.09% |
|   12 | Seller — Casablanca-Settat            |      1.57% |
|   13 | Customer — Tanger-Tétouan-Al Hoceïma  |      1.19% |
|   14 | Items per Order                       |      0.88% |
|   15 | Product Category — Beauty & Cosmetics |      0.81% |
|   16 | Customer — Guelmim-Oued Noun          |      0.81% |
|   17 | Seller Count                          |      0.80% |
|   18 | Cash on Delivery                      |      0.80% |
|   19 | Bank Card                             |      0.77% |
|   20 | Seller — Tanger-Tétouan-Al Hoceïma    |      0.77% |

The results indicate that temporal, geographic, freight, payment, and order-value characteristics contain useful predictive information.

Purchase month and purchase quarter were among the strongest features, suggesting that delivery performance varies across different periods.

---

## 12. Model Comparison

The two models produced different results.

**Logistic Regression**
- ROC-AUC: 0.667
- Accuracy: 64.1%
- Late-delivery recall: 60.2%

**Random Forest**
- ROC-AUC: 0.763
- Accuracy: 80.0%
- Late-delivery recall: 57.2%

Although Logistic Regression achieved slightly higher recall for late orders, Random Forest provided substantially better overall discrimination and ROC-AUC.

For this project, **Random Forest was selected as the final model**.

---

## 13. Business Value

A predictive late-delivery model can potentially support:

- Proactive logistics monitoring
- Identification of high-risk orders
- Regional delivery analysis
- Seller performance monitoring
- Customer communication
- Operational resource planning

For example, orders with a high predicted probability of late delivery could be prioritized for monitoring or proactive intervention.

---

## 14. Limitations

The model should be considered a portfolio-level analytical prototype rather than a production deployment.

### 14.1 Class Imbalance

Late deliveries represent only a small proportion of the dataset, which contributes to the relatively low precision for the late class.

### 14.2 Temporal Features

Purchase month and quarter have substantial importance. The model may therefore capture seasonal patterns that could change over time.

### 14.3 Moroccanized Dataset

The original Olist dataset was adapted to a Moroccan business context through the project's Moroccanization process.

Geographic and business transformations therefore represent a simulated Moroccan e-commerce environment rather than real Moroccan e-commerce operational data.

### 14.4 No Real-Time Operational Data

The model does not currently incorporate real-time information such as:

- Carrier status
- Traffic
- Weather
- Warehouse workload
- Inventory availability
- Real-time delivery tracking

### 14.5 Limited Model Optimization

The project focuses on demonstrating a complete end-to-end ML workflow rather than extensive hyperparameter optimization.

---

## 15. Model Artifact

The selected Random Forest pipeline was saved as:

```
models/
└── late_delivery_random_forest.joblib
```

The saved pipeline contains both the preprocessing steps and the trained classifier.

This allows the same preprocessing transformations to be applied when generating predictions on new data.

---

## 16. ML Workflow

The complete machine learning workflow is:

```
PostgreSQL Data
       ↓
Order-Level ML Dataset
       ↓
Data Validation
       ↓
Feature Engineering
       ↓
Leakage Prevention
       ↓
Train / Test Split
       ↓
Preprocessing Pipeline
       ↓
Logistic Regression
       ↓
Random Forest
       ↓
Model Evaluation
       ↓
Feature Importance
       ↓
Best Model Selection
       ↓
Saved Model
```

---

## 17. Conclusion

The machine learning component extends ChriLy from descriptive and diagnostic analytics into predictive analytics.

The Random Forest model achieved a ROC-AUC of **0.763**, outperforming the Logistic Regression baseline with a ROC-AUC of **0.667**.

The model detected **57.2%** of late deliveries and demonstrated that temporal, geographic, freight, payment, and order characteristics contain useful predictive information.

While the model is not intended to be a production-ready system, it demonstrates a complete machine learning workflow integrated with the project's PostgreSQL data platform.

Overall, ChriLy combines:

**Data Engineering → Data Warehouse → Business Intelligence → Machine Learning**

into a single end-to-end data analytics project.
