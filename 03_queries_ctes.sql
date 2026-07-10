-- =====================================================
-- 03 – Part 4: Common Table Expressions (CTEs)
-- =====================================================
USE LibraryManagement;

-- 4.1 Total revenue generated from fines
WITH fine_summary AS (
    SELECT SUM(fine) AS total_fine
    FROM Borrow_Transactions
    WHERE fine IS NOT NULL
)
SELECT * FROM fine_summary;

-- 4.2 Top five members based on number of books borrowed
WITH member_borrow_count AS (
    SELECT member_id, COUNT(*) AS books_borrowed
    FROM Borrow_Transactions
    GROUP BY member_id
)
SELECT m.member_name, mbc.books_borrowed
FROM member_borrow_count mbc
INNER JOIN Members m ON mbc.member_id = m.member_id
ORDER BY mbc.books_borrowed DESC
LIMIT 5;

-- 4.3 Monthly borrowing statistics
WITH monthly_stats AS (
    SELECT
        DATE_FORMAT(issue_date, '%Y-%m') AS month,
        COUNT(*) AS total_borrowed,
        SUM(CASE WHEN return_date IS NOT NULL THEN 1 ELSE 0 END) AS returned,
        SUM(CASE WHEN return_date IS NULL THEN 1 ELSE 0 END) AS still_borrowed
    FROM Borrow_Transactions
    GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
)
SELECT * FROM monthly_stats ORDER BY month;

-- 4.4 Publishers with the highest number of books
WITH publisher_book_count AS (
    SELECT publisher_id, COUNT(*) AS book_count
    FROM Books
    GROUP BY publisher_id
)
SELECT p.publisher_name, pbc.book_count
FROM publisher_book_count pbc
INNER JOIN Publishers p ON pbc.publisher_id = p.publisher_id
ORDER BY pbc.book_count DESC
LIMIT 1;