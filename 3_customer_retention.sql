WITH customer_purchase AS
(
	SELECT 
		ca.customerkey,
		MAX(ca.name) AS name,
		MAX(ca.orderdate) AS last_purchase_date,
		MAX(ca.first_purchase_date) AS first_purchase_date,
		MAX(ca.cohort_year) AS cohort_year
	FROM 
		cohort_analysis  ca
	GROUP BY
		ca.customerkey
),
customer_retention_segment AS 
(
	SELECT
		customerkey,
		name,
		last_purchase_date,
		CASE 
			WHEN last_purchase_date < (SELECT MAX(orderdate) FROM cohort_analysis) - INTERVAL '6 months' THEN 'Churn'
			ELSE 'Active'
		END AS customer_status,
		cohort_year
	FROM
		customer_purchase
	WHERE
		first_purchase_date < (SELECT MAX(orderdate) FROM cohort_analysis) - INTERVAL '6 months'
)

SELECT
	cohort_year,
	customer_status,
	COUNT(customer_status) AS num_customers,
	SUM(COUNT(customer_status)) OVER(PARTITION BY cohort_year) AS total_customers,
	ROUND(COUNT(customer_status) / SUM(COUNT(customer_status)) OVER(PARTITION BY cohort_year), 2) AS status_percentage
FROM 
	customer_retention_segment
GROUP BY
	cohort_year,
	customer_status