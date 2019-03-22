-- binary tree code
-- P parent, N node inner (not leaf /root)

SELECT N,
CASE
    WHEN P IS NULL THEN 'Root'
    WHEN N NOT IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL) THEN 'Leaf'
    ELSE 'Inner'
    END AS condition
FROM BST
ORDER BY N


-- New Companies

SELECT company_code, founder, c_l, c_s, c_m, c_e
FROM Company
JOIN 
(SELECT company_code lc, COUNT(DISTINCT lead_manager_code) c_l
FROM Lead_Manager
GROUP BY company_code) t1
ON t1.lc = company_code
JOIN 
(SELECT company_code sc, COUNT(DISTINCT senior_manager_code) c_s
FROM Senior_Manager
GROUP BY company_code) t2
ON t2.sc = t1.lc
JOIN
(SELECT company_code mc, COUNT(DISTINCT manager_code) c_m
FROM Manager
GROUP BY company_code) t3
ON t3.mc = t2.sc
JOIN
(SELECT company_code ec, COUNT(DISTINCT employee_code) c_e
FROM Employee
GROUP BY company_code) t4
ON t4.ec = t3.mc
ORDER BY company_code

-- occupations

SELECT named,namep,names,namea
FROM
(SELECT Name named, ROW_NUMBER() OVER(ORDER BY Name) as rown FROM OCCUPATIONS WHERE Occupation = "Doctor") t1
FULL OUTER JOIN 
(SELECT Name namep, ROW_NUMBER() OVER(ORDER BY Name) as rown FROM OCCUPATIONS WHERE Occupation = "Professor") t2
ON t1.rown = t2.rown
FULL OUTER JOIN
(SELECT Name names, ROW_NUMBER() OVER(ORDER BY Name) as rown FROM OCCUPATIONS WHERE Occupation = "Singer") t3
ON t2.rown = t3.rown
FULL OUTER JOIN
(SELECT Name namea, ROW_NUMBER() OVER(ORDER BY Name) as rown FROM OCCUPATIONS WHERE Occupation = "Actor") t4
ON t3.rown = t4.rown;

-- occupations
SELECT named,namep,names,namea
FROM
(SELECT Name named, ROW_NUMBER() OVER(ORDER BY Name) as rown FROM OCCUPATIONS WHERE Occupation = "Doctor") t1
FULL OUTER JOIN 
(SELECT Name namep, ROW_NUMBER() OVER(ORDER BY Name) as rown FROM OCCUPATIONS WHERE Occupation = "Professor") t2
ON t1.rown = t2.rown
FULL OUTER JOIN
(SELECT Name names, ROW_NUMBER() OVER(ORDER BY Name) as rown FROM OCCUPATIONS WHERE Occupation = "Singer") t3
ON t2.rown = t3.rown
FULL OUTER JOIN
(SELECT Name namea, ROW_NUMBER() OVER(ORDER BY Name) as rown FROM OCCUPATIONS WHERE Occupation = "Actor") t4
ON t3.rown = t4.rown;

-- The PADS

SELECT CONCAT(Name,"(",LEFT(Occupation,1),")") text
FROM OCCUPATIONS
ORDER BY text ASC;

SELECT CONCAT("There are a total of ",COUNT(*)," ",LOWER(Occupation),"s.") FROM OCCUPATIONS
GROUP BY Occupation
ORDER BY COUNT(*) ASC, Occupation ASC;


