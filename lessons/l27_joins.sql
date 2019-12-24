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

