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
