SELECT version();

SELECT * FROM information_schema.tables

SELECT * FROM information_schema.tables
WHERE table_name = 'film';

SELECT * FROM information_schema.columns
where table_name = 'film';

/* column_name, data_type, character_maximum_length */
SELECT column_name FROM information_schema.columns
where table_name = 'film';

SELECT table_name FROM information_schema.tables

SELECT column_name FROM information_schema.columns   /* all column name */

SELECT column_name FROM information_schema.columns
WHERE table_name = 'customer'

SELECT table_name FROM information_schema.columns
WHERE column_name = 'email'

SELECT column_name FROM information_schema.columns
WHERE table_name = 'customer'

SELECT DISTINCT release_year, rental_duration FROM film   -- distinct of both year and duration (year+duration) not individually

SELECT rental_rate, COUNT(rental_rate)  FROM film
GROUP BY rental_rate

SELECT column_name FROM information_schema.columns
WHERE table_name = 'film'

SELECT column_name FROM information_schema.columns
WHERE table_name = 'film' AND column_name LIKE '%rating%'

SELECT column_name from information_schema.columns
WHERE table_name = 'payment'

SELECT COUNT(*) FROM customer; -- total number of rows

SELECT COUNT(DISTINCT first_name) FROM customer;

SELECT COUNT(DISTINCT first_name) AS name, COUNT(DISTINCT last_name) AS surname FROM customer;

SELECT payment_id FROM payment
LIMIT 5 OFFSET 5;
-- postgres sql allow you to sort columns (orderby) without putting it in select statement as well, not true for other DB SQL
SELECT last_name FROM customer
WHERE first_name = 'Kelly'
ORDER BY first_name ASC

SELECT customer_id, amount FROM payment
WHERE amount NOT BETWEEN 8 AND 9;

SELECT payment_date FROM payment
WHERE payment_date BETWEEN '2007-02-07' AND '2007-02-15'; -- time not needed

SELECT customer_id, rental_id, return_date FROM rental
WHERE customer_id NOT IN (1, 2) AND return_date IS NOT NULL
ORDER BY return_date DESC;

SELECT first_name FROM customer
WHERE first_name LIKE '%er%'; -- any character

SELECT first_name FROM customer
WHERE first_name LIKE '_her%'; -- _ one character in front, like is case sensitive ilike (postgres) not case sensitivie

SELECT COUNT(first_name) FROM actor
WHERE first_name LIKE 'P%';

SELECT COUNT(DISTINCT district) FROM address;

SELECT COUNT(film_id) FROM film
WHERE replacement_cost BETWEEN 5 and 15 AND
rating = 'R'

SELECT ROUND(AVG(amount), 2) FROM payment;

SELECT COUNT(amount) FROM payment
WHERE amount = 0.00;

SELECT amount, COUNT(amount) AS count_amount FROM payment
GROUP BY amount
ORDER BY count_amount;

SELECT amount, COUNT(amount) AS count_amount FROM payment
WHERE amount = (SELECT MIN(amount) FROM payment) 
OR amount = (SELECT MAX(amount) FROM payment)
GROUP BY amount
ORDER BY count_amount;

SELECT customer_id FROM payment
GROUP BY customer_id; -- act like distinct , show unique cases 

SELECT customer_id, SUM(amount)  -- better to include customer_id in select
FROM payment 
GROUP BY customer_id
ORDER BY sum(amount) DESC;

SELECT staff_id, COUNT(payment_id)
FROM payment
GROUP BY staff_id; -- getting number of rows (payment_id primary key) per staff

SELECT rating, COUNT(*)  -- or COUNT(rating)
FROM film
GROUP BY rating;

SELECT staff_id, COUNT(payment_id), SUM(amount), ROUND(AVG(amount),1)
FROM payment
GROUP BY staff_id
ORDER BY COUNT(payment_id) DESC, SUM(amount) DESC

SELECT column_name, table_name
FROM information_schema.columns
WHERE column_name LIKE '%rating%'

SELECT rating, ROUND(AVG(replacement_cost),2) AS replace_cost
FROM film
GROUP BY rating
ORDER BY replace_cost DESC;

