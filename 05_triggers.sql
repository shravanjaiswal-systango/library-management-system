-- =====================================================
-- 05 – Triggers
-- =====================================================
USE LibraryManagement;

-- ---------------------------------------------------
-- Trigger 1: After inserting a borrow transaction
--            Decrease available copies of the book.
-- ---------------------------------------------------
DROP TRIGGER IF EXISTS trg_borrow_insert;
DELIMITER //

CREATE TRIGGER trg_borrow_insert
AFTER INSERT ON Borrow_Transactions
FOR EACH ROW
BEGIN
    UPDATE Books
    SET available_copies = available_copies - 1
    WHERE book_id = NEW.book_id;
END//

DELIMITER ;

-- ---------------------------------------------------
-- Trigger 2: After updating return_date
--            Calculate fine (tiered, capped) and
--            increase available copies.
-- ---------------------------------------------------
DROP TRIGGER IF EXISTS trg_return_update;
DELIMITER //

CREATE TRIGGER trg_return_update
AFTER UPDATE ON Borrow_Transactions
FOR EACH ROW
BEGIN
    DECLARE v_price       DECIMAL(10,2);
    DECLARE v_overdue     INT DEFAULT 0;
    DECLARE v_fine        DECIMAL(10,2) DEFAULT 0;
    DECLARE v_day         INT DEFAULT 1;

    -- Only act when return_date changes from NULL to a value
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN

        -- Get the book price for fine calculation
        SELECT price INTO v_price FROM Books WHERE book_id = NEW.book_id;

        -- Calculate overdue days (only if returned late)
        IF NEW.return_date > NEW.due_date THEN
            SET v_overdue = DATEDIFF(NEW.return_date, NEW.due_date);

            -- Tiered daily rates (Plan Y)
            WHILE v_day <= v_overdue DO
                IF v_day <= 7 THEN
                    SET v_fine = v_fine + (v_price * 0.05);
                ELSEIF v_day <= 14 THEN
                    SET v_fine = v_fine + (v_price * 0.10);
                ELSEIF v_day <= 21 THEN
                    SET v_fine = v_fine + (v_price * 0.15);
                ELSE
                    SET v_fine = v_fine + (v_price * 0.20);
                END IF;
                SET v_day = v_day + 1;
            END WHILE;

            -- Cap the fine at the book's price
            IF v_fine > v_price THEN
                SET v_fine = v_price;
            END IF;

            -- Update the fine in the transaction record
            UPDATE Borrow_Transactions
            SET fine = v_fine
            WHERE transaction_id = NEW.transaction_id;
        END IF;

        -- Increase available copies (book is back)
        UPDATE Books
        SET available_copies = available_copies + 1
        WHERE book_id = NEW.book_id;
    END IF;
END//

DELIMITER ;

-- ---------------------------------------------------
-- Trigger 3: After deleting a book
--            Save the record to Deleted_Books audit.
-- ---------------------------------------------------
DROP TRIGGER IF EXISTS trg_book_delete;
DELIMITER //

CREATE TRIGGER trg_book_delete
AFTER DELETE ON Books
FOR EACH ROW
BEGIN
    INSERT INTO Deleted_Books (book_id, title, author_id, publisher_id, category, price, published_year)
    VALUES (OLD.book_id, OLD.title, OLD.author_id, OLD.publisher_id, OLD.category, OLD.price, OLD.published_year);
END//

DELIMITER ;