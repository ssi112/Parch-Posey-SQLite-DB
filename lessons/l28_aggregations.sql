
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
       SUM(total_amt_usd / total) AS "Total Unit Price"
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
ORDER BY s.name;

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

