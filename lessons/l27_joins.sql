SELECT total, total_amt_usd,
       a.name AS "Customer Name", primary_poc AS "Point-of-Contact", sales_rep_id,
       s.name AS "Sale Rep Name", r.name AS "Region"
FROM orders o
  JOIN accounts a
  ON o.account_id = a.id
    JOIN sales_reps s
    ON a.sales_rep_id = s.id
      JOIN region r
      ON s.region_id = r.id
ORDER BY a.name
LIMIT 55;

/*
Provide a table for all web_events associated with account name of Walmart.
There should be three columns. Be sure to include the primary_poc, time of the event, and the channel for each event.
Additionally, you might choose to add a fourth column to assure only Walmart events were chosen.
*/
SELECT a.primary_poc,  e.occurred_at, e.channel, a.name
FROM web_events e
  JOIN accounts a
  ON e.account_id = a.id
WHERE a.name = 'Walmart';

/*
Provide a table that provides the region for each sales_rep along with their associated accounts.
Your final table should include three columns: the region name, the sales rep name, and the account name.
Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT r.name AS "Region Name", s.name AS "Sales Rep Name", a.name AS "Account Name"
FROM sales_reps s
  JOIN accounts a
  ON s.id = a.sales_rep_id
    JOIN region r
    ON s.region_id = r.id
ORDER BY a.name;

/*
Provide the name for each region for every order, as well as the account name and the unit price they paid
   (total_amt_usd/total) for the order.
Your final table should have 3 columns: region name, account name, and unit price.
A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.
*/
/* ---------------------- */
/* >>>>> FOR SQLite <<<<< */
/* ---------------------- */
SELECT r.name AS "Region Name", a.name AS "Account Name",
       CASE
          WHEN o.total IS NOT NULL OR o.total <> 0
             THEN printf("$%.2f", (o.total_amt_usd / o.total))
             ELSE printf("$%.2f", 0.0)
       END AS "Unit Price"
FROM region r
  JOIN sales_reps s
  ON r.id = s.region_id
    JOIN accounts a
    ON s.id = a.sales_rep_id
      JOIN orders o
      ON a.id = o.account_id;

/* -------------------------- */
/* >>>>> FOR POSTGRESQL <<<<< */
/* -------------------------- */
SELECT r.name AS "Region Name", a.name AS "Account Name",
       CASE o.total
          WHEN 0
             THEN to_char(0.0, '99999.99')
             ELSE to_char(o.total_amt_usd / o.total, '99999.99')
       END AS "Unit Price"
FROM region r
  JOIN sales_reps s
  ON r.id = s.region_id
    JOIN accounts a
    ON s.id = a.sales_rep_id
      JOIN orders o
      ON a.id = o.account_id;


/* 
left join with filter on the ON clause
When the database executes a query, it executes the join and everything in the ON clause first 
Then applies any WHERE filter to the results
*/
SELECT o.*, a.*
FROM orders o
LEFT JOIN accounts a
  on o.account_id = a.id
  -- adds filter to the on clause
  -- occurs before the join is executed
  AND a.sales_rep_id = 321500
-- a WHERE clause here applies to results of the join
;

/*
1) Provide a table that provides the region for each sales_rep along with their associated accounts. 
This time only for the Midwest region. 
Your final table should include three columns: the region name, the sales rep name, and the account name. 
Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT r.name AS "Region Name", s.name AS "Sales Rep Name", a.name AS "Account Name"
FROM sales_reps s
LEFT JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN region r
  ON s.region_id = r.id
WHERE r.id = 2
ORDER BY a.name;

/*
2) Provide a table that provides the region for each sales_rep along with their associated accounts. 
This time only for accounts where the sales rep has a first name starting with S and in the Midwest region.
Your final table should include three columns: the region name, the sales rep name, and the account name. 
Sort the accounts alphabetically (A-Z) according to account name. 
*/
SELECT r.name AS "Region Name", s.name AS "Sales Rep Name", a.name AS "Account Name"
FROM sales_reps s
LEFT JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN region r
  ON s.region_id = r.id
