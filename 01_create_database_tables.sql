-- =====================================================
-- Library Management System – Database Schema
-- MySQL 8.0+ (InnoDB)
-- =====================================================

-- Fix 1: switch to a different database before dropping
USE mysql;
DROP DATABASE IF EXISTS LibraryManagement;
CREATE DATABASE LibraryManagement;
USE LibraryManagement;

-- ---------------------------------------------------
-- 1. Authors
-- ---------------------------------------------------
CREATE TABLE Authors (
    author_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    author_name  VARCHAR(100) NOT NULL,
    country      VARCHAR(50)  NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------
-- 2. Publishers
-- ---------------------------------------------------
CREATE TABLE Publishers (
    publisher_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL,
    city           VARCHAR(50)  NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------
-- 3. Books
-- (foreign keys allowed here because it's not partitioned)
-- ---------------------------------------------------
CREATE TABLE Books (
    book_id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title             VARCHAR(200)   NOT NULL,
    author_id         INT UNSIGNED   NOT NULL,
    publisher_id      INT UNSIGNED   NOT NULL,
    category          VARCHAR(50)    NOT NULL,
    price             DECIMAL(10,2)  NOT NULL,
    published_year    YEAR           NOT NULL,
    available_copies  INT UNSIGNED   NOT NULL DEFAULT 1,
    CONSTRAINT chk_copies CHECK (available_copies >= 0),
    FOREIGN KEY (author_id)    REFERENCES Authors(author_id),
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------
-- 4. Members
-- ---------------------------------------------------
CREATE TABLE Members (
    member_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    member_name     VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    city            VARCHAR(50)  NOT NULL,
    membership_date DATE         NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------
-- 5. Borrow_Transactions (PARTITIONED)
-- Fix 2: MySQL forbids foreign keys on partitioned tables.
-- We document logical relationships instead:
--   member_id -> Members(member_id)
--   book_id   -> Books(book_id)
-- ---------------------------------------------------
CREATE TABLE Borrow_Transactions (
    transaction_id INT UNSIGNED AUTO_INCREMENT,
    member_id      INT UNSIGNED NOT NULL,
    book_id        INT UNSIGNED NOT NULL,
    issue_date     DATE         NOT NULL,
    due_date       DATE         NOT NULL,
    return_date    DATE         NULL,
    fine           DECIMAL(10,2) NULL,
    PRIMARY KEY (transaction_id, issue_date)
) ENGINE=InnoDB
PARTITION BY RANGE (YEAR(issue_date)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- ---------------------------------------------------
-- 6. Deleted_Books (audit table for trigger)
-- ---------------------------------------------------
CREATE TABLE Deleted_Books (
    book_id        INT UNSIGNED,
    title          VARCHAR(200),
    author_id      INT UNSIGNED,
    publisher_id   INT UNSIGNED,
    category       VARCHAR(50),
    price          DECIMAL(10,2),
    published_year YEAR,
    deleted_date   DATETIME DEFAULT CURRENT_TIMESTAMP
);