# Transaction_Fraud_Analysis
This is a project where I analyze different transactions made over 30 days with varying types of movements and analyze the fraud relationship between them.

![image](https://github.com/user-attachments/assets/76a5e9d2-d672-4f44-8a94-e81a8c7de2a1)


## General description
This project aims to analyze financial transactions to identify patterns that may indicate fraudulent activity. Through this analysis, it seeks to provide useful insights to improve fraud detection systems in the financial industry.

## Dataset

**Introduction**

This dataset presents a synthetic representation of mobile money transactions, meticulously crafted to mirror the complexities of real-world financial activities while integrating fraudulent behaviors for research purposes. Derived from a simulator named PaySim, which utilizes aggregated data from actual financial logs of a mobile money service in an African country, this dataset aims to fill the gap in publicly available financial datasets for fraud detection studies. It encompasses a variety of transaction types including CASH-IN, CASH-OUT, DEBIT, PAYMENT, and TRANSFER over a simulated period of 30 days, providing a comprehensive environment for evaluating fraud detection methodologies. By addressing the intrinsic privacy concerns associated with financial transactions, this dataset offers a unique resource for researchers and analysts in the field of financial security and fraud detection, scaled to 1/4 of the original dataset size for efficient use within the Kaggle platform. Please note that transactions marked as fraudulent have been nullified, emphasizing the importance of non-balance columns for fraud analysis. This dataset is a contribution to the field from the "Scalable resource-efficient systems for big data analytics" project, funded by the Knowledge Foundation in Sweden.

**Dataset Details**
PaySim synthesizes mobile money transactions using data derived from a month's worth of financial logs from a mobile money service operating in an African country. These logs were provided by a multinational company that offers this financial service across more than 14 countries globally.

This synthetic dataset has been scaled to one-quarter the size of the original dataset and is specifically tailored for Kaggle.

**Dataset Structure**
step: Represents a unit of time in the real world, with 1 step equating to 1 hour. The total simulation spans 744 steps, equivalent to 30 days.
type: Transaction types include CASH-IN, CASH-OUT, DEBIT, PAYMENT, and TRANSFER.
amount: The transaction amount in the local currency.
nameOrig: The customer initiating the transaction.
oldbalanceOrg: The initial balance before the transaction.
newbalanceOrig: The new balance after the transaction.
nameDest: The transaction's recipient customer.
oldbalanceDest: The initial recipient's balance before the transaction. Not applicable for customers identified by 'M' (Merchants).
newbalanceDest: The new recipient's balance after the transaction. Not applicable for 'M' (Merchants).
isFraud: Identifies transactions conducted by fraudulent agents aiming to deplete customer accounts through transfers and cash-outs.

**Previous Research and Acknowledgments**
This dataset has been generated through multiple runs of the PaySim simulator, each simulating a month of real-time transactions over 744 steps. Each run produced approximately 24 million financial records across the five transaction categories.

This project is part of the "Scalable resource-efficient systems for big data analytics" research, supported by the Knowledge Foundation (grant: 20140032) in Sweden.

For citations and further references, please use:

E. A. Lopez-Rojas, A. Elmir, and S. Axelsson. "PaySim: A financial mobile money simulator for fraud detection". In: The 28th European Modeling and Simulation Symposium-EMSS, Larnaca, Cyprus. 2016

**The phases that guided this analysis are the following:**

## **Phase 1: Preprocessing & Data Cleaning with Python (Pandas)**
Objective: Make sure that the data is clean and ready for the posterior analysis on SQL.

**Load and Initial Exploratory:**

Load the dataset into a Pandas DataFrame.

``python
import pandas as pd

data = pd.read_csv('Synthetic_Financial_datasets_log.csv', delimiter = ',')
df = data.copy()
df
``
Inspect the first few rows to familiarize yourself with the structure and content.
``python
df.head()
``
Check the data type for each column.
``python
df.dtypes
``

Handling of Null Values:

Identifies columns with null or missing values.
``python
df.isna().sum()

df.isnull().sum()

``

## **Phase 2: Quantitative & Qualitative Analysis with SQL**  
Objective: Extract valuable information and patterns that help to detect financial fraud.

### Descriptive Analysis:

**Transaction Distribution:**
What is the distribution of transactions by type (e.g., transfer, payment)?

``sql
DROP TABLE IF EXISTS transaction_dist;

SELECT
	dt.transaction_id,
	dt.amount,
	dt.type_id,
	tt.type_name
INTO 
	transaction_dist
FROM 
	dest_transactions dt
JOIN 
	transaction_types tt
ON 
	dt.type_id = tt.type_id;

SELECT * FROM transaction_dist;

SELECT 
	type_name,
	COUNT(*) AS count
FROM 
	transaction_dist
GROUP BY 
	type_name
ORDER BY 
	count DESC;

``

What is the distribution of transaction amounts?
``sql
SELECT 
	type_name,
	COUNT(*) AS count,
	SUM(amount) AS total_amount
FROM 
	transaction_dist
GROUP BY 
	type_name
ORDER BY 
	total_amount DESC;
``

**Fraud Frequency:**
What percentage of total transactions are fraudulent?
``sql
SELECT 
	SUM(isfraud) AS total_frauds,
	COUNT(*) AS total_transactions,
	(SUM(isfraud) * 100.0 / COUNT(*)) AS fraud_percentage
FROM 
	fraud_transaction;
``
How does the frequency of fraud vary depending on the type of transaction?
``sql
SELECT 
	td.transaction_id,
	td.amount,
	td.type_name,
	ft.isfraud
INTO
	fraud_distribution
FROM
	transaction_dist td
JOIN 
	fraud_transaction ft
ON 
	td.transaction_id = ft.transaction_id;

SELECT * FROM fraud_distribution;

-- Solution 1
SELECT
	type_name,
	COUNT(*) AS total_frauds
FROM
	fraud_distribution
WHERE
	isfraud = 1
GROUP BY
	type_name
ORDER BY 
	total_frauds DESC;

-- Solution 2
SELECT
	type_name,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN isFraud = 1 THEN 1 ELSE 0 END) AS total_frauds
