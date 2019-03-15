/*
Provide a table that provides the region for each sales_rep along with their associated accounts.
This time only for the Midwest region. Your final table should include three columns: 
the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.
*/

SELECT s.name AS sale_name, s.id, s.region_id, r.name AS region_name, a.name AS account
FROM sales_reps AS s
JOIN region AS r
ON r.id =  s.region_id AND r.name = 'Midwest'
JOIN accounts AS a
ON a.sales_rep_id = s.id
ORDER BY account ASC;

/*
Provide a table that provides the region for each sales_rep along with their associated accounts.
This time only for accounts where the sales rep has a first name starting with S and in the Midwest region.
Your final table should include three columns: the region name, the sales rep name, and the account name. 
Sort the accounts alphabetically (A-Z) according to account name.
*/

SELECT s.name AS sale_name, s.id, s.region_id, r.name AS region_name, a.name AS account
FROM sales_reps AS s
JOIN region AS r
ON r.id =  s.region_id AND r.name = 'Midwest' AND s.name LIKE 'S%'
JOIN accounts AS a
ON a.sales_rep_id = s.id
-- alternate WHERE r.name = 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name ASC;


/*
Provide a table that provides the region for each sales_rep along with their associated accounts.
This time only for accounts where the sales rep has a last name starting with K and in the Midwest region.
Your final table should include three columns: the region name, the sales rep name, and the account name.
Sort the accounts alphabetically (A-Z) according to account name.
*/

SELECT s.name AS sale_name, s.id, s.region_id, r.name AS region_name, a.name AS account
FROM sales_reps AS s
JOIN region AS r
ON r.id =  s.region_id AND r.name = 'Midwest' AND s.name LIKE '% K%'
JOIN accounts AS a
ON a.sales_rep_id = s.id
ORDER BY a.name ASC;

/*
Provide the name for each region for every order,
as well as the account name and the unit price they paid (total_amt_usd/total) for the order.
However, you should only provide the results if the standard order quantity exceeds 100.
Your final table should have 3 columns: region name, account name, and unit price.
*/

SELECT a.name account_name, o.total_amt_usd/(o.total+ 0.01) unit_price, r.name region_name
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON s.region_id = r.id
WHERE o.standard_qty >100

/*
Provide the name for each region for every order,
as well as the account name and the unit price they paid (total_amt_usd/total) for the order.
However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50.
Your final table should have 3 columns: region name, account name, and unit price. Sort for the largest unit price first.
*/

SELECT r.name region_name, a.name account_name, ROUND((o.total_amt_usd/(o.total+0.01)),2) unit_price
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON s.region_id = r.id
WHERE standard_qty >100 AND poster_qty>50
ORDER BY unit_price DESC;

/*
What are the different channels used by account id 1001? Your final table should have only 2 columns:
account name and the different channels.
You can try SELECT DISTINCT to narrow down the results to only the unique values.
*/

SELECT COUNT(a.name), w.channel
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
WHERE a.id = 1001
GROUP BY w.channel  -- give # occurance per channel

SELECT DISTINCT a.name, w.channel
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
WHERE a.id = 1001  -- no counting

/*
Find all the orders that occurred in 2015.
Your final table should have 4 columns: occurred_at, account name, order total, and order total_amt_usd.
*/

SELECT o.occurred_at, a.name account_name, o.total, o.total_amt_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE EXTRACT(YEAR FROM o.occurred_at) = '2015' -- WHERE o.occurred_at BETWEEN 2015-01-01 AND 2016-01-01
ORDER BY o.occurred_at ASC;