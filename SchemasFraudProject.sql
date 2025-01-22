-- Financial Fraud Transaction Project

-- Crear tabla de tipo de transaccion

DROP TABLE IF EXISTS transaction_types;

CREATE TABLE transaction_types(
			type_id INT PRIMARY KEY,
			type_name VARCHAR(20)
);

DROP TABLE IF EXISTS orig_transactions;

CREATE TABLE orig_transactions(
			transaction_ID INT PRIMARY KEY,
			amount FLOAT,
			nameOrig VARCHAR(50),
			oldbalanceOrig FLOAT,
			newbalanceOrig FLOAT,
			type_id INT
);

DROP TABLE IF EXISTS dest_transactions;

CREATE TABLE dest_transactions(
			transaction_ID INT PRIMARY KEY,
			amount FLOAT,
			nameDest VARCHAR(50),
			oldbalanceDest FLOAT,
			newbalanceDest FLOAT,
			type_id INT
);

DROP TABLE IF EXISTS transactions_date;

CREATE TABLE transactions_date(
			transaction_ID INT PRIMARY KEY,
			hour INT,
			day INT
);

DROP TABLE IF EXISTS fraud_transaction;

CREATE TABLE fraud_transaction(
			transaction_ID INT PRIMARY KEY,
			isFraud INT,
			isFlaggedFraud INT
);

-- Relación entre transactions_date y orig_transactions
ALTER TABLE transactions_date
ADD CONSTRAINT fk_transactions_date_orig
FOREIGN KEY (transaction_ID) REFERENCES orig_transactions(transaction_ID);

-- Relación entre transactions_date y dest_transactions
ALTER TABLE transactions_date
ADD CONSTRAINT fk_transactions_date_dest
FOREIGN KEY (transaction_ID) REFERENCES dest_transactions(transaction_ID);

-- Relación entre fraud_transaction y orig_transactions
ALTER TABLE fraud_transaction
ADD CONSTRAINT fk_fraud_transaction_orig
FOREIGN KEY (transaction_ID) REFERENCES orig_transactions(transaction_ID);

-- Relación entre fraud_transaction y dest_transactions
ALTER TABLE fraud_transaction
ADD CONSTRAINT fk_fraud_transaction_dest
FOREIGN KEY (transaction_ID) REFERENCES dest_transactions(transaction_ID);

ALTER TABLE orig_transactions
ADD CONSTRAINT fk_transaction_type
FOREIGN KEY (type_id) REFERENCES transaction_types(type_id);

ALTER TABLE dest_transactions
ADD CONSTRAINT fk_transaction_type
FOREIGN KEY (type_id) REFERENCES transaction_types(type_id);

