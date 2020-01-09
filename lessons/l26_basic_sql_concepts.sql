SELECT id, account_id,total_amt_usd
FROM orders
ORDER BY  account_id, total_amt_usd DESC
LIMIT 10;

SELECT id, account_id,total_amt_usd
FROM orders
ORDER BY  total_amt_usd DESC, account_id;

SELECT *
FROM orders
WHERE gloss_amt_usd >= 1000
LIMIT 5;

SELECT *
FROM orders
WHERE total_amt_usd < 500
ORDER BY account_id
LIMIT 10;

SELECT name, website, primary_poc
FROM accounts
WHERE name = 'Exxon Mobil';

SELECT id, account_id, standard_amt_usd, standard_qty,
       (standard_amt_usd / standard_qty) AS unit_price
FROM orders
LIMIT 10;

SELECT id, account_id, poster_amt_usd,
       -- % in printf function is a holder to be substituted for the value
       -- the second % in the second printf is a literal character that will print, i.e., 20.02%
       -- this is specific to SQLite
       printf("$%.2f", (standard_amt_usd + gloss_amt_usd + poster_amt_usd)) AS total_revenue,
       printf("%.2f%", poster_amt_usd / (standard_amt_usd + gloss_amt_usd + poster_amt_usd) * 100) AS poster_revenue
FROM orders
LIMIT 10;

SELECT id, name
FROM accounts
-- ends with 's'
WHERE name LIKE '%s';
-- contains string 'one'
--WHERE name LIKE '%one%';
-- begins with 'C'
--WHERE name LIKE 'C%';

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom');

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords');

-- AND and BETWEEN
SELECT id, account_id, standard_qty, poster_qty, gloss_qty
FROM orders
-- returns no results in sqlite, works in postgresql ???
-- test for IS NULL (there are no zero values - see readme)
WHERE standard_qty > 1000
  -- AND poster_qty == 0
  -- AND gloss_qty == 0
  AND poster_qty IS NULL
  AND gloss_qty IS NULL;

SELECT occurred_at, gloss_qty
FROM orders
WHERE gloss_qty BETWEEN 24 AND 29;

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords')
  AND occurred_at >= '2016-01-01' AND occurred_at < '2017-01-01'
ORDER BY occurred_at DESC;

-- OR what?
SELECT id, gloss_qty, poster_qty
FROM ORDERS
WHERE (gloss_qty > 4000 OR poster_qty > 4000);

-- should return 17 results
-- cannot test for zero as in standard_qt = 0 as they are nulls instead
SELECT id, standard_qty, gloss_qty, poster_qty
FROM ORDERS
WHERE standard_qty IS NULL AND (gloss_qty > 1000 OR poster_qty > 1000);


SELECT name, primary_poc
FROM accounts
WHERE (name LIKE 'C%' or name LIKE 'W%')
  AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%') AND primary_poc NOT LIKE '%eana%')
  ;





