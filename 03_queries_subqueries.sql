-- =====================================================
-- 03 – Part 3: Subqueries
-- =====================================================
USE LibraryManagement;

-- 3.1 Books priced above the average book price
SELECT title, price
FROM Books
WHERE price > (SELECT AVG(price) FROM Books);

-- 3.2 Members who have borrowed more books than the average member
SELECT member_id, COUNT(*) AS borrow_count
FROM Borrow_Transactions
GROUP BY member_id
HAVING COUNT(*) > (
    SELECT AVG(borrow_cnt)
    FROM (
        SELECT COUNT(*) AS borrow_cnt
        FROM Borrow_Transactions
        GROUP BY member_id
    ) AS avg_table
);

-- 3.3 Publisher of the most expensive book
SELECT p.publisher_name, b.price
FROM Publishers p
INNER JOIN Books b ON p.publisher_id = b.publisher_id
WHERE b.price = (SELECT MAX(price) FROM Books);

-- 3.4 Books borrowed by members from a particular city (e.g., 'Delhi')
SELECT DISTINCT b.title
FROM Books b
WHERE b.book_id IN (
    SELECT bt.book_id
    FROM Borrow_Transactions bt
    WHERE bt.member_id IN (
        SELECT member_id FROM Members WHERE city = 'Delhi'
    )
);

-- 3.5 Authors who have written more than five books
SELECT author_id, COUNT(*) AS book_count
FROM Books
GROUP BY author_id
HAVING COUNT(*) > 5;