/* SQLite */
SELECT channel, Day,
      printf("%.2f", AVG(event_count)) AS avg_event_count
FROM
(SELECT strftime('%d', e.occurred_at) AS Day,
       channel,
       COUNT(*) AS event_count
FROM web_events e
GROUP BY 1, 2
--ORDER BY 2
) sub
GROUP BY 1, 2
ORDER BY 2 DESC;

SELECT *
FROM orders
WHERE strftime('%m', occurred_at) = (SELECT strftime('%m', MIN(occurred_at)) as min_month FROM orders)
ORDER BY occurred_at;

SELECT channel,
       printf("%.2f", AVG(event_count)) AS avg_event_count
FROM (SELECT date(e.occurred_at) AS Date,
             channel,
             COUNT(*) AS event_count
      FROM web_events e
      GROUP BY 1, 2
      --ORDER BY 2
     ) sub
GROUP BY 1
ORDER BY 2 DESC;


/*
Find the orders that took place in same month and year as the first order ever placed
*/
SELECT account_id, occurred_at,
       AVG(standard_qty) AS avg_std_qty,
       AVG(gloss_qty) AS avg_gloss_qty,
       AVG(poster_qty) AS avg_poster_qty
FROM orders
WHERE strftime('%m', occurred_at) = (SELECT strftime('%m', MIN(occurred_at)) as min_month FROM orders)
  AND strftime('%Y', occurred_at) = (SELECT strftime('%Y', MIN(occurred_at)) as min_year  FROM orders)
GROUP BY account_id, occurred_at
ORDER BY account_id, occurred_at;


/* count of channel activity by account */
SELECT a.id, a.name, e.channel, COUNT(*) cnt
FROM accounts a
JOIN web_events e
  ON a.id = e.account_id
GROUP BY a.id, a.name, e.channel
ORDER BY a.id;

/* 
   max channel activity for each account
   will provide rows when activity is equal for different channels
*/
SELECT t3.id, t3.name, t3.channel, t3.ct
FROM (SELECT a.id, a.name, e.channel, COUNT(*) ct
      FROM accounts a
      JOIN web_events e
        ON a.id = e.account_id
      GROUP BY a.id, a.name, e.channel) t3
JOIN (SELECT t1.id, t1.name, MAX(ct) max_channel_cnt
      FROM (SELECT a.id, a.name, e.channel, COUNT(*) ct
            FROM accounts a
            JOIN web_events e
              ON a.id = e.account_id
            GROUP BY a.id, a.name, e.channel) t1
      GROUP BY t1.id, t1.name) t2
ON t2.id = t3.id AND t2.max_channel_cnt = t3.ct
ORDER BY t3.id, t3.ct;

/* ----------------------------------------------------------------------------------------------------
                         >>>>>     >>>>> SUBQUERY MANIA <<<<<     <<<<<
   ----------------------------------------------------------------------------------------------------
1) Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales
    https://www.sqlite.org/printf.html <= commas, but not with decimal point
*/
SELECT t1.reg_name,  MAX(t1.name) AS sales_rep,  printf("%,d", MAX(t1.total_sales_amt)) AS max_total_sales
FROM (SELECT s.id, s.name, r.name AS reg_name, SUM(o.total_amt_usd) AS total_sales_amt
      FROM sales_reps s
      JOIN region r
        ON s.region_id = r.id
      JOIN accounts a
        ON s.id = a.sales_rep_id
      JOIN orders o
        ON a.id = o.account_id
      GROUP BY 1, 2, 3
      --ORDER BY 4
     ) t1
GROUP BY 1;


/* -------------------------------------------------------------------------------------------------------
2) For the region with the largest (sum) sales total_amt_usd, how many total (count) orders were placed?
*/
SELECT reg_name, MAX(total_sales_amt) AS max_tot_sales_amt, MAX(order_cnt) AS max_order_cnt
FROM (
      SELECT r.name AS reg_name,
             SUM(o.total_amt_usd) AS total_sales_amt,
             COUNT(*) AS order_cnt
      FROM sales_reps s
      JOIN region r
        ON s.region_id = r.id
      JOIN accounts a
        ON s.id = a.sales_rep_id
      JOIN orders o
        ON a.id = o.account_id
      GROUP BY 1
     ) t1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

/*
3) How many accounts had more total purchases than the account name which has bought the most standard_qty paper
throughout their lifetime as a customer?
*/
SELECT name, sum_total, tagged
FROM (
SELECT a1.name, SUM(total) AS sum_total,
       CASE
         WHEN SUM(total) > (SELECT t1.sum_std_qty
                            FROM (SELECT a.name AS acct_name,
                                         SUM(standard_qty) AS sum_std_qty,
                                         COUNT(standard_qty) AS cnt_std_qty
                                  FROM accounts a
                                  JOIN orders o
                                    ON a.id = o.account_id
                                  GROUP BY 1
                                 ) t1
                            ORDER BY 1 DESC
                            LIMIT 1
                           )
           THEN 1 ELSE 0
       END AS tagged
FROM accounts a1
JOIN orders o1
  ON a1.id = o1.account_id
GROUP BY a1.name
ORDER BY 2 DESC
) t3
WHERE tagged = 1;

