-- Fase 2: Análisis Cuantitativo y Cualitativo con SQL
-- Objetivo: Extraer información valiosa y patrones que ayuden a detectar fraudes financieros.

-- Análisis Descriptivo

-- Distribución de Transacciones:
-- ¿Cuál es la distribución de las transacciones por tipo (e.g., transferencia, pago)?
-- ¿Cuál es la distribución de los montos de cada tipo de transacción?

-- Frecuencia de Fraudes:
-- ¿Qué porcentaje del total de transacciones son fraudulentas?
-- ¿Cómo varía la frecuencia de fraudes según el tipo de transacción?

-- Análisis Temporal

-- Tendencias Temporales:
-- ¿Cómo varía el número de transacciones y fraudes a lo largo del tiempo?
-- ¿Existen patrones estacionales o picos en ciertos períodos?

-- Análisis de Usuarios y Cuentas

-- Identificación de Comportamientos Sospechosos:

-- ¿Qué cuentas tienen el mayor número de transacciones fraudulentas?
-- ¿Existen cuentas con múltiples transacciones de alto valor en cortos períodos?

-- Relaciones entre Cuentas:

-- ¿Hay patrones en las transferencias entre cuentas que puedan indicar redes de fraude?

-- Análisis de Montos de Transacciones:

-- Detección de Anomalías:
-- ¿Cuáles son los montos promedio y máximos de las transacciones fraudulentas versus las legítimas?
-- ¿Existen umbrales de monto que sean más propensos a ser fraudulentos?

-- Pregunta 1: ¿Cuál es la distribución de las transacciones por tipo (e.g., transferencia, pago)?
SELECT * FROM transaction_types;

SELECT * FROM dest_transactions;

-- Mapear los IDs en la tabla transaction_types

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

-- Pregunta 2: ¿Cuál es la distribución de los montos de cada tipo de transacción?

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
	
-- Pregunta 3: ¿Qué porcentaje del total de transacciones son fraudulentas?

SELECT 
	SUM(isfraud) AS total_frauds,
	COUNT(*) AS total_transactions,
	(SUM(isfraud) * 100.0 / COUNT(*)) AS fraud_percentage
FROM 
	fraud_transaction;

-- Pregunta 5: ¿Cómo varía la frecuencia de fraudes según el tipo de transacción?

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

-- Solucion 1
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

-- Solucion 2
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

-- Pregunta 6: ¿Cómo varía el número de transacciones y fraudes a lo largo del tiempo?

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

-- El dia numero 1 fue el dia en el que mas transacciones se registraron con 574255, seguidos del dia 2 con 455238 y luego el dia 8 con 449637.
-- El dia numero 17 fue el dia que mas registro fraudes con 320, seguidos del dia 3 con 310 y luego el dia 2 con 309.
-- Sin embargo hay un hallazgo interesante en el dia 3, ya que siendo este dia el penultimo dia con menos transacciones, 1070 registradas,
-- tambien es uno de los dias en el que mas fraudes se detectaron lo que podria sugerir una futura investigacion mas a fondo de este dia en particular.

-- Pregunta 7: ¿Existen patrones estacionales o picos en ciertos períodos?

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

-- Si, ya que el dia en el que mas transacciones se registraron fue el dia 1 con 574255 el de menores transacciones fue el 31 con 272

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

-- Aqui la fluctuacion no fue tan extrema como en el caso de las transacciones, el dia con mas fraudes registrados fue el dia 17 con 320 y el
-- dia con menos fue de 216.

-- Pregunta 8: ¿Qué cuentas tienen el mayor número de transacciones fraudulentas?

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

-- Las primeras 44 cuentas que aparecen tienen 2 fraudes asociados y este es el maximo de fraudes asociados a todas las cuentas

-- Pregunta 9: ¿Existen cuentas con múltiples transacciones de alto valor en cortos períodos?

-- Alto valor: los pagos de alto valor son transacciones que implican la transferencia de grandes 
-- sumas de dinero entre bancos u otras instituciones financieras.
-- Por lo general, estos pagos son por montos superiores a $ 100,000

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

-- Si existen

-- Pregunta 10: ¿Hay patrones en las transferencias entre cuentas que puedan indicar redes de fraude?

-- Paso 1: Identificar Cuentas con Alta Actividad de Transferencias

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
    tt.type_name = 'TRANSFER'  -- Filtrar solo transferencias
GROUP BY
    ot.nameOrig, dt.nameDest
HAVING
    COUNT(*) > 5  -- Filtrar relaciones con más de 5 transferencias
ORDER BY
    transaction_count DESC;

-- Paso 2: Encontrar Transferencias Recíprocas

SELECT
    t1.nameOrig AS account_a,
    t2.nameDest AS account_b,
    COUNT(*) AS reciprocal_count,  -- Alias para contar transacciones recíprocas
    SUM(t1.amount) AS total_amount  -- Suma de los montos originales
FROM
    orig_transactions t1
JOIN
    dest_transactions t2
ON
    t1.transaction_id = t2.transaction_id  -- Relaciona origen y destino
JOIN
    orig_transactions t3
ON
    t1.nameOrig = t2.nameDest  -- Relación de ida
JOIN
    dest_transactions t4
ON
    t3.nameOrig = t4.nameDest  -- Relación de vuelta
WHERE
    t1.type_id = 2  -- Filtrar solo transacciones de tipo "TRANSFER"
GROUP BY
    t1.nameOrig, t2.nameDest
HAVING
    COUNT(*) > 1  -- Condición para relaciones recíprocas frecuentes
ORDER BY
    COUNT(*) DESC;  -- Ordena por la cantidad de transacciones recíprocas


-- Pregunta 11: ¿Cuáles son los montos promedio y máximos de las transacciones fraudulentas versus las legítimas?

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

-- Pregunta 12: ¿Existen umbrales de monto que sean más propensos a ser fraudulentos?

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

-- El rango 500001+ tiene la proporción más alta de fraudes, con un 1.14% de transacciones fraudulentas. 
-- Aunque representa una pequeña proporción de todas las transacciones, este rango tiene un mayor riesgo asociado a montos altos.

-- Los rangos más bajos, como 0-1000 y 1001-10000, tienen una proporción significativamente menor de fraudes (0.04% y 0.02%, respectivamente), 
-- lo que indica que las transacciones de bajo monto son menos susceptibles a fraudes.

