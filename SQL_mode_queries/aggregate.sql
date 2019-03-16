/*
TIP:

Functionally, MIN and MAX are similar to COUNT in that they can be used on non-numerical columns.
Depending on the column type, MIN will return the lowest number, earliest date, or non-numerical
value as early in the alphabet as possible. As you might suspect,
MAX does the opposite—it returns the highest number, the latest date,
or the non-numerical value closest alphabetically to “Z.”

COUNT, MIN/MAX/AVG/SUM ignores the NULL, get number of NULLs WHERE IS NULL and COUNT()

median might be a more appropriate measure of center for this data,
but finding the median happens to be a pretty difficult thing to get using SQL alone
— so difficult that finding a median is occasionally asked as an interview question.
*/

/*
Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table.
This should give a dollar amount for each order in the table.
*/

SELECT o.id, SUM(o.standard_amt_usd), SUM(o.gloss_amt_usd)
FROM orders o
GROUP BY o.id
HAVING o.id =1
ORDER BY o.id ASC;

/*
Calculate median of 
*/
-- MIN 0, MAX 22591, AVG 280.432 Median 290
SELECT AVG(standard_qty) FROM
(SELECT * FROM 
(SELECT * FROM 
(SELECT standard_qty
FROM orders
ORDER BY standard_qty) AS t1
LIMIT (SELECT COUNT(*) FROM orders)/2) AS t2
ORDER BY standard_qty DESC
LIMIT 2) AS t3

-- Any column in the SELECT statement that is not within an aggregator must be in the GROUP BY clause.
-- The GROUP BY always goes between WHERE and ORDER BY
-- SQL evaluates the aggregations before the LIMIT clause


/*
Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
*/

SELECT a.name account_name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY o.occurred_at ASC
LIMIT 1;

/*
Find the total sales in usd for each account.
You should include two columns - the total sales for each company's orders in usd and the company name.
*/

SELECT a.name, SUM(o.total_amt_usd)
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY SUM(o.total_amt_usd) DESC;

/*
Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? 
Your query should return only three values - the date, channel, and account name.
*/

SELECT a.name, w.occurred_at, w.channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
ORDER BY w.occurred_at DESC
LIMIT 1;

/*
Find the total number of times each type of channel from the web_events was used.
Your final table should have two columns - the channel and the number of times the channel was used.
*/

SELECT w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY w.channel;

/*
Who was the primary contact associated with the earliest web_event? 
*/

SELECT w.channel, w.occurred_at, a.name, a.primary_poc
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at ASC
LIMIT 1;

/*
What was the smallest order placed by each account in terms of total usd. 
Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.
*/

SELECT a.name, MIN(o.total_amt_usd)
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name 
ORDER BY MIN(o.total_amt_usd) ASC;


/*
number of events per each channel and account
*/

SELECT account_id, channel, COUNT(id) events
FROM web_events
GROUP BY account_id, channel
ORDER BY account_id, events DESC;

--The order of column names in your GROUP BY clause doesn’t matter—the results will be the same regardless.


/*
For each account, determine the average amount of each type of paper they purchased across their orders.
Your result should have four columns - 
one for the account name and one for the average quantity purchased for each of the paper types for each account. 
*/

SELECT a.name account_name, ROUND(AVG(o.standard_qty),1) avg_standard, ROUND(AVG(o.gloss_qty),1) avg_glossy, ROUND(AVG(o.poster_qty),1) avg_poster
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
/*
Determine the number of times a particular channel was used in the web_events table for each sales rep.
Your final table should have three columns -
the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of occurrences first
*/

SELECT s.name rep_name, w.channel, COUNT(*) count_event
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY w.channel, s.name
ORDER BY count_event DESC, rep_name, channel

-- count of rep and channels
SELECT rep_name, COUNT(channel)
FROM
(SELECT s.name rep_name, w.channel, COUNT(*) count_event
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY w.channel, s.name
ORDER BY count_event DESC, rep_name, channel) t1
GROUP BY rep_name
ORDER BY COUNT(channel) 

/*
Determine the number of times a particular channel was used in the web_events table for each region.
Your final table should have three columns - the region name, the channel, and the number of occurrences.
Order your table with the highest number of occurrences first.
*/


SELECT r.name region_name, w.channel, COUNT(*) count_event
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY count_event DESC, region_name, w.channel

