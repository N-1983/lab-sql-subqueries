-- self-contained scalar subqueries

-- step 1: calculate the average
SELECT AVG(amount) FROM bank.loan;

-- step 2 --> pseudo code the main goal of this step ....
SELECT * FROM bank.loan
WHERE amount > "AVERAGE";

-- step 3 ... create the query
SELECT * FROM bank.loan
WHERE amount > (
  SELECT avg(amount)
  FROM bank.loan
);

-- step 4 - Prettify the result. Let's find top 10 such customers
SELECT * FROM bank.loan
WHERE amount > (SELECT avg(amount)
                FROM bank.loan)
ORDER BY amount desc
LIMIT 10;

-- self-contained subqueries

SELECT * FROM (
  SELECT account_id, bank_to, account_to, sum(amount) AS Total
  FROM bank.order
  GROUP BY account_id, bank_to, account_to
) sub1
WHERE total > 10000;

-- alternative without subquery:

SELECT account_id, bank_to, account_to, sum(amount) AS Total
FROM bank.order
GROUP BY account_id, bank_to, account_to
HAVING Total > 10000

-- subquery needed because we only want the bank column
SELECT bank FROM (
  SELECT bank, avg(amount) AS Average
  FROM bank.trans
  WHERE bank <> ''
  GROUP BY bank
  HAVING Average > 5500) sub1;

-- use this list of banks to check which orders relate to these banks
SELECT * FROM bank.order
  WHERE bank_to IN (
    SELECT bank FROM (
      SELECT bank, avg(amount) AS Average
      FROM bank.trans
      WHERE bank <> ''
      GROUP BY bank
      HAVING Average > 5500
      ) sub1
  )
  AND k_symbol <> ' ';

-- select transactions where the k_symbol is from the 'larger' k_symbols
  SELECT * FROM bank.trans
  WHERE k_symbol IN (
    SELECT k_symbol AS symbol FROM (
      SELECT avg(amount) AS Average, k_symbol
      FROM bank.order
      WHERE k_symbol <> ' '
      GROUP by k_symbol
      HAVING Average > 3000
      ORDER BY Average DESC
    ) sub1
  );

-- A subquery is a select statement that is included with another query.
-- Enclose the subquery in parenthesis.
-- A subquery can return a single value, a list of values or a complete table.
-- A subquery can't include an ORDER BY clause.
-- There can be many levels of nesting in the subquery.
-- When you use a subquery, its results can't be included in the SELECT statement of the main query.

-- logical order of processing:
-- FROM
-- ON
-- JOIN
-- WHERE
-- GROUP BY
-- HAVING
-- SELECT
-- DISTINCT
-- ORDER BY
-- LIMIT

-- nested subqueries

SELECT k_symbol FROM (
  SELECT avg(amount) AS mean, k_symbol
  FROM bank.order
  WHERE bank_to IN (
    SELECT bank
    FROM (
      SELECT bank, avg(amount) AS Average
      FROM bank.trans
      WHERE bank <> ''
      GROUP BY bank
      HAVING Average > 5500
    ) sub1
  )
  AND k_symbol <> ' '
  GROUP BY k_symbol
  HAVING mean > 2000
) sub;

-- another example:
-- Step 1
SELECT avg(balance) AS Avg_balance, operation
FROM bank.trans
WHERE k_symbol IN (
  SELECT k_symbol AS symbol
  FROM (
    SELECT avg(amount) AS Average, k_symbol
    FROM bank.order
    WHERE k_symbol <> ' '
    GROUP BY k_symbol
    HAVING Average > 3000
    ORDER BY Average DESC
  ) sub1
)
GROUP BY operation;

-- Step2: just interested in the name of the operation with the highest AVERAGE
SELECT operation FROM (
  SELECT avg(balance) AS Avg_balance, operation
  FROM bank.trans
  WHERE k_symbol IN (
    SELECT k_symbol AS symbol
    FROM (
      SELECT avg(amount) AS Average, k_symbol
      FROM bank.order
      WHERE k_symbol <> ' '
      GROUP BY k_symbol
      HAVING Average > 3000
      ORDER BY Average DESC
    ) sub1
  )
  GROUP BY operation
) sub2
ORDER BY Avg_balance
LIMIT 1;

-- TEMPORARY TABLE 'execute once - use many times'

CREATE TEMPORARY TABLE avg_balance_per_operation AS (
  SELECT avg(balance) AS Avg_balance, operation
  FROM bank.trans
  WHERE k_symbol IN (
    SELECT k_symbol AS symbol
    FROM (
      SELECT avg(amount) AS Average, k_symbol
      FROM bank.order
      WHERE k_symbol <> ' '
      GROUP BY k_symbol
      HAVING Average > 3000
      ORDER BY Average desc
    ) sub1
  )
  GROUP BY operation
)

SELECT operation
FROM avg_balance_per_operation
ORDER BY Avg_balance
LIMIT 1

-- TEMPORARY TABLEs exist as long as your login session exists (or you explicitly drop them)

-- VIEWS: showing the data that you want to show, but not more.
CREATE VIEW Customers_for_mailroom AS (
  SELECT customer_id, name, address_line1, address_line2, postcode, state, country
  FROM customers
);

-- Once created, views remain visible. They do not store information; think of them as 'virtual tables'
-- you want them for a. security (access control), and b. simplification of queries

-- NEVER UPDATE ANYTHING THROUGH A VIEW (usually we only grant read access to a view)
