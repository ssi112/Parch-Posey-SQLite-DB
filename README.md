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

Previously, the data were pulled from another repository. There were _some_ missing values among the order data. This was handled by inserting NULL into the scripts. It appears that in the online Postgres DB these have zereos instead. _Data has since been pulled from the course DB and reloaded to eliminate any data differences_.

Another important note is that PostgreSQL attempts to stay close to the SQL standard and so there may be differences in how a query is written. Although, most of the queries for this course are rather standard and don't rely on DBMS specific functions, etc. The most obvious difference is how dates are handled. A short example follows:

Databases store dates from biggest to most granular | YYYY MM DD HH MM SS

References for PostgreSQL using [DATE_TRUNC](http://www.postgresqltutorial.com/postgresql-date_trunc/) and [DATE_PART](https://www.postgresql.org/docs/9.1/functions-datetime.html)

Reference for SQLite3 [strftime](https://www.w3resource.com/sqlite/sqlite-strftime.php)

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
2016 | 02 | 4673.76
2016 | 09 | 4673.75
2016 | 08 | 4531.45
2016 | 11 | 4359.18
2016 | 07 | 4254.32
2016 | 10 | 1071.07
2016 | 12 | 951.23
2016 | 06 | 344.54
2015 | 10 | 164.78




