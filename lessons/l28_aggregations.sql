
SELECT AVG(standard_amt_usd) AS avg_std_usd, 
       AVG(standard_qty) AS avg_std_qty,
       AVG(gloss_amt_usd) AS avg_gloss_usd,
       AVG(gloss_qty) AS avg_gloss_qty,
       AVG(poster_amt_usd) AS avg_poster_usd,
       AVG(poster_qty) AS avg_poster_qty
FROM orders o;


SELECT MIN(occurred_at)
FROM orders o;

SELECT occurred_at
FROM orders o
ORDER BY occurred_at ASC
LIMIT 1;

SELECT MAX(occurred_at)
FROM web_events;

/* what is the MEDIAN total_usd spent on all orders? */
SELECT total_amt_usd
FROM orders o1
LIMIT 1
OFFSET (SELECT COUNT(*)
        FROM orders o) / 2;

/* MEDIAN: combine even/odd cases */
SELECT AVG(total_amt_usd) AS Median
FROM (SELECT total_amt_usd
      FROM orders o3 
      ORDER BY total_amt_usd
      LIMIT 2 - (SELECT COUNT(*) FROM orders o1 ) % 2    -- odd 1, even 2
      OFFSET (SELECT (COUNT(*) - 1) / 2
              FROM orders)) AS o;

/*
offset is used to determine the starting point for the number of rows to be returned from a query. 
running just this code, see that LIMIT 2 returns just two rows, as expected, and the OFFSET tells it which row to begin at
*/
SELECT total_amt_usd
      FROM orders o3 
      ORDER BY total_amt_usd
      LIMIT 2 - (SELECT COUNT(*) FROM orders o1 ) % 2    -- odd 1, even 2
      OFFSET (SELECT (COUNT(*) - 1) / 2
              FROM orders);

/* aggregate - group by, order by */
SELECT o.account_id,  a.name,
       SUM(total) AS "Total AMT", 
       SUM(total_amt_usd) AS "Total USD",
       SUM(total_amt_usd / (total + 0.01)) AS "Total Unit Price"
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
GROUP BY o.account_id, a.name
ORDER BY o.account_id;


/* 
     GROUP BY 1
1) Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
*/
SELECT MIN(o.account_id), MIN(a.name), MIN(o.occurred_at) AS "Earlist Order"
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
GROUP BY o.account_id, a.name
ORDER BY o.occurred_at
LIMIT 1;

SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY occurred_at
LIMIT 1;

/*
2) Find the total sales in usd for each account. 
Include two columns - the total sales for each company's orders in usd and the company name
*/
SELECT a.name, SUM(o.total_amt_usd)
FROM accounts a
JOIN orders o
  ON a.id = o.account_id
GROUP BY a.name
ORDER BY a.name;

/*
3) Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? 
Your query should return only three values - the date, channel, and account name.
*/
SELECT w.account_id, a.name, w.channel, MAX(w.occurred_at) "Earlist Event"
FROM web_events w
JOIN accounts a
  ON w.account_id = a.id
GROUP BY  w.account_id, a.name, w.channel, w.occurred_at
ORDER BY w.occurred_at DESC
LIMIT 1;

/*
5) Who was the primary contact associated with the earliest web_event? 
*/
SELECT a.primary_poc, w.occurred_at
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;

