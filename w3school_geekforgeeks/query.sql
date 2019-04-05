/*
DELETE
*/

DELETE FROM Customers
WHERE CustomerName = 'Alfreds Futterkiste'

-- DELETE ALL content

DELETE FROM Customers

-- TOP sql server, limit mysql rownum oracle

SELECT * FROM Customers
WHERE Country='Germany' AND ROWNUM <= 3;

SELECT * FROM Customers
WHERE Country='Germany'
LIMIT 3;

SELECT TOP(3) * FROM Customers
WHERE Country='Germany'
LIMIT 3;

SELECT TOP(50) PERCENT * FROM Customers --under clause top 50% entry
WHERE Country='Germany'
LIMIT 3;

-- DROP/TRUNCATE

DROP TABLE test  -- completelt remove
TRUNCATE TABLE test  /*-- rmove content, keep structure  == */ DELETE FROM TABLE test

DROP DATABASE x

-- JOIN

INSERT INTO test(Id, Num)
VALUES(1, 'a'),
      (2, 'b'),
      (3, 'c'),
	  (4, 'c'),
      (5, 'd'),
      (6, 'e'),
      (7, 'f'),	  
      (8, 'g'),
	  (9, 'g');

SELECT t1.Id, t2.Id, t1.Num, t2.Num -- self join
FROM test t1, test t2
WHERE t1.Num = t2.Num

SELECT t1.Id, t2.Id, t1.Num, t2.Num -- cross n*n if no constraint,join with appropriate conb
FROM test t1
CROSS JOIN test t2;
-- can become self  using WHERE e.g.


-- CONCAT
SELECT Id, Num, CONCAT(Id, ' Dept: ', Num)
FROM test
-- piping
SELECT Id, Num, Id || ' Dept: ' || Num AS text
FROM test

-- ALL ANY
SELECT * 
FROM test
WHERE Id >= 5
/*
INSERT INTO test(Id, Num)
VALUES(1, 'a'),
      (2, 'b'),
      (3, 'c'),
	  (4, 'c'),
      (5, 'd'),
      (6, 'e'),
      (7, 'f'),	  
      (8, 'g'),
	  (9, 'g');

INSERT INTO test2(Id, Num)
VALUES(1, 'x'),
      (2, 'y'),
      (3, 'z');
*/

SELECT * 
FROM test
WHERE Id >= ALL(SELECT Id FROM test2);  -- 3-9 only from test2

SELECT * 
FROM test
WHERE Id >= ANY(SELECT Id FROM test2);  -- gets 1-9 from test

-- DATETIME

SELECT NOW() 04/05/2019
SELECT EXTRACT(Day FROM NOW())  --5
SELECT DATE_PART('day',NOW())  --5 
SELECT DATE_PART('dow',NOW())  -- day of week  'doy' day of year
SELECT DATE_PART('quarter',NOW())
SELECT DATE_PART('minute',NOW() + interval '30 min')  -- 29 min -> 50 min
SELECT DATE_TRUNC('month', NOW()) --2019-04-01 00:00:00-07  (keep 2019-04 rest are restted)
--21 * interval '1 day'  -> 21 day
SELECT t1.id, t1.account_id, t2.id, t2.account_id, t1.occurred_at, t2.occurred_at, EXTRACT('day' FROM t1.occurred_at - t2.occurred_at) diff
FROM orders t1, orders t2
WHERE t1.account_id = 1001
-- format timestamp
SELECT t1.id, t1.account_id, t2.id, t1.occurred_at, t2.occurred_at,
to_char(t1.occurred_at, 'Day, DD  Month mm HH12:MI:SS'), -- '2015-10-06 17:31:14  - >  Tuesday  , 06  October   10 05:31:14'
EXTRACT('day' FROM t1.occurred_at - t2.occurred_at) diff
FROM orders t1, orders t2

-- sampling

SELECT random_num, COUNT(random_num)
FROM
(SELECT *, CEIL(RANDOM()*1000000) random_num   -- need random numbers between 1 to 1000000 record
FROM generate_series(1, 1000) series) t1    --need 1000 of them, since 1000000 >> 1000 repetiotin not seen
GROUP BY random_num

-- STRING

SELECT LENGTH('text') -- CHAR_LENGTH('text') => 4
SELECT LEFT('geeksforgeeks.org', 5);
SELECT SUBSTR('geeksforgeeks.org', 1, 5);
SELECT STRPOS('geeksforgeeks.org', 'f');
SELECT REPLACE('geeksforgeeks.org', 'e','*')
SELECT REVERSE('geeksforgeeks.org')
SELECT TRIM(' geeksforgeeks.org '); -- white space out
SELECT SPLIT_PART('geeksforgeeks.org','for',2);   --> geeks.org


-- UDF uder defnied function

CREATE FUNCTION inc(val integer) RETURNS integer AS $$
BEGIN
RETURN val + 1;
END; $$
LANGUAGE PLPGSQL;

SELECT inc(20);