-- ************************
SELECT sum_std_qty
FROM (
      SELECT a.name AS acct_name, SUM(standard_qty) AS sum_std_qty, COUNT(standard_qty) AS cnt_std_qty
      FROM accounts a
      JOIN orders o
        ON a.id = o.account_id
      GROUP BY 1
     )
ORDER BY 1 DESC
LIMIT 1;
-- ************************

-- ***************************************
-- classroom solution using CTE
WITH t1 AS (
  SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1),
t2 AS (
  SELECT a.name
  FROM orders o
  JOIN accounts a
  ON a.id = o.account_id
  GROUP BY 1
  HAVING SUM(o.total) > (SELECT total FROM t1))
SELECT COUNT(*)
FROM t2;
-- ***************************************


/*
4) For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
how many web_events did they have for each channel?
*/
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;

/*
5) What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
*/
SELECT AVG(sum_tot_usd)
FROM (
      SELECT a.id, a.name, SUM(o.total_amt_usd) AS sum_tot_usd
      FROM accounts a JOIN orders o ON a.id = o.account_id
      GROUP BY 1, 2
      ORDER BY 3 DESC
      LIMIT 10
     ) t1;

/*
6) What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that
spent more per order, on average, than the average of all orders.
*/

SELECT AVG(avg_tot_usd) AS liftime_avg_amt_usd
FROM (SELECT t1.name, t1.avg_tot_usd,
             CASE
               WHEN t1.avg_tot_usd > (SELECT AVG(total_amt_usd) FROM orders)
                 THEN 1
                 ELSE 0
             END AS tagged
      FROM (SELECT a.name, a.id, AVG(o.total_amt_usd) AS avg_tot_usd
            FROM accounts a JOIN orders o ON a.id = o.account_id
            GROUP BY a.name, a.id
           ) t1
     ) t2
WHERE tagged = 1;
--ORDER BY 3 DESC;

SELECT AVG(total_amt_usd) AS avg_tot_usd_all_orders FROM orders;


/* ------------------------ <<< PostgreSQL >>> ------------------------ */
SELECT channel,
       to_char(AVG(event_count), '999.99') AS avg_event_count
FROM (SELECT -- DATE_PART('day', e.occurred_at) AS Day,
             DATE_TRUNC('day', e.occurred_at) AS Day,
             channel,
            COUNT(*) AS event_count
      FROM web_events e
      GROUP BY 1, 2
     ) sub
GROUP BY 1
ORDER BY 2 DESC;

/*
Find the orders that took place in same month and year as the first order ever placed
*/
SELECT account_id, occurred_at,
       AVG(standard_qty) AS avg_std_qty,
       AVG(gloss_qty) AS avg_gloss_qty,
       AVG(poster_qty) AS avg_poster_qty
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = (SELECT DATE_TRUNC('month', MIN(occurred_at)) as min_month FROM orders)
  AND  DATE_TRUNC('year', occurred_at) = (SELECT DATE_TRUNC('year',  MIN(occurred_at)) as min_year FROM orders)
GROUP BY account_id, occurred_at
ORDER BY account_id, occurred_at;

-- ************************************************************************
-- see final problem before SUB-QUERY MANIA
SELECT t3.id, t3.name, t3.channel, t3.ct
FROM (SELECT a.id, a.name, e.channel, COUNT(*) ct
      FROM accounts a
      JOIN web_events e
        ON a.id = e.account_id
      GROUP BY a.id, a.name, e.channel) t3
JOIN (SELECT t1.id, t1.name, MAX(ct) max_channel_cnt
      FROM (SELECT a.id, a.name, e.channel, COUNT(*) ct
            FROM accounts a
            JOIN web_events e
              ON a.id = e.account_id
            GROUP BY a.id, a.name, e.channel) t1
      GROUP BY t1.id, t1.name) t2
ON t2.id = t3.id AND t2.max_channel_cnt = t3.ct
ORDER BY t3.id, t3.ct;

-- t1 count by channgel for accounts
SELECT a.id, a.name, e.channel, COUNT(*) ct
            FROM accounts a
            JOIN web_events e
              ON a.id = e.account_id
            GROUP BY a.id, a.name, e.channel;

-- t2 summarizes counts for the accounts
SELECT t1.id, t1.name, MAX(ct) max_channel_cnt
      FROM (SELECT a.id, a.name, e.channel, COUNT(*) ct
            FROM accounts a
            JOIN web_events e
              ON a.id = e.account_id
            GROUP BY a.id, a.name, e.channel) t1
      GROUP BY t1.id, t1.name;
      
-- t3 count by channgel for accounts
SELECT a.id, a.name, e.channel, COUNT(*) ct
      FROM accounts a
      JOIN web_events e
        ON a.id = e.account_id
      GROUP BY a.id, a.name, e.channel;
