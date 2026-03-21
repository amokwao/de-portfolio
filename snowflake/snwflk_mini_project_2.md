# 1. Unstructured Data — Simple JSON + Internal Stage + COPY Command  
## Mini Project — Snowflake JSON ETL Pipeline

---

## 2. Project Overview

In this mini project, you will:

- Load customer data from a **JSON file** into a **raw table** in Snowflake using an **internal stage**  
- Perform **JSON flattening** on the raw table and create a **flattened table**  
- Perform **data analysis** on the flattened data  

---

## 3. Objectives

- Work with **Snowflake Internal Stages** for file storage  
- Use the **COPY INTO** command to load **unstructured JSON data**  
- Perform **simple JSON flattening** using `LATERAL FLATTEN`  
- Build **RAW** and **FLATTEN** layers for analytics  

---

## 4. Tools & Technologies

| Tool / Technology | Purpose |
|------------------|---------|
| Snowflake | Cloud data warehouse |
| Snowflake Web UI | SQL execution environment |
| JSON File | Customer dataset |

---

## 5. Architecture

*(Insert your JSON → Stage → Raw Table → Flatten Table → Analytics diagram here)*
![alt text](image-1.png)
---

# 6. High‑Level Step‑by‑Step Implementation

---

## 6.1 Create Database & Schemas

```sql
CREATE DATABASE CUSTOMER_DATA;

CREATE SCHEMA CUSTOMER_DATA.RAW_DATA;
CREATE SCHEMA CUSTOMER_DATA.FLATTEN_DATA;
```

---

## 6.2 Create RAW Table (RAW_DATA Schema)

**Table:** `CUSTOMER_DATA.RAW_DATA.CUSTOMER_RAW`

### Table Structure

| Column Name | Data Type |
|-------------|-----------|
| JSON_DATA | VARIANT |

```sql
CREATE OR REPLACE TABLE CUSTOMER_DATA.RAW_DATA.CUSTOMER_RAW (
    JSON_DATA VARIANT
);
```

---

## 6.3 Create FLATTEN Table (FLATTEN_DATA Schema)

**Table:** `CUSTOMER_DATA.FLATTEN_DATA.CUSTOMER_FLATTEN`

### Table Structure

| Column Name | Data Type |
|-------------|-----------|
| CUSTOMERID | INT |
| NAME | STRING |
| EMAIL | STRING |
| REGION | STRING |
| COUNTRY | STRING |
| PRODUCTNAME | STRING |
| PRODUCTBRAND | STRING |
| CATEGORY | STRING |
| QUANTITY | INT |
| PRICEPERUNIT | FLOAT |
| TOTALSALES | FLOAT |
| PURCHASEMODE | STRING |
| MODEOFPAYMENT | STRING |
| PURCHASEDATE | DATE |

```sql
CREATE OR REPLACE TABLE CUSTOMER_DATA.FLATTEN_DATA.CUSTOMER_FLATTEN (
    CUSTOMERID INT,
    NAME STRING,
    EMAIL STRING,
    REGION STRING,
    COUNTRY STRING,
    PRODUCTNAME STRING,
    PRODUCTBRAND STRING,
    CATEGORY STRING,
    QUANTITY INT,
    PRICEPERUNIT FLOAT,
    TOTALSALES FLOAT,
    PURCHASEMODE STRING,
    MODEOFPAYMENT STRING,
    PURCHASEDATE DATE
);
```

---

## 6.4 Upload JSON File to Internal Stage

### Create Stage

```sql
CREATE OR REPLACE STAGE CUSTOMER_DATA.RAW_DATA.CUSTOMER_STAGE;
```

### Upload File  
Use Snowflake Web UI → Load Data → Select Stage.

### List Files in Stage

```sql
LIST @CUSTOMER_DATA.RAW_DATA.CUSTOMER_STAGE;
```

---

## 6.5 Load Data from Stage into RAW Table

```sql
COPY INTO CUSTOMER_DATA.RAW_DATA.CUSTOMER_RAW
FROM @CUSTOMER_DATA.RAW_DATA.CUSTOMER_STAGE
FILE_FORMAT = (TYPE = 'JSON');
```

---

## 6.6 Perform JSON Flattening & Insert into FLATTEN Table

Use `LATERAL FLATTEN` to extract nested JSON fields.

