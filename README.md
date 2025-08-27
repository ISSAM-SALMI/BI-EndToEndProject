=======
# BI-EndToEndProject

## 📦 Présentation

Ce projet propose un pipeline complet de Data Warehouse en architecture medallion (**Bronze, Silver, Gold**) pour l'intégration et la modélisation de données issues de systèmes **CRM** et **ERP**. Il s'appuie sur **SQL Server** et des scripts SQL pour automatiser la création, le chargement, la transformation et la modélisation analytique des données.

---

## 🏗️ Architecture & Workflow

1. **Initialisation** :
   - `init_databases.sql` : Création de la base `datawerehouse` et des schémas (`bronze`, `silver`, `gold`).

2. **Bronze Layer** :
   - Stockage des données brutes issues des fichiers CSV CRM/ERP.
   - Scripts :
     - `create_raws_data.sql` : Création des tables brutes.
     - `insert_to_row_data.sql` / `load_bronze.sql` : Procédures de chargement automatisé via BULK INSERT.

3. **Silver Layer** :
   - Nettoyage, transformation et enrichissement des données.
   - Scripts :
     - `create_rows_silver.sql` : Création des tables Silver.
     - `load_silver.sql` : Procédure d'automatisation du nettoyage et de la transformation (normalisation, jointures, enrichissement).

4. **Gold Layer** :
   - Modélisation analytique (vues dimensionnelles et factuelles pour BI).
   - Scripts :
     - `view_Customer.sql` : Vue dimension client.
     - `view_Product.sql` : Vue dimension produit.
     - `view_sales_facts.sql` : Vue factuelle des ventes.

---

## 📊 Data Flow & Modélisation

![Project Architecture](ProjectOverviw.png)

![Data Flow & Model Schema](DataFlow.png)

---

## 🗂️ Structure du projet

```
│   DataFlow.png
│   ProjectOverviw.png
│   README.md
│   
├───datasets
│   ├───source_crm
│   │       cust_info.csv
│   │       prd_info.csv
│   │       sales_details.csv
│   │       
│   └───source_erp
│           CUST_AZ12.csv
│           LOC_A101.csv
│           PX_CAT_G1V2.csv
│
└───scritpts
    │   init_databases.sql
    │
    ├───bronze
    │       create_raws_data.sql
    │       insert_to_row_data.sql
    │       load_bronze.sql
    │
    ├───gold
    │       view_Customer.sql
    │       view_Product.sql
    │       view_sales_facts.sql
    │
    └───Silver
            create_rows_silver.sql
            load_silver.sql
```

---

## 🛠️ Technologies utilisées

- **Microsoft SQL Server**
- **Windows**

---

## 💡 Explication des couches

- **Bronze Layer** : Données brutes chargées sans transformation.
- **Silver Layer** : Données nettoyées, jointes et transformées pour analyse.
- **Gold Layer** : Modèles analytiques (vues dimensionnelles et factuelles) pour la BI et le reporting.

---

## 🚀 Installation & Exécution

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/ISSAM-SALMI/BI-EndToEndProject.git
   ```

2. **Préparer les fichiers CSV**
   - Placez les fichiers dans les dossiers `datasets/source_crm` et `datasets/source_erp`.

3. **Exécuter les scripts SQL dans l'ordre** :
   - `scritpts/init_databases.sql` : Initialise la base et les schémas.
   - `scritpts/bronze/create_raws_data.sql` : Crée les tables brutes.
   - `scritpts/bronze/load_bronze.sql` : Charge les données brutes.
   - `scritpts/Silver/create_rows_silver.sql` : Crée les tables Silver.
   - `scritpts/Silver/load_silver.sql` : Transforme et nettoie les données.
   - `scritpts/gold/view_Customer.sql`, `view_Product.sql`, `view_sales_facts.sql` : Crée les vues analytiques.

4. **Vérifier les vues Gold**
   - Utilisez SQL Server Management Studio pour interroger les vues `gold.dim_customers`, `gold.dim_product`, `gold.fact_sales`.

---

## 📐 Aperçu des modèles de données

### Exemple : Vue dimension client
```sql
CREATE VIEW gold.dim_customers AS 
SELECT 
  ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
  ci.cst_id AS customer_id,
  ci.cst_key AS customer_number,
  ci.cst_firstname AS first_name,
  ci.cst_lastname AS last_name,
  la.cntry AS country,
  ci.cst_marital_status AS marital_status,
  CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr ELSE COALESCE(ca.gen, 'n/a') END AS gender,
  ca.bdate AS birthdate,
  ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid;
```

### Exemple : Vue factuelle des ventes
```sql
CREATE VIEW gold.fact_sales AS
SELECT 
  sd.sls_ord_num AS order_number,
  pr.product_key,
  cu.customer_key,
  sd.sls_order_dt AS order_date,
  sd.sls_ship_dt AS shipping_date,
  sd.sls_due_dt AS due_date,
  sd.sls_sales AS sales_amount,
  sd.sls_quantity AS quantity,
  sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id;
```

---

## 👥 Contributeurs

- ISSAM SALMI
- Abdel

---

## 📫 Contact

Pour toute question ou suggestion, veuillez ouvrir une issue sur le dépôt GitHub ou contacter les contributeurs.
# BI-EndToEndProject
