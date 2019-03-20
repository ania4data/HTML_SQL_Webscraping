SELECT name, SPLIT_PART(name,' ',1) first_seg
FROM accounts

/*
In the accounts table, there is a column holding the website for each company.
The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here.
https://iwantmyname.com/domains
Pull these extensions and provide how many of each website type exist in the accounts table.
*/

SELECT RIGHT(website,3) web_type, COUNT(*)
FROM accounts
GROUP BY RIGHT(website,3)

/*
There is much debate about how much the name (or even the first letter of a company name) matters.
Use the accounts table to pull the first letter
of each company name to see the distribution of company names that begin with each letter (or number). 
*/

SELECT SUBSTR(name,1,1) first_letter, COUNT(*) count_first_letter
FROM accounts
GROUP BY SUBSTR(name,1,1)
ORDER BY count_first_letter DESC

/*
Use the accounts table and a CASE statement to create two groups: 
one group of company names that start with a number and a second group of those company names that start with a letter.
What proportion of company names start with a letter?
*/

SELECT name, SUBSTR(name,1,1) first_letter,
CASE 
	WHEN SUBSTR(name,1,1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 'number'
	ELSE 'letter'
	END AS letter_or_number
FROM accounts
ORDER BY letter_or_number DESC

/*
Use the accounts table and a CASE statement to create two groups: 
one group of company names that start with a number and a second group of those company names that start with a letter.
What proportion of company names start with a letter?
*/



(SELECT t1.letter_or_number, COUNT(*) count_per_type, 
 (SELECT COUNT(*) FROM accounts) AS total, ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM accounts),2)
FROM
(SELECT name, SUBSTR(name,1,1) first_letter,
CASE 
	WHEN SUBSTR(name,1,1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 'number'
	ELSE 'letter'
	END AS letter_or_number
FROM accounts) t1
GROUP BY t1.letter_or_number) 

/*
Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?
*/



(SELECT t1.vowel, COUNT(*) count_per_type, 
 (SELECT COUNT(*) FROM accounts) AS total, ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM accounts),1)
FROM
(SELECT name, SUBSTR(LOWER(name),1,1) first_letter,
CASE 
	WHEN SUBSTR(LOWER(name),1,1) IN ('a','e','i','o','u') THEN 'vowel'
	ELSE 'not vowel'
	END AS vowel
FROM accounts) t1
GROUP BY t1.vowel) 

/*
Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc. 
*/

SELECT primary_poc, STRPOS(primary_poc, ' ') as pos_space, 
LEFT(primary_poc,STRPOS(primary_poc, ' ')-1) first_name,
RIGHT(primary_poc, LENGTH(primary_poc)-STRPOS(primary_poc, ' ')) last_name
FROM accounts

/*
Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.
*/

SELECT name, STRPOS(name, ' ') as pos_space, 
LEFT(name,STRPOS(name, ' ')-1) first_name,
RIGHT(name, LENGTH(name)-STRPOS(name, ' ')) last_name
FROM sales_reps

/*
Each company in the accounts table wants to create an email address for each primary_poc.
The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
*/

SELECT t1.first_name, t1.last_name, CONCAT(t1.first_name,'.',t1.last_name,'@',t1.account_name,'.com')
FROM
(SELECT REPLACE(name, ' ','') account_name, primary_poc, STRPOS(primary_poc, ' ') as pos_space, 
LEFT(primary_poc,STRPOS(primary_poc, ' ')-1) first_name,
RIGHT(primary_poc, LENGTH(primary_poc)-STRPOS(primary_poc, ' ')) last_name
FROM accounts) t1

/*
We would also like to create an initial password, which they will change after their first log in.
The first password will be the first letter of the primary_poc's first name (lowercase),
then the last letter of their first name (lowercase), the first letter of their last name (lowercase),
the last letter of their last name (lowercase), the number of letters in their first name, 
the number of letters in their last name,
and then the name of the company they are working with, all capitalized with no spaces.
*/

SELECT t1.first_name, t1.last_name, t1.account_name,
CONCAT(LEFT(LOWER(t1.first_name),1),
			RIGHT(LOWER(t1.first_name),1),
			LEFT(LOWER(t1.last_name),1), 
			RIGHT(LOWER(t1.last_name),1),
			LENGTH(t1.first_name),
			LENGTH(t1.last_name),
			UPPER(t1.account_name)) password_init
FROM
(SELECT REPLACE(name, ' ','') account_name, primary_poc, STRPOS(primary_poc, ' ') as pos_space, 
LEFT(primary_poc,STRPOS(primary_poc, ' ')-1) first_name,
RIGHT(primary_poc, LENGTH(primary_poc)-STRPOS(primary_poc, ' ')) last_name
FROM accounts) t1

-- recast a mm-dd-yyyy to yyyy-mm-dd
SELECT t1.concat_date::DATE  new_date-- CAST(t1.concat_date AS DATE)
FROM
(SELECT CONCAT('year',SUBSTR(sf.date,-4,4),'-',
	                  SUBSTR(sf.date,1,2),'-',
	                  SUBSTR(sf.date,3,2)) concat_date
FROM sf_crime_data sf) t1
--COALESCE
SELECT a.id, o.id, COALESCE(o.account_id, a.id), o.total, COALESCE(o.total,0) new_total 
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL; 

