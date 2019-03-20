/*
create a running total of standard_amt_usd (in the orders table) over order time with no date truncation.
Your final table should have two columns: one with the amount being added for each new row, and a second with the running total.
*/

SELECT occurred_at, standard_amt_usd,
SUM(standard_amt_usd) OVER(ORDER BY occurred_at)
FROM orders

/*
Now, modify your query from the previous quiz to include partitions. 
Still create a running total of standard_amt_usd (in the orders table) over order time, but this time,
date truncate occurred_at by year and partition by that same year-truncated occurred_at variable. 
Your final table should have three columns:
One with the amount being added for each row, one for the truncated date, and a final column with the running total within each year.
*/

SELECT occurred_at, standard_amt_usd, DATE_TRUNC('year', occurred_at),
SUM(standard_amt_usd) OVER(PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at)  --ORDER_BY occurred_at gradual row by row sum for tuncated partition
FROM orders


/*
Select the id, account_id, and total variable from the orders table, 
then create a column called total_rank that ranks this total amount of paper ordered (from highest to lowest) 
for each account using a partition. Your final table should have these four columns.
*/

SELECT id, account_id, total, 
RANK() OVER(PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders
/*

The ORDER BY clause is one of two clauses integral to window functions.
 The ORDER and PARTITION define what is referred to as the “window”—the ordered subset of data over which calculations are made.
 Removing ORDER BY just leaves an unordered partition;
in our query's case, each column's value is simply an aggregation (e.g., sum, count, average, minimum, or maximum)
 of all the standard_qty values in its respective account_id.

As Stack Overflow user mathguy explains:

The easiest way to think about this -
 leaving the ORDER BY out is equivalent to "ordering" in a way that all rows in the partition are "equal" to each other.
 Indeed, you can get the same effect by explicitly adding the ORDER BY clause like this:
 ORDER BY 0 (or "order by" any constant expression), or even, more emphatically, ORDER BY NULL.

*/


SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
	   RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS rank,
	   ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS row_number,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders

/*
create and use an alias to shorten the following query (which is different than the one in Derek's previous video)
that has multiple window functions. Name the alias account_year_window,
which is more descriptive than main_window in the example above.
*/

SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       SUM(total_amt_usd) OVER account_year_window  AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window  AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window  AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window  AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window  AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS(PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))

/*
Scenarios for using LAG and LEAD functions
You can use LAG and LEAD functions whenever you are trying to
compare the values in adjacent rows or rows that are offset by a certain number.
LAG  (expression [,offset] [,default])
LEAD (expression [,offset] [,default])
 LEAD (price, 1)

expression – a column or expression to compute the returned value.
 offset – the number of rows preceding ( LAG)/ following ( LEAD) the current row. The default value of offset is 1.
 default – the default returned value if the offset is outside the scope of the window. The default of the default is NULL.
*/
-- difference in amount between  orders 

SELECT     id, account_id, total_amt_usd, occurred_at,
           LAG(total_amt_usd) OVER lead_lag_windows AS lag_amount, 
		   LEAD(total_amt_usd) OVER lead_lag_windows AS lead_amount,
		   LEAD(total_amt_usd) OVER lead_lag_windows - total_amt_usd AS diff_lag_lead_amt
		
FROM       orders
WINDOW lead_lag_windows AS (PARTITION BY account_id ORDER BY occurred_at)

-- difference in time between in orders / and amount

SELECT     id, account_id, total_amt_usd, occurred_at,
           LAG(total_amt_usd) OVER lead_lag_windows AS lag_amount, 
		   LEAD(total_amt_usd) OVER lead_lag_windows AS lead_amount,
		   LEAD(total_amt_usd) OVER lead_lag_windows - total_amt_usd AS diff_lag_lead_amt,
		   LEAD(occurred_at) OVER lead_lag_windows - occurred_at AS diff_lag_lead_time
		
FROM       orders
WINDOW lead_lag_windows AS (PARTITION BY account_id ORDER BY occurred_at)

-- how the current order's total revenue ("total" meaning from sales of all types of paper) compares to the next order's total revenue.
SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (  -- this piece not really needed since, timestamp is so discrete sum does not do any thing
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders 
 GROUP BY 1
) sub

/*
Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders.
Your resulting table should have the account_id, the occurred_at time for each order, 
the total amount of standard_qty paper purchased, and one of four levels in a standard_quartile column.
*/