--DISTINCT is always used in SELECT statements, and it provides the unique rows for all columns written
-- in the SELECT statement. Therefore, you only use DISTINCT once in any particular SELECT statement.
--using DISTINCT, particularly in aggregations, can slow your queries down quite a bit.


/*
Use DISTINCT to test if there are any accounts associated with more than one region.
*/

SELECT a.name account_name, COUNT(r.name) region_name_count
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
GROUP BY a.name
ORDER BY account_name, region_name_count DESC

/*
Have any sales reps worked on more than one account?
*/

SELECT s.name sales_name, COUNT(a.name) account_count
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY sales_name
ORDER BY account_count DESC -- all 50 have atleast 3 accounts
-- vs all unique sales rep 
SELECT DISTINCT id, name
FROM sales_reps;  -- 50 unique sales_person

/*
How many of the sales reps have more than 5 accounts that they manage
*/

(SELECT s.id rep_id, COUNT(a.id) sum_account
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id
HAVING COUNT(a.id) > 5
ORDER BY sum_account DESC)
-- get exact count
SELECT COUNT(rep_id) FROM
(SELECT s.id rep_id, COUNT(a.id) sum_account
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id
HAVING COUNT(a.id) > 5
) t1

/*
How many accounts have more than 20 orders?
*/
SELECT COUNT(*) FROM
(SELECT a.id account_id, COUNT(o.id) 
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id
HAVING COUNT(o.id)  > 20
ORDER BY a.id
) t1

/*
Which account has the most orders?
*/

SELECT a.id account_id, COUNT(o.id) 
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id
HAVING COUNT(o.id)  > 20
ORDER BY COUNT(o.id) DESC
LIMIT 1;

/*
Which accounts spent more than 30,000 usd total across all orders?
*/

SELECT a.id account_id, SUM(o.total_amt_usd) total_sum
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_sum DESC

/*
Which account has spent the least with us?
*/

SELECT a.id account_id, SUM(o.total_amt_usd) total_sum
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id
ORDER BY total_sum ASC
LIMIT 1

/*
Which accounts used facebook as a channel to contact customers more than 6 times?
*/

SELECT a.id account_id, COUNT(w.channel)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE LOWER(w.channel) = 'facebook'
GROUP BY a.id
HAVING COUNT(w.channel) > 6
ORDER BY COUNT(w.channel)  DESC

/*
Which account used facebook most as a channel? 
*/
-- interprtation most contact per account was facebook not other means

/*
Which account used facebook most as a channel? 
*/
SELECT maxx.account_id, maxx.max, t2.channel, t2.account_id, t2.count
FROM --merge max occurance with original count
(SELECT t1.account_id, MAX(t1.count) FROM
(SELECT  a.id account_id, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, w.channel) t1
--WHERE t1.account_id < 1100
GROUP BY t1.account_id) maxx  --max finding between counts
JOIN (SELECT  a.id account_id, w.channel, COUNT(*) --  count finding general
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, w.channel) t2
ON t2.account_id = maxx.account_id
WHERE t2.count = maxx.max AND LOWER(t2.channel) = 'facebook' -- only when max is found
ORDER BY maxx.account_id

/*
Find the sales in terms of total dollars for all orders in each year,
ordered from greatest to least.
Do you notice any trends in the yearly sales totals?
*/

SELECT DATE_PART('year', occurred_at), SUM(total_amt_usd)
FROM orders
GROUP BY DATE_PART('year', occurred_at)
ORDER BY SUM(total_amt_usd) DESC

SELECT EXTRACT('year' from occurred_at), SUM(total_amt_usd)
FROM orders
GROUP BY EXTRACT('year' from occurred_at)
ORDER BY SUM(total_amt_usd) DESC

/*
In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
*/
SELECT DATE_PART('month',o.occurred_at),DATE_PART('year',o.occurred_at),  SUM(o.gloss_amt_usd)
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE LOWER(a.name) = 'walmart'
GROUP BY 1,2
ORDER BY SUM(total_amt_usd) DESC

/*DATE_TRUNC allows you to truncate your date to a particular part of your date-time column.
Common trunctions are day, month, and year. Here is a great blog post by Mode Analytics on the power of this function.

DATE_PART can be useful for pulling a specific portion of a date,
but notice pulling month or day of the week (dow) means that you are no longer keeping the years in order.
Rather you are grouping for certain components regardless of which year they belonged in. */
--- from solution , not exactly same results ?!
SELECT DATE_TRUNC('month', o.occurred_at) ord_date, SUM(o.gloss_amt_usd) tot_spent
FROM orders o 
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--The CASE statement always goes in the SELECT clause.
--CASE must include the following components: WHEN, THEN, and END. ELSE is an optional
-- component to catch cases that didn’t meet any of the other previous CASE conditions.