SELECT customer_id, SUM(amount) AS sum_amount
FROM payment
GROUP BY customer_id
ORDER BY sum_amount DESC
LIMIt 5;

SELECT store_id, COUNT(customer_id), AVG(customer_id)
FROM customer
GROUP BY store_id
HAVING AVG(customer_id) > 300;  -- comes after groupby

SELECT rating, ROUND(AVG(rental_rate), 2)
FROM film
WHERE rating IN ('R', 'G', 'PG')
GROUP BY rating
HAVING AVG(rental_rate) < 3.0;

SELECT customer_id, COUNT(amount)
FROM payment
GROUP BY customer_id
HAVING COUNT(amount) >= 40;

SELECT rating, AVG(rental_duration)
FROM film
GROUP BY rating
HAVING AVG(rental_duration) > 5;

SELECT customer_id, SUM(amount)
FROM payment
WHERE staff_id = 2
GROUP BY customer_id
HAVING SUM(amount) >= 110;

SELECT COUNT(title)
FROM film
WHERE title LIKE 'J%';

SELECT *
FROM customer
WHERE first_name LIKE 'E%' AND address_id <500
ORDER BY customer_id DESC
LIMIT 1;

SELECT customer.customer_id, first_name, last_name, amount, payment_date
FROM customer
INNER JOIN payment ON payment.customer_id = customer.customer_id  -- inner join is join 
WHERE customer.customer_id = 2   -- when column name is unique among tables, don't need to put table name behind it
ORDER BY first_name;

SELECT title, film.film_id, COUNT(title) AS count_movie
FROM film
JOIN inventory ON film.film_id = inventory.film_id
WHERE store_id = 1
GROUP BY film.film_id
ORDER BY count_movie DESC;

SELECT film.title, language.name, language.language_id
FROM film
INNER JOIN language
ON language.language_id = film.language_id
ORDER BY language.name ASC;

SELECT language.name, COUNT(language.language_id)
FROM film
JOIN language
ON language.language_id = film.language_id
GROUP BY language.language_id
ORDER BY language.name ASC;

SELECT lan.name, COUNT(lan.language_id)
FROM film
JOIN language AS lan
ON lan.language_id = film.language_id
GROUP BY lan.language_id
ORDER BY lan.name ASC;

SELECT title, rating, language.name, actor.first_name, actor.last_name,
film.film_id, language.language_id, film_actor.actor_id
FROM film
	JOIN language ON 
	film.language_id = language.language_id
	JOIN film_actor ON
	film_actor.film_id = film.film_id
    
SELECT film.film_id, film.title, inventory.inventory_id, inventory.store_id
FROM film
LEFT OUTER JOIN inventory 
ON film.film_id = inventory.film_id
WHERE inventory.inventory_id IS NULL;   -- w/o where will get all movie that are in film no matter has it inventory or not
-- with where only get the ones that title is in film but movie is not in inventory

SELECT *
FROM language
UNION ALL  -- concatenate two tables without ALL drop duplicates, with ALL keep all rows, need to have same data type and col #
SELECT * 
FROM language;

SELECT SUM(amount), extract(month from payment_date) AS month -- month , day , dow day of week, doy day of year
FROM payment -- epoch, microseconds, minute, month, second, week, year
GROUP BY month
ORDER BY SUM(amount) DESC;

SELECT customer_id + rental_id AS customer_rental_id
FROM payment; -- / is division integer, need to do x*1.0/y to get float, mod(x,y)=== %

SELECT first_name || ' ' || last_name AS first_last FROM customer; -- upper, lower, left('abcd', 2) =>'ab'

SELECT char_length(first_name || ' ' || last_name) AS length_name
FROM customer;
/* position('st' in 'postgre') => 2
 substring('postgres' from 5 for 4) => gres
 split_part('abc@xyb@hi','@,3) => 'hi'
 replace ('abcdefabcdef', 'cd','XX') => 'abXXefabXXef' */

SELECT title, rental_rate  -- subquery
FROM film
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film);

