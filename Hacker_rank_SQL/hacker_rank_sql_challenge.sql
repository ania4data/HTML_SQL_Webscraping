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
/*
Query the list of CITY names from STATION that either do not start with vowels or do not end with vowels. Your result cannot contain duplicates.
*/

SELECT DISTINCT CITY
FROM STATION
WHERE (LEFT(LOWER(CITY), 1) NOT IN ('a', 'i', 'e', 'o', 'u')) OR (RIGHT(LOWER(CITY), 1) NOT IN ('a', 'i', 'e', 'o', 'u'));
/*

Query the Name of any student in STUDENTS who scored higher than  Marks. Order your output by the last three characters of each name.
 If two or more students both have names ending in the same last three characters (i.e.: Bobby, Robby, etc.), secondary sort them by ascending ID
*/
SELECT Name
FROM STUDENTS
WHERE Marks>75
ORDER BY RIGHT(Name, 3), ID ASC;
/*

Considerp1(a,b)  and p2(c,d) to be two points on a 2D plane.

a happens to equal the minimum value in Northern Latitude (LAT_N in STATION).
b happens to equal the minimum value in Western Longitude (LONG_W in STATION).
c happens to equal the maximum value in Northern Latitude (LAT_N in STATION).
d happens to equal the maximum value in Western Longitude (LONG_W in STATION).
Query the Manhattan Distance between points  and  and round it to a scale of  decimal places.

*/

SELECT ROUND((c-a) + (d-b),4)
FROM
(SELECT
(SELECT MIN(LAT_N) FROM STATION) a,
(SELECT MIN(LONG_W) FROM STATION) b,
(SELECT MAX(LAT_N) FROM STATION) c,
(SELECT MAX(LONG_W) FROM STATION) d) t1
/*
Consider p1(a,b)  andp2(c,d)to be two points on a 2D plane where a,b are the respective minimum and maximum values 
of Northern Latitude (LAT_N) and c,d-b are the respective minimum and maximum values of Western Longitude (LONG_W) in STATION.

Query the Euclidean Distance between points p1 and p2 and format your answer to display  decimal digits.

*/

SELECT ROUND(SQRT(POWER((b-a),2) + POWER((d-c),2)),4)
FROM
(SELECT
(SELECT MIN(LAT_N) FROM STATION) a,
(SELECT MAX(LAT_N) FROM STATION) b,
(SELECT MIN(LONG_W) FROM STATION) c,
(SELECT MAX(LONG_W) FROM STATION) d) t1s

/*
A median is defined as a number separating the higher half of a data set from the lower half.
 Query the median of the Northern Latitudes (LAT_N) from STATION and round your answer to  decimal places.

Input Format

The STATION table is described as follows:
*/

SELECT ROUND(AVG(LAT_N),4)
FROM
(SELECT LAT_N,
CASE 
    WHEN (MOD(counter,2)=0 AND row_ IN (counter/2, counter/2 +1)) THEN 1
    WHEN (MOD(counter,2)=1 AND row_ IN ((counter+1)/2)) THEN 1
    END AS tag
FROM
(SELECT LAT_N,
ROW_NUMBER() OVER(ORDER BY LAT_N) row_,
(SELECT COUNT(*) FROM STATION) counter
FROM STATION) t1) t2
WHERE tag = 1;
/*
Write a query identifying the type of each record in the TRIANGLES table using its three side lengths. Output one of the following statements for each record in the table:

Equilateral: It's a triangle with  sides of equal length.
Isosceles: It's a triangle with  sides of equal length.
Scalene: It's a triangle with  sides of differing lengths.
Not A Triangle: The given values of A, B, and C don't form a triangle.

*/


SELECT
CASE 
WHEN A+B <= C OR A+C <= B OR B+C <= A THEN 'Not A Triangle'
WHEN A=B AND B=C THEN 'Equilateral'
WHEN A!=B AND B!=C AND A!=C THEN 'Scalene'
WHEN A=B OR B=C OR A=C THEN 'Isosceles'
END
FROM TRIANGLES;

/*
Hackers
Challenges:
Julia asked her students to create some coding challenges. Write a query to print the hacker_id, name,
and the total number of challenges created by each student. Sort your results by the total number of challenges in descending order.
If more than one student created the same number of challenges, then sort the result by hacker_id.
If more than one student created the same number of challenges and the count is less than the maximum number of challenges created,
then exclude those students from the result.
*/

WITH
t1 AS (
SELECT h.hacker_id, h.name, COUNT(challenge_id) challenges_created
FROM Hackers h
JOIN Challenges c
ON h.hacker_id = c.hacker_id
GROUP BY h.hacker_id, h.name
ORDER BY challenges_created DESC, h.hacker_id),
t2 AS (SELECT MAX(challenges_created) max_count FROM t1),
t3 AS (SELECT challenges_created challenge_count, COUNT(name) name_count FROM t1 GROUP BY challenges_created)
SELECT t1.hacker_id, t1.name, t1.challenges_created --, t3.name_count, (SELECT max_count FROM t2)
FROM t1
JOIN t3
ON t1.challenges_created = t3.challenge_count
WHERE (t3.name_count > 1 AND t1.challenges_created >= (SELECT max_count FROM t2)) OR t3.name_count = 1
ORDER BY t1.challenges_created DESC, t3.name_count DESC, t1.hacker_id;
