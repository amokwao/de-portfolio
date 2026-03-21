
# Structured Data + Internal Stage + Copy Command + Data Transformation  
## Mini Project — Snowflake ETL Pipeline

---

## Project Overview

In this mini‑project, you will:

- Load employee data from a **CSV file** into a **raw table** in Snowflake using an **internal stage**  
- Perform **complex SQL transformations** on the raw data  
- Load the transformed results into a **new transformed table** for analytics  

---

## Objectives

- Work with **Snowflake Internal Stages**  
- Use the **COPY INTO** command to load structured data  
- Perform **SQL‑based data transformations**  
- Build **RAW** and **TRANSFORMED** data layers for analytics  

---

## Tools & Technologies

| Tool / Technology | Purpose |
|------------------|---------|
| Snowflake | Cloud data warehouse |
| Snowflake Web UI | SQL execution & data loading |
| CSV File | Employee dataset |

---

## Architecture

*(Insert your architecture diagram here — Raw → Stage → Raw Table → Transform → Transformed Table → Analytics)*
![alt text](image.png)
---

# High‑Level Step‑by‑Step Implementation

---

## 1. Create Database & Schemas

```sql
CREATE DATABASE EMPLOYEE_DATA;

CREATE SCHEMA EMPLOYEE_DATA.RAW_DATA;
CREATE SCHEMA EMPLOYEE_DATA.TRANSFORMED_DATA;
```

---

## 2. Create RAW Table (RAW_DATA Schema)

**Table:** `EMPLOYEE_DATA.RAW_DATA.EMPLOYEE_RAW`

### Table Structure

| Column Name | Data Type |
|-------------|-----------|
| EMPLOYEE_ID | STRING |
| FIRST_NAME | STRING |
| LAST_NAME | STRING |
| DEPARTMENT | STRING |
| SALARY | DECIMAL(10,2) |
| HIRE_DATE | DATE |
| LOCATION | STRING |

```sql
CREATE OR REPLACE TABLE EMPLOYEE_DATA.RAW_DATA.EMPLOYEE_RAW (
    EMPLOYEE_ID STRING,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    DEPARTMENT STRING,
    SALARY DECIMAL(10,2),
    HIRE_DATE DATE,
    LOCATION STRING
);
```

---

## 3. Create TRANSFORMED Table (TRANSFORMED_DATA Schema)

**Table:** `EMPLOYEE_DATA.TRANSFORMED_DATA.EMPLOYEE_TRANSFORMED`

### Table Structure

| Column Name | Data Type |
|-------------|-----------|
| EMPLOYEE_ID | STRING |
| FULL_NAME | STRING |
| DEPARTMENT | STRING |
| ANNUAL_SALARY | DECIMAL(10,2) |
| HIRE_DATE | DATE |
| EXPERIENCE_LEVEL | STRING |
| TENURE_DAYS | STRING |
| STATE | STRING |
| COUNTRY | STRING |
| BONUS_ELIGIBILITY | STRING |
| HIGH_POTENTIAL_FLAG | STRING |

```sql
CREATE OR REPLACE TABLE EMPLOYEE_DATA.TRANSFORMED_DATA.EMPLOYEE_TRANSFORMED (
    EMPLOYEE_ID STRING,
    FULL_NAME STRING,
    DEPARTMENT STRING,
    ANNUAL_SALARY DECIMAL(10,2),
    HIRE_DATE DATE,
    EXPERIENCE_LEVEL STRING,
    TENURE_DAYS STRING,
    STATE STRING,
    COUNTRY STRING,
    BONUS_ELIGIBILITY STRING,
    HIGH_POTENTIAL_FLAG STRING
);
```

---

## 4. Upload CSV to Internal Stage

### Create Stage

```sql
CREATE OR REPLACE STAGE EMPLOYEE_DATA.RAW_DATA.EMPLOYEE_STAGE;
```

### Upload File  
Use Snowflake Web UI → Load Data → Select Stage.

### List Files in Stage

```sql
LIST @EMPLOYEE_DATA.RAW_DATA.EMPLOYEE_STAGE;
```

---

## 5. Load Data into RAW Table

```sql
COPY INTO EMPLOYEE_DATA.RAW_DATA.EMPLOYEE_RAW
FROM @EMPLOYEE_DATA.RAW_DATA.EMPLOYEE_STAGE
FILE_FORMAT = (
    TYPE = 'CSV',
    FIELD_OPTIONALLY_ENCLOSED_BY = '"',
    SKIP_HEADER = 1
);
```