SELECT customer.customer_id,
first_name, last_name, email, amount, payment_date, rental_id
FROM customer
JOIN payment
ON customer.customer_id = payment.customer_id
LIMIT 10;

SELECT customer.customer_id,
first_name, last_name, email, SUM(amount) AS sum_rental
FROM customer
JOIN payment
ON customer.customer_id = payment.customer_id
WHERE (char_length(first_name) BETWEEN 3 AND 4) AND first_name LIKE 'J%'
GROUP BY customer.customer_id
HAVING SUM(amount) > 110

SELECT address_id, address, district, phone
FROM address
WHERE address.address_id IN 
(SELECT customer.address_id
FROM customer
JOIN payment
ON customer.customer_id = payment.customer_id
WHERE (char_length(first_name) BETWEEN 3 AND 4) AND first_name LIKE 'J%'
GROUP BY customer.customer_id
HAVING SUM(amount) > 110)


SELECT t1.address_id, t1.address, t1.district, t2.first_name, t2.last_name
FROM address AS t1
INNER JOIN (SELECT customer.customer_id, address_id,
first_name, last_name, email, SUM(amount)
FROM customer
INNER JOIN payment
ON customer.customer_id = payment.customer_id
WHERE (char_length(first_name) BETWEEN 3 AND 4) AND first_name LIKE 'J%'
GROUP BY customer.customer_id
HAVING SUM(amount) > 110) AS t2
ON t1.address_id = t2.address_id

SELECT *,
CASE
WHEN (char_length(t3.address) > 20) THEN 'LONG ADDRESS'
WHEN (char_length(t3.address) = 20) THEN 'MEDIUM ADDRESS'
ELSE 'SHORT ADDRESS'
END AS address_length
FROM (SELECT t1.address_id, t1.address, t1.district, t2.first_name, t2.last_name
FROM address AS t1
INNER JOIN (SELECT customer.customer_id, address_id,
first_name, last_name, email, SUM(amount)
FROM customer
INNER JOIN payment
ON customer.customer_id = payment.customer_id
WHERE (char_length(first_name) BETWEEN 3 AND 4) AND first_name LIKE 'J%'
GROUP BY customer.customer_id
HAVING SUM(amount) > 110) AS t2
ON t1.address_id = t2.address_id) AS t3

SELECT t1.customer_id, t1.first_name, t1.last_name, t2.customer_id, t2.first_name, t2.last_name
FROM customer AS t1, /* INNER JOIN */ customer AS t2
/* ON */ WHERE t1.first_name = t2.last_name

SELECT t1.actor_id, t1.film_id, t2.actor_id, t2.film_id
FROM film_actor AS t1, film_actor AS t2
WHERE (t1.film_id = t2.film_id) AND (t1.film_id =1) AND (t1.actor_id < t2.actor_id)  /* to remove repetition */
ORDER BY t1.actor_id ASC, t2.actor_id ASC

1) SELECT * FROM cd.facilities;
2) SELECT name, membercost FROM cd.facilities;
3) SELECT name, membercost FROM cd.facilities
WHERE membercost > 0;
4) SELECT facid, name, membercost, monthlymaintenance FROM cd.facilities
WHERE membercost > 0 AND membercost < monthlymaintenance/50.;
5) SELECT * FROM cd.facilities
WHERE LOWER(name) LIKE '%tennis%';
6) SELECT * FROM cd.facilities
WHERE facid = 1 OR facid = 5; WHERE facid IN (1, 5);
7) SELECT firstname, surname, joindate FROM cd.members
WHERE joindate >= '2012-09-01'
8)SELECT DISTINCT surname FROM cd.members
ORDER BY surname ASC
LIMIT 10;
9) SELECT memid, surname, firstname FROM cd.members
ORDER BY joindate DESC
LIMIT 1; /* darren smith */
10) SELECT COUNT(facid) FROM cd.facilities
WHERE guestcost >= 10; /* 6 */
12) SELECT facid, SUM(slots) AS sum_slot FROM cd.bookings
WHERE EXTRACT(year FROM starttime)=2012 AND EXTRACT(month FROM starttime)=9
GROUP BY facid
ORDER BY sum_slot DESC;
13) SELECT facid, SUM(slots) AS sum_slot FROM cd.bookings
-- WHERE EXTRACT(year FROM starttime)=2012 AND EXTRACT(month FROM starttime)=9
GROUP BY facid
HAVING SUM(slots) >1000
ORDER BY facid DESC;
14)
SELECT t1.facid, t1.starttime, t2.name AS name
FROM cd.bookings AS t1
INNER JOIN cd.facilities AS t2
ON t1.facid = t2.facid
WHERE EXTRACT(year FROM t1.starttime) = 2012 AND EXTRACT(month FROM t1.starttime) = 9 AND EXTRACT(day FROM t1.starttime) = 21
AND LOWER(t2.name) LIKE ('%tennis court%')
ORDER BY t1.starttime ASC;