SELECT account_id, sum_standard_qty, 
NTILE(4) OVER (ORDER BY sum_standard_qty) AS quartile
FROM
(SELECT account_id, SUM(standard_qty) sum_standard_qty   -- over all purchases that accout 
FROM orders
GROUP BY account_id) t1
ORDER BY sum_standard_qty DESC

-- NTILE(4) based on all purchases regardless of account
SELECT account_id, occurred_at, standard_qty,
NTILE(4) OVER (ORDER BY standard_qty) AS quartile
FROM orders
ORDER BY standard_qty DESC

-- NTILE(4) based on all purchases of each account
SELECT
       account_id,
       occurred_at,
       standard_qty,
       NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
  FROM orders 
 ORDER BY account_id DESC
 
 
 /*
Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders.
Your resulting table should have the account_id, 
the occurred_at time for each order, the total amount of gloss_qty paper purchased, 
and one of two levels in a gloss_half column.
*/

-- divide account based on total purchased
SELECT account_id, sum_gloss_qty,
NTILE(2) OVER(ORDER BY sum_gloss_qty) ntile_2
FROM
(SELECT account_id, SUM(gloss_qty) sum_gloss_qty
FROM orders
GROUP BY account_id) t1
ORDER BY sum_gloss_qty DESC

-- divide each account into to layer in time

SELECT account_id, occurred_at, gloss_qty,
NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) gloss_half
FROM orders
ORDER BY account_id, gloss_qty DESC

/*
Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders.
Your resulting table should have the account_id,
the occurred_at time for each order, the total amount of total_amt_usd paper purchased, and one of 100 levels in a total_percentile column.
*/


--if the count of rows in a partition is less than 100, the highest value of NTILE() will be the row count in that partition.

SELECT account_id, occurred_at, total_amt_usd,
NTILE(20) OVER win AS total_percentile_int, CAST(NTILE(20) OVER win AS decimal(6,4)) -- cannot divide if NTILE(n) n> row count per partiotion
FROM orders
WINDOW win AS(PARTITION BY account_id ORDER BY total_amt_usd)
ORDER BY account_id, total_amt_usd DESC


--median
/*
Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders.
Your resulting table should have the account_id,
the occurred_at time for each order, the total amount of total_amt_usd paper purchased, and one of 100 levels in a total_percentile column.
*/

SELECT AVG(id)
FROM
(SELECT id, count_tot, rownum,
 NTILE(2) OVER (ORDER BY rownum) AS ntile2,
CASE 
	WHEN (count_tot% 2 =0 AND rownum IN (count_tot/2,count_tot/2+1)) THEN 'tag'
	WHEN (count_tot% 2 =1 AND rownum IN (count_tot/2+1)) THEN 'tag'
	ELSE 'no'
	END AS column_tag
FROM
(SELECT id, (SELECT COUNT(id) FROM orders) count_tot,
ROW_NUMBER() OVER (ORDER BY id) AS rownum
FROM orders) t1
ORDER BY id ASC
 ) t2
 WHERE column_tag = 'tag'



SELECT id,
FIRST_VALUE(id) OVER (ORDER BY id) AS first,
LAST_VALUE(id) OVER (ORDER BY id RANGE BETWEEN UNBOUNDED PRECEDING
 AND UNBOUNDED FOLLOWING) AS last,
LEAD(id) OVER (ORDER BY id) AS lead,
LAG(id) OVER (ORDER BY id) AS lag,
LEAD(id) OVER (ORDER BY id) - id AS diff
FROM orders

SELECT account_id, occurred_at,
FIRST_VALUE(occurred_at) OVER (PARTITION BY account_id ORDER BY occurred_at) AS first,
LAST_VALUE(occurred_at) OVER (PARTITION BY account_id ORDER BY occurred_at RANGE BETWEEN UNBOUNDED PRECEDING
 AND UNBOUNDED FOLLOWING) AS last,
RANK() OVER (PARTITION BY account_id ORDER BY occurred_at) AS rank,
NTILE(2) OVER (PARTITION BY account_id ORDER BY occurred_at) AS ntile,
LEAD(occurred_at) OVER (PARTITION BY account_id ORDER BY occurred_at) AS lead,
LAG(occurred_at) OVER (PARTITION BY account_id ORDER BY occurred_at) AS lag,
LEAD(occurred_at) OVER (PARTITION BY account_id ORDER BY occurred_at) - occurred_at AS diff
FROM orders
ORDER BY account_id, occurred_at 