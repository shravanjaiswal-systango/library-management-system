# Library Management System

## Overview

This project implements a complete Library Management System using MySQL. It features a normalized database schema, stored procedures, triggers, partitioning, indexing, and a comprehensive set of SQL queries demonstrating joins, subqueries, CTEs, window functions, and performance optimization techniques. A professional LaTeX report explains the approach, optimization strategies, and includes an ER diagram.

---

## Key Features

- Normalized 3NF database with 6 tables and full referential integrity
- 500 synthetic records per table for realistic testing
- Stored procedures for borrowing (`BorrowBook`) and returning (`ReturnBook`) books
- Trigger‑based automation: copy decrement, fine calculation, audit logging
- Progressive tiered fine system capped at book price
- Partitioning by year on `Borrow_Transactions` with composite primary key
- Performance‑optimized indexes on frequently queried columns
- Advanced SQL queries: joins (INNER, LEFT, RIGHT, CROSS, FULL OUTER emulation), subqueries, CTEs, window functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`, `LAG`, `LEAD`)
- LaTeX report with performance comparison (before/after indexing) and ER diagram

---

## Key Database Statistics

| Metric | Value |
|--------|-------|
| Total Books | 500 |
| Total Authors | 500 |
| Total Publishers | 500 |
| Total Members | 500 |
| Total Borrow Transactions | 500 |
| Categories | Fiction, Non‑Fiction, Science, History |
| Loan Period | 30 days |
| Fine Structure | Tiered (5%‑20% per day), capped at book price |
| Partitioning | By `YEAR(issue_date)` 2023–2026 + MAXVALUE |
| Indexes Created | `member_id`, `book_id`, `issue_date` |

---

## Technologies

- MySQL 8.0+
- DBeaver (or MySQL Workbench)
- LaTeX (Overleaf compatible) for the report
- Draw.io (or any ER diagram tool)

---

## Performance Optimization Highlights

- **Indexes** on `member_id`, `book_id`, and `issue_date` reduced a typical query’s row scan from **333 rows to 1 row** – a **99.7% reduction**.
- **Partitioning** by year enables partition pruning for date‑range queries.
- **Composite primary key** (`transaction_id`, `issue_date`) satisfies MySQL’s partition requirement while preserving uniqueness.

---

## Example Queries

### Rank books by price within each category
```sql
SELECT title, category, price,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank
FROM Books;
```

### Monthly borrowing statistics (CTE + LAG)
```sql
WITH monthly_counts AS (
    SELECT DATE_FORMAT(issue_date, '%Y-%m') AS month, COUNT(*) AS borrow_count
    FROM Borrow_Transactions
    GROUP BY month
)
SELECT month, borrow_count,
       LAG(borrow_count) OVER (ORDER BY month) AS prev_month,
       borrow_count - LAG(borrow_count) OVER (ORDER BY month) AS change
FROM monthly_counts;
```

---

## Triggers & Stored Procedures

- **BorrowBook**: Checks availability, inserts transaction. **Trigger 1** decrements copies automatically.
- **ReturnBook**: Updates return date. **Trigger 2** calculates fine (tiered, capped) and increments copies.
- **MemberHistory**: Returns total borrows, active borrowings, and total fines for a member.
- **Trigger 3**: Archives deleted books into `Deleted_Books`.

---

## License

MIT License

---

## Acknowledgements

- Mr. Prateek Khandelwal – for providing the problem statement, guidance, and mentorship
- Systango – for providing the opportunity

---

## Contact

- Shravan Jaiswal
- https://in.linkedin.com/in/shravan-jaiswal-6542061b0
