/*
================================================================================
Project: BookSwap Local Community Database
File: 00_full_setup.sql

Run this single file to create the complete database:
1. Creates all tables and constraints.
2. Inserts all dummy data.
3. Keeps the SQL implementation documented for IU Phase 2.
================================================================================
*/


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



/*
================================================================================
Project: BookSwap Local Community Database
File: 02_seed_data.sql

Purpose:
This file inserts meaningful dummy data into every table. Each table receives at
least 10 entries, which supports the Phase 2 requirement that the database can be
tested and demonstrated with visible query results.
================================================================================
*/

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- users: 10 registered platform users.
-- ---------------------------------------------------------------------------
INSERT INTO users (user_id, full_name, email, phone, password_hash, user_status, created_at, updated_at) VALUES
(1, 'Amirah Khan', 'amirah.khan@example.com', '+49-151-10000001', 'hashed_pw_001', 'active', '2026-01-01 09:00:00', '2026-01-01 09:00:00'),
(2, 'Lina Weber', 'lina.weber@example.com', '+49-151-10000002', 'hashed_pw_002', 'active', '2026-01-02 09:00:00', '2026-01-02 09:00:00'),
(3, 'Noah Fischer', 'noah.fischer@example.com', '+49-151-10000003', 'hashed_pw_003', 'active', '2026-01-03 09:00:00', '2026-01-03 09:00:00'),
(4, 'Sara Hoffmann', 'sara.hoffmann@example.com', '+49-151-10000004', 'hashed_pw_004', 'active', '2026-01-04 09:00:00', '2026-01-04 09:00:00'),
(5, 'Omar Ahmed', 'omar.ahmed@example.com', '+49-151-10000005', 'hashed_pw_005', 'active', '2026-01-05 09:00:00', '2026-01-05 09:00:00'),
(6, 'Mia Schneider', 'mia.schneider@example.com', '+49-151-10000006', 'hashed_pw_006', 'active', '2026-01-06 09:00:00', '2026-01-06 09:00:00'),
(7, 'Elias Braun', 'elias.braun@example.com', '+49-151-10000007', 'hashed_pw_007', 'active', '2026-01-07 09:00:00', '2026-01-07 09:00:00'),
(8, 'Nora Becker', 'nora.becker@example.com', '+49-151-10000008', 'hashed_pw_008', 'active', '2026-01-08 09:00:00', '2026-01-08 09:00:00'),
(9, 'David Klein', 'david.klein@example.com', '+49-151-10000009', 'hashed_pw_009', 'suspended', '2026-01-09 09:00:00', '2026-01-09 09:00:00'),
(10, 'Hanna Wolf', 'hanna.wolf@example.com', '+49-151-10000010', 'hashed_pw_010', 'active', '2026-01-10 09:00:00', '2026-01-10 09:00:00');

-- ---------------------------------------------------------------------------
-- user_roles: 10 possible platform roles.
-- ---------------------------------------------------------------------------
INSERT INTO user_roles (role_id, role_name, role_description) VALUES
(1, 'registered_user', 'Can use basic platform functions.'),
(2, 'book_owner', 'Can list books for lending.'),
(3, 'borrower', 'Can request and borrow books.'),
(4, 'administrator', 'Can moderate users, listings and reports.'),
(5, 'community_moderator', 'Can support local community quality control.'),
(6, 'support_agent', 'Can support user communication.'),
(7, 'content_reviewer', 'Can review listing descriptions.'),
(8, 'finance_manager', 'Can review fines and payments.'),
(9, 'logistics_helper', 'Can support postal handover coordination.'),
(10, 'guest_viewer', 'Can view public book availability.');

-- ---------------------------------------------------------------------------
-- user_role_assignments: at least 10 user-role assignments.
-- ---------------------------------------------------------------------------
INSERT INTO user_role_assignments (user_id, role_id, assigned_at) VALUES
(1, 1, '2026-01-01 09:10:00'),
(1, 2, '2026-01-01 09:11:00'),
(2, 1, '2026-01-02 09:10:00'),
(2, 3, '2026-01-02 09:11:00'),
(3, 1, '2026-01-03 09:10:00'),
(3, 2, '2026-01-03 09:11:00'),
(4, 1, '2026-01-04 09:10:00'),
(4, 3, '2026-01-04 09:11:00'),
(5, 4, '2026-01-05 09:10:00'),
(6, 5, '2026-01-06 09:10:00'),
(7, 6, '2026-01-07 09:10:00'),
(8, 7, '2026-01-08 09:10:00'),
(9, 8, '2026-01-09 09:10:00'),
(10, 9, '2026-01-10 09:10:00');

