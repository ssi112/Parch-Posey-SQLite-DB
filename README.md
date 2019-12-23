# Parch-Posey-SQLite-DB

### Parch and Posey database used in the Udacity / Bertelsmann Technology Scholarship challenge course.

Parch and Posey is a fictional paper-selling company used in SQL lessons.

The course uses PostgreSQL to store the data. The database here, however, is SQLite3. This was chosen for simplicity so students would have not to download or manage an entire DBMS.

SQLite is available for download [here](https://www.sqlite.org/index.html).

Advantages | Disadvantages
---------- | -------------
Small footprint | Limited concurrency
User Friendly | No user management
Portable | Security

For the purpose of learning and usage in this course none of the disadvantages are a concern.

For ease of use [SQLite Studio](https://sqlitestudio.pl/index.rvt) is available. Though, I recommend running the import scripts using the SQLite command line as the studio does not handle large CSV import files well. It also, mysteriously, altered some of the id values used as keys. This did not happen in the command line version and it is significanlty quicker. The studio is suitable for exploring the database schema and writing queries.

The database contains the following tables:
* accounts: accounts from Parch and Posey
* orders: orders made from 2014-12-03 to 2017-01-01
* regions: four geographical regions in the United States
* sales_reps: information on Parch and Posey's sales reps
* web_events: all web event data for Parch and Posey accounts

There are CSV files holding the raw data for import and scripts if users wish to import the data themselves.


