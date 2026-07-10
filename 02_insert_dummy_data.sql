-- =====================================================
-- 02 – Insert 500 Dummy Records (no stored procedure)
-- Uses recursive CTEs to generate numbers.
-- Run after 01_create_database_tables.sql.
-- =====================================================
USE LibraryManagement;

-- ---------------------------------------------------
-- 1. Authors (500 rows)
-- ---------------------------------------------------
INSERT INTO Authors (author_name, country)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 500
)
SELECT CONCAT('Author_', n),
       ELT(FLOOR(1 + RAND() * 5), 'India', 'USA', 'UK', 'Canada', 'Australia')
FROM seq;

-- ---------------------------------------------------
-- 2. Publishers (500 rows)
-- ---------------------------------------------------
INSERT INTO Publishers (publisher_name, city)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 500
)
SELECT CONCAT('Publisher_', n),
       ELT(FLOOR(1 + RAND() * 5), 'Mumbai', 'New York', 'London', 'Toronto', 'Sydney')
FROM seq;

-- ---------------------------------------------------
-- 3. Books (500 rows)
-- References random author_id and publisher_id.
-- Price ₹100‑₹2000, available copies 5‑10.
-- ---------------------------------------------------
INSERT INTO Books (title, author_id, publisher_id, category, price, published_year, available_copies)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 500
)
SELECT CONCAT('Book_', n),
       FLOOR(1 + RAND() * 500),                     -- random author
       FLOOR(1 + RAND() * 500),                     -- random publisher
       ELT(FLOOR(1 + RAND() * 4), 'Fiction', 'Non-Fiction', 'Science', 'History'),
       ROUND(100 + RAND() * 1900, 2),
       2020 + FLOOR(RAND() * 7),                    -- year 2020‑2026
       FLOOR(5 + RAND() * 6)                        -- copies 5‑10
FROM seq;

-- ---------------------------------------------------
-- 4. Members (500 rows)
-- Membership dates between ~2019 and 2026.
-- ---------------------------------------------------
INSERT INTO Members (member_name, email, city, membership_date)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 500
)
SELECT CONCAT('Member_', n),
       CONCAT('member', n, '@library.com'),
       ELT(FLOOR(1 + RAND() * 5), 'Delhi', 'Mumbai', 'Bangalore', 'Chennai', 'Kolkata'),
       DATE_SUB(CURDATE(), INTERVAL FLOOR(100 + RAND() * 2500) DAY)
FROM seq;

-- ---------------------------------------------------
-- 5. Borrow_Transactions (500 rows)
-- Issue dates from 2023‑01‑01 to ~2026‑07‑01.
-- Due date = issue_date + 30 days.
-- ~70% returned, some overdue, some still borrowed.
-- fine remains NULL (calculated later by trigger).
-- ---------------------------------------------------
INSERT INTO Borrow_Transactions (member_id, book_id, issue_date, due_date, return_date, fine)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 500
)
SELECT
    FLOOR(1 + RAND() * 500),                        -- random member
    FLOOR(1 + RAND() * 500),                        -- random book
    r_issue,
    r_issue + INTERVAL 30 DAY,
    IF(RAND() < 0.7,
       r_issue + INTERVAL FLOOR(15 + RAND() * 55) DAY,  -- returned
       NULL),                                           -- still borrowed
    NULL                                              -- fine left null
FROM (
    SELECT n,
           DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 1270) DAY) AS r_issue
    FROM seq
) sub;