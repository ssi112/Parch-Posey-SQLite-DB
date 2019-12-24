/*
 * Original query done for PostgreSQL
 *    create statements updated for SQLite
 *    indexes and foreign keys defined
 *    no constraints added (sample DB for read-only queries)
 */
CREATE TABLE accounts (
    id INTEGER (9) NOT NULL PRIMARY KEY,
    name TEXT,
    website TEXT,
    lat DECIMAL(11,8) NULL,
    long DECIMAL(11,8) NULL,
    primary_poc TEXT,
    sales_rep_id INTEGER (9) NOT NULL,
    FOREIGN KEY(sales_rep_id) REFERENCES sales_reps(id) );

CREATE TABLE orders (
    id INTEGER (9) NOT NULL PRIMARY KEY,
    account_id INTEGER (9) NOT NULL,
    occurred_at TIMESTAMP NOT NULL,
    standard_qty INTEGER (10) NULL,
    gloss_qty INTEGER (10) NULL,
    poster_qty INTEGER (10) NULL,
    total INTEGER (10) NULL,
    standard_amt_usd DECIMAL(12,2) NULL,
    gloss_amt_usd DECIMAL(12,2) NULL,
    poster_amt_usd DECIMAL(12,2) NULL,
    total_amt_usd DECIMAL(12,2) NULL,
    FOREIGN KEY(account_id) REFERENCES accounts(id) );

CREATE TABLE region (
    id INTEGER (9) NOT NULL PRIMARY KEY,
    name TEXT );

CREATE TABLE sales_reps (
    id INTEGER (9) NOT NULL PRIMARY KEY,
    name TEXT,
    region_id INTEGER (9) NOT NULL,
    FOREIGN KEY(region_id) REFERENCES region(id) );

CREATE TABLE web_events (
    id INTEGER (9) NOT NULL PRIMARY KEY,
    account_id INTEGER (9) NOT NULL,
    occurred_at TIMESTAMP,
    channel TEXT,
    FOREIGN KEY(account_id) REFERENCES accounts(id) );


