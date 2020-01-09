-- using subquery
-- EXAMPLE
SELECT channel, AVG(events) AS average_events
FROM (SELECT datetime(occurred_at, 'start of day') AS day,
             channel, COUNT(*) as events
      FROM web_events 
      GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;

-- using a WITH statement
WITH events AS (
                SELECT datetime(occurred_at, 'start of day') AS day,
                       channel, COUNT(*) as events
                FROM web_events 
                GROUP BY 1,2
)
SELECT channel, AVG(events) AS average_events
FROM events
GROUP BY channel
ORDER BY 2 DESC;

/* -------------------------------------------------------------------------------------------------------
1) Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales
    https://www.sqlite.org/printf.html <= commas, but not with decimal point
*/
WITH t1 AS (
      SELECT s.id, s.name, r.name AS reg_name, SUM(o.total_amt_usd) AS total_sales_amt
      FROM sales_reps s
      JOIN region r
        ON s.region_id = r.id
      JOIN accounts a
        ON s.id = a.sales_rep_id
      JOIN orders o
        ON a.id = o.account_id
      GROUP BY 1, 2, 3
     )
SELECT t1.reg_name,  MAX(t1.name) AS sales_rep,  printf("%,d", MAX(t1.total_sales_amt)) AS max_total_sales
FROM t1
GROUP BY t1.reg_name;

/* -------------------------------------------------------------------------------------------------------
2) For the region with the largest (sum) sales total_amt_usd, how many total (count) orders were placed? 
*/
WITH t1 AS (
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
)
SELECT reg_name, MAX(total_sales_amt) AS max_tot_sales_amt, MAX(order_cnt) AS max_order_cnt
FROM t1
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
                                         COUNT(standard_qty) AS cnt_std_qty,
                                         SUM(total) AS total
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

-- ***************************************************************************
-- CLASSROM SOLUTION
-- Ambiguous wording of problem - provides a different answer
-- ***************************************************************************
SELECT a.name AS acct_name, 
               SUM(o.standard_qty) AS sum_std_qty, 
               COUNT(o.standard_qty) AS cnt_std_qty,
               SUM(o.total) AS total
        FROM accounts a
        JOIN orders o
          ON a.id = o.account_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1;

WITH t1 AS (
        SELECT a.name AS acct_name, 
               SUM(o.standard_qty) AS sum_std_qty, 
               COUNT(o.standard_qty) AS cnt_std_qty,
               SUM(o.total) AS total
        FROM accounts a
        JOIN orders o
          ON a.id = o.account_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1
    ),
    t2 AS (
      SELECT a.name
      FROM orders o
      JOIN accounts a
        ON a.id = o.account_id
      GROUP BY 1
      HAVING SUM(o.total) > (SELECT total FROM t1)
    )
SELECT COUNT(*)
FROM t2;
-- ***************************************************************************


/*
4) For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
how many web_events did they have for each channel?
*/
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id = (SELECT id
                                   FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                                         FROM orders o
                                              JOIN accounts a
                                                ON a.id = o.account_id
                                              GROUP BY a.id, a.name
                                              ORDER BY 3 DESC
                                              LIMIT 1) t3)
GROUP BY 1, 2
ORDER BY 3 DESC;


WITH t3 AS (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
            FROM orders o
            JOIN accounts a
              ON a.id = o.account_id
            GROUP BY a.id, a.name
            ORDER BY 3 DESC
            LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
  ON a.id = w.account_id AND a.id = (SELECT id FROM t3)
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

WITH las AS (
      SELECT a.id, a.name, SUM(o.total_amt_usd) AS sum_tot_usd
      FROM accounts a JOIN orders o ON a.id = o.account_id
      GROUP BY 1, 2
      ORDER BY 3 DESC
      LIMIT 10
)
SELECT AVG(sum_tot_usd)
FROM las;

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

WITH t1 AS (
            SELECT AVG(o.total_amt_usd) AS avg_tot_usd
            FROM accounts a 
            JOIN orders o 
              ON a.id = o.account_id
    ),
    t2 AS (
            SELECT o.account_id, AVG(o.total_amt_usd) AS avg_usd
            FROM orders o
            GROUP BY 1
            HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1)
)
SELECT AVG(avg_usd)
FROM t2;
