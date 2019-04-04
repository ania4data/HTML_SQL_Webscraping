--List the name and continent of countries in the continents containing either Argentina or Australia. Order by name of the country.

SELECT name, continent
FROM world
WHERE continent IN 
(SELECT DISTINCT(continent) WHERE name IN ('Argentina', 'Australia'))

--Which country has a population that is more than Canada but less than Poland? Show the name and the population.
SELECT name, population
FROM world
WHERE population > (SELECT population FROM world WHERE name = 'Canada')
AND
population < (SELECT population FROM world WHERE name = 'Poland')

--Germany (population 80 million) has the largest population of the countries in Europe.
-- Austria (population 8.5 million) has 11% of the population of Germany.

--Show the name and the population of each country in Europe. Show the population as a percentage of the population of Germany.


SELECT name, CONCAT(ROUND(population*100/(SELECT population FROM world WHERE name = 'Germany')),'%')
FROM world
WHERE continent = 'Europe'

--We can use the word ALL to allow >= or > or < or <=to act over a list. For example, you can find the largest country in the world, by population with this query:

SELECT name
  FROM world
 WHERE population >= ALL(SELECT population
                           FROM world
                          WHERE population>0)
                          
--Which countries have a GDP greater than every country in Europe? [Give the name only.] (Some countries may have NULL gdp values)                       
--correlated or synchronized sub-query.

SELECT name
FROM world
WHERE GDP > ALL(SELECT GDP FROM world WHERE continent = 'Europe' AND GDP>0)
                          
--Find the largest country (by area) in each continent, show the continent, the name and the area:

--With a normal nested subquery, the inner SELECT query runs first and executes once, returning values to be used by the main query.
-- A correlated subquery, however, executes once for each candidate row considered by the outer query.
-- In other words, the inner query is driven by the outer query.
--NOTE : You can also use the ANY and ALL operator in a correlated subquery.

--Find all the employees who earn more than the average salary in their department.  # if not nested have to use join (by departemnt)
-- and original table and put where salaray >avg(salary)
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
          
SELECT continent, name, area
FROM world x
WHERE area >= ALL
(SELECT area
FROM world y
WHERE x.continent = y.continent AND area>0)
          

SELECT name, area,
(SELECT name, continent, area, RANK() OVER(PARTITION BY continent ORDER BY area DESC) AS rank_area
FROM world) rank_Area
FROM world
WHERE rank_area = 1      

--List each continent and the name of the country that comes first alphabetically
-- using correlated (synchronized) loop
SELECT continent, name
FROM world x
WHERE name <= ALL
(SELECT name
FROM world y
WHERE x.continent = y.continent)

--using RANK
SELECT continent, name, RANK() OVER (PARTITION BY continent ORDER BY name ASC) rank_name
FROM world
WHERE RANK() OVER (PARTITION BY continent ORDER BY name ASC) = 1

-- using self join
SELECT x.continent, MIN(y.name)
FROM world x
JOIN world y
ON x.continent = y.continent
WHERE x.name <= y.name
GROUP BY x.continent



--Find the continents where all countries have a population <= 25000000. 
--Then find the names of the countries associated with these continents. Show name, continent and population.

SELECT name, continent, population 
FROM world
WHERE continent IN
(SELECT continent FROM
(SELECT continent, SUM(pop_25k) count_name_25k, COUNT(*) count_name
FROM
(SELECT continent, name,  
CASE
    WHEN population <= 25000000 THEN 1
    ELSE 0
    END AS pop_25k
FROM world) t1
GROUP BY continent
HAVING count_name_25k = count_name) t2)




--another way
SELECT name, continent, population FROM
world
WHERE continent IN
(SELECT t1.c_all
FROM
(SELECT continent c_all, COUNT(name) count_name_all
FROM world
GROUP BY continent) t1
JOIN
(SELECT continent c_25k, COUNT(name) count_name_25k
FROM world
WHERE population <= 25000000
GROUP BY continent) t2
ON t1.c_all = t2.c_25k
WHERE t1.count_name_all = t2.count_name_25k)

-- another way



SELECT t1.t1_name, COUNT(t2.t2_name) count_pop_3
FROM
(SELECT name t1_name, continent t1_continent, population t1_population
FROM world) t1
JOIN
(SELECT name t2_name, continent t2_continent, population t2_population
FROM world) t2
ON t1.t1_continent = t2.t2_continent
WHERE t1.t1_population / t2.t2_population> 3.0
GROUP BY t1.t1_name

--Some countries have populations more than three times that of any of their neighbours (in the same continent). Give the countries and continents.

SELECT DISTINCT t5.t5_name, t5.t5_continent 
FROM
(SELECT continent t3_continent, COUNT(*)-1 count_near
FROM world 
GROUP BY continent) t3
JOIN
(SELECT name t5_name, continent t5_continent
FROM world) t5
ON t5.t5_continent = t3.t3_continent
JOIN 
(SELECT t1.t1_name, COUNT(t2.t2_name) count_pop_3
FROM
(SELECT name t1_name, continent t1_continent, population t1_population
FROM world) t1
JOIN
(SELECT name t2_name, continent t2_continent, population t2_population
FROM world) t2
ON t1.t1_continent = t2.t2_continent
WHERE t1.t1_population / t2.t2_population> 3.0
GROUP BY t1.t1_name) t4
ON t5.t5_name = t4.t1_name
WHERE t3.count_near = t4.count_pop_3