FROM
    fraud_distribution
GROUP BY
    type_name
ORDER BY
    total_frauds DESC;
``

### Temporal Analysis:

**Temporal Trends:**
How does the number of transactions and frauds vary over time?
``sql
SELECT
    td.day,
    COUNT(td.transaction_id) AS total_transactions,
    SUM(CASE WHEN ft.isfraud = 1 THEN 1 ELSE 0 END) AS total_frauds
FROM
    transactions_date td
JOIN
    fraud_transaction ft
ON
    td.transaction_id = ft.transaction_id
GROUP BY
    td.day
ORDER BY
    total_transactions DESC;
``
Are there seasonal patterns or peaks in certain periods?
``sql
SELECT
    td.day,
    COUNT(td.transaction_id) AS total_transactions,
    SUM(CASE WHEN ft.isfraud = 1 THEN 1 ELSE 0 END) AS total_frauds
FROM
    transactions_date td
JOIN
    fraud_transaction ft
ON
    td.transaction_id = ft.transaction_id
GROUP BY
    td.day
ORDER BY
    total_transactions DESC;

SELECT
    td.day,
    COUNT(td.transaction_id) AS total_transactions,
    SUM(CASE WHEN ft.isfraud = 1 THEN 1 ELSE 0 END) AS total_frauds
FROM
    transactions_date td
JOIN
    fraud_transaction ft
ON
    td.transaction_id = ft.transaction_id
GROUP BY
    td.day
ORDER BY
    total_frauds DESC;
``
### User and Accounts Analysis:

**Identifying Suspicious Behavior:**
Which accounts have the highest number of fraudulent transactions?
``sql
SELECT * FROM dest_transactions;
SELECT * FROM fraud_transaction;