15) SELECT memid, starttime FROM cd.bookings
WHERE memid IN
(SELECT memid FROM cd.members
WHERE cd.members.firstname = 'David' AND cd.members.surname = 'Farrell')
ORDER BY starttime;

--suggested one 15) don't think is as fast
select bks.starttime from cd.bookings bks
 inner join cd.members mems on mems.memid = bks.memid
 where mems.firstname='David' and mems.surname='Farrell';
 
SELECT t1.address_id, t1.address, t1.district, t2.first_name, t2.last_name, t2.sum_amount, t2.count_amount
FROM address AS t1
INNER JOIN (SELECT customer.customer_id, address_id,
first_name, last_name, email, SUM(amount) AS sum_amount, COUNT(amount) AS count_amount
FROM customer
INNER JOIN payment
ON customer.customer_id = payment.customer_id
WHERE (char_length(first_name) BETWEEN 3 AND 4) AND first_name LIKE 'J%'
GROUP BY customer.customer_id
HAVING SUM(amount) > 50) AS t2
ON t1.address_id = t2.address_id
ORDER BY t2.count_amount DESC;

/*Boolean TRUE/FALSE/NULL 1/yes/y/t => TRUE  0/no/n/false/f => FALSE, space character => NULL
Character char, fixed length character string char(n) short<n padd, longer >n error,
 variable length varchar(n) shortner<n no pad, longer> n? probably error
Number
Temporal (date, time, ...)
Special types (Geometric data tyoe)
Array
*/


-- FOREIGN KEY (group_id) REFERENCES product_groups (group_id)
CREATE TABLE account(
user_id serial /* auto increment */ PRIMARY KEY,
username VARCHAR(50) UNIQUE NOT NULL, /* better be unique */
password VARCHAR(50) NOT NULL,
email VARCHAR(355) UNIQUE NOT NULL, /* better be unique */
create_on TIMESTAMP NOT NULL,
last_log TIMESTAMP);

CREATE TABLE potential_lead(
customer_id serial PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(150) UNIQUE NOT NULL,
sign_up_date TIMESTAMP NOT NULL,
minutes_spent numeric(10, 2) NOT NULL
);

CREATE TABLE link(
ID serial PRIMARY KEY,
URL VARCHAR(255) NOT NULL,
name VARCHAR(266) NOT NULL,
description VARCHAR(255),
relation VARCHAR(50)
);

INSERT INTO link(url, name)
VALUES('www.Google.com','Google'); /* don't need to add id since is serial automatic */

INSERT INTO link(url, name)
VALUES('www.bing.com', 'Bing'),
	  ('www.amazon.com', 'Amazon');
      
CREATE TABLE link2(LIKE link); -- copy structure to new table (only strcuture not data)

INSERT INTO link2 -- instead of putting column here (col1,col2) 
SELECT * FROM link -- instead of putting VALUES(var1,var2) here
WHERE LOWER(url) LIKE '%google%'

UPDATE link
SET description = 'Google LLC is an American multinational technology company'
WHERE name LIKE '%Google%'

UPDATE link
SET description = 'empty description'
WHERE description IS NULL

UPDATE link
SET description = 'Random stuff'
WHERE id IN (2, 4)
RETURNING id, url, name, description, relation;

INSERT INTO link(url, name)
VALUES('test1_link', 'test1_name'),
      ('test2_link', 'test2_name')
