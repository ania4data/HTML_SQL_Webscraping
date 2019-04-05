-- customers that never ordered

--183. Customers Who Never Order

SELECT Name Customers
FROM Customers
LEFT JOIN Orders
ON Customers.ID = Orders.CustomerID
WHERE customerID IS NULL

-- Department Top Three Salaries
-- 185. Department Top Three Salaries
SELECT Department.Name Department, t1.Name Employee, t1.Salary 
FROM
(SELECT
    Name,
    Salary,
    DepartmentId,
    DENSE_RANK() OVER (PARTITION BY
                     DepartmentId
                 ORDER BY
                     Salary DESC
                ) row_rank
FROM
    Employee) t1
JOIN Department
ON t1.DepartmentId = Department.Id AND row_rank < 4

/*
262. Trips and Users  Hard

The Trips table holds all taxi trips. Each trip has a unique Id,
 while Client_Id and Driver_Id are both foreign keys to the Users_Id at the Users table.
 Status is an ENUM type of (‘completed’, ‘cancelled_by_driver’, ‘cancelled_by_client’).

The Users table holds all users. Each user has an unique Users_Id, 
and Role is an ENUM type of (‘client’, ‘driver’, ‘partner’).

Write a SQL query to find the cancellation rate of requests made by unbanned users between Oct 1, 2013 and Oct 3, 2013.
 For the above tables, your SQL query should return the following rows with the cancellation rate being rounded to two decimal places.
*/

WITH t1 AS(SELECT Id, Client_Id, SUBSTR(Status, 1, 9) Status_new, Request_at Day   -- clean the cancelled to be common among passenger/driver
            FROM Trips 
            WHERE (Request_at BETWEEN '2013-10-01' AND '2013-10-03')  -- fix the date
            AND
            (Client_Id IN (SELECT Users_Id
            FROM Users
            WHERE Banned = 'No')) AND (Driver_Id IN (SELECT Users_Id   -- make sure not passenger or driver are banned
                                    FROM Users
                                    WHERE Banned = 'No')))


SELECT t2.Day, COALESCE(ROUND(canceled/total, 2), ROUND(0,1)) "Cancellation Rate"  --space for alias possible with "" 
FROM
(SELECT Day, COUNT(*) total   -- separately getting total ride and canceled ride to get ratio
FROM t1
GROUP BY Day) t2
LEFT JOIN
(SELECT Day, COUNT(*) canceled
FROM t1
WHERE Status_new = 'cancelled'
GROUP BY Day) t3
ON t2.Day = t3.Day
ORDER BY t2.Day

'''
626. Exchange Seats Medium

Input
+---------+---------+
|    id   | student |
+---------+---------+
|    1    | Abbot   |
|    2    | Doris   |
|    3    | Emerson |
|    4    | Green   |
|    5    | Jeames  |
+---------+---------+
Output
+---------+---------+
|    id   | student |
+---------+---------+
|    1    | Doris   |
|    2    | Abbot   |
|    3    | Green   |
|    4    | Emerson |
|    5    | Jeames  |
+---------+---------+
If the number of students is odd, there is no need to change the last one\'s seat.
'''


SELECT t1.id, t2.student2 student
FROM
(SELECT id, student student1, CEIL(id*0.5) tag1, 1 counter1   -- ceil get the pairs, counter make all combinations
FROM seat) t1
JOIN 
(SELECT id, student student2, CEIL(id*0.5) tag2, 1 counter2
FROM seat) t2
ON t1.counter1 = t2.counter2 AND ((tag1 = tag2 AND t1.id != t2.id) OR
      ((t1.id = (SELECT COUNT(*) FROM seat)) AND (MOD(t1.id, 2)=1) AND t1.student1 = t2.student2))  -- keep last entry if odd
ORDER BY t1.id 



SELECT Id, Email, row_num
FROM
(SELECT Id, Email,
RANK() OVER(PARTITION BY Email ORDER BY Id ASC) AS row_num
FROM Person) t1
WHERE t1.row_num = 1

-----
DROP TABLE IF EXISTS test;

CREATE TABLE test(
Id integer PRIMARY KEY NOT NULL,
Email varchar(40) NOT NULL   
);

INSERT INTO test(Id, Email)
VALUES(1, 'john@example.com'),
      (2, 'bob@example.com'),
      (3, 'john@example.com');

SELECT MIN(Id) Id, Email
FROM test
GROUP BY Email
ORDER BY Id;


SELECT Id, Email
FROM
(SELECT Id, Email,
RANK() OVER(PARTITION BY Email ORDER BY Id ASC) AS row_num
FROM test) t1
WHERE t1.row_num = 1
ORDER BY Id

-- 595. Big Countries
SELECT name, population, area
FROM World
WHERE area > 3000000 OR population > 25000000


-- 182. Duplicate Emails
SELECT Email
FROM Person
GROUP BY Email
HAVING COUNT(Email) > 1


SELECT num
FROM
(SELECT Id, Num, 
LEAD(Num) OVER(PARTITION BY num ORDER BY Id) lead_num,
num - LEAD(Num) OVER(PARTITION BY num ORDER BY Id) + 1 delta
FROM test) t1
GROUP BY num
HAVING SUM(delta) >= 3
-- 180. Consecutive Numbers
-- Write a SQL query to find all numbers that appear at least three times consecutively.
SELECT Num ConsecutiveNums
FROM
(SELECT Id, Num,
LEAD(Num, 1) OVER(ORDER BY Id) lead_num1,
LEAD(Num, 2) OVER(ORDER BY Id) lead_num2
FROM Logs) t1
WHERE Num = lead_num1 AND lead_num1 = lead_num2
GROUP BY Num