--- SUM /AVG/ ...
-- africa total GDP
SELECT SUM(GDP)
FROM world
WHERE continent = 'Africa'

-- How many countries have an area of at least 1000000
SELECT COUNT(name)
FROM world
WHERE area >= 1000000

--What is the total population of ('Estonia', 'Latvia', 'Lithuania')
SELECT SUM(population)
FROM world
WHERE name IN ('Estonia', 'Latvia', 'Lithuania')

--For each continent show the continent and number of countries.
SELECT continent, COUNT(name)
FROM world
GROUP BY continent

--For each continent show the continent and number of countries with populations of at least 10 million.
SELECT continent, COUNT(name)
FROM world
WHERE population >= 10000000
GROUP BY continent

--List the continents that have a total population of at least 100 million.
SELECT continent
FROM world
GROUP BY continent
HAVING SUM(population) >= 100000000

/*

JOIN

*/
--show the matchid and player name for all goals scored by Germany. To identify German players, check for: teamid = 'GER'
SELECT matchid, player FROM goal 
  WHERE teamid = 'GER'
  
--show the player, teamid, stadium and mdate for every German goal.
SELECT player, teamid, stadium, mdate
  FROM game 
  JOIN goal
  ON (game.id=goal.matchid)
  WHERE goal.teamid = 'GER'
  
-- Show the team1, team2 and player for every goal scored by a player called Mario  
SELECT team1, team2, player
  FROM game 
  JOIN goal
  ON (game.id=goal.matchid)
  WHERE goal.player LIKE 'Mario%'
  
-- Show player, teamid, coach, gtime for all goals scored in the first 10 minutes  
SELECT player, teamid, coach, gtime
FROM goal
JOIN eteam
ON eteam.id = goal.teamid
WHERE gtime <= 10

-- List the the dates of the matches and the name of the team in which 'Fernando Santos' was the team1 coach.
SELECT DISTINCT mdate, teamname
FROM game
JOIN goal
ON game.id = goal.matchid
JOIN eteam
ON goal.teamid = eteam.id AND eteam.id = game.team1
WHERE eteam.coach = 'Fernando Santos'

--List the player for every goal scored in a game where the stadium was 'National Stadium, Warsaw'
SELECT player
FROM game
JOIN goal
ON game.id = goal.matchid
WHERE stadium = 'National Stadium, Warsaw'

-- show the name of all players who scored a goal against Germany.
SELECT DISTINCT player
  FROM game
  JOIN goal
  ON goal.matchid = game.id 
    WHERE (team1='GER' OR team2='GER') AND goal.teamid != 'GER'
    
-- Show teamname and the total number of goals scored
SELECT teamname, t1.goal_count
FROM eteam
JOIN
(SELECT teamid, COUNT(*) goal_count
FROM goal
GROUP BY teamid) t1
ON t1.teamid = eteam.id

--Show the stadium and the number of goals scored in each stadium.
SELECT stadium, COUNT(*) total_goal
FROM game
JOIN goal
ON game.id = goal.matchid
GROUP BY stadium

--For every match involving 'POL', show the matchid, date and the number of goals scored.

SELECT matchid, mdate, COUNT(*) count_goal
FROM game 
JOIN goal
ON goal.matchid = game.id AND (game.team1 = 'POL' OR game.team2 = 'POL')
GROUP BY matchid, mdate

-- For every match where 'GER' scored, show matchid, match date and the number of goals scored by 'GER'
SELECT matchid, mdate, COUNT(*) count_goal
FROM game
JOIN goal
ON game.id = goal.matchid AND goal.teamid = 'GER'
GROUP BY matchid, mdate

/*


List every match with the goals scored by each team as shown.
This will use "CASE WHEN" which has not been explained in any previous exercises.
mdate	team1	score1	team2	score2
1 July 2012	ESP	4	ITA	0
10 June 2012	ESP	1	ITA	1
10 June 2012	IRL	1	CRO	3
...
Notice in the query given every goal is listed. If it was a team1 goal then a 1 appears in score1, otherwise there is a 0.
 You could SUM this column to get a count of the goals scored by team1. Sort your result by mdate, matchid, team1 and team2.
*/


WITH t3 AS (SELECT mdate, team1, team2, teamid, matchid, gtime,
CASE 
    WHEN team1 = teamid THEN 1
    ELSE 0   -- when team has no goal
    END AS score_team1,
CASE 
    WHEN team2 = teamid THEN 1
    ELSE 0   -- when team has no goal
    END AS score_team2
FROM game
LEFT JOIN   -- had to do this for games with no goal either side to have all game entries
(SELECT matchid, teamid, gtime
FROM goal) t1
ON game.id = t1.matchid
ORDER BY mdate)

SELECT mdate, team1, SUM(score_team1) score1, team2, SUM(score_team2) score2
FROM t3
GROUP BY mdate, matchid
ORDER BY mdate, matchid, team1, team2