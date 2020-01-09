/*
1) The last three digits specify what type of web address they are using. 
   Pull these extensions and provide how many of each website type exist in the accounts table
*/
SELECT SUBSTR(website, LENGTH(website) - 2), COUNT(*)
FROM accounts a
GROUP BY 1;

/* <<< POSTGRESQL >>>
SELECT RIGHT(website, 3), COUNT(*)
FROM accounts a
GROUP BY 1;
*/


/*
2)  Use the accounts table to pull the first letter of each company name to see the distribution of 
   company names that begin with each letter (or number). 
*/
SELECT UPPER(SUBSTR(name, 1, 1)), COUNT(*)
FROM accounts a
GROUP BY 1
ORDER BY 2;

SELECT name FROM accounts WHERE name LIKE 'X%';

/*
SELECT UPPER(LEFT(name, 1)), COUNT(*)
FROM accounts a
GROUP BY 1
ORDER BY 2;
*/

/*
3) Use the accounts table and a CASE statement to create two groups: 
  one group of company names that start with a number and a second group that start with a letter. 
  What proportion of company names start with a letter?
*/
SELECT SUM(num_cnt) AS tot_num_cnt, 
       (SUM(num_cnt) * 1.0) / SUM(num_cnt + ltr_cnt) * 100 AS ratio_nums,
       SUM(ltr_cnt) AS tot_ltr_cnt,
       (SUM(ltr_cnt) * 1.0) / SUM(num_cnt + ltr_cnt) * 100 AS ratio_ltrs
FROM (
SELECT CASE WHEN SUBSTR(name, 1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
            THEN 1
            ELSE 0
       END AS num_cnt,
       CASE WHEN SUBSTR(name, 1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
            THEN 0
            ELSE 1
       END AS ltr_cnt
FROM accounts a
) t1;


/*
4) Consider vowels as a, e, i, o, and u. 
  What proportion of company names start with a vowel, and what percent start with anything else? 
*/
SELECT SUM(vowel_cnt) AS tot_vowel_cnt, 
       (SUM(vowel_cnt) * 1.0) / SUM(vowel_cnt + other_cnt) * 100 AS ratio_vowels,
       SUM(other_cnt) AS tot_other_cnt,
       (SUM(other_cnt) * 1.0) / SUM(vowel_cnt + other_cnt) * 100 AS ratio_other
FROM (
SELECT name, UPPER( SUBSTR(name, 1, 1) ) AS fucked,
       CASE WHEN UPPER( SUBSTR(name, 1, 1) ) IN ('A','E','I','O','U')
            THEN 1
            ELSE 0
       END AS vowel_cnt,
       CASE WHEN UPPER( SUBSTR(name, 1, 1) ) IN ('A','E','I','O','U')
            THEN 0
            ELSE 1
       END AS other_cnt
FROM accounts a
) vowels;

/*
SELECT SUM(vowel_cnt) AS tot_vowel_cnt, 
       (SUM(vowel_cnt) * 1.0) / SUM(vowel_cnt + other_cnt) * 100 AS ratio_vowels,
       SUM(other_cnt) AS tot_other_cnt,
       (SUM(other_cnt) * 1.0) / SUM(vowel_cnt + other_cnt) * 100 AS ratio_other
FROM (
SELECT name,
       CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
            THEN 1
            ELSE 0
       END AS vowel_cnt,
       CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
            THEN 0
            ELSE 1
       END AS other_cnt
FROM accounts a
) vowels;
*/

/*
   separate name columns into first and last name
*/
SELECT primary_poc, 
       '[' || SUBSTR(primary_poc, 0, INSTR(primary_poc, ' ')) || ']' AS fname,
       '[' || SUBSTR(primary_poc, INSTR(primary_poc, ' ') + 1, LENGTH(primary_poc) - INSTR(primary_poc, ' ')) || ']' as lname,
       LENGTH(primary_poc) AS len,
       INSTR(primary_poc, ' ') AS pos
FROM accounts;

/* ------------------------ <<< POSTGRESQL >>> ------------------------
SELECT primary_poc, 
       '[' || LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) || ']' AS fname,
       '[' || RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) || ']' AS lname
FROM accounts;
SELECT name, 
      '[' || LEFT(name, STRPOS(name, ' ') - 1) || ']' AS fname,
      '[' || RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) || ']' AS lname
FROM sales_reps;
*/


/*
1) Each company in the accounts table wants to create an email address for each primary_poc. 
   The email address should be the first name of the primary_poc '.' last name primary_poc @ company name '.com.'
2) Create an email address that will work by removing all of the spaces in the account name
SELECT primary_poc, 
       LOWER(LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1)) || '.' ||
       LOWER(RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' '))) || '@' ||
       LOWER( REPLACE(name, ' ', '_') ) || '.com'
       AS email_address
FROM accounts;
*/


/*
3) Create an initial password:
   c1 = first letter of the primary_poc's first name (lowercase)
   c2 = last letter of their first name (lowercase)
   c3 = first letter of their last name (lowercase)
   c4 = last letter of their last name (lowercase)
   c5 = the number of letters in their first name
   c6 = the number of letters in their last name
   c7 = the name of the company they are working with, all capitalized with no spaces
   
   ! For PostgreSQL use LEFT, RIGTH with proper parameters in place of SUBSTR (see above) !
   
*/
WITH t1 AS ( -- extract parts of name and company
            SELECT LOWER(SUBSTR(primary_poc, 0, INSTR(primary_poc, ' '))) AS fname,
                   LOWER(SUBSTR(primary_poc, INSTR(primary_poc, ' ') + 1, LENGTH(primary_poc) - INSTR(primary_poc, ' '))) AS lname,
                   UPPER(REPLACE(name, ' ', '_')) AS company
            FROM accounts a
),
     t2 AS ( -- extract each component of criteria numbered above
            SELECT fname, lname, company,
            SUBSTR(fname, 1, 1) AS c1,
            SUBSTR(fname, LENGTH(fname), 1) AS C2,
            SUBSTR(lname, 1, 1) AS c3,
            SUBSTR(lname, LENGTH(lname), 1) AS c4,
            LENGTH(fname) AS c5,
            LENGTH(lname) AS c6,
            company AS c7
            FROM t1
)
SELECT *, c1 || c2|| c3|| c4 || c5 || c6 || c7 AS temp_password
FROM t2;

/*
   Date conversion - note the course uses a different DB for this lesson: SF Crime Data database
   Write a query to change the date into correct SQL format.
   Once the column is in correct format, CAST it to a date.
   Note dates in this table are formatted as: 01/31/2014 08:00:00 AM +0000
   
   * SQLite's SUBSTR performs the same function *
*/
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


SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL; 

SELECT a.*,
       COALESCE(o.account_id, a.id) AS null_id,
       COALESCE(o.total, 0) AS total,
       COALESCE(o.total_amt_usd, 0) AS total_amt_usd
FROM accounts a
LEFT JOIN orders o
  ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COALESCE(a.id, a.id) filled_id, 
       a.name, 
       a.website, 
       a.lat, 
       a.long, 
       a.primary_poc, 
       a.sales_rep_id, 
       COALESCE(o.account_id, a.id) account_id, 
       o.occurred_at, 
       COALESCE(o.standard_qty, 0) standard_qty, 
       COALESCE(o.gloss_qty,0) gloss_qty, 
       COALESCE(o.poster_qty,0) poster_qty, 
       COALESCE(o.total,0) total, 
       COALESCE(o.standard_amt_usd,0) standard_amt_usd, 
       COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, 
       COALESCE(o.poster_amt_usd,0) poster_amt_usd, 
       COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;


