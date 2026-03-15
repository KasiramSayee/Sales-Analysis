--Title: Customer Revenue by Cohort (NOT adjusted for time in market)
SELECT 
	cohort_year,
	SUM(total_net_revenue) AS total_cohort_revenue,
	COUNT(DISTINCT customerkey) AS customer_count,
	SUM(total_net_revenue)/ COUNT(DISTINCT customerkey) AS avg_customer_ltv
FROM 
	cohort_analysis
GROUP BY
	cohort_year;
	

-- Title: Customer Revenue by days since first urchase for adjusting time in market
WITH purchase_data AS
(
	SELECT 
		customerkey,
		orderdate,
		first_purchase_date,
		orderdate - first_purchase_date AS days_since_first_purchase,
		total_net_revenue
	FROM 
		cohort_analysis
)


SELECT
	days_since_first_purchase,
	SUM(total_net_revenue) AS total_net_revenue,
	SUM(total_net_revenue) / (SELECT SUM(total_net_revenue) FROM purchase_data) * 100 AS percentage_net_revenue,
	SUM(SUM(total_net_revenue) / (SELECT SUM(total_net_revenue) FROM purchase_data) * 100) OVER(ORDER BY days_since_first_purchase) AS cumulative_net_revenue
FROM
	purchase_data
GROUP BY
	days_since_first_purchase
ORDER BY
	days_since_first_purchase;


-- Title: Customer Revenue by Cohort (Adjusted for time in market) - Only First Purchase Date
SELECT 
	cohort_year,
	SUM(total_net_revenue) AS total_cohort_revenue,
	COUNT(DISTINCT customerkey) AS customer_count,
	SUM(total_net_revenue)/ COUNT(DISTINCT customerkey) AS avg_customer_ltv
FROM 
	cohort_analysis
WHERE
	orderdate = first_purchase_date
GROUP BY
	cohort_year;	