-- ---------------------------------------------------------------------------
-- addresses: 10 addresses with coordinates for spatial search.
-- ---------------------------------------------------------------------------
INSERT INTO addresses (address_id, user_id, street, city, state, postal_code, country, latitude, longitude, is_default) VALUES
(1, 1, 'Main Street 12', 'Berlin', 'Berlin', '10115', 'Germany', 52.53210, 13.38490, 1),
(2, 2, 'River Road 8', 'Berlin', 'Berlin', '10117', 'Germany', 52.51704, 13.38886, 1),
(3, 3, 'Library Lane 4', 'Potsdam', 'Brandenburg', '14467', 'Germany', 52.40093, 13.05914, 1),
(4, 4, 'Market Square 21', 'Hamburg', 'Hamburg', '20095', 'Germany', 53.55034, 10.00065, 1),
(5, 5, 'Book Avenue 5', 'Munich', 'Bavaria', '80331', 'Germany', 48.13743, 11.57549, 1),
(6, 6, 'Green Park 17', 'Cologne', 'North Rhine-Westphalia', '50667', 'Germany', 50.93753, 6.96028, 1),
(7, 7, 'Old Town 3', 'Frankfurt', 'Hesse', '60311', 'Germany', 50.11092, 8.68213, 1),
(8, 8, 'Student Street 19', 'Leipzig', 'Saxony', '04109', 'Germany', 51.33970, 12.37307, 1),
(9, 9, 'North Gate 6', 'Dresden', 'Saxony', '01067', 'Germany', 51.05041, 13.73726, 1),
(10, 10, 'South Road 14', 'Bremen', 'Bremen', '28195', 'Germany', 53.07930, 8.80169, 1);

-- ---------------------------------------------------------------------------
-- languages: 10 book languages.
-- ---------------------------------------------------------------------------
INSERT INTO languages (language_id, language_name, language_code) VALUES
(1, 'English', 'EN'),
(2, 'German', 'DE'),
(3, 'French', 'FR'),
(4, 'Spanish', 'ES'),
(5, 'Italian', 'IT'),
(6, 'Arabic', 'AR'),
(7, 'Hindi', 'HI'),
(8, 'Bengali', 'BN'),
(9, 'Turkish', 'TR'),
(10, 'Dutch', 'NL');

-- ---------------------------------------------------------------------------
-- publishers: 10 publishers.
-- ---------------------------------------------------------------------------
INSERT INTO publishers (publisher_id, publisher_name, country, website) VALUES
(1, 'Penguin Books', 'United Kingdom', 'https://www.penguin.co.uk'),
(2, 'Suhrkamp Verlag', 'Germany', 'https://www.suhrkamp.de'),
(3, 'OReilly Media', 'United States', 'https://www.oreilly.com'),
(4, 'Springer', 'Germany', 'https://www.springer.com'),
(5, 'HarperCollins', 'United States', 'https://www.harpercollins.com'),
(6, 'Oxford University Press', 'United Kingdom', 'https://global.oup.com'),
(7, 'Cambridge University Press', 'United Kingdom', 'https://www.cambridge.org'),
(8, 'No Starch Press', 'United States', 'https://nostarch.com'),
(9, 'Manning Publications', 'United States', 'https://www.manning.com'),
(10, 'Routledge', 'United Kingdom', 'https://www.routledge.com');

