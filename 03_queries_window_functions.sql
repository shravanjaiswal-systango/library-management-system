-- =====================================================
-- 03 – Part 5: Window Functions
-- =====================================================
USE LibraryManagement;

-- 5.1 Rank books by price within each category
SELECT title, category, price,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank
FROM Books;

-- 5.2 Rank members by total fines paid
SELECT member_id,
       SUM(COALESCE(fine, 0)) AS total_fine,
       RANK() OVER (ORDER BY SUM(COALESCE(fine, 0)) DESC) AS fine_rank
FROM Borrow_Transactions
GROUP BY member_id;

-- 5.3 Second most borrowed book in every category
WITH book_borrow_count AS (
    SELECT b.book_id, b.title, b.category, COUNT(bt.transaction_id) AS borrow_count
    FROM Books b
    LEFT JOIN Borrow_Transactions bt ON b.book_id = bt.book_id
    GROUP BY b.book_id, b.title, b.category
),
ranked_books AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY borrow_count DESC) AS rnk
    FROM book_borrow_count
)
SELECT title, category, borrow_count
FROM ranked_books
WHERE rnk = 2;

-- 5.4 Compare current month's borrowing count with previous month (LAG)
WITH monthly_counts AS (
    SELECT DATE_FORMAT(issue_date, '%Y-%m') AS month,
           COUNT(*) AS borrow_count
    FROM Borrow_Transactions
    GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
),
with_prev AS (
    SELECT month, borrow_count,
           LAG(borrow_count) OVER (ORDER BY month) AS prev_month_count
    FROM monthly_counts
)
SELECT month, borrow_count, prev_month_count,
       (borrow_count - prev_month_count) AS `change`
FROM with_prev;

-- 5.5 Sequential borrowing numbers for each member by borrowing date
SELECT member_id, transaction_id, issue_date,
       ROW_NUMBER() OVER (PARTITION BY member_id ORDER BY issue_date) AS borrow_seq
FROM Borrow_Transactions;

-- 5.6 Next borrow date for each member (LEAD)
SELECT member_id, transaction_id, issue_date,
       LEAD(issue_date) OVER (PARTITION BY member_id ORDER BY issue_date) AS next_borrow_date
FROM Borrow_Transactions;