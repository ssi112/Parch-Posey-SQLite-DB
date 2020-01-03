# Parch-Posey-SQLite-DB

### Parch and Posey database used in the Udacity / Bertelsmann Technology Scholarship challenge course.

Parch and Posey is a fictional paper-selling company used in SQL lessons.

The course uses PostgreSQL to store the data. The database here, however, is SQLite3. This was chosen for simplicity so students would have not to download or manage an entire DBMS.

SQLite is available for download [here](https://www.sqlite.org/index.html).

Advantages |
---------- |
Small footprint |
User Friendly |
Portable |

There are disadvantages as well: limited concurrency, no user management for instace. For the purpose of learning and usage in this course none of the disadvantages are a concern.

For ease of use [SQLite Studio](https://sqlitestudio.pl/index.rvt) is available. Though, I recommend running the import scripts using the SQLite command line as the studio does not handle large CSV import files well. It also, mysteriously, altered some of the id values used as keys. This did not happen in the command line version and it is significantly quicker. The studio _is_ suitable for exploring the database schema and writing queries.

The database contains the following tables:
* __accounts__: accounts from Parch and Posey
* __orders__: orders made from 2014-12-03 to 2017-01-01
* __regions__: four geographical regions in the United States
* __sales_reps__: information on Parch and Posey sales reps
* __web_events__: all web event data for Parch and Posey accounts

![ERD](/images/parch-posey-erd.png "Entity Relationship Diagram")

### Importing Data

Within the /script folder there is a `create_tables.sql` script to create empty tables. An Excel file holds all the data extracted from the course DB. Within each sheet are formulas for creating the import scripts. One script exists for each table and can be ran using the command line. This is recommended as SQLite Studio had difficulty importing the larger data.

---

**It is not necessary to create the DB, tables and load the data from scratch.**

**A SQLite database exists ready to use as _parch_posey.db_**

Clicking on the file name link above will open a new page with a download option.

---

Previously, the data were pulled from another repository. There were _some_ missing values among the orders table data. This was handled by inserting NULL into the scripts. It appears that in the online Postgres DB these have zereos instead. _Data has since been pulled from the course DB and reloaded to eliminate any data differences_.

Another important note is that PostgreSQL attempts to stay close to the SQL standard and so there may be differences in how a query is written. Although, most of the queries for this course are rather standard and don't rely on DBMS specific functions, etc. The most obvious difference is how dates are handled. A short example follows:

Databases store dates from biggest to most granular | YYYY MM DD HH MM SS

**PostgreSQL**
```
SELECT DATE_PART('year', o.occurred_at) as Year,
       DATE_PART('month', o.occurred_at) as Month,
       SUM(gloss_amt_usd) AS gloss_amt_usd
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY Month, Year
ORDER BY gloss_amt_usd DESC;
```

**SQLite**
```
SELECT strftime('%Y', o.occurred_at) as Year,
       strftime('%m', o.occurred_at) as Month,
       SUM(gloss_amt_usd) AS gloss_amt_usd
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY Month, Year
ORDER BY gloss_amt_usd DESC;
```

**OUTPUT**

Year | Month | gloss_amt_usd
---- | ----- | -------------
2016 | 05 | 9257.64
2016 | 01 | 5070.73
2015 | 11 | 4890.97
2016 | 04 | 4875.99
2015 | 12 | 4823.55
2016 | 03 | 4711.21


References for PostgreSQL using [DATE_TRUNC](http://www.postgresqltutorial.com/postgresql-date_trunc/) and [DATE_PART](https://www.postgresql.org/docs/9.1/functions-datetime.html)

Reference for SQLite3 [strftime](https://www.w3resource.com/sqlite/sqlite-strftime.php)

---


Another area where the two DBs differ are some string handling functions. In the lesson on data cleansing the course uses a different table: SF Crime Data which has dates formatted in the following manner: 01/31/2014 08:00:00 AM +0000.

To convert this to a proper SQL date the `SUBSTRING` function can be used in both systems.

`SUBSTRING ( string, start_position, length )`

As example:

```
WITH d1 AS (SELECT date,
            SUBSTRING(date, 1, 2) AS month,
            SUBSTRING(date, 4, 2) AS day,
            SUBSTRING(date, 7, 4) AS year
FROM sf_crime_data
LIMIT 10
)
SELECT *,  year || '-' || month || '-' || day AS new_date,
       CAST( year || '-' || month || '-' || day AS date ) AS sql_date
FROM d1;
```

On the othe hand, SQLite has a `SUBSTR` function that performs the same function. With PostqreSQL you can use `LEFT` and `RIGHT` functions to solve similar problems. Note SQLite does _not_ have either of those.

**SQLite**
```
SELECT primary_poc,
       '[' || SUBSTR(primary_poc, 0, INSTR(primary_poc, ' ')) || ']' AS fname,
       '[' || SUBSTR(primary_poc, INSTR(primary_poc, ' ') + 1, LENGTH(primary_poc) - INSTR(primary_poc, ' ')) || ']' as lname,
       LENGTH(primary_poc) AS len,
       INSTR(primary_poc, ' ') AS pos
FROM accounts;
```

**PostgreSQL**
```
SELECT primary_poc,
       '[' || LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) || ']' AS fname,
       '[' || RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) || ']' AS lname
FROM accounts;
```

Also, note that SQLite made use of the `INSTR` function while PostgreSQL used `STRPOS` to find the position of a string within a string.

Reference:
 * SQLite => https://sqlite.org/lang_corefunc.html#instr
 * PostgreSQL => https://www.postgresql.org/docs/current/functions-string.html