-- ---------------------------------------------------------------------------
-- books: 10 general book records.
-- ---------------------------------------------------------------------------
INSERT INTO books (book_id, isbn, title, publication_year, edition, language_id, publisher_id, description, created_at) VALUES
(1, '9780140449136', 'The Odyssey', 1996, 'Revised', 1, 1, 'Classic epic poem in translation.', '2026-01-11 10:00:00'),
(2, '9783518467103', 'The Metamorphosis', 1999, 'Paperback', 2, 2, 'A modernist novella about alienation.', '2026-01-11 10:05:00'),
(3, '9781492056355', 'Designing Data-Intensive Applications', 2017, 'First', 1, 3, 'Book about reliable and scalable data systems.', '2026-01-11 10:10:00'),
(4, '9783319219410', 'Database Systems', 2020, 'Third', 1, 4, 'Academic introduction to database systems.', '2026-01-11 10:15:00'),
(5, '9780061120084', 'To Kill a Mockingbird', 2006, 'Reprint', 1, 5, 'Novel about justice and social values.', '2026-01-11 10:20:00'),
(6, '9780199535569', 'Pride and Prejudice', 2008, 'Oxford World Classics', 1, 6, 'Classic novel about manners and relationships.', '2026-01-11 10:25:00'),
(7, '9781108420418', 'Introduction to Algorithms', 2022, 'Fourth', 1, 7, 'Comprehensive text on algorithms.', '2026-01-11 10:30:00'),
(8, '9781593279509', 'Automate the Boring Stuff with Python', 2019, 'Second', 1, 8, 'Practical Python programming for automation.', '2026-01-11 10:35:00'),
(9, '9781617294945', 'Grokking Algorithms', 2016, 'First', 1, 9, 'Beginner-friendly algorithms guide.', '2026-01-11 10:40:00'),
(10, '9780415821312', 'Sociology: A Brief Introduction', 2018, 'Second', 1, 10, 'Introductory sociology textbook.', '2026-01-11 10:45:00');

-- ---------------------------------------------------------------------------
-- authors: 10 authors.
-- ---------------------------------------------------------------------------
INSERT INTO authors (author_id, author_name, biography) VALUES
(1, 'Homer', 'Ancient Greek poet traditionally credited with epic poetry.'),
(2, 'Franz Kafka', 'German-language writer known for modernist fiction.'),
(3, 'Martin Kleppmann', 'Author and researcher in data systems.'),
(4, 'Thomas Connolly', 'Author of database systems textbooks.'),
(5, 'Harper Lee', 'American novelist.'),
(6, 'Jane Austen', 'English novelist.'),
(7, 'Thomas H. Cormen', 'Computer scientist and algorithm textbook author.'),
(8, 'Al Sweigart', 'Author of programming books.'),
(9, 'Aditya Bhargava', 'Author and illustrator of programming books.'),
(10, 'John Macionis', 'Sociology textbook author.');

-- ---------------------------------------------------------------------------
-- book_authors: at least 10 mappings.
-- ---------------------------------------------------------------------------
INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- ---------------------------------------------------------------------------
-- genres: 10 genres.
-- ---------------------------------------------------------------------------
INSERT INTO genres (genre_id, genre_name, genre_description) VALUES
(1, 'Classic Literature', 'Long-standing works of literary value.'),
(2, 'Modernist Fiction', 'Fiction associated with modernist themes.'),
(3, 'Computer Science', 'Books about computing and software.'),
(4, 'Database', 'Books about data storage, modeling and querying.'),
(5, 'Social Justice', 'Books discussing social and ethical issues.'),
(6, 'Romance', 'Books focusing on relationships.'),
(7, 'Algorithms', 'Books about algorithmic thinking and design.'),
(8, 'Programming', 'Books about practical programming.'),
(9, 'Education', 'Learning-oriented books and textbooks.'),
(10, 'Sociology', 'Books about society and social behavior.');