--There are some advantages to separating data into separate columns like this depending on what you want to do,
--but often this level of separation might be easier to do in another programming language - rather than with SQL

/*
Write a query to display for each order, the account ID, total amount of the order,
and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.
*/

SELECT id, account_id, total_amt_usd,
	CASE 
		WHEN total_amt_usd >=  3000 THEN 'Large'
		WHEN total_amt_usd < 3000 THEN 'Small'
		END AS text
FROM orders

/*
Write a query to display the number of orders in each of three categories, based on the 'total' amount of each order.
The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
*/

SELECT  
	CASE 
		WHEN total >= 2000 THEN 'At Least 2000'
		WHEN total BETWEEN 1000 AND 2000 THEN 'Between 1000 and 2000'
		WHEN total < 1000 THEN 'Less than 1000'
		END AS text, COUNT(*)
FROM orders
GROUP BY text


/*
We would like to understand 3 different branches of customers based on the amount associated with their purchases.
The top branch includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd.
The second branch is between 200,000 and 100,000 usd. The lowest branch is anyone under 100,000 usd.
Provide a table that includes the level associated with each account.
You should provide the account name, the total sales of all orders for the customer, and the level.
Order with the top spending customers listed first.
*/
SELECT t1.name, t1.total_spend,
CASE
	WHEN t1.total_spend > 200000 THEN 'level1'
	WHEN t1.total_spend BETWEEN 100000 AND 200000 THEN 'level2'
	WHEN t1.total_spend < 100000 THEN 'level3'
	END AS cust_level
FROM
	(SELECT a.name, SUM(o.total_amt_usd) total_spend
	FROM orders o
	JOIN accounts a
	ON a.id = o.account_id
	GROUP BY a.name
	ORDER BY total_spend DESC) t1
ORDER BY t1.total_spend DESC, cust_level, t1.name

-- better
SELECT a.name, SUM(total_amt_usd) total_spent, 
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
     WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
     ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
GROUP BY a.name
ORDER BY 2 DESC;	

*
We would now like to perform a similar calculation to the first,
but we want to obtain the total amount spent by customers only in 2016 and 2017.
Keep the same levels as in the previous question.
Order with the top spending customers listed first.
*/

SELECT a.name account_name, SUM(total_amt_usd),
CASE
	WHEN SUM(total_amt_usd) > 200000 THEN 'level1'
	WHEN SUM(total_amt_usd) BETWEEN 100000 AND 200000 THEN 'level2'
	WHEN SUM(total_amt_usd) < 100000 THEN 'level3'
	END AS cust_level
FROM accounts a
JOIN orders o
ON a.id = o.account_id
WHERE o.occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
GROUP BY a.name
ORDER BY SUM(total_amt_usd) DESC, cust_level

/*
We would like to identify top performing sales reps,
which are sales reps associated with more than 200 orders. 
Create a table with the sales rep name, the total number of orders,
and a column with top or not depending on if they have more than 200 orders. 
Place the top sales people first in your final table.
*/

SELECT s.name sale_name, COUNT(*),
CASE
	WHEN COUNT(*) > 200 THEN 'Top'
	ELSE 'Not'
	END AS sale_level
FROM accounts a
JOIN orders o
ON a.id = o.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY COUNT(*) DESC, sale_level

/*
The previous didn't account for the middle, nor the dollar amount associated with the sales.
Management decides they want to see these characteristics represented as well.
We would like to identify top performing sales reps, which are sales reps associated with more than 200 
orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or
500000 in sales. Create a table with the sales rep name, the total number of orders, total sales across 
all orders, and a column with top, middle, or low depending on this criteria.
Place the top sales people based on dollar amount of sales first in your final table.
*/

SELECT s.name sale_name, COUNT(*), SUM(total_amt_usd),
CASE
	WHEN COUNT(*) > 200 AND SUM(total_amt_usd)>750000 THEN 'Top'
	WHEN COUNT(*) > 150 AND SUM(total_amt_usd)>500000 THEN 'Mid'
	ELSE 'Low'
	END AS sale_level
FROM accounts a
JOIN orders o
ON a.id = o.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY SUM(total_amt_usd)DESC, COUNT(*) DESC, sale_level