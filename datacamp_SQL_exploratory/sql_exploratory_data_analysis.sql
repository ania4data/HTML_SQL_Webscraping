--row and column max number

SELECT COUNT(*) FROM stackoverflow;  --45238
SELECT COUNT(*) FROM company;  -- 14
SELECT COUNT(*) FROM tag_company; --56
SELECT COUNT(*) FROM tag_type; --61
SELECT COUNT(*) FROM fortune500; --500

SELECT COUNT(*) FROM information_schema.columns
WHERE table_name = 'company'  --5
SELECT COUNT(*) FROM information_schema.columns
WHERE table_name = 'company'  --7
SELECT COUNT(*) FROM information_schema.columns
WHERE table_name = 'tag_company'  --2
SELECT COUNT(*) FROM information_schema.columns
WHERE table_name = 'stackoverflow'
SELECT COUNT(*) FROM information_schema.columns
WHERE table_name = 'tag_type'  --3
SELECT COUNT(*) FROM information_schema.columns
WHERE table_name = 'fortune500'  --15


-- column with most null
SELECT (SELECT COUNT(*) FROM fortune500) - COUNT(ticker) missing
FROM fortune500

-- common column
SELECT company.name 
FROM company
INNER JOIN fortune500
ON company.ticker = fortune500.ticker