-- ---------------------------------------------------------------------------
-- book_genres: at least 10 mappings.
-- ---------------------------------------------------------------------------
INSERT INTO book_genres (book_id, genre_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(3, 4),
(4, 3),
(4, 4),
(5, 1),
(5, 5),
(6, 1),
(6, 6),
(7, 3),
(7, 7),
(8, 3),
(8, 8),
(9, 7),
(10, 10);

-- ---------------------------------------------------------------------------
-- book_conditions: 10 possible physical conditions.
-- ---------------------------------------------------------------------------
INSERT INTO book_conditions (condition_id, condition_name, condition_description) VALUES
(1, 'New', 'Unused book with no visible damage.'),
(2, 'Like New', 'Almost unused with very minor signs of handling.'),
(3, 'Very Good', 'Clean copy with small signs of use.'),
(4, 'Good', 'Readable copy with normal signs of use.'),
(5, 'Acceptable', 'Readable but visibly worn.'),
(6, 'Annotated', 'Contains useful notes or highlights.'),
(7, 'Damaged Cover', 'Cover has visible damage but pages are readable.'),
(8, 'Old Edition', 'Older edition but still usable.'),
(9, 'Library Copy', 'Former library copy with labels.'),
(10, 'Rare Copy', 'Special or hard-to-find copy.');

-- ---------------------------------------------------------------------------
-- book_listings: 10 physical book offers.
-- ---------------------------------------------------------------------------
INSERT INTO book_listings (listing_id, book_id, owner_id, condition_id, pickup_address_id, max_lending_days, listing_status, is_postal_delivery_available, postal_delivery_fee, listing_note, created_at, updated_at) VALUES
(1, 1, 1, 3, 1, 21, 'available', 1, 3.50, 'Available for literature readers in central Berlin.', '2026-01-12 08:00:00', '2026-01-12 08:00:00'),
(2, 2, 2, 4, 2, 14, 'available', 0, 0.00, 'Pickup only near the city centre.', '2026-01-12 08:10:00', '2026-01-12 08:10:00'),
(3, 3, 3, 2, 3, 30, 'reserved', 1, 4.99, 'Useful for database and systems students.', '2026-01-12 08:20:00', '2026-01-12 08:20:00'),
(4, 4, 4, 3, 4, 28, 'borrowed', 1, 4.50, 'Academic database textbook.', '2026-01-12 08:30:00', '2026-01-12 08:30:00'),
(5, 5, 5, 4, 5, 21, 'available', 1, 3.00, 'Classic fiction in good condition.', '2026-01-12 08:40:00', '2026-01-12 08:40:00'),
(6, 6, 6, 5, 6, 14, 'available', 0, 0.00, 'Older but readable copy.', '2026-01-12 08:50:00', '2026-01-12 08:50:00'),
(7, 7, 7, 2, 7, 30, 'reserved', 1, 5.00, 'Algorithm book for serious study.', '2026-01-12 09:00:00', '2026-01-12 09:00:00'),
(8, 8, 8, 3, 8, 21, 'available', 1, 3.99, 'Python book for beginner automation tasks.', '2026-01-12 09:10:00', '2026-01-12 09:10:00'),
(9, 9, 9, 4, 9, 14, 'inactive', 0, 0.00, 'Listing paused by user.', '2026-01-12 09:20:00', '2026-01-12 09:20:00'),
(10, 10, 10, 3, 10, 21, 'available', 1, 3.25, 'Sociology introduction for first-year students.', '2026-01-12 09:30:00', '2026-01-12 09:30:00');

-- ---------------------------------------------------------------------------
-- time_slots: 10 pickup/return slots.
-- ---------------------------------------------------------------------------
INSERT INTO time_slots (time_slot_id, listing_id, available_date, start_time, end_time, slot_status) VALUES
(1, 1, '2026-02-01', '10:00', '11:00', 'open'),
(2, 2, '2026-02-02', '12:00', '13:00', 'open'),
(3, 3, '2026-02-03', '14:00', '15:00', 'reserved'),
(4, 4, '2026-02-04', '16:00', '17:00', 'completed'),
(5, 5, '2026-02-05', '10:30', '11:30', 'open'),
(6, 6, '2026-02-06', '12:30', '13:30', 'open'),
(7, 7, '2026-02-07', '14:30', '15:30', 'reserved'),
(8, 8, '2026-02-08', '16:30', '17:30', 'open'),
(9, 9, '2026-02-09', '18:00', '19:00', 'cancelled'),
(10, 10, '2026-02-10', '09:00', '10:00', 'open');

-- ---------------------------------------------------------------------------
-- delivery_methods: 10 handover methods.
-- ---------------------------------------------------------------------------
INSERT INTO delivery_methods (delivery_method_id, method_name, method_description) VALUES
(1, 'Pickup', 'Borrower collects the book at the pickup address.'),
(2, 'Postal Delivery', 'Book is sent by post for an additional fee.'),
(3, 'Community Locker', 'Book is placed in a shared community locker.'),
(4, 'Campus Handover', 'Book is exchanged on a campus location.'),
(5, 'Library Desk', 'Book is left at a library information desk.'),
(6, 'Cafe Meetup', 'Owner and borrower meet at a public cafe.'),
(7, 'Neighbour Drop-off', 'Owner drops the book at a nearby address.'),
(8, 'Bike Courier', 'Local bike courier transports the book.'),
(9, 'Weekend Market', 'Book is handed over at a weekend market point.'),
(10, 'Return Box', 'Book is returned through a dedicated return box.');

-- ---------------------------------------------------------------------------
-- listing_delivery_options: at least 10 options for listings.
-- ---------------------------------------------------------------------------
INSERT INTO listing_delivery_options (listing_id, delivery_method_id, extra_fee, is_enabled) VALUES
(1, 1, 0.00, 1),
(1, 2, 3.50, 1),
(2, 1, 0.00, 1),
(3, 2, 4.99, 1),
(4, 2, 4.50, 1),
(5, 1, 0.00, 1),
(5, 2, 3.00, 1),
(6, 1, 0.00, 1),
(7, 4, 0.00, 1),
(8, 3, 1.00, 1),
(9, 1, 0.00, 0),
(10, 2, 3.25, 1);

-- ---------------------------------------------------------------------------
-- borrow_requests: 10 user borrowing requests.
-- ---------------------------------------------------------------------------
INSERT INTO borrow_requests (request_id, listing_id, borrower_id, selected_time_slot_id, delivery_method_id, request_status, requested_from_date, requested_to_date, request_message, created_at, updated_at) VALUES
(1, 1, 2, 1, 1, 'accepted', '2026-02-01', '2026-02-15', 'I would like to read this for my literature class.', '2026-01-20 10:00:00', '2026-01-20 11:00:00'),
(2, 2, 3, 2, 1, 'pending', '2026-02-02', '2026-02-10', 'Can I collect this on Tuesday?', '2026-01-20 10:10:00', '2026-01-20 10:10:00'),
(3, 3, 4, 3, 2, 'accepted', '2026-02-03', '2026-02-25', 'I need it for database revision.', '2026-01-20 10:20:00', '2026-01-20 11:20:00'),
(4, 4, 5, 4, 2, 'accepted', '2026-02-04', '2026-02-28', 'This book is useful for my assignment.', '2026-01-20 10:30:00', '2026-01-20 11:30:00'),
(5, 5, 6, 5, 1, 'rejected', '2026-02-05', '2026-02-16', 'I can return it quickly.', '2026-01-20 10:40:00', '2026-01-20 11:40:00'),
(6, 6, 7, 6, 1, 'pending', '2026-02-06', '2026-02-18', 'Pickup is possible in the afternoon.', '2026-01-20 10:50:00', '2026-01-20 10:50:00'),
(7, 7, 8, 7, 4, 'accepted', '2026-02-07', '2026-03-01', 'I need it for algorithm practice.', '2026-01-20 11:00:00', '2026-01-20 12:00:00'),
(8, 8, 9, 8, 3, 'cancelled', '2026-02-08', '2026-02-20', 'Request cancelled by borrower.', '2026-01-20 11:10:00', '2026-01-20 12:10:00'),
(9, 9, 10, 9, 1, 'rejected', '2026-02-09', '2026-02-19', 'Listing is inactive.', '2026-01-20 11:20:00', '2026-01-20 12:20:00'),
(10, 10, 1, 10, 2, 'accepted', '2026-02-10', '2026-02-24', 'I want to use it for a seminar.', '2026-01-20 11:30:00', '2026-01-20 12:30:00');

-- ---------------------------------------------------------------------------
-- loans: 10 confirmed or historic lending records.
-- ---------------------------------------------------------------------------
INSERT INTO loans (loan_id, request_id, listing_id, borrower_id, owner_id, loan_start_date, due_date, actual_return_date, loan_status, created_at) VALUES
(1, 1, 1, 2, 1, '2026-02-01', '2026-02-15', '2026-02-14', 'returned', '2026-02-01 11:05:00'),
(2, 2, 2, 3, 2, '2026-02-02', '2026-02-10', NULL, 'active', '2026-02-02 13:05:00'),
(3, 3, 3, 4, 3, '2026-02-03', '2026-02-25', NULL, 'active', '2026-02-03 15:05:00'),
(4, 4, 4, 5, 4, '2026-02-04', '2026-02-28', NULL, 'overdue', '2026-02-04 17:05:00'),
(5, 5, 5, 6, 5, '2026-02-05', '2026-02-16', '2026-02-16', 'returned', '2026-02-05 11:35:00'),
(6, 6, 6, 7, 6, '2026-02-06', '2026-02-18', NULL, 'cancelled', '2026-02-06 13:35:00'),
(7, 7, 7, 8, 7, '2026-02-07', '2026-03-01', NULL, 'active', '2026-02-07 15:35:00'),
(8, 8, 8, 9, 8, '2026-02-08', '2026-02-20', '2026-02-19', 'returned', '2026-02-08 17:35:00'),
(9, 9, 9, 10, 9, '2026-02-09', '2026-02-19', NULL, 'cancelled', '2026-02-09 19:05:00'),
(10, 10, 10, 1, 10, '2026-02-10', '2026-02-24', NULL, 'active', '2026-02-10 10:05:00');

-- ---------------------------------------------------------------------------
-- loan_status_history: 10 traceability records.
-- ---------------------------------------------------------------------------
INSERT INTO loan_status_history (history_id, loan_id, old_status, new_status, changed_by_user_id, changed_at, note) VALUES
(1, 1, NULL, 'active', 1, '2026-02-01 11:05:00', 'Loan created after accepted request.'),
(2, 1, 'active', 'returned', 2, '2026-02-14 16:00:00', 'Book returned one day early.'),
(3, 2, NULL, 'active', 2, '2026-02-02 13:05:00', 'Loan activated.'),
(4, 3, NULL, 'active', 3, '2026-02-03 15:05:00', 'Loan activated.'),
(5, 4, NULL, 'active', 4, '2026-02-04 17:05:00', 'Loan activated.'),
(6, 4, 'active', 'overdue', 4, '2026-03-01 09:00:00', 'Due date passed.'),
(7, 5, NULL, 'active', 5, '2026-02-05 11:35:00', 'Loan activated.'),
(8, 5, 'active', 'returned', 6, '2026-02-16 18:00:00', 'Returned on due date.'),
(9, 7, NULL, 'active', 7, '2026-02-07 15:35:00', 'Loan activated.'),
(10, 10, NULL, 'active', 10, '2026-02-10 10:05:00', 'Loan activated.');

-- ---------------------------------------------------------------------------
-- reviews: 10 reviews related to loan experiences.
-- ---------------------------------------------------------------------------
INSERT INTO reviews (review_id, loan_id, reviewer_id, reviewee_id, book_id, rating, comment, created_at) VALUES
(1, 1, 2, 1, 1, 5, 'Excellent condition and easy pickup.', '2026-02-15 10:00:00'),
(2, 1, 1, 2, 1, 5, 'Borrower returned the book early.', '2026-02-15 10:05:00'),
(3, 3, 4, 3, 3, 4, 'Very useful book for database concepts.', '2026-02-26 10:00:00'),
(4, 4, 5, 4, 4, 3, 'Helpful but the book is slightly worn.', '2026-03-02 10:00:00'),
(5, 5, 6, 5, 5, 5, 'Friendly owner and smooth handover.', '2026-02-17 10:00:00'),
(6, 7, 8, 7, 7, 4, 'Great book for algorithm practice.', '2026-03-02 10:00:00'),
(7, 8, 9, 8, 8, 5, 'Good Python book and clear communication.', '2026-02-21 10:00:00'),
(8, 10, 1, 10, 10, 4, 'Useful for seminar preparation.', '2026-02-25 10:00:00'),
(9, 2, 3, 2, 2, 4, 'Good pickup location.', '2026-02-11 10:00:00'),
(10, 6, 7, 6, 6, 2, 'Loan was cancelled, but communication was acceptable.', '2026-02-19 10:00:00');

-- ---------------------------------------------------------------------------
-- notifications: 10 platform notifications.
-- ---------------------------------------------------------------------------
INSERT INTO notifications (notification_id, user_id, notification_type, title, message, is_read, created_at) VALUES
(1, 1, 'request_accepted', 'Borrow request accepted', 'Your request for Sociology was accepted.', 0, '2026-02-10 10:10:00'),
(2, 2, 'return_reminder', 'Return reminder', 'Please return The Odyssey by the due date.', 1, '2026-02-13 09:00:00'),
(3, 3, 'new_request', 'New borrow request', 'A user requested your data systems book.', 1, '2026-01-20 10:25:00'),
(4, 4, 'overdue_notice', 'Loan overdue', 'A loan connected to your listing is overdue.', 0, '2026-03-01 09:05:00'),
(5, 5, 'review_received', 'New review received', 'You received a review for your book listing.', 1, '2026-02-17 10:05:00'),
(6, 6, 'request_pending', 'Request pending', 'Your request is still waiting for approval.', 0, '2026-01-20 11:00:00'),
(7, 7, 'pickup_slot', 'Pickup slot reserved', 'A pickup slot has been reserved.', 1, '2026-02-07 09:00:00'),
(8, 8, 'listing_enabled', 'Listing enabled', 'Your Python listing is visible again.', 1, '2026-02-08 09:00:00'),
(9, 9, 'account_warning', 'Account status warning', 'Your account is temporarily suspended.', 0, '2026-01-09 09:15:00'),
(10, 10, 'postal_delivery', 'Postal delivery selected', 'A borrower selected postal delivery.', 1, '2026-02-10 09:55:00');

-- ---------------------------------------------------------------------------
-- reports: 10 moderation records.
-- ---------------------------------------------------------------------------
INSERT INTO reports (report_id, reported_by_user_id, reported_user_id, listing_id, loan_id, report_reason, report_description, report_status, created_at) VALUES
(1, 2, 1, 1, 1, 'Listing description mismatch', 'The condition was slightly different from the listing note.', 'resolved', '2026-02-15 12:00:00'),
(2, 3, 2, 2, 2, 'Late response', 'Owner replied late to a pending request.', 'open', '2026-02-11 12:00:00'),
(3, 4, 3, 3, 3, 'Postal delay', 'Postal delivery took longer than expected.', 'under_review', '2026-02-26 12:00:00'),
(4, 5, 4, 4, 4, 'Late return', 'Book was not returned by the due date.', 'under_review', '2026-03-01 12:00:00'),
(5, 6, 5, 5, 5, 'Communication issue', 'Pickup communication was unclear.', 'dismissed', '2026-02-17 12:00:00'),
(6, 7, 6, 6, 6, 'Cancelled loan', 'Loan was cancelled after planning.', 'resolved', '2026-02-19 12:00:00'),
(7, 8, 7, 7, 7, 'Book damage', 'Possible damage noticed during loan.', 'open', '2026-03-02 12:00:00'),
(8, 9, 8, 8, 8, 'Locker access issue', 'Community locker code was delayed.', 'resolved', '2026-02-21 12:00:00'),
(9, 10, 9, 9, 9, 'Inactive listing', 'Listing was inactive after request.', 'dismissed', '2026-02-20 12:00:00'),
(10, 1, 10, 10, 10, 'Postal fee question', 'Postal fee should be clarified.', 'open', '2026-02-25 12:00:00');

-- ---------------------------------------------------------------------------
-- fines: 10 optional fine records.
-- ---------------------------------------------------------------------------
INSERT INTO fines (fine_id, loan_id, borrower_id, fine_reason, fine_amount, fine_status, created_at) VALUES
(1, 1, 2, 'No fine - returned early', 0.00, 'waived', '2026-02-14 16:05:00'),
(2, 2, 3, 'Pending return monitoring', 0.00, 'open', '2026-02-10 17:00:00'),
(3, 3, 4, 'No fine yet', 0.00, 'open', '2026-02-25 17:00:00'),
(4, 4, 5, 'Late return', 5.00, 'open', '2026-03-01 09:10:00'),
(5, 5, 6, 'No fine - returned on time', 0.00, 'waived', '2026-02-16 18:05:00'),
(6, 6, 7, 'Cancelled loan without cost', 0.00, 'waived', '2026-02-19 12:10:00'),
(7, 7, 8, 'Possible damage review', 7.50, 'disputed', '2026-03-02 12:10:00'),
(8, 8, 9, 'No fine - returned on time', 0.00, 'paid', '2026-02-21 10:10:00'),
(9, 9, 10, 'Cancelled inactive listing', 0.00, 'waived', '2026-02-20 12:10:00'),
(10, 10, 1, 'Postal fee difference', 2.00, 'open', '2026-02-25 12:10:00');
