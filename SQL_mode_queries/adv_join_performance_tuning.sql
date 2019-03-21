/*
each account who has a sales rep and each sales rep that has an account (all of the columns in these returned rows will be full)
but also each account that does not have a sales rep and each sales rep that does not have an account 
(some of the columns in these returned rows will be empty)
*/

SELECT a.id, s.id
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id

SELECT a.id account_id, s.id sales_rep_id
FROM accounts a
LEFT JOIN sales_reps s
ON a.sales_rep_id = s.id
WHERE sales_rep_id IS NULL  --none
ORDER BY sales_rep_id DESC

SELECT a.id account_id, s.id sales_rep_id
FROM accounts a
RIGHT JOIN sales_reps s
ON a.sales_rep_id = s.id
WHERE a.id IS NULL  --none
ORDER BY a.id DESC


SELECT o.account_id, DATE_TRUNC('month',MIN(o.occurred_at))
FROM orders o
GROUP BY o.account_id
ORDER BY o.account_id

SELECT o.account_id, o.occurred_at, DATE_TRUNC('month',o.occurred_at),
MIN(DATE_TRUNC('month',o.occurred_at)) OVER (PARTITION BY o.account_id)
FROM orders o
ORDER BY o.account_id, DATE_TRUNC('month',o.occurred_at)

/*
write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number
and joins it using the < comparison operator on accounts.primary_poc and sales_reps.name, like so:

accounts.primary_poc < sales_reps.name
*/

-- even though id matches, if condition of alphabetical is not satisfied leave the sales_rep name null on right table only (rest have value)
SELECT a.id account_id, a.name account_name, a.primary_poc, s.name sales_rep_name
FROM accounts a
LEFT JOIN sales_reps s
ON s.id = a.sales_rep_id AND a.primary_poc < s.name -- alphabetically primary_poc < sales_reps.name
ORDER BY a.id, a.name, a.primary_poc



/*
self join the web_events table, change the interval to 1 day to find those web events that occurred after, but not more than 1 day after,
another web event add a column for the channel variable in both instances of the table in your query
perhaps can do this with window, partition over account and lag or lead of 1 hour?
*/
-- connecting the account_id not primary
SELECT w1.account_id account_id1, w2.account_id account_id2,
w1.occurred_at w1_date, w2.occurred_at w2_date,
w1.occurred_at - w2.occurred_at delta_time,
w1.channel w1_channel, w2.channel w2_channel

FROM web_events w1
LEFT JOIN web_events w2
ON w1.account_id = w2.account_id
   AND 
   w1.occurred_at > w2.occurred_at AND
   w1.occurred_at <= (w2.occurred_at + INTERVAL '1 day')
ORDER BY account_id1, w1_date, w2_date, w1.id,w2.id

-- same thing with account table

SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at
  FROM orders o1
 LEFT JOIN orders o2
   ON o1.account_id = o2.account_id
  AND o2.occurred_at > o1.occurred_at
  AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at


/*
DROPPING duplicates
*/

DROP TABLE IF EXISTS test_duplicate;

CREATE TABLE test_duplicate(
names VARCHAR(50) NOT NULL,
numbers integer NOT NULL
)

CREATE TABLE test_duplicate2 (LIKE test_duplicate)

INSERT INTO test_duplicate(names, numbers)
VALUES ('john',5),
	   ('jim',10),
	   ('jim',10),
	   ('john',5),
	   ('sarah',11)
SELECT * FROM test_duplicate

INSERT INTO test_duplicate2
SELECT DISTINCT * FROM test_duplicate

SELECT * FROM test_duplicate2

---- 2nd using rownum screening

WITH t1 AS
(SELECT names, numbers,
ROW_NUMBER() OVER (PARTITION BY names, numbers ORDER BY names, numbers) rowcount
FROM test_duplicate)
SELECT * FROM t1
WHERE rowcount = 1

/*
SQL's two strict rules for appending data:

1-Both tables must have the same number of columns.
2-Those columns must have the same data types in the same order as the first table.

A common misconception is that column names have to be the same.
Column names, in fact, don't need to be the same to append two tables but you will find that they typically are.
*/

/*
Write a query that uses UNION ALL on two instances (and selecting all columns) of the accounts table. 
*/

SELECT COUNT(*)
FROM
(
SELECT a1.*
FROM accounts a1
UNION ALL
SELECT a2.*
FROM accounts a2) union_table

/*
Add a WHERE clause to each of the tables that you unioned in the query above, filtering the first table where
 name equals Walmart and filtering the second table where name equals Disney. Inspect the results then answer the subsequent quiz.
*/


SELECT COUNT(*)
FROM
(
SELECT a1.*
FROM accounts a1
	WHERE a1.name ='Walmart'
UNION ALL
SELECT a2.*
FROM accounts a2
	WHERE a2.name ='Disney') union_table
    
/*
One way to make a query run faster is to reduce the number of calculations that need to be performed. Some of the high-level things that will affect the number of calculations a given query will make include:

Table size
Joins
Aggregations
Query runtime is also dependent on some things that you can’t really control related to the database itself:

Other users running queries concurrently on the database
Database software and optimization (e.g., Postgres is optimized for faster read and write on new rows , Redshift faster on aggregation)

-If you have time series data, limiting to a small time window can make your queries run more quickly.
-Testing your queries on a subset of data, finalizing your query, then removing the subset limitation is a sound strategy.
-When working with subqueries, limiting the amount of data you’re working with in the place where it will be executed first will have
 the maximum impact on query run time, doing limit after aggregate will not impact the speed, since aggregate (time consuming) part already done
- count distinct , expensive
 - do aggregation before joining tables , incases that make sense, aggregate by id, then join to another table to get the name,
 specially if date is involved that need to get aggregated, separately aggregating each table by date and join the aggregated tables by dat much
 more efficient
- Use explain to get a sense of time per step of query and sequence of the run. after tuning for speed run explain again to see the difference
*/

EXPLAIN
SELECT COUNT(*) FROM orders  --3rd
WHERE account_id =1001 --1st
GROUP BY id  --2nd
LIMIT 100  --last


/* TABLE PIVOT */


CREATE TABLE agg_channel(
account_id integer NOT NULL,
channel VARCHAR(50) NOT NULL,
count_event bigint NOT NULL)

INSERT INTO agg_channel
SELECT * FROM
(SELECT account_id, channel, COUNT(*) count_event
FROM web_events
GROUP BY account_id, channel) t1

SELECT * FROM agg_channel

SELECT account_id,
CASE WHEN channel = 'twitter' THEN count_event 
     ELSE 0
	 END AS twitter,
CASE WHEN channel = 'adwords' THEN count_event
     ELSE 0
	 END AS adwords,
CASE WHEN channel = 'organic' THEN count_event
     ELSE 0
	 END AS organic,
CASE WHEN channel = 'banner' THEN count_event
     ELSE 0
	 END AS banner,
CASE WHEN channel = 'direct' THEN count_event
     ELSE 0
	 END AS direct,
CASE WHEN channel = 'facebook' THEN count_event 
     ELSE 0
	 END AS facebook
FROM agg_channel

