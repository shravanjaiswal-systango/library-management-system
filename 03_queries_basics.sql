-- =====================================================
-- 03 – Part 1: SQL Basics
-- =====================================================
USE LibraryManagement;

-- 1.1 Display all books
SELECT * FROM Books;

-- 1.2 Books belonging to a specific category (e.g., Fiction)
SELECT * FROM Books WHERE category = 'Fiction';

-- 1.3 Members from a specific city (e.g., Mumbai)
SELECT * FROM Members WHERE city = 'Mumbai';

-- 1.4 Books with price greater than ₹500
SELECT * FROM Books WHERE price > 500;

-- 1.5 Books sorted by price descending
SELECT * FROM Books ORDER BY price DESC;

-- 1.6 Update the price of selected books (example: increase by 10% for books published before 2020)
UPDATE Books
SET price = price * 1.10
WHERE published_year < 2020;

-- 1.7 Delete inactive members (example: members who have never borrowed)
-- First, find members with no borrow transactions
DELETE FROM Members
WHERE member_id NOT IN (
    SELECT DISTINCT member_id FROM Borrow_Transactions
);