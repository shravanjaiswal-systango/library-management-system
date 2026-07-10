-- =====================================================
-- 06b – Performance Comparison (Before vs After Indexing)
-- =====================================================
-- Run the steps in order. For each EXPLAIN ANALYZE,
-- copy the output (especially 'actual time' and 'rows')
-- to use in your report.
-- =====================================================

USE LibraryManagement;

-- ---------------------------------------------------
-- 1. Run this WITH indexes (the "after" state)
-- ---------------------------------------------------
EXPLAIN ANALYZE
SELECT * FROM Borrow_Transactions
WHERE member_id = 42
  AND issue_date >= '2024-01-01';

-- ---------------------------------------------------
-- 2. Temporarily drop the indexes
-- ---------------------------------------------------
DROP INDEX idx_member_id  ON Borrow_Transactions;
DROP INDEX idx_book_id    ON Borrow_Transactions;
DROP INDEX idx_issue_date ON Borrow_Transactions;

-- ---------------------------------------------------
-- 3. Run the SAME query WITHOUT indexes (the "before" state)
-- ---------------------------------------------------
EXPLAIN ANALYZE
SELECT * FROM Borrow_Transactions
WHERE member_id = 42
  AND issue_date >= '2024-01-01';

-- ---------------------------------------------------
-- 4. Recreate the indexes (restore final state)
-- ---------------------------------------------------
CREATE INDEX idx_member_id  ON Borrow_Transactions(member_id);
CREATE INDEX idx_book_id    ON Borrow_Transactions(book_id);
CREATE INDEX idx_issue_date ON Borrow_Transactions(issue_date);