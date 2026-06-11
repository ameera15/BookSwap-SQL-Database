/*
================================================================================
Project: BookSwap Local Community Database
Course: DLBDSPBDM01_D - Data-Mart-Erstellung in SQL
Student name: Amirah
Phase: Development / Reflection Phase (Phase 2)
DBMS: SQLite 3
File: 01_schema.sql

Purpose:
This file creates the relational database schema for a local book exchange app.
The design follows the Phase 1 ER model and separates bibliographic book data
from concrete physical book listings. It also implements users, roles, addresses,
time slots, delivery methods, borrowing requests, loans, reviews, notifications,
reports and fines.

Important design decisions:
1. General book information is stored in books.
2. Physical lendable copies are stored in book_listings.
3. Many-to-many relationships are implemented through junction tables.
4. Primary keys, foreign keys, unique keys, CHECK constraints and indexes are
   used to improve integrity and query performance.
5. The model is modular. The core lending workflow is separated from support
   modules such as notifications, reports, reviews, status history and fines.
================================================================================
*/

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- Clean database objects in dependency-safe order.
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS fines;
DROP TABLE IF EXISTS reports;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS loan_status_history;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS borrow_requests;
DROP TABLE IF EXISTS listing_delivery_options;
DROP TABLE IF EXISTS delivery_methods;
DROP TABLE IF EXISTS time_slots;
DROP TABLE IF EXISTS book_listings;
DROP TABLE IF EXISTS book_conditions;
DROP TABLE IF EXISTS book_genres;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS languages;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS user_role_assignments;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS users;

-- ---------------------------------------------------------------------------
-- 1. users
-- Stores registered platform users. A user can offer books and borrow books.
-- Primary key: user_id uniquely identifies each user.
-- UNIQUE: email prevents two accounts from using the same email address.
-- CHECK: user_status limits records to valid account states only.
-- ON DELETE: child tables decide whether related records should be deleted or
-- preserved, depending on the business meaning of the relationship.
-- ---------------------------------------------------------------------------
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    password_hash TEXT NOT NULL,
    user_status TEXT NOT NULL DEFAULT 'active'
        CHECK (user_status IN ('active', 'suspended', 'deleted')),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------------
-- 2. user_roles
-- Stores reusable platform roles. Roles are assigned through a junction table.
-- Primary key: role_id uniquely identifies each role.
-- UNIQUE: role_name prevents duplicate role names such as two administrator
-- roles with the same meaning.
-- ---------------------------------------------------------------------------
CREATE TABLE user_roles (
    role_id INTEGER PRIMARY KEY,
    role_name TEXT NOT NULL UNIQUE,
    role_description TEXT
);

-- ---------------------------------------------------------------------------
-- 3. user_role_assignments
-- Junction table between users and user_roles.
-- One user may have several roles, and one role may belong to many users.
-- Composite primary key: user_id and role_id together prevent duplicate role
-- assignments for the same user.
-- Foreign keys: connect each assignment to a valid user and a valid role.
-- ON DELETE CASCADE: if a user or role is removed, the related assignment rows
-- are removed automatically because they no longer have meaning alone.
-- ---------------------------------------------------------------------------
CREATE TABLE user_role_assignments (
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    assigned_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES user_roles(role_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- 4. addresses
-- Stores user addresses with latitude and longitude for spatial search.
-- Primary key: address_id uniquely identifies each address.
-- Foreign key: user_id connects each address to one user.
-- CHECK: latitude, longitude and is_default are restricted to valid values.
-- ON DELETE CASCADE: if a user is deleted, their addresses are deleted too.
-- ---------------------------------------------------------------------------
CREATE TABLE addresses (
    address_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    street TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT,
    postal_code TEXT NOT NULL,
    country TEXT NOT NULL,
    latitude REAL NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude REAL NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    is_default INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1)),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- 5. languages
-- Master table for book languages.
-- Primary key: language_id uniquely identifies each language.
-- UNIQUE: language_name and language_code avoid duplicate language entries.
-- ---------------------------------------------------------------------------
CREATE TABLE languages (
    language_id INTEGER PRIMARY KEY,
    language_name TEXT NOT NULL UNIQUE,
    language_code TEXT NOT NULL UNIQUE
);

-- ---------------------------------------------------------------------------
-- 6. publishers
-- Master table for publishers.
-- Primary key: publisher_id uniquely identifies each publisher.
-- UNIQUE: publisher_name avoids storing the same publisher more than once.
-- ---------------------------------------------------------------------------
CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL UNIQUE,
    country TEXT,
    website TEXT
);

