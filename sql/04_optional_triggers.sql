/*
================================================================================
Project: BookSwap Local Community Database
File: 04_optional_triggers.sql

Purpose:
This file contains optional SQLite triggers based on Phase 1 tutor feedback.
The base project works without these triggers. They are included to document how
notification and fine logic could be automated in a future application version.

Run only after the main database has been created:
sqlite3 bookswap_app.db ".read sql/04_optional_triggers.sql"
================================================================================
*/

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- Trigger 1: create a notification when a borrow request is accepted.
--
-- Business logic:
-- When request_status changes from another value to 'accepted', the borrower
-- should receive a notification. This explains one possible trigger condition
-- for the notifications support module.
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_notify_borrow_request_accepted;

CREATE TRIGGER trg_notify_borrow_request_accepted
AFTER UPDATE OF request_status ON borrow_requests
FOR EACH ROW
WHEN NEW.request_status = 'accepted'
     AND OLD.request_status <> 'accepted'
BEGIN
    INSERT INTO notifications (
        user_id,
        notification_type,
        title,
        message,
        is_read,
        created_at
    )
    VALUES (
        NEW.borrower_id,
        'request_accepted',
        'Borrow request accepted',
        'Your borrow request has been accepted.',
        0,
        CURRENT_TIMESTAMP
    );
END;

-- ---------------------------------------------------------------------------
-- Trigger 2: create a fine when a loan becomes overdue.
--
-- Business logic:
-- When loan_status changes from another value to 'overdue', the borrower may
-- receive an open fine. The NOT EXISTS condition prevents duplicate automatic
-- fines for the same loan.
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_create_fine_for_overdue_loan;

CREATE TRIGGER trg_create_fine_for_overdue_loan
AFTER UPDATE OF loan_status ON loans
FOR EACH ROW
WHEN NEW.loan_status = 'overdue'
     AND OLD.loan_status <> 'overdue'
     AND NOT EXISTS (
         SELECT 1
         FROM fines
         WHERE fines.loan_id = NEW.loan_id
     )
BEGIN
    INSERT INTO fines (
        loan_id,
        borrower_id,
        fine_reason,
        fine_amount,
        fine_status,
        created_at
    )
    VALUES (
        NEW.loan_id,
        NEW.borrower_id,
        'Automatic fine for overdue loan',
        5.00,
        'open',
        CURRENT_TIMESTAMP
    );
END;
