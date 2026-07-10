-- =====================================================
-- 03 – Part 2: Joins
-- =====================================================
USE LibraryManagement;

-- 2.1 Every book along with its author (INNER JOIN)
SELECT b.title, a.author_name
FROM Books b
INNER JOIN Authors a ON b.author_id = a.author_id;

-- 2.2 Every book along with its publisher (INNER JOIN)
SELECT b.title, p.publisher_name
FROM Books b
INNER JOIN Publishers p ON b.publisher_id = p.publisher_id;

-- 2.3 Members and the books they have borrowed
SELECT m.member_name, b.title, bt.issue_date
FROM Members m
INNER JOIN Borrow_Transactions bt ON m.member_id = bt.member_id
INNER JOIN Books b ON bt.book_id = b.book_id;

-- 2.4 Books that have never been borrowed (LEFT JOIN + IS NULL)
SELECT b.title
FROM Books b
LEFT JOIN Borrow_Transactions bt ON b.book_id = bt.book_id
WHERE bt.transaction_id IS NULL;

-- 2.5 All authors, including those with no books published (LEFT JOIN)
SELECT a.author_name, b.title
FROM Authors a
LEFT JOIN Books b ON a.author_id = b.author_id;

-- 2.6 Every possible Author–Publisher combination (CROSS JOIN)
SELECT a.author_name, p.publisher_name
FROM Authors a
CROSS JOIN Publishers p;

-- 2.7 FULL OUTER JOIN emulation (Books ↔ Borrow_Transactions)
SELECT b.title, bt.transaction_id
FROM Books b
LEFT JOIN Borrow_Transactions bt ON b.book_id = bt.book_id
UNION
SELECT b.title, bt.transaction_id
FROM Borrow_Transactions bt
LEFT JOIN Books b ON bt.book_id = b.book_id
WHERE b.book_id IS NULL;

-- 2.8 Display every publisher and the books they have published (RIGHT JOIN)
SELECT p.publisher_name, b.title
FROM Books b
RIGHT JOIN Publishers p ON b.publisher_id = p.publisher_id;