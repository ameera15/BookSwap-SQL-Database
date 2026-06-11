/*
================================================================================
Project: BookSwap Local Community Database
File: 03_test_queries.sql

Purpose:
This file contains practical SQL test cases for Phase 2. The queries are designed
to be used in screenshots for the presentation PDF. They demonstrate row counts,
joins, spatial search, status filtering, ratings, fines and metadata.
================================================================================
*/

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- Test 1: Verify that every table has at least 10 records.
-- This directly supports the Phase 2 requirement for dummy data.
-- ---------------------------------------------------------------------------
SELECT 'users' AS table_name, COUNT(*) AS total_rows FROM users
UNION ALL SELECT 'user_roles', COUNT(*) FROM user_roles
UNION ALL SELECT 'user_role_assignments', COUNT(*) FROM user_role_assignments
UNION ALL SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL SELECT 'languages', COUNT(*) FROM languages
UNION ALL SELECT 'publishers', COUNT(*) FROM publishers
UNION ALL SELECT 'books', COUNT(*) FROM books
UNION ALL SELECT 'authors', COUNT(*) FROM authors
UNION ALL SELECT 'book_authors', COUNT(*) FROM book_authors
UNION ALL SELECT 'genres', COUNT(*) FROM genres
UNION ALL SELECT 'book_genres', COUNT(*) FROM book_genres
UNION ALL SELECT 'book_conditions', COUNT(*) FROM book_conditions
UNION ALL SELECT 'book_listings', COUNT(*) FROM book_listings
UNION ALL SELECT 'time_slots', COUNT(*) FROM time_slots
UNION ALL SELECT 'delivery_methods', COUNT(*) FROM delivery_methods
UNION ALL SELECT 'listing_delivery_options', COUNT(*) FROM listing_delivery_options
UNION ALL SELECT 'borrow_requests', COUNT(*) FROM borrow_requests
UNION ALL SELECT 'loans', COUNT(*) FROM loans
UNION ALL SELECT 'loan_status_history', COUNT(*) FROM loan_status_history
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'reports', COUNT(*) FROM reports
UNION ALL SELECT 'fines', COUNT(*) FROM fines
ORDER BY table_name;

-- ---------------------------------------------------------------------------
-- Test 2: Show available books with owner, language, condition and pickup city.
-- This demonstrates the practical search result shown to users.
-- ---------------------------------------------------------------------------
SELECT
    bl.listing_id,
    b.title,
    u.full_name AS owner_name,
    l.language_name,
    bc.condition_name,
    a.city AS pickup_city,
    bl.max_lending_days,
    bl.listing_status
FROM book_listings bl
JOIN books b ON bl.book_id = b.book_id
JOIN users u ON bl.owner_id = u.user_id
JOIN languages l ON b.language_id = l.language_id
JOIN book_conditions bc ON bl.condition_id = bc.condition_id
JOIN addresses a ON bl.pickup_address_id = a.address_id
WHERE bl.listing_status = 'available'
ORDER BY a.city, b.title;

-- ---------------------------------------------------------------------------
-- Test 3: Spatial-style search using latitude and longitude.
-- The query approximates nearby books for a user located around Berlin.
-- ---------------------------------------------------------------------------
SELECT
    bl.listing_id,
    b.title,
    a.city,
    a.latitude,
    a.longitude,
    ROUND(((a.latitude - 52.5200) * (a.latitude - 52.5200)) +
          ((a.longitude - 13.4050) * (a.longitude - 13.4050)), 6) AS approximate_distance_score
FROM book_listings bl
JOIN books b ON bl.book_id = b.book_id
JOIN addresses a ON bl.pickup_address_id = a.address_id
WHERE bl.listing_status = 'available'
ORDER BY approximate_distance_score ASC
LIMIT 5;

-- ---------------------------------------------------------------------------
-- Test 4: Show books with their authors and genres.
-- This demonstrates many-to-many relationships through junction tables.
-- ---------------------------------------------------------------------------
SELECT
    b.book_id,
    b.title,
    GROUP_CONCAT(DISTINCT au.author_name) AS authors,
    GROUP_CONCAT(DISTINCT g.genre_name) AS genres
FROM books b
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors au ON ba.author_id = au.author_id
LEFT JOIN book_genres bg ON b.book_id = bg.book_id
LEFT JOIN genres g ON bg.genre_id = g.genre_id
GROUP BY b.book_id, b.title
ORDER BY b.book_id;

-- ---------------------------------------------------------------------------
-- Test 5: Borrow requests with borrower, owner and selected delivery method.
-- This demonstrates the request workflow before confirmed loans.
-- ---------------------------------------------------------------------------
SELECT
    br.request_id,
    b.title,
    borrower.full_name AS borrower_name,
    owner.full_name AS owner_name,
    dm.method_name AS delivery_method,
    br.request_status,
    br.requested_from_date,
    br.requested_to_date