WHERE r.id = 2 AND s.name LIKE 'S%'
ORDER BY a.name;

/*
3) Provide a table that provides the region for each sales_rep along with their associated accounts. 
This time only for accounts where the sales rep has a last name starting with K and in the Midwest region. 
Your final table should include three columns: the region name, the sales rep name, and the account name. 
Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT r.name AS "Region Name", s.name AS "Sales Rep Name", a.name AS "Account Name"
FROM sales_reps s
LEFT JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN region r
  ON s.region_id = r.id
WHERE r.id = 2 AND s.name LIKE '% K%'
ORDER BY a.name;

/*
4) Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd / total) for the order.
However, you should only provide the results if the standard order quantity exceeds 100. 
Your final table should have 3 columns: region name, account name, and unit price. 
In order to avoid a division by zero error, adding .01 to the denominator here is helpful total_amt_usd / (total + 0.01). 
*/
SELECT r.name AS "Region Name", a.name AS "Account Name",
       CASE
          WHEN o.total IS NOT NULL OR o.total <> 0
             THEN printf("$%.2f", (o.total_amt_usd / o.total))
             ELSE printf("$%.2f", 0.0)
       END AS "Unit Price"
FROM region r
  JOIN sales_reps s
  ON r.id = s.region_id
    JOIN accounts a
    ON s.id = a.sales_rep_id
      JOIN orders o
      ON a.id = o.account_id
WHERE o.standard_qty > 100;

/* >>>>> POSTGRESQL <<<<< */
SELECT r.name AS "Region Name", a.name AS "Account Name",
       o.total_amt_usd / (o.total + 0.01) AS "Unit Price"
FROM region r
  JOIN sales_reps s
  ON r.id = s.region_id
    JOIN accounts a
    ON s.id = a.sales_rep_id
      JOIN orders o
      ON a.id = o.account_id
WHERE o.standard_qty > 100;


/*
5) Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd / total) for the order. 
However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. 
Your final table should have 3 columns: region name, account name, and unit price. 
Sort for the smallest unit price first. In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd / (total+0.01).
*/
SELECT r.name AS "Region Name", a.name AS "Account Name",
       o.total_amt_usd / (o.total + 0.01) AS "Unit Price"
FROM region r
  JOIN sales_reps s
  ON r.id = s.region_id
    JOIN accounts a
    ON s.id = a.sales_rep_id
      JOIN orders o
      ON a.id = o.account_id
WHERE o.standard_qty > 100 AND poster_qty > 50
ORDER BY "Unit Price";


/*
6) Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd / total) for the order. 
However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. 
Your final table should have 3 columns: region name, account name, and unit price. Sort for the largest unit price first. 
In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd / (total + 0.01)
*/
SELECT r.name AS "Region Name", a.name AS "Account Name",
       o.total_amt_usd / (o.total + 0.01) AS "Unit Price"
FROM region r
  JOIN sales_reps s
  ON r.id = s.region_id
    JOIN accounts a
    ON s.id = a.sales_rep_id
      JOIN orders o
      ON a.id = o.account_id
WHERE o.standard_qty > 100 AND poster_qty > 50
ORDER BY "Unit Price" DESC;


/*
7) What are the different channels used by account id 1001? 
Your final table should have only 2 columns: account name and the different channels. 
You can try SELECT DISTINCT to narrow down the results to only the unique values.
*/
SELECT DISTINCT a.name as "Account Name", w.channel
FROM accounts a
LEFT JOIN web_events w
  ON a.id = w.account_id
WHERE a.id = 1001;

/*
8) Find all the orders that occurred in 2015. 
Your final table should have 4 columns: occurred_at, account name, order total, and order total_amt_usd. 
*/
SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM orders o
LEFT JOIN accounts a
  ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '2015-01-01' AND '2016-01-01'
ORDER BY o.occurred_at;


