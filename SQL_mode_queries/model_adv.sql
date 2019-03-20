substring('postgres' from 5 for 4)-- => gres
SUBSTR('text',2,2) --'xt'
replace ('abcdefabcdef', 'cd','XX') --=> 'abXXefabXXef'
split_part('abc@xyb@hi',@,3) -- => 'hi'

conn=sqlite3.connect('dataframe.db')
df=pd.read_sql("SELECT * FROM x", con=conn)

cur = conn.cursor()
cur.execute("DROP TABLE IF EXISTS")
cur.execute("CREATE TABLE y(coly serial integer PRIMARY KEY)")

from sqlalchemy import create_engine

sql_engine = create_engine(
    'sqlite:///' + str(database_filepath), echo=False)
--had to have this line otherwise froze
connection = sql_engine.raw_connection()
table_name = str(sql_engine.table_names()[0])
print('DB table names', sql_engine.table_names())

df = pd.read_sql("SELECT * FROM '{}'".format(table_name), con=connection)
category_names = list(df.columns[4:])
# Remove rows when all categories not labled, or unknown '2' value
df = df[(df.related != 2) & (df[category_names].sum(axis=1) != 0)]
# if do df[['message']], later need get df.message
X = df['message']
Y = df.drop(columns=['id', 'message', 'original', 'genre'])



SELECT CURRENT_DATE AS date,
       CURRENT_TIME AS time,
       CURRENT_TIMESTAMP AS timestamp,
       LOCALTIME AS localtime,
       LOCALTIMESTAMP AS localtimestamp,
       NOW() AS now
       
/*       
COALESCE
Occasionally, you will end up with a dataset that has some nulls that you’d prefer to contain 
actual values. This happens frequently in numerical data (displaying nulls as 0 is often preferable)
and when performing outer joins that result in some unmatched rows. In cases like this, you can use
 COALESCE to replace the null values:
*/

SELECT incidnt_num,
       descript,
       COALESCE(descript, 'No Description')
  FROM tutorial.sf_crime_incidents_cleandate
 ORDER BY descript DESC
 
 
 SELECT *
  FROM tutorial.sf_crime_incidents_2014_01
 WHERE Date = (SELECT MIN(date)
                 FROM tutorial.sf_crime_incidents_2014_01
              )
              
SELECT *
  FROM tutorial.sf_crime_incidents_2014_01
 WHERE Date IN (SELECT date
                 FROM tutorial.sf_crime_incidents_2014_01
                ORDER BY date
                LIMIT 5
              )
---              
SELECT *
  FROM tutorial.crunchbase_investments_part1

 UNION ALL

 SELECT *
   FROM tutorial.crunchbase_investments_part2
   
   
--ROW_NUMBER()
--ROW_NUMBER() does just what it sounds like—displays the number of a given row.
-- It starts are 1 and numbers the rows according to the ORDER BY part of the window statement.
-- ROW_NUMBER() does not require you to specify a variable within the parentheses:

SELECT start_terminal,
       start_time,
       duration_seconds,
       ROW_NUMBER() OVER (ORDER BY start_time)
                    AS row_number
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'   
 
 
 
--Using the PARTITION BY clause will allow you to begin counting 1 again in each partition.
-- The following query starts the count over again for each terminal:

SELECT start_terminal,
       start_time,
       duration_seconds,
       ROW_NUMBER() OVER (PARTITION BY start_terminal
                          ORDER BY start_time)
                    AS row_number
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 
 --RANK() and DENSE_RANK()
--RANK() is slightly different from ROW_NUMBER(). If you order by start_time, for example, it might be the case that some terminals have rides with two identical start times.
--In this case, they are given the same rank, whereas ROW_NUMBER() gives them different numbers.
 
 SELECT start_terminal,
       duration_seconds,
       RANK() OVER (PARTITION BY start_terminal
                    ORDER BY start_time)
              AS rank
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 
--EXPLAIN
--You can add EXPLAIN at the beginning of any (working) query to get a sense of how long it will take. It’s not perfectly accurate, but it’s a useful tool. Try running this:

EXPLAIN
SELECT *
  FROM benn.sample_event_table
 WHERE event_date >= '2014-03-01'
   AND event_date < '2014-04-01'
 LIMIT 100