-- ---------------------------------------------------------------------------
-- 7. books
-- Stores general bibliographic book data. It does not represent a physical copy.
-- Primary key: book_id uniquely identifies the bibliographic book record.
-- UNIQUE: isbn avoids duplicate book records for the same ISBN.
-- Foreign keys: language_id and publisher_id connect books to master data.
-- CHECK: publication_year keeps publication dates within a realistic range.
-- ON DELETE: no cascade is used because book records are shared reference data.
-- ---------------------------------------------------------------------------
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    isbn TEXT UNIQUE,
    title TEXT NOT NULL,
    publication_year INTEGER CHECK (publication_year BETWEEN 1400 AND 2100),
    edition TEXT,
    language_id INTEGER NOT NULL,
    publisher_id INTEGER,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (language_id) REFERENCES languages(language_id),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);

-- ---------------------------------------------------------------------------
-- 8. authors
-- Master table for authors.
-- Primary key: author_id uniquely identifies each author.
-- UNIQUE: author_name avoids duplicate author master records.
-- ---------------------------------------------------------------------------
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL UNIQUE,
    biography TEXT
);

-- ---------------------------------------------------------------------------
-- 9. book_authors
-- Junction table for the many-to-many relationship between books and authors.
-- Composite primary key: book_id and author_id prevent duplicate mappings.
-- Foreign keys: require valid book and author records.
-- ON DELETE CASCADE: if a book or author is removed, the related mapping rows
-- are removed automatically.
-- ---------------------------------------------------------------------------
CREATE TABLE book_authors (
    book_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- 10. genres
-- Master table for book genres.
-- Primary key: genre_id uniquely identifies each genre.
-- UNIQUE: genre_name avoids duplicate genre labels.
-- ---------------------------------------------------------------------------
CREATE TABLE genres (
    genre_id INTEGER PRIMARY KEY,
    genre_name TEXT NOT NULL UNIQUE,
    genre_description TEXT
);

-- ---------------------------------------------------------------------------
-- 11. book_genres
-- Junction table for the many-to-many relationship between books and genres.
-- Composite primary key: book_id and genre_id prevent duplicate mappings.
-- Foreign keys: require valid book and genre records.
-- ON DELETE CASCADE: if a book or genre is removed, the related mapping rows
-- are removed automatically.
-- ---------------------------------------------------------------------------
CREATE TABLE book_genres (
    book_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, genre_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- 12. book_conditions
-- Master table for the physical condition of a listed book copy.
-- Primary key: condition_id uniquely identifies each condition category.
-- UNIQUE: condition_name avoids duplicate condition labels.
-- ---------------------------------------------------------------------------
CREATE TABLE book_conditions (
    condition_id INTEGER PRIMARY KEY,
    condition_name TEXT NOT NULL UNIQUE,
    condition_description TEXT
);

-- ---------------------------------------------------------------------------
-- 13. book_listings
-- Represents a concrete physical copy offered by a specific owner.
-- This table connects book, owner, condition, address and lending information.
-- Primary key: listing_id uniquely identifies each physical book offer.
-- Foreign keys: book_id, owner_id, condition_id and pickup_address_id ensure
-- that each listing is linked to valid master and user data.
-- CHECK: max_lending_days, listing_status, postal flag and postal fee restrict
-- values to realistic lending rules.
-- ON DELETE: no cascade is used here so active lending records are not removed
-- accidentally when referenced data is still important for audit purposes.
-- ---------------------------------------------------------------------------
CREATE TABLE book_listings (
    listing_id INTEGER PRIMARY KEY,
    book_id INTEGER NOT NULL,
    owner_id INTEGER NOT NULL,
    condition_id INTEGER NOT NULL,
    pickup_address_id INTEGER NOT NULL,
    max_lending_days INTEGER NOT NULL CHECK (max_lending_days > 0),
    listing_status TEXT NOT NULL DEFAULT 'available'
        CHECK (listing_status IN ('available', 'reserved', 'borrowed', 'inactive')),
    is_postal_delivery_available INTEGER NOT NULL DEFAULT 0 CHECK (is_postal_delivery_available IN (0, 1)),
    postal_delivery_fee REAL NOT NULL DEFAULT 0 CHECK (postal_delivery_fee >= 0),
    listing_note TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (owner_id) REFERENCES users(user_id),
    FOREIGN KEY (condition_id) REFERENCES book_conditions(condition_id),
    FOREIGN KEY (pickup_address_id) REFERENCES addresses(address_id)
);

-- ---------------------------------------------------------------------------
-- 14. time_slots
-- Stores available handover time slots for a book listing.
-- Primary key: time_slot_id uniquely identifies each slot.
-- Foreign key: listing_id connects each slot to one listing.
-- CHECK: slot_status limits workflow states, and start_time < end_time prevents
-- invalid time intervals.
-- ON DELETE CASCADE: if a listing is deleted, its time slots are deleted too.
-- ---------------------------------------------------------------------------
CREATE TABLE time_slots (
    time_slot_id INTEGER PRIMARY KEY,
    listing_id INTEGER NOT NULL,
    available_date TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    slot_status TEXT NOT NULL DEFAULT 'open'
        CHECK (slot_status IN ('open', 'reserved', 'completed', 'cancelled')),
    CHECK (start_time < end_time),
    FOREIGN KEY (listing_id) REFERENCES book_listings(listing_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- 15. delivery_methods
-- Master table for handover methods such as pickup, postal delivery, locker etc.
-- Primary key: delivery_method_id uniquely identifies each method.
-- UNIQUE: method_name avoids duplicate delivery method names.
-- ---------------------------------------------------------------------------
CREATE TABLE delivery_methods (
    delivery_method_id INTEGER PRIMARY KEY,
    method_name TEXT NOT NULL UNIQUE,
    method_description TEXT
);

-- ---------------------------------------------------------------------------
-- 16. listing_delivery_options
-- Junction table showing which delivery methods are available for each listing.
-- Composite primary key: listing_id and delivery_method_id prevent duplicate
-- delivery options for the same listing.
-- Foreign keys: connect the option to a valid listing and delivery method.
-- CHECK: extra_fee and is_enabled keep option values valid.
-- ON DELETE CASCADE: if a listing is deleted, its delivery options are deleted.
-- ---------------------------------------------------------------------------
CREATE TABLE listing_delivery_options (
    listing_id INTEGER NOT NULL,
    delivery_method_id INTEGER NOT NULL,
    extra_fee REAL NOT NULL DEFAULT 0 CHECK (extra_fee >= 0),
    is_enabled INTEGER NOT NULL DEFAULT 1 CHECK (is_enabled IN (0, 1)),
    PRIMARY KEY (listing_id, delivery_method_id),
    FOREIGN KEY (listing_id) REFERENCES book_listings(listing_id) ON DELETE CASCADE,
    FOREIGN KEY (delivery_method_id) REFERENCES delivery_methods(delivery_method_id)
);

-- ---------------------------------------------------------------------------
-- 17. borrow_requests
-- Stores borrower requests before they become confirmed loans.
-- Primary key: request_id uniquely identifies each request.
-- Foreign keys: listing_id, borrower_id, selected_time_slot_id and
-- delivery_method_id connect the request to the lending workflow.
-- CHECK: request_status limits workflow states, and requested_from_date <=
-- requested_to_date prevents invalid borrowing periods.
-- ON DELETE: no cascade is used because requests are part of the transaction
-- history and should remain available for review.
-- ---------------------------------------------------------------------------
CREATE TABLE borrow_requests (
    request_id INTEGER PRIMARY KEY,
    listing_id INTEGER NOT NULL,
    borrower_id INTEGER NOT NULL,
    selected_time_slot_id INTEGER,
    delivery_method_id INTEGER,
    request_status TEXT NOT NULL DEFAULT 'pending'
        CHECK (request_status IN ('pending', 'accepted', 'rejected', 'cancelled')),
    requested_from_date TEXT NOT NULL,
    requested_to_date TEXT NOT NULL,
    request_message TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (requested_from_date <= requested_to_date),
    FOREIGN KEY (listing_id) REFERENCES book_listings(listing_id),
    FOREIGN KEY (borrower_id) REFERENCES users(user_id),
    FOREIGN KEY (selected_time_slot_id) REFERENCES time_slots(time_slot_id),
    FOREIGN KEY (delivery_method_id) REFERENCES delivery_methods(delivery_method_id)
);

-- ---------------------------------------------------------------------------
-- 18. loans
-- Stores confirmed lending transactions created from accepted requests.
-- Primary key: loan_id uniquely identifies each confirmed loan.
-- UNIQUE: request_id ensures that one accepted borrow request can create only
-- one loan.
-- Foreign keys: connect the loan to its request, listing, borrower and owner.
-- CHECK: loan_status limits workflow states, and loan_start_date <= due_date
-- prevents invalid loan periods.
-- ON DELETE: no cascade is used for users or listings to preserve loan history.
-- ---------------------------------------------------------------------------
CREATE TABLE loans (
    loan_id INTEGER PRIMARY KEY,
    request_id INTEGER NOT NULL UNIQUE,
    listing_id INTEGER NOT NULL,
    borrower_id INTEGER NOT NULL,
    owner_id INTEGER NOT NULL,
    loan_start_date TEXT NOT NULL,
    due_date TEXT NOT NULL,
    actual_return_date TEXT,
    loan_status TEXT NOT NULL DEFAULT 'active'
        CHECK (loan_status IN ('active', 'returned', 'overdue', 'cancelled')),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (loan_start_date <= due_date),
    FOREIGN KEY (request_id) REFERENCES borrow_requests(request_id),
    FOREIGN KEY (listing_id) REFERENCES book_listings(listing_id),
    FOREIGN KEY (borrower_id) REFERENCES users(user_id),
    FOREIGN KEY (owner_id) REFERENCES users(user_id)
);

-- ---------------------------------------------------------------------------
-- 19. loan_status_history
-- Stores changes in the status of a loan for traceability.
-- Primary key: history_id uniquely identifies each history entry.
-- Foreign keys: loan_id connects the entry to a loan and changed_by_user_id
-- records the user who made or caused the change.
-- ON DELETE CASCADE: if a loan is deleted, its status history is deleted too.
-- ---------------------------------------------------------------------------
CREATE TABLE loan_status_history (
    history_id INTEGER PRIMARY KEY,
    loan_id INTEGER NOT NULL,
    old_status TEXT,
    new_status TEXT NOT NULL,
    changed_by_user_id INTEGER NOT NULL,
    changed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note TEXT,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by_user_id) REFERENCES users(user_id)
);

-- ---------------------------------------------------------------------------
-- 20. reviews
-- Stores feedback after a loan has been completed.
-- Primary key: review_id uniquely identifies each review.
-- Foreign keys: connect the review to a loan, reviewer, reviewee and book.
-- CHECK: rating allows only values from 1 to 5.
-- ON DELETE CASCADE: if a loan is deleted, related reviews are deleted because
-- they describe that specific loan experience.
-- ---------------------------------------------------------------------------
CREATE TABLE reviews (
    review_id INTEGER PRIMARY KEY,
    loan_id INTEGER NOT NULL,
    reviewer_id INTEGER NOT NULL,
    reviewee_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES users(user_id),
    FOREIGN KEY (reviewee_id) REFERENCES users(user_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- ---------------------------------------------------------------------------
-- 21. notifications
-- Stores platform messages for users.
-- Primary key: notification_id uniquely identifies each notification.
-- Foreign key: user_id connects each message to one user.
-- CHECK: is_read is stored as a SQLite boolean value, either 0 or 1.
-- Logic: notifications may be inserted by application code or by optional
-- triggers, for example when a request is accepted.
-- ON DELETE CASCADE: if a user is deleted, their notifications are deleted too.
-- ---------------------------------------------------------------------------
CREATE TABLE notifications (
    notification_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    notification_type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read INTEGER NOT NULL DEFAULT 0 CHECK (is_read IN (0, 1)),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- 22. reports
-- Stores moderation reports submitted by users.
-- Primary key: report_id uniquely identifies each report.
-- Foreign keys: connect the report to the reporter, optional reported user,
-- optional listing and optional loan.
-- CHECK: report_status limits moderation workflow states.
-- ON DELETE: no cascade is used so moderation records can remain available as
-- audit information.
-- ---------------------------------------------------------------------------
CREATE TABLE reports (
    report_id INTEGER PRIMARY KEY,
    reported_by_user_id INTEGER NOT NULL,
    reported_user_id INTEGER,
    listing_id INTEGER,
    loan_id INTEGER,
    report_reason TEXT NOT NULL,
    report_description TEXT,
    report_status TEXT NOT NULL DEFAULT 'open'
        CHECK (report_status IN ('open', 'under_review', 'resolved', 'dismissed')),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reported_by_user_id) REFERENCES users(user_id),
    FOREIGN KEY (reported_user_id) REFERENCES users(user_id),
    FOREIGN KEY (listing_id) REFERENCES book_listings(listing_id),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- ---------------------------------------------------------------------------
-- 23. fines
-- Stores optional fines for late return, loss or damage.
-- Primary key: fine_id uniquely identifies each fine.
-- Foreign keys: connect the fine to a loan and the responsible borrower.
-- CHECK: fine_amount cannot be negative and fine_status is limited to valid
-- payment or dispute states.
-- Logic: fines may be entered manually or generated by the optional overdue
-- trigger when a loan status changes to overdue.
-- ON DELETE CASCADE: if a loan is deleted, its fines are deleted too.
-- ---------------------------------------------------------------------------
CREATE TABLE fines (
    fine_id INTEGER PRIMARY KEY,
    loan_id INTEGER NOT NULL,
    borrower_id INTEGER NOT NULL,
    fine_reason TEXT NOT NULL,
    fine_amount REAL NOT NULL CHECK (fine_amount >= 0),
    fine_status TEXT NOT NULL DEFAULT 'open'
        CHECK (fine_status IN ('open', 'paid', 'waived', 'disputed')),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (borrower_id) REFERENCES users(user_id)
);

-- ---------------------------------------------------------------------------
-- Indexes for efficient filtering and joins.
-- ---------------------------------------------------------------------------
CREATE INDEX idx_addresses_coordinates ON addresses(latitude, longitude);
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_book_listings_status ON book_listings(listing_status);
CREATE INDEX idx_borrow_requests_status ON borrow_requests(request_status);
CREATE INDEX idx_loans_status ON loans(loan_status);
CREATE INDEX idx_reviews_book_rating ON reviews(book_id, rating);
