-- =====================================================
-- 06a – Create Indexes & Verify Partitioning
-- =====================================================
USE LibraryManagement;

-- Create the three required indexes
CREATE INDEX idx_member_id  ON Borrow_Transactions(member_id);
CREATE INDEX idx_book_id    ON Borrow_Transactions(book_id);
CREATE INDEX idx_issue_date ON Borrow_Transactions(issue_date);

-- Check that the partitioned table has data in the correct partitions
SELECT PARTITION_NAME, TABLE_ROWS
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'Borrow_Transactions';