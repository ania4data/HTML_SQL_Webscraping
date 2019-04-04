-- text processing
substring('postgres' from 5 for 4)-- => gres
SUBSTR('text',2,2) --'xt'
replace ('abcdefabcdef', 'cd','XX') --=> 'abXXefabXXef'
split_part('abc@xyb@hi',@,3) -- => 'hi'

-- sqrt(dp or numeric), power() == ^
-- prime number between 1 to 1000
-- setseed(dp) set seed for subsequent random() calls (value between 0 and 1.0)
SELECT num1, COUNT(*)
FROM
(SELECT num1, num2, MOD(num1,num2) mod_num1_num2
FROM
(SELECT *, 1 tag1, RANDOM()  --random value in the range 0.0 <= x < 1.0
FROM generate_series(1,1000) num1) t1  --start/stop/step
JOIN
(SELECT *, 1 tag2, RANDOM()
FROM generate_series(1,1000) num2) t2
ON tag1 = tag2
WHERE MOD(num1,num2) = 0) t3
GROUP BY num1
HAVING COUNT(*) IN (1,2)

 -- window

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

-- median

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
 
 -- ALL
 
 SELECT name
FROM world
WHERE GDP > ALL(SELECT GDP FROM world WHERE continent = 'Europe' AND GDP>0)

-- correlated or synchronized sub-query.

 SELECT last_name, salary, department_id
 FROM employees outer
 WHERE salary >
                (SELECT AVG(salary)
                 FROM employees
                 WHERE department_id =
                        outer.department_id);
                        
                        
 SELECT continent, name, area FROM world x
  WHERE area >= ALL
    (SELECT area FROM world y
        WHERE y.continent=x.continent
          AND population>0)   

          
-- random sampling

SELECT random_num, COUNT(random_num)
FROM
(SELECT *, CEIL(RANDOM()*1000000) random_num   -- need random numbers between 1 to 1000000 record
FROM generate_series(1, 1000) series) t1    --need 1000 of them, since 1000000 >> 1000 repetiotin not seen
GROUP BY random_num