RETURNING id, url, name, description

DROP TABLE IF EXISTS link;

CREATE TABLE link(
id serial PRIMARY KEY,
title VARCHAR(512) NOT NULL,
url VARCHAR(512) NOT NULL UNIQUE
);

ALTER TABLE link ADD COLUMN active boolean;
ALTER TABLE link DROP COLUMN active;
ALTER TABLE link RENAME COLUMN title TO title_new
ALTER TABLE link RENAME TO link_new

CREATE TABLE new_users(
id serial PRIMARY KEY,
first_name VARCHAR(50),
birth_date DATE CHECK(birth_date > '1900-01-01'), 
join_date DATE CHECK(join_date > birth_date),
salary integer CHECK(salary > 0)
);

INSERT INTO new_users(first_name, birth_date, join_date, salary)
VALUES ('Me', '1980-01-02', '1990-03-4', -10);  -- this fail check constrin of salary>0

CREATE TABLE check_test(
sales integer CONSTRAINT positive_sales CHECK(sales>0) -- call the check posotive_sale
);
ALTER TABLE check_test ADD CONSTRAINT sales CHECK(sales>=0)


ALTER TABLE check_test DROP CONSTRAINT sales
ALTER TABLE check_test DROP CONSTRAINT positive_sales

ALTER TABLE check_test ADD CONSTRAINT sales CHECK(sales>=0)

ALTER TABLE check_test ADD unique_name VARCHAR(30) UNIQUE

UPDATE check_test
SET last_name = name || ' ' || name

ALTER TABLE check_Test ADD UNIQUE (last_name)

INSERT INTO check_test(name,email,last_name)
VALUES('john','john@john.com',NULL) -- can get away with lower case


CREATE TABLE students(
student_id serial PRIMARY KEY,
first_name VARCHAR(50) UNIQUE NOT NULL,
last_name VARCHAR(50) UNIQUE NOT NULL,
homeroom_number integer NOT NULL,
phone VARCHAR(12) UNIQUE NOT NULL CONSTRAINT check_phone_length CHECK(char_length(phone) = 12 AND phone LIKE '%[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]%'),
email VARCHAR(250) UNIQUE,
graduation_year integer CONSTRAINT check_year_graduate CHECK(graduation_year BETWEEN TO_NUMBER(EXTRACT(year FROM NOW())) AND TO_NUMBER(EXTRACT(year FROM (NOW() + interval '10 years'))))
);  -- not successful with last line

CREATE TABLE students(
student_id serial PRIMARY KEY,
first_name VARCHAR(50) UNIQUE NOT NULL,
last_name VARCHAR(50) UNIQUE NOT NULL,
homeroom_number integer NOT NULL,
phone VARCHAR(12) UNIQUE NOT NULL CONSTRAINT check_phone_length CHECK(char_length(phone) = 12 AND phone LIKE '%[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]%'),
email VARCHAR(250) UNIQUE,
graduation_year integer CONSTRAINT check_year_graduate CHECK(graduation_year BETWEEN 2018 AND 2028)
);

CREATE TABLE teachers(
teacher_id serial PRIMARY KEY,
first_name VARCHAR(50) UNIQUE NOT NULL,
last_name VARCHAR(50) UNIQUE NOT NULL,
homeroom_number integer NOT NULL,
department VARCHAR(50) NOT NULL,
phone VARCHAR(12) UNIQUE NOT NULL CONSTRAINT check_phone_length CHECK(char_length(phone) = 12 AND phone LIKE '%[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]%'),
email VARCHAR(250) UNIQUE
);

INSERT INTO students(first_name, last_name, homeroom_number, phone, graduation_year)
VALUES('Mark','Watney',5,'777-555-1234',2035)
ALTER TABLE students DROP CONSTRAINT check_phone_length
ALTER TABLE students ADD CONSTRAINT check_phone_length CHECK(char_length(phone) = 12 AND phone LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
-- could not do phone numers
INSERT INTO students(first_name, last_name, homeroom_number, phone, graduation_year)
VALUES('Mark','Watney',5,'777-555-1234',2028)