---

## 6. Transform & Load into TRANSFORMED Table

### Transformation Rules

- **FULL_NAME** = FIRST_NAME + ' ' + LAST_NAME  
- **ANNUAL_SALARY** = SALARY × 12  
- **EXPERIENCE_LEVEL**  
  - `< 1 year` → New Hire  
  - `1–5 years` → Mid‑level  
  - `> 5 years` → Senior  
- **TENURE_DAYS** = DATEDIFF('day', HIRE_DATE, CURRENT_DATE)  
- **STATE** = text before `-` in LOCATION  
- **COUNTRY** = text after `-` in LOCATION  
- **BONUS_ELIGIBILITY** = salary > 10000 → Yes  
- **HIGH_POTENTIAL_FLAG** = tenure > 3 years → Yes  

### Insert Transformed Data

```sql
INSERT INTO EMPLOYEE_DATA.TRANSFORMED_DATA.EMPLOYEE_TRANSFORMED
SELECT
    EMPLOYEE_ID,
    FIRST_NAME || ' ' || LAST_NAME AS FULL_NAME,
    DEPARTMENT,
    SALARY * 12 AS ANNUAL_SALARY,
    HIRE_DATE,
    CASE
        WHEN DATEDIFF('year', HIRE_DATE, CURRENT_DATE) < 1 THEN 'New Hire'
        WHEN DATEDIFF('year', HIRE_DATE, CURRENT_DATE) BETWEEN 1 AND 5 THEN 'Mid-level'
        ELSE 'Senior'
    END AS EXPERIENCE_LEVEL,
    DATEDIFF('day', HIRE_DATE, CURRENT_DATE) AS TENURE_DAYS,
    SPLIT_PART(LOCATION, '-', 1) AS STATE,
    SPLIT_PART(LOCATION, '-', 2) AS COUNTRY,
    CASE WHEN SALARY > 10000 THEN 'Yes' ELSE 'No' END AS BONUS_ELIGIBILITY,
    CASE WHEN DATEDIFF('year', HIRE_DATE, CURRENT_DATE) > 3 THEN 'Yes' ELSE 'No' END AS HIGH_POTENTIAL_FLAG
FROM EMPLOYEE_DATA.RAW_DATA.EMPLOYEE_RAW;
```

---

# Data Analysis on Transformed Data

---

## 1. Employee Count by Department

```sql
SELECT DEPARTMENT, COUNT(*) AS EMP_COUNT
FROM EMPLOYEE_DATA.TRANSFORMED_DATA.EMPLOYEE_TRANSFORMED
GROUP BY DEPARTMENT;
```

---

## 2. Employee Count by Country

```sql
SELECT COUNTRY, COUNT(*) AS EMP_COUNT
FROM EMPLOYEE_DATA.TRANSFORMED_DATA.EMPLOYEE_TRANSFORMED
GROUP BY COUNTRY;
```

---

## 3. Employees Hired Within Last 12 Months

```sql
SELECT *
FROM EMPLOYEE_DATA.TRANSFORMED_DATA.EMPLOYEE_TRANSFORMED
WHERE DATEDIFF('month', HIRE_DATE, CURRENT_DATE) <= 12;
```

---

## 4. Top 10% Highest‑Paid Employees

```sql
SELECT *
FROM EMPLOYEE_DATA.TRANSFORMED_DATA.EMPLOYEE_TRANSFORMED
QUALIFY PERCENT_RANK() OVER (ORDER BY ANNUAL_SALARY DESC) <= 0.10;
```

---

## 5. Total Salary Expense per Department per Year

```sql
SELECT 
    YEAR(HIRE_DATE) AS YEAR,
    DEPARTMENT,
    SUM(ANNUAL_SALARY) AS TOTAL_SALARY_EXPENSE
FROM EMPLOYEE_DATA.TRANSFORMED_DATA.EMPLOYEE_TRANSFORMED
GROUP BY YEAR, DEPARTMENT
ORDER BY YEAR, TOTAL_SALARY_EXPENSE DESC;
```

---

## 6. Employees with 5+ Years Tenure

```sql
SELECT *
FROM EMPLOYEE_DATA.TRANSFORMED_DATA.EMPLOYEE_TRANSFORMED
WHERE DATEDIFF('year', HIRE_DATE, CURRENT_DATE) >= 5;
```

---
