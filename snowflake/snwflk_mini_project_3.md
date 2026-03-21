
# 1. Recover Accidentally Deleted Data Using Time Travel  
## Mini Project — Snowflake Time Travel with CSV‑Loaded Table

---

## 2. Problem Statement

An analyst accidentally deletes records from the `EMPLOYEE` table.  
The data in this table was originally loaded from a **CSV file** stored in an **internal stage**.  
The deleted data is critical, and the team needs to recover it **without downtime**, **without reloading from CSV**, and **without backup restoration**.

Snowflake’s **Time Travel** feature allows us to recover the deleted data directly from table history.

---

## 3. Project Overview

In this mini project, you will:

- Load employee data from `employee_data.csv` into an `EMPLOYEE` table using an **internal stage** and **COPY INTO**  
- Simulate accidental deletion of specific employee records  
- Use **Snowflake Time Travel** to query the table **as it existed before the deletion**  
- Restore the deleted rows back into the live `EMPLOYEE` table  

---

## 4. Tools & Technologies

| Tool / Technology | Purpose |
|------------------|---------|
| Snowflake | Cloud data warehouse |
| Snowflake Web UI | SQL execution environment |
| CSV File (`employee_data.csv`) | Source employee dataset |

---

# 5. High‑Level Step‑by‑Step Implementation

---

## 5.1 Create Database & Schema

```sql
CREATE DATABASE IF NOT EXISTS TIMETRAVEL_DB;

CREATE SCHEMA IF NOT EXISTS TIMETRAVEL_DB.TIMETRAVEL_DATA;
```

---

## 5.2 Create EMPLOYEE Table

**Location:**  
- **Database:** `TIMETRAVEL_DB`  
- **Schema:** `TIMETRAVEL_DATA`  
- **Table:** `EMPLOYEE`

### Table Structure

| Column Name  | Data Type |
|--------------|-----------|
| EMPLOYEE_ID  | STRING    |
| FIRST_NAME   | STRING    |
| LAST_NAME    | STRING    |
| DEPARTMENT   | STRING    |
| SALARY       | FLOAT     |
| HIRE_DATE    | DATE      |
| LOCATION     | STRING    |

```sql
CREATE OR REPLACE TABLE TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE (
    EMPLOYEE_ID STRING,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    DEPARTMENT STRING,
    SALARY FLOAT,
    HIRE_DATE DATE,
    LOCATION STRING
);
```

---

## 5.3 Create Internal Stage and File Format

### Create Internal Stage

```sql
CREATE OR REPLACE STAGE TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE_STAGE;
```

### Create File Format for CSV

```sql
CREATE OR REPLACE FILE FORMAT TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE_CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';
```

---

## 5.4 Upload `employee_data.csv` to Internal Stage

Use **Snowflake Web UI**:

- Go to **Databases → TIMETRAVEL_DB → TIMETRAVEL_DATA → STAGES → EMPLOYEE_STAGE**  
- Upload `employee_data.csv` into `EMPLOYEE_STAGE`

### Verify File in Stage

```sql
LIST @TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE_STAGE;
```

---

## 5.5 Load Data from Stage into EMPLOYEE Table

```sql
COPY INTO TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE
FROM @TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE_STAGE
FILE_FORMAT = (FORMAT_NAME = TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE_CSV_FORMAT);
```

---

## 5.6 View Current Data

```sql
SELECT *
FROM TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE;
```

---

## 5.7 Simulate Accidental Deletion

Delete a couple of employees (for example, `E002` and `E007`) to simulate accidental deletion.  
(Use IDs that actually exist in your `employee_data.csv`.)

```sql
DELETE FROM TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE
WHERE EMPLOYEE_ID IN ('E002', 'E007');
```

---

## 5.8 Verify the Deletion

```sql
SELECT *
FROM TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE;
```

You should no longer see the deleted employee IDs.

---

## 5.9 Fetch the QUERY_ID of the DELETE Statement

```sql
SELECT QUERY_ID, QUERY_TEXT, START_TIME
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE QUERY_TEXT ILIKE '%DELETE FROM TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE%'
ORDER BY START_TIME DESC
LIMIT 1;
```

Copy the `QUERY_ID` from this result.

---

# 6. Recovering Deleted Data Using Time Travel

---

## 6.1 View Historical Data Before Deletion

Replace `<QUERY_ID>` with the actual ID from the previous step.

```sql
SELECT *
FROM TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE
BEFORE (STATEMENT => '<QUERY_ID>');
```

This shows the table **exactly as it was before the delete**.

---

## 6.2 Restore the Deleted Records

```sql
INSERT INTO TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE
SELECT *
FROM TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE
BEFORE (STATEMENT => '<QUERY_ID>')
WHERE EMPLOYEE_ID IN ('E002', 'E007');
```

---

## 6.3 Verify the Recovery

```sql
SELECT *
FROM TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE
ORDER BY EMPLOYEE_ID;
```

You should now see the previously deleted employees restored.

---

## 6.4 Optional: Use Time Offset Instead of Statement

As an alternative, if you know the approximate time of deletion, you can use a **time offset**:

```sql
SELECT *
FROM TIMETRAVEL_DB.TIMETRAVEL_DATA.EMPLOYEE
AT (OFFSET => -60);  -- 60 seconds before current time
```

---