# ChriLy 🇲🇦
### An End-to-End Moroccan E-Commerce Analytics Platform

**"Chri"** means *buy* in Darija. **"Ly"** is a nod to Shopify. ChriLy = Buy-ify — a synthetic Moroccan e-commerce company built to practice a full analytics workflow: raw data → audit → localization → cleaning → warehouse → BI → machine learning.

The dataset started as the Brazilian Olist e-commerce dataset (9 relational tables, 2016–2018) and was fully localized into a fictional Moroccan market: MAD currency, real Moroccan regions and cities, local payment methods (including Cash on Delivery), local logistics providers, and Ramadan/holiday effects on shopping behavior.

---

## 📊 Snapshot

| Metric | Value |
|---|---|
| Total Orders | ~99K |
| Total Customers | ~95K |
| Total Revenue | 29.00M MAD |
| Average Order Value | 293.91 MAD |
| Average Review Score | 4.0 / 5 |
| Average Delivery Time | 12.0 days |
| Localized Timeline | 2024–2026 |

---

## 🏗️ Pipeline

```
Raw Olist Data (9 CSVs)
        │
        ▼
1. Data Quality Audit  →  2. Moroccanization  →  3. Cleaning  →  4. Feature Engineering
        │
        ▼
5. PostgreSQL Warehouse (star schema)
        │
        ▼
6. Power BI Dashboards  →  7. Machine Learning (delivery delay prediction)
```

---

## 🏆 Highlights

- **99.70% payment reconciliation match rate** validated across 99,441 orders during the initial data quality audit, before any transformation was applied
- **Star schema warehouse** in PostgreSQL (`fact_orders` + 4 dimensions), with KPI logic deliberately kept in SQL rather than precomputed in pandas
- **3-page Power BI suite** — Executive, Logistics & Delivery, Customer & Payment Behavior
- **Delivery delay prediction model** (Random Forest, 0.76 ROC-AUC) using only pre-shipment information, so it reflects a realistic, deployable use case

---

## 📖 Documentation

Full write-ups for each stage of the pipeline:

| Stage | Doc |
|---|---|
| Data Quality Audit | [`docs/Data_Understaning_Profiling&Quality.md`](docs/Data_Understaning_Profiling&Quality.md) |
| Moroccanization | [`notebooks/02_moroccanization.ipynb`](notebooks/02_moroccanization.ipynb) |
| Data Cleaning | [`docs/cleaning.md`](docs/cleaning.md) |
| Feature Engineering | [`docs/Feature_Engineering.md`](docs/Feature_Engineering.md) |
| PostgreSQL Data Warehouse | [`docs/postgresql_data_warehouse.md`](docs/postgresql_data_warehouse.md) |
| Power BI Dashboards | [`docs/POWER_BI.md`](docs/POWER_BI.md) |
| Machine Learning | [`docs/ML.md`](docs/ML.md) |

---

## 🛠️ Tech Stack

**Data Engineering:** Python, pandas, numpy, Jupyter Notebook
**Database:** PostgreSQL, SQLAlchemy, SQL
**BI:** Power BI, DAX
**Machine Learning:** scikit-learn (Logistic Regression, Random Forest), matplotlib, seaborn

---
## Repository Structure

ChriLy/
│
├── data/
│   ├── raw/
│   ├── morocco/
│   └── clean/
│
├── notebooks/
│   ├── 01_Data_Understanding_Profiling&quality.ipynb
│   ├── 02_moroccanization.ipynb
│   ├── 03_cleaning_feature_engineering.ipynb
│   ├── 04_postgresql_etl.ipynb
│   └── 05_ML_Delivery_Prediction.ipynb
│
├── src/
│   └── moroccanization.py
│
├── sql/
│   ├── 01_create_schema.sql
│   ├── 02_create_dimensions.sql
│   ├── ...
│   └── 07_views.sql
│
├── models/
│   └── late_delivery_random_forest.joblib
│
├── power_bi/
│   └── ChriLy_Dashboard.pbix
│
├── docs/
│   ├── data-understanding_profiling&quality.md
│   ├── cleaning.md
│   ├── feature-engineering.md
│   ├── postgresql_datawarehouse.md
│   ├── POWER_BI.md
│   └── ML.md
│
└── README.md


```

---

## 🚀 How to Run

1. Clone the repo
2. Install dependencies: `pip install -r requirements.txt`
3. Run notebooks in `notebooks/` in order to reproduce the audit, localization, cleaning, feature engineering, and ML stages
4. Load cleaned data into PostgreSQL
5. Open `powerbi/chrily_dashboard.pbix` and point the data source to your local PostgreSQL instance

---

## 👤 Author

Mohamed Amine Mostaqim
[GitHub](https://github.com/MohamedAmineMostaqim/ChriLy)