SELECT 
	dt.namedest,
	SUM(CASE WHEN ft.isfraud = 1 THEN 1 ELSE 0 END) AS total_frauds
FROM 
	dest_transactions dt
JOIN
	fraud_transaction ft
ON
	dt.transaction_id = ft.transaction_id
GROUP BY 
	dt.namedest
ORDER BY
	total_frauds DESC;
``
Are there accounts with multiple high-value transactions in short periods?
``sql
SELECT 
    dt.namedest,
    td.day,
    SUM(dt.amount) AS total_amount,
	SUM(CASE WHEN dt.amount > 1000000 THEN 1 ELSE 0 END) AS high_value_transactions
FROM
    dest_transactions dt
JOIN 
    transactions_date td
ON
    dt.transaction_id = td.transaction_id
WHERE
    dt.amount > 1000000  
GROUP BY 
    dt.namedest,
    td.day
ORDER BY 
    td.day ASC, 
    high_value_transactions DESC;
``

**Relationships between Accounts:**
Are there patterns in transfers between accounts that could indicate fraud rings?
``sql
-- Step 1: Identify high activity accounts

SELECT
    ot.nameOrig AS source_account,
    dt.nameDest AS destination_account,
    COUNT(*) AS transaction_count,
    SUM(ot.amount) AS total_amount
FROM
    orig_transactions ot
JOIN
    dest_transactions dt
ON
    ot.transaction_id = dt.transaction_id
JOIN
    transaction_types tt
ON
    ot.type_id = tt.type_id
WHERE
    tt.type_name = 'TRANSFER' 
GROUP BY
    ot.nameOrig, dt.nameDest
HAVING
    COUNT(*) > 5  
ORDER BY
    transaction_count DESC;

-- Step 2: Find reciprocal transfers

SELECT
    t1.nameOrig AS account_a,
    t2.nameDest AS account_b,
    COUNT(*) AS reciprocal_count,  
    SUM(t1.amount) AS total_amount  
FROM
    orig_transactions t1
JOIN
    dest_transactions t2
ON
    t1.transaction_id = t2.transaction_id  
JOIN
    orig_transactions t3
ON
    t1.nameOrig = t2.nameDest  
JOIN
    dest_transactions t4
ON
    t3.nameOrig = t4.nameDest  
WHERE
    t1.type_id = 2  
GROUP BY
    t1.nameOrig, t2.nameDest
HAVING
    COUNT(*) > 1  
ORDER BY
    COUNT(*) DESC;  


``
### Analysis of Transaction Amounts:

**Anomaly Detection:**
What are the average and maximum amounts of fraudulent versus legitimate transactions?
``sql

SELECT
    ft.isFraud,
    AVG(ot.amount) AS average_amount,
    MAX(ot.amount) AS max_amount
FROM
    orig_transactions ot
JOIN
    fraud_transaction ft
ON
    ot.transaction_id = ft.transaction_id
GROUP BY
    ft.isFraud
ORDER BY
    ft.isFraud DESC;
``
Are there any amount thresholds that are more likely to be fraudulent?
``sql
SELECT
    CASE
        WHEN ot.amount <= 1000 THEN '0-1000'
        WHEN ot.amount <= 10000 THEN '1001-10000'
        WHEN ot.amount <= 50000 THEN '10001-50000'
        WHEN ot.amount <= 100000 THEN '50001-100000'
        WHEN ot.amount <= 500000 THEN '100001-500000'
        ELSE '500001+'
    END AS amount_range,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN ft.isFraud = 1 THEN 1 ELSE 0 END) AS total_frauds,
    ROUND(SUM(CASE WHEN ft.isFraud = 1 THEN 1 ELSE 0 END)::NUMERIC * 100.0 / COUNT(*), 2) AS fraud_percentage
FROM
    orig_transactions ot
JOIN
    fraud_transaction ft
ON
    ot.transaction_id = ft.transaction_id
GROUP BY
    amount_range
ORDER BY
    fraud_percentage DESC;
``
