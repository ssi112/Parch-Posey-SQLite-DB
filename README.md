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

### CSV Data Files

There are CSV files within the /data folder holding the raw data for import and scripts if users wish to import the data themselves. In addition, there is a `create_tables.sql` script There are also two Excel files with formulas showing how the individual data lines were created. An important thing to note about the scripts is some difference between PostgreSQL and SQLite.

**It is not necessary to create the DB, tables and load the data from scratch.**

**A SQLite database exists ready to use as _parch_posey.db_**

The CSV files were pulled from another repository. There were _some_ missing values among the order data. This was handled by inserting NULL into the scripts. It appears that in the online Postgres DB these have zereos instead. Therefore, when running some queries that specify numeric columns that equal zero one must instead include the condition of checking for NULL as well.

There is a huge difference between a value of zero and one that does not exist. I'm not certain if this course purposely inserted zereos for simplicity sake as this database is used in more than one Udacity course based on the repositories available on GitHub.

Another important note for students is that PostgreSQL attempts to stay close to the SQL standard and so there may be differences in how a query is written. Although, most of the queries for this course are rather standard and don't rely on DBMS specific functions, etc.