```sql
INSERT OVERWRITE INTO CUSTOMER_DATA.FLATTEN_DATA.CUSTOMER_FLATTEN
SELECT
    f.value:customerid::INT          AS CUSTOMERID,
    f.value:name::STRING             AS NAME,
    f.value:email::STRING            AS EMAIL,
    f.value:region::STRING           AS REGION,
    f.value:country::STRING          AS COUNTRY,
    f.value:productname::STRING      AS PRODUCTNAME,
    f.value:productbrand::STRING     AS PRODUCTBRAND,
    f.value:category::STRING         AS CATEGORY,
    f.value:quantity::INT            AS QUANTITY,
    f.value:priceperunit::FLOAT      AS PRICEPERUNIT,
    f.value:totalsales::FLOAT        AS TOTALSALES,
    f.value:purchasemode::STRING     AS PURCHASEMODE,
    f.value:modeofpayment::STRING    AS MODEOFPAYMENT,
    f.value:purchasedate::DATE       AS PURCHASEDATE
FROM CUSTOMER_DATA.RAW_DATA.CUSTOMER_RAW,
LATERAL FLATTEN(input => JSON_DATA) f;
```

---

# 7. Data Analysis on Flattened Data

---

## 7.1 Total Sales by Region

```sql
SELECT REGION, SUM(TOTALSALES) AS TOTAL_SALES
FROM CUSTOMER_DATA.FLATTEN_DATA.CUSTOMER_FLATTEN
GROUP BY REGION;
```

---

## 7.2 Region with Highest Total Sales

```sql
SELECT REGION, SUM(TOTALSALES) AS TOTAL_SALES
FROM CUSTOMER_DATA.FLATTEN_DATA.CUSTOMER_FLATTEN
GROUP BY REGION
ORDER BY TOTAL_SALES DESC
LIMIT 1;
```

---

## 7.3 Total Quantity Sold per Product Brand

```sql
SELECT PRODUCTBRAND, SUM(QUANTITY) AS TOTAL_QUANTITY
FROM CUSTOMER_DATA.FLATTEN_DATA.CUSTOMER_FLATTEN
GROUP BY PRODUCTBRAND;
```

---

## 7.4 Product with Least Quantity Sold

```sql
SELECT PRODUCTNAME, SUM(QUANTITY) AS TOTAL_QUANTITY
FROM CUSTOMER_DATA.FLATTEN_DATA.CUSTOMER_FLATTEN
GROUP BY PRODUCTNAME
ORDER BY TOTAL_QUANTITY ASC
LIMIT 1;
```

---

## 7.5 Customer with Highest Purchase Amount

```sql
SELECT CUSTOMERID, NAME, SUM(TOTALSALES) AS TOTAL_PURCHASE
FROM CUSTOMER_DATA.FLATTEN_DATA.CUSTOMER_FLATTEN
GROUP BY CUSTOMERID, NAME
ORDER BY TOTAL_PURCHASE DESC
LIMIT 1;
```

---

## 7.6 Product Name & Brand with Lowest Unit Price

```sql
SELECT PRODUCTNAME, PRODUCTBRAND, MIN(PRICEPERUNIT) AS LOWEST_PRICE
FROM CUSTOMER_DATA.FLATTEN_DATA.CUSTOMER_FLATTEN
GROUP BY PRODUCTNAME, PRODUCTBRAND
ORDER BY LOWEST_PRICE ASC
LIMIT 1;
```

---

## 7.7 Top 5 Best‑Selling Products

```sql
SELECT PRODUCTNAME, SUM(QUANTITY) AS TOTAL_QUANTITY
FROM CUSTOMER_DATA.FLATTEN_DATA.CUSTOMER_FLATTEN
GROUP BY PRODUCTNAME
ORDER BY TOTAL_QUANTITY DESC
LIMIT 5;
```

---

## 7.8 Five Countries with Lowest Sales

```sql
SELECT COUNTRY, SUM(TOTALSALES) AS TOTAL_SALES
FROM CUSTOMER_DATA.FLATTEN_DATA.CUSTOMER_FLATTEN
GROUP BY COUNTRY
ORDER BY TOTAL_SALES ASC
LIMIT 5;
```

---

If you want, I can also produce:

- A **combined SQL script**  
- A **dbt model version**  
- A **side‑by‑side comparison** of the structured vs unstructured ETL pipelines  
- A **teaching‑ready lab guide** for deAcademy  

Just tell me where you want to take it next.
