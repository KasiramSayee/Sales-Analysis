WITH customer_ltv AS 
(
	SELECT 
		customerkey,
		name,
		SUM(total_net_revenue) AS total_ltv		
	FROM cohort_analysis
	GROUP BY
		customerkey,
		name
),
segment_values AS 
(
	SELECT
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS p25,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS p75
	FROM
		customer_ltv
),
customer_segments AS
(
	SELECT 
		customerkey,
		name,
		total_ltv,
		CASE 
			WHEN total_ltv <= (SELECT p25 FROM segment_values) THEN '1 - Low Value'
			WHEN total_ltv <= (SELECT p75 FROM segment_values) THEN '2 - Mid Value'
			ELSE '3 - High Value'
		END AS customer_segment
	FROM
		customer_ltv
)

SELECT 
	customer_segment,
	SUM(total_ltv) AS total_ltv,
	SUM(total_ltv) / (SELECT SUM(total_ltv) FROM customer_segments) AS percentage_total_ltv,
	COUNT(customer_segment) AS customer_count,
	COUNT(customer_segment)::numeric / (SELECT COUNT(customer_segment) FROM customer_segments) AS percentage_customer_count,
	SUM(total_ltv) / COUNT(customer_segment) AS avg_ltv
FROM
	customer_segments
GROUP BY 
	customer_segment
ORDER BY
	customer_segment DESC