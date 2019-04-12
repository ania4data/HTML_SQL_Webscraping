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
--
WITH seat_new AS(SELECT id, student, CEIL(id*0.5) tag
FROM seat),

     count_table AS(SELECT COUNT(*) FROM seat)

SELECT t1.id, t2.student
FROM seat_new t1
JOIN seat_new t2
ON t1.tag = t2.tag
WHERE (t1.student != t2.student) OR (t1.id = (SELECT * FROM count_table) AND MOD(t1.id,2) = 1)
ORDER BY t1.id

--

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
/*
+----+-------+--------+-----------+
| Id | Name  | Salary | ManagerId |
+----+-------+--------+-----------+
| 1  | Joe   | 70000  | 3         |
| 2  | Henry | 80000  | 4         |
| 3  | Sam   | 60000  | NULL      |
| 4  | Max   | 90000  | NULL      |
+----+-------+--------+-----------+

finds out employees who earn more than their managers

*/

SELECT t1.Name Employee
FROM Employee t1, Employee t2
WHERE t1.ManagerId = t2.Id AND t1.Salary > t2.Salary


--184. Department Highest Salary

/*
+----+-------+--------+--------------+
| Id | Name  | Salary | DepartmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 70000  | 1            |
| 2  | Jim   | 90000  | 1            |
| 3  | Henry | 80000  | 2            |
| 4  | Sam   | 60000  | 2            |
| 5  | Max   | 90000  | 1            |
+----+-------+--------+--------------+

+----+----------+
| Id | Name     |
+----+----------+
| 1  | IT       |
| 2  | Sales    |
+----+----------+
*/
--group by base
SELECT Department.Name Department, Employee.Name Employee, t1.max_salary Salary
FROM
(SELECT DepartmentId, MAX(Salary) max_salary
FROM Employee
GROUP BY DepartmentId) t1
JOIN Department
ON Department.Id = t1.DepartmentId
JOIN Employee
ON Employee.DepartmentId = t1.DepartmentId AND t1.max_salary = Employee.Salary

SELECT d.Name Department, e.Name Employee, t1.max_salary Salary
FROM
(SELECT DepartmentId, MAX(Salary) max_salary
FROM Employee
GROUP BY DepartmentId) t1
JOIN Employee e
ON t1.max_salary = e.Salary AND t1.DepartmentId = e.DepartmentId
JOIN Department d
ON e.DepartmentId = d.Id

-- rank base
SELECT Department.Name Department, t1.Name Employee, t1.Salary Salary 
FROM
(SELECT Name, Salary, DepartmentId,
DENSE_RANK() OVER(PARTITION BY DepartmentId ORDER BY Salary DESC) AS salary_rank
FROM Employee) t1
JOIN Department
ON t1.DepartmentId = Department.Id AND t1.salary_rank = 1 


/*
176. Second Highest Salary
+----+--------+
| Id | Salary |
+----+--------+
| 1  | 100    |
| 2  | 200    |
| 3  | 300    |
+----+--------+
+---------------------+
| SecondHighestSalary |
+---------------------+
| 200                 |
+---------------------+

*/

SELECT (SELECT DISTINCT Salary
FROM
(SELECT Salary,
DENSE_RANK() OVER (ORDER BY Salary DESC) AS rank
FROM Employee) t1
WHERE rank = 2) SecondHighestSalary   -- goal to get the null if did not find (that's why all extra select), other wise structure to get 2nd and coming of empty is correct

SELECT (SELECT DISTINCT Salary
FROM Employee
ORDER BY Salary DESC
LIMIT 1 OFFSET 1) SecondHighestSalary

SELECT MAX(DISTINCT Salary) SecondHighestSalary
FROM Employee 
WHERE Salary NOT IN (SELECT MAX(DISTINCT Salary) FROM Employee)  -- inner loop get max salary, outer loop get 2ndmax (by excluding first max)

-- DELETE Duplicate

--IF want to drop all dupliacate email owners

DELETE FROM Person
WHERE Email IN (SELECT * FROM (SELECT Email FROM Person GROUP BY Email HAVING COUNT(*) >=2) t1)
-- 196. Delete Duplicate Emails
-- IF WANT to drop the extra count per person
-- Write a SQL query to delete all duplicate email entries in a table named Person, keeping only unique emails based on its smallest Id.
DELETE FROM Person
WHERE Id NOT IN
(SELECT * FROM (SELECT MIN(Id)
FROM Person
GROUP BY Email) t1)

-- 178. Rank Scores  had to clean up the extra decimals in some entries
SELECT new_score Score,
DENSE_RANK() OVER (ORDER BY new_score DESC) AS Rank
FROM
(SELECT Id, ROUND(Score, 2) new_score
FROM Scores) t1

-- 197. Rising Temperature
-- Given a Weather table, write a SQL query to find all dates' Ids with higher temperature compared to its previous (yesterday's) dates.
SELECT w1.Id  --, w1.Temperature, w2.Temperature, w1.RecordDate, w2.RecordDate
FROM Weather w1
CROSS JOIN Weather w2  --DATEDIFF(w1.date, w.date)
WHERE (w1.RecordDate = w2.RecordDate + 1) AND  (w1.Temperature > w2.Temperature) -- interval '1 day' AND 

--175. Combine Two Tables
-- Write a SQL query for a report that provides the following information for each person in the Person table, regardless if there is an address for each of those people:
SELECT p.FirstName, p.LastName, a.City, a.State
FROM Person p
LEFT JOIN Address a
ON p.PersonId = a.PersonId


--620. Not Boring Movies

SELECT id, movie, description, rating
FROM cinema
WHERE MOD(id,2) = 1 AND LOWER(description) NOT LIKE '%boring%'   -- STRPOS(LOWER(description),'boring') = 0 (did not find)
ORDER BY rating DESC
