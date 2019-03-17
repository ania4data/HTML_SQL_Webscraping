/* average of number of events for each day for each channel.
 The first table will provide us the number of events for each day and channel,
 and then we will need to average these values together using a second query */
SELECT count_tbl.channel, ROUND(AVG(count_tbl.count_day_event),2) avg_count_per_channel
FROM
	(SELECT DATE_TRUNC('day', w.occurred_at), w.channel, COUNT(*) count_day_event
	FROM web_events w
	GROUP BY DATE_TRUNC('day', w.occurred_at), w.channel
	ORDER BY count_day_event DESC) count_tbl
GROUP BY count_tbl.channel
ORDER BY avg_count_per_channel DESC

-- not include an alias when you write a subquery in a conditional statement.
--This is because the subquery is treated as an individual value (or set of values in the IN case) rather than as a table.
 -- If we returned an entire column IN would need to be used to perform a logical argument. If we are returning an entire table,
-- then we must use an ALIAS for the table, and perform additional logic on the entire table.
 
 /* get month of first orders from order table, get all orders as min month (2013-12-01 00:00:00)
for this particular month find the avg of quantity for each type of paper and sum money spent
*/

SELECT DATE_TRUNC('month', occurred_at), AVG(standard_qty), AVG(gloss_qty), AVG(poster_qty), SUM(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
	(SELECT DATE_TRUNC('month', MIN(o.occurred_at))
	FROM orders o)
GROUP BY DATE_TRUNC('month', occurred_at)
-- correct also when no date, no need groupby
SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gls, AVG(poster_qty) avg_pst
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
     (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);
     
/*
Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
*/


SELECT s.name sale_rep, r.name region_name, total_amt_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
	WHERE total_amt_usd IN 
	(SELECT MAX(total_amt_usd)
	FROM orders o
	JOIN accounts a
	ON o.account_id = a.id
	JOIN sales_reps s
	ON a.sales_rep_id = s.id
	JOIN region r
	ON r.id = s.region_id
	GROUP BY r.name)
ORDER BY region_name, total_amt_usd DESC, sale_rep    

/*
Provide the name of the sales_rep in each region with the largest amount of sum of total_amt_usd sales.
*/


SELECT s.name sale_rep, r.name region_name, SUM(total_amt_usd) total_sale_region
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
GROUP BY s.name, r.name
HAVING SUM(total_amt_usd) IN
	(SELECT MAX(t1.total_sale_region)
	 FROM 
											(SELECT s.name sale_rep, r.name region_name, SUM(total_amt_usd) total_sale_region
											FROM orders o
											JOIN accounts a
											ON o.account_id = a.id
											JOIN sales_reps s
											ON a.sales_rep_id = s.id
											JOIN region r
											ON r.id = s.region_id
											GROUP BY s.name, r.name) t1
	GROUP BY t1.region_name)

ORDER BY region_name, total_sale_region DESC, sale_rep

-- can do the same thing with join comment instead of having IN
-- joining rep/region max(sum(amount)) with rep/region/sum(amount)

SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;

/*
For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed? 
*/

SELECT r.name region_name, SUM(total_amt_usd) total_sale_region, COUNT(*)
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(total_amt_usd) IN
	(SELECT MAX(t1.total_sale_region)
	 FROM 
											(SELECT r.name region_name, SUM(total_amt_usd) total_sale_region
											FROM orders o
											JOIN accounts a
											ON o.account_id = a.id
											JOIN sales_reps s
											ON a.sales_rep_id = s.id
											JOIN region r
											ON r.id = s.region_id
											GROUP BY r.name) t1
	)
    
    
 /*
For the name of the account that purchased the most (in total over their lifetime as a customer) standard_qty paper,
how many accounts still had more in total purchases? 
*/   
    

SELECT a.name account_name, SUM(total) 
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
GROUP BY a.name
HAVING SUM(total) >
(SELECT SUM(total) total_paper --, SUM(standard_qty), a.name account_name,
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
GROUP BY a.name
HAVING SUM(standard_qty) IN
(SELECT MAX(t1.total_standard)
FROM 
(SELECT a.name account_name, SUM(standard_qty) total_standard
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
GROUP BY a.name) t1
))

/*
For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
how many web_events did they have for each channel? 
*/
SELECT w.account_id, w.channel, COUNT(*)
FROM web_events w
GROUP BY w.account_id, w.channel
HAVING w.account_id IN
(SELECT a.id top_customer_id
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
GROUP BY a.name, a.id
HAVING SUM(total_amt_usd) IN
(SELECT MAX(t1.amt_usd)
FROM 
(SELECT a.name account_name, SUM(total_amt_usd) amt_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
GROUP BY a.name) t1
))

/*
What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
*/

SELECT t1.account_name, ROUND(t1.avg_spent,1) avg_amount
FROM
(SELECT a.name account_name, SUM(total_amt_usd) amt_usd, AVG(total_amt_usd) avg_spent
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
GROUP BY a.name
ORDER BY amt_usd DESC
LIMIT 10) t1

/*
What is the lifetime average amount spent in terms of total_amt_usd
for only the companies that spent more than the average of all orders.
*/


SELECT AVG(t1.avg_spent)
FROM
(SELECT o.account_id, AVG(o.total_amt_usd) avg_spent
FROM orders o
GROUP BY o.account_id
HAVING AVG(o.total_amt_usd)>
(SELECT AVG(total_amt_usd) avg_all_orders
FROM orders)) t1