-- =====================================================
-- 04 – Stored Procedures
-- =====================================================
USE LibraryManagement;

-- ---------------------------------------------------
-- Procedure 1: BorrowBook
-- ---------------------------------------------------
DROP PROCEDURE IF EXISTS BorrowBook;
DELIMITER //

CREATE PROCEDURE BorrowBook(
    IN p_member_id INT UNSIGNED,
    IN p_book_id   INT UNSIGNED
)
BEGIN
    DECLARE book_available INT;
    DECLARE member_exists  INT DEFAULT 0;

    -- Start a transaction so we can roll back if something fails
    START TRANSACTION;

    -- Check if the member exists
    SELECT COUNT(*) INTO member_exists FROM Members WHERE member_id = p_member_id;
    IF member_exists = 0 THEN
        ROLLBACK;
        SELECT 'Error: Member not found.' AS message;
    ELSE
        -- Check book availability
        SELECT available_copies INTO book_available
        FROM Books
        WHERE book_id = p_book_id;

        IF book_available IS NULL THEN
            ROLLBACK;
            SELECT 'Error: Book not found.' AS message;
        ELSEIF book_available > 0 THEN
            -- Insert the borrow record. The trigger will decrement available_copies.
            INSERT INTO Borrow_Transactions (member_id, book_id, issue_date, due_date)
            VALUES (p_member_id, p_book_id, CURDATE(), CURDATE() + INTERVAL 30 DAY);

            COMMIT;
            SELECT 'Book borrowed successfully.' AS message;
        ELSE
            ROLLBACK;
            SELECT 'Error: No copies available for this book.' AS message;
        END IF;
    END IF;
END//

DELIMITER ;

-- ---------------------------------------------------
-- Procedure 2: ReturnBook
-- ---------------------------------------------------
DROP PROCEDURE IF EXISTS ReturnBook;
DELIMITER //

CREATE PROCEDURE ReturnBook(
    IN p_transaction_id INT UNSIGNED
)
BEGIN
    DECLARE current_return DATE;
    DECLARE trans_exists   INT DEFAULT 0;

    START TRANSACTION;

    -- Check if the transaction exists
    SELECT COUNT(*) INTO trans_exists
    FROM Borrow_Transactions
    WHERE transaction_id = p_transaction_id;

    IF trans_exists = 0 THEN
        ROLLBACK;
        SELECT 'Error: Transaction not found.' AS message;
    ELSE
        SELECT return_date INTO current_return
        FROM Borrow_Transactions
        WHERE transaction_id = p_transaction_id;

        IF current_return IS NOT NULL THEN
            ROLLBACK;
            SELECT 'Error: Book already returned.' AS message;
        ELSE
            -- Update the return date. The trigger will calculate fine and increase copies.
            UPDATE Borrow_Transactions
            SET return_date = CURDATE()
            WHERE transaction_id = p_transaction_id;

            COMMIT;
            SELECT 'Book returned successfully.' AS message;
        END IF;
    END IF;
END//

DELIMITER ;

-- ---------------------------------------------------
-- Procedure 3: MemberHistory
-- ---------------------------------------------------
DROP PROCEDURE IF EXISTS MemberHistory;
DELIMITER //

CREATE PROCEDURE MemberHistory(
    IN p_member_id INT UNSIGNED
)
BEGIN
    SELECT
        COUNT(*) AS total_borrowed,
        SUM(CASE WHEN return_date IS NULL THEN 1 ELSE 0 END) AS active_borrowings,
        COALESCE(SUM(fine), 0) AS total_fines_paid
    FROM Borrow_Transactions
    WHERE member_id = p_member_id;
END//

DELIMITER ;