FROM borrow_requests br
JOIN book_listings bl ON br.listing_id = bl.listing_id
JOIN books b ON bl.book_id = b.book_id
JOIN users borrower ON br.borrower_id = borrower.user_id
JOIN users owner ON bl.owner_id = owner.user_id
LEFT JOIN delivery_methods dm ON br.delivery_method_id = dm.delivery_method_id
ORDER BY br.request_id;

-- ---------------------------------------------------------------------------
-- Test 6: Confirmed loan overview with status.
-- This supports screenshots for the loans entity.
-- ---------------------------------------------------------------------------
SELECT
    lo.loan_id,
    b.title,
    owner.full_name AS owner_name,
    borrower.full_name AS borrower_name,
    lo.loan_start_date,
    lo.due_date,
    lo.actual_return_date,
    lo.loan_status
FROM loans lo
JOIN book_listings bl ON lo.listing_id = bl.listing_id
JOIN books b ON bl.book_id = b.book_id
JOIN users owner ON lo.owner_id = owner.user_id
JOIN users borrower ON lo.borrower_id = borrower.user_id
ORDER BY lo.loan_id;

-- ---------------------------------------------------------------------------
-- Test 7: Average rating per book.
-- This demonstrates how reviews can support quality and trust.
-- ---------------------------------------------------------------------------
SELECT
    b.book_id,
    b.title,
    ROUND(AVG(r.rating), 2) AS average_rating,
    COUNT(r.review_id) AS review_count
FROM books b
LEFT JOIN reviews r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
ORDER BY average_rating DESC;

-- ---------------------------------------------------------------------------
-- Test 8: Delivery options available for each listing.
-- This demonstrates the junction table listing_delivery_options.
-- ---------------------------------------------------------------------------
SELECT
    bl.listing_id,
    b.title,
    dm.method_name,
    ldo.extra_fee,
    CASE WHEN ldo.is_enabled = 1 THEN 'enabled' ELSE 'disabled' END AS option_status
FROM listing_delivery_options ldo
JOIN book_listings bl ON ldo.listing_id = bl.listing_id
JOIN books b ON bl.book_id = b.book_id
JOIN delivery_methods dm ON ldo.delivery_method_id = dm.delivery_method_id
ORDER BY bl.listing_id, dm.method_name;

-- ---------------------------------------------------------------------------
-- Test 9: Loan status history for traceability.
-- ---------------------------------------------------------------------------
SELECT
    lsh.history_id,
    lsh.loan_id,
    b.title,
    lsh.old_status,
    lsh.new_status,
    u.full_name AS changed_by,
    lsh.changed_at,
    lsh.note
FROM loan_status_history lsh
JOIN loans lo ON lsh.loan_id = lo.loan_id
JOIN book_listings bl ON lo.listing_id = bl.listing_id
JOIN books b ON bl.book_id = b.book_id
JOIN users u ON lsh.changed_by_user_id = u.user_id
ORDER BY lsh.changed_at;

-- ---------------------------------------------------------------------------
-- Test 10: Open or disputed fines.
-- ---------------------------------------------------------------------------
SELECT
    f.fine_id,
    b.title,
    borrower.full_name AS borrower_name,
    f.fine_reason,
    f.fine_amount,
    f.fine_status
FROM fines f
JOIN loans lo ON f.loan_id = lo.loan_id
JOIN book_listings bl ON lo.listing_id = bl.listing_id
JOIN books b ON bl.book_id = b.book_id
JOIN users borrower ON f.borrower_id = borrower.user_id
WHERE f.fine_status IN ('open', 'disputed')
ORDER BY f.fine_amount DESC;

-- ---------------------------------------------------------------------------
-- Test 11: Moderation reports with user and listing context.
-- ---------------------------------------------------------------------------
SELECT
    r.report_id,
    reporter.full_name AS reported_by,
    reported.full_name AS reported_user,
    b.title AS listing_book,
    r.report_reason,
    r.report_status
FROM reports r
JOIN users reporter ON r.reported_by_user_id = reporter.user_id
LEFT JOIN users reported ON r.reported_user_id = reported.user_id
LEFT JOIN book_listings bl ON r.listing_id = bl.listing_id
LEFT JOIN books b ON bl.book_id = b.book_id
ORDER BY r.report_id;

-- ---------------------------------------------------------------------------
-- Test 12: Database metadata - total tables and database size.
-- For SQLite, page_count * page_size gives approximate database size in bytes.
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS number_of_tables
FROM sqlite_master
WHERE type = 'table' AND name NOT LIKE 'sqlite_%';

PRAGMA page_count;
PRAGMA page_size;