/*
6) What was the smallest order placed by each account in terms of total usd. 
Provide only two columns - the account name and the total usd.
 Order from smallest dollar amounts to largest.
*/
SELECT a.name, MIN(total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order DESC;

/* -------------------------------------------------------------------------------------------------------------
     GROUP BY 2
1) For each account, determine the average amount of each type of paper they purchased across their orders. 
Your result should have four columns - one for the account name and one for the average quantity purchased for 
each of the paper types for each account. 
*/
SELECT a.name, AVG(standard_qty) AS avg_std, AVG(gloss_qty) AS avg_gloss, AVG(poster_qty) AS avg_poster
FROM accounts a
JOIN orders o
  ON a.id = o.account_id
GROUP BY a.name
ORDER BY a.name;

/*
2) For each account, determine the average amount spent per order on each paper type. 
Your result should have four columns - one for the account name and one for the average amount spent on each paper type.
*/
SELECT a.name, AVG(standard_amt_usd) AS avg_std_usd, AVG(gloss_amt_usd) AS avg_gloss_usd, AVG(poster_amt_usd) AS avg_poster_usd
FROM accounts a
JOIN orders o
  ON a.id = o.account_id
GROUP BY a.name
ORDER BY a.name;

/*
3) Determine the number of times a particular channel was used in the web_events table for each sales rep. 
Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. 
Order your table with the highest number of occurrences first.
*/
SELECT s.name AS "Sales Rep", w.channel AS "Channel",
       COUNT(channel) AS "Channel Occurrences"
FROM accounts a
JOIN sales_reps s
  ON a.sales_rep_id = s.id
JOIN web_events w
  ON a.id = w.account_id
GROUP BY s.name, w.channel  
ORDER BY 1, 2;

/*
4) Determine the number of times a particular channel was used in the web_events table for each region. 
Your final table should have three columns - the region name, the channel, and the number of occurrences. 
Order your table with the highest number of occurrences first.
*/
SELECT r.name, w.channel, COUNT(channel) AS channel_occurrences
FROM accounts a
JOIN web_events w
  ON a.id = w.account_id
JOIN sales_reps s
  ON s.id = a.sales_rep_id
JOIN region r
  ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY channel_occurrences DESC;


/*
1) Use DISTINCT to test if there are any accounts associated with more than one region.
*/
SELECT DISTINCT a.name AS "Account Name", r.name AS "Region Name"
FROM accounts a
JOIN sales_reps s
  ON a.sales_rep_id = s.id
JOIN region r
  ON s.region_id = r.id
ORDER BY a.name;

/*
2) Have any sales reps worked on more than one account?
*/
SELECT DISTINCT a.name AS "Account Name", s.name AS "Sales Rep Name"
FROM accounts a
JOIN sales_reps s
  ON a.sales_rep_id = s.id
ORDER BY s.name;


/* HAVE YOU OR HAVE YOU NOT */
SELECT o.account_id, SUM(o.total_amt_usd) AS sum_tot_usd
FROM orders o
GROUP BY 1
--HAVING sum_tot_usd >= 250000 -- PostgreSQL = NO GO!
HAVING SUM(o.total_amt_usd) >= 250000
ORDER BY 2 DESC;

/*
1) How many of the sales reps have more than 5 accounts that they manage?
*/
SELECT s.id, s.name as sales_rep_name, COUNT(*) as num_accounts
FROM sales_reps s
JOIN accounts a
  ON s.id = a.sales_rep_id
GROUP BY 1, 2
HAVING COUNT(*) > 5
ORDER BY num_accounts;

/*
3) which account has the most orders
*/
SELECT DISTINCT account_id, COUNT(total) as num_orders
FROM orders o
GROUP BY 1
--HAVING MAX(total) don't need HAVING for this
ORDER BY 2 DESC
LIMIT 1 ;

/*
4) How many accounts spent more than 30,000 usd total across all orders?
*/
SELECT a.name, COUNT(*), SUM(total_amt_usd) AS tot_amt_usd
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
GROUP BY a.name
HAVING SUM(total_amt_usd) > 30000
ORDER BY a.name;

/*
8) Which accounts used facebook as a channel to contact customers more than 6 times?
*/
SELECT a.name as acct_name, w.channel as fuckbook, COUNT(*) as abused
FROM accounts a
JOIN web_events w
  ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.name, w.channel
HAVING COUNT(*) > 6
ORDER BY abused, a.name;


/* ----------------------------------------------------------------------------------------
    DATES DB stored from biggest to most granular | YYYY MM DD HH MM SS 

    PostgreSQL uses DATE_TRUNC('day', datecolumn) to accomplish same
    https://stackoverflow.com/questions/28638907/postgresql-sqlite-date-trunc-equivalent
    
    For PostgreSQL also see DATE_PART: parms: 'second', 'day', 'month', 'year', 'dow'
    https://www.postgresql.org/docs/9.1/functions-datetime.html
*/
SELECT DATETIME(o.occurred_at, 'start of day'), 
       strftime('%m', o.occurred_at) as Month,
       strftime('%d', o.occurred_at) as Day,
       strftime('%Y', o.occurred_at) as Year,
       SUM(standard_qty) AS sum_std_qty
FROM orders o
GROUP BY  datetime(o.occurred_at, 'start of day')
ORDER BY  datetime(o.occurred_at, 'start of day');

/*
1) Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. 
Do you notice any trends in the yearly sales totals?
*/
SELECT strftime('%Y', o.occurred_at) as Year,
       SUM(total_amt_usd) AS sum_tot_usd
FROM orders o
GROUP BY Year
ORDER BY sum_tot_usd DESC;


/*
2) Which month did Parch & Posey have the greatest sales in terms of total dollars? 
Are all months evenly represented by the dataset?
*/
SELECT strftime('%m', o.occurred_at) as Month,
       SUM(total_amt_usd) AS sum_tot_usd
FROM orders o
WHERE o.occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY Month
ORDER BY sum_tot_usd DESC;

/*
3) Which year did Parch & Posey have the greatest sales in terms of total number of orders? 
Are all years evenly represented by the dataset?
*/
SELECT strftime('%Y', o.occurred_at) as Year,
       SUM(total) AS total
FROM orders o
GROUP BY Year
ORDER BY total DESC
LIMIT 1;

/*
4) Which month did Parch & Posey have the greatest sales in terms of total number of orders? 
Are all months evenly represented by the dataset?
*/
SELECT strftime('%m', o.occurred_at) as Month,
       SUM(total) AS total
FROM orders o
GROUP BY Month
ORDER BY total DESC;

/*
5) In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
*/
SELECT strftime('%Y', o.occurred_at) as Year,
       strftime('%m', o.occurred_at) as Month,
       SUM(gloss_amt_usd) AS gloss_amt_usd
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY Month, Year
ORDER BY gloss_amt_usd DESC;

/* 5) POSTGRESQL */
SELECT DATE_PART('year', o.occurred_at) as Year,
       DATE_PART('month', o.occurred_at) as Month,
       SUM(gloss_amt_usd) AS gloss_amt_usd
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY Month, Year
ORDER BY gloss_amt_usd DESC;


/* ------------------------------------------------------------------------------------------------ */
/* HEAD CASE - derived columns */
SELECT id, account_id, occurred_at, channel,
       CASE
            WHEN channel = 'facebook' OR channel = 'direct'
                 THEN 'Yea'
                 ELSE 'Nay'
       END AS "Something"
FROM web_events w
ORDER BY occurred_at;

SELECT id, 
       CASE WHEN standard_qty = 0 OR standard_qty IS NULL 
       THEN 0
       ELSE standard_amt_usd / standard_qty END AS unit_price
FROM orders
LIMIT 10;

SELECT CASE WHEN total > 500  
       THEN 'Over 500'
       ELSE '500 or Under' END AS group_total,
       COUNT(*) AS order_count
FROM orders
GROUP BY 1;

/*
1) Write a query to display for each order, the account ID, total amount of the order, and the level of the order - 
 ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.
*/
SELECT account_id, total_amt_usd,
       CASE WHEN total_amt_usd > 3000  
       THEN 'Large'
       ELSE 'Small' END AS order_size
FROM orders
GROUP BY 1, 2;

/*
2) Write a query to display the number of orders in each of three categories, based on the total number of items in each order. 
The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'
*/
SELECT CASE 
         WHEN total > 2000 THEN 'At Least 2000'
         WHEN total >= 1000 AND total <= 2000 THEN 'Between 1000 and 2000'
         ELSE 'Less than 1000'
       END AS category,
       COUNT(*) cat_count
FROM orders
GROUP BY 1;

/*
3) We would like to understand 3 different levels of customers based on the amount associated with their purchases. 
The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. 
The second level is between 200,000 and 100,000 usd. 
The lowest level is anyone under 100,000 usd. 
Provide a table that includes the level associated with each account. 
You should provide the account name, the total sales of all orders for the customer, and the level.
Order with the top spending customers listed first.
*/
SELECT a.name, SUM(total_amt_usd) AS total_sales,
       CASE 
         WHEN SUM(o.total_amt_usd) > 200000 THEN 'Tier 1'
         WHEN SUM(o.total_amt_usd) >= 100000 AND SUM(o.total_amt_usd) <= 200000 THEN 'Tier 2'
         ELSE 'Tier 3'
       END AS lifetime_value
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
GROUP BY 1
ORDER BY 3, 2 DESC, 1;

/*
4) We would now like to perform a similar calculation to the first, 
but we want to obtain the total amount spent by customers only in 2016 and 2017.
Keep the same levels as in the previous question. Order with the top spending customers listed first.
*/
SELECT a.name, SUM(total_amt_usd) AS total_sales,
       CASE 
         WHEN SUM(o.total_amt_usd) > 200000 THEN 'Tier 1'
         WHEN SUM(o.total_amt_usd) >= 100000 AND SUM(o.total_amt_usd) <= 200000 THEN 'Tier 2'
         ELSE 'Tier 3'
       END AS lifetime_value
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
WHERE strftime('%Y', o.occurred_at) IN ('2016', '2017')
-- for PostgreSQL
--WHERE DATE_PART('year', o.occurred_at) IN (2016, 2017)
GROUP BY 1
ORDER BY 3, 2 DESC, 1;


/*
6) Identify top performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales.
The middle group has any rep with more than 150 orders or 500000 in sales. 
Create a table with the sales rep name, the total number of orders, total sales across all orders, 
and a column with top, middle, or low depending on this criteria. 
Place the top sales people based on dollar amount of sales first in your final table.
*/
SELECT s.name, COUNT(*) order_cnt, SUM(o.total_amt_usd) total_spent, 
      CASE 
           WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
           WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
           ELSE 'low' 
      END AS sales_rep_level
FROM orders o
JOIN accounts a
  ON o.account_id = a.id 
JOIN sales_reps s
  ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC;