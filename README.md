# BookSwap SQL Database Project

**Student name:** Amira Sahraoui

**Course:** DLBDSPBDM01_D – Data-Mart-Erstellung in SQL  
**Project topic:** Relational database for a local book exchange / book lending app  
**DBMS used:** SQLite 3  
**Phase:** Development / Reflection Phase (Phase 2)

---

## 1. Project Overview

This project implements a relational SQL database for a local book exchange app. The application scenario allows registered users to offer their own books for temporary lending and to borrow books from other people in the local community.

The database stores:

- user accounts and roles,
- addresses with latitude and longitude for spatial search,
- general book information,
- authors, publishers, genres and languages,
- concrete physical book listings,
- book conditions,
- available time slots,
- delivery and handover methods,
- borrow requests,
- confirmed loans,
- loan status history,
- reviews,
- notifications,
- moderation reports,
- optional fines.

The implementation follows the Phase 1 ER model and separates general bibliographic book records from physical lendable book listings. This reduces redundancy and makes the database easier to maintain.

The model is comprehensive, but it is organised in a modular way. The core workflow is built from `users`, `addresses`, `books`, `book_listings`, `borrow_requests` and `loans`. Support modules such as `notifications`, `reports`, `reviews`, `loan_status_history` and `fines` extend the system but do not make the basic lending workflow harder to understand.

---

## 2. Folder Structure

```text
amirah_bookswap_sql_phase2/
│
├── README.md
├── bookswap_app.db
│
├── sql/
│   ├── 00_full_setup.sql
│   ├── 01_schema.sql
│   ├── 02_seed_data.sql
│   ├── 03_test_queries.sql
│   └── 04_optional_triggers.sql
│
├── docs/
│   ├── CODEX_STEP_BY_STEP_PROMPT.md
│   ├── INSTALLATION_GUIDE.md
│   ├── RELATIONSHIP_CARDINALITIES.md
│   └── SUBMISSION_CHECKLIST.md
│
└── outputs/
    └── test_output_summary.txt
```

---

## 3. Files Explained

### `sql/00_full_setup.sql`

This is the easiest file to run. It creates the full database schema and inserts all dummy data.

### `sql/01_schema.sql`

This file contains the documented SQL `CREATE TABLE` statements, constraints, foreign keys and indexes.

### `sql/02_seed_data.sql`

This file inserts meaningful dummy data. Each table has at least 10 records, so the database is ready for testing and screenshots.

### `sql/03_test_queries.sql`

This file contains SQL test cases for screenshots and Phase 2 presentation slides. It includes row count verification, available book search, spatial-style search, borrow request overview, loan overview, review summary, reports, fines and metadata.

### `sql/04_optional_triggers.sql`

This file contains optional SQLite triggers. They show how notification and fine logic could be automated. The base database works without these triggers.

### `docs/RELATIONSHIP_CARDINALITIES.md`

This file explains the main one-to-many, one-to-one and many-to-many relationships in simple English.

### `bookswap_app.db`

This is the generated SQLite database file created from the setup SQL.

---

## 4. How to Run the Project in VS Code

### Step 1: Install Required Tools

Install:

1. Visual Studio Code
2. SQLite extension for VS Code, for example **SQLite Viewer** or **SQLite**
3. Optional: DB Browser for SQLite

SQLite is already available on many systems. If the `sqlite3` command is missing, install it first.

---

### Step 2: Open the Project Folder

Open VS Code and select:

```text
File → Open Folder → amirah_bookswap_sql_phase2
```

---

### Step 3: Create the Database from SQL

Open a terminal inside VS Code and run:

```bash
sqlite3 bookswap_app.db ".read sql/00_full_setup.sql"
```

This creates the full database and inserts dummy data.

---

### Step 4: Run Test Queries

Run:

```bash
sqlite3 bookswap_app.db ".read sql/03_test_queries.sql"
```

Use the output as evidence for screenshots in the Phase 2 presentation.

---

### Step 5: Optional Trigger Logic

The optional trigger file can be loaded after the main database has been created:

```bash
sqlite3 bookswap_app.db ".read sql/04_optional_triggers.sql"
```

These triggers are not required for the base setup. They document possible automation rules:

1. When a borrow request becomes accepted, a notification is inserted for the borrower.
2. When a loan becomes overdue, an open fine is inserted if no fine already exists for that loan.

---

## 5. Recommended Screenshots for Phase 2 Presentation

Use these screenshots:

1. Database tables visible in VS Code or DB Browser for SQLite.
2. `users` table with data.
3. `books` table with data.
4. `book_listings` table with data.
5. `borrow_requests` table with data.
6. `loans` table with data.
7. Test 1 row count query showing at least 10 rows per table.
8. Test 2 available books query.
9. Test 3 spatial-style search query.
10. Test 5 borrow request workflow query.
11. Test 6 loan overview query.
12. Test 7 average ratings query.
13. Test 10 open/disputed fines query.
14. Test 12 metadata query.

---

## 6. Database Design Summary

The database is normalized into reusable master tables and junction tables. For example, authors, genres, languages, publishers and delivery methods are stored separately. Many-to-many relationships are implemented using junction tables such as `book_authors`, `book_genres`, `user_role_assignments` and `listing_delivery_options`.

The database is divided into two clear areas:

1. **Core lending workflow:** `users`, `addresses`, `books`, `book_listings`, `borrow_requests` and `loans`.
2. **Support modules:** `notifications`, `reports`, `reviews`, `loan_status_history`, `fines`, roles, authors, genres, languages, publishers, conditions, time slots and delivery options.

This structure controls complexity because the main lending process can be understood first. The support modules can then be explained as additional features for trust, moderation, communication and audit history.

The main workflow is:

1. A user owns a physical copy of a book.
2. The physical copy is stored as a `book_listings` record.
3. Another user creates a `borrow_requests` record.
4. If the request is accepted, a `loans` record is created.
5. The loan can be tracked through `loan_status_history`.
6. Reviews, reports, notifications and fines support trust, moderation and quality control.

The main cardinalities are documented separately in `docs/RELATIONSHIP_CARDINALITIES.md`.

---

## 7. Tutor Feedback Implementation

The Phase 1 tutor feedback was addressed in the Phase 2 implementation.

1. **Model complexity:** The 23-table structure was kept because it represents the BookSwap app in a complete way. Complexity is controlled through modular separation between the core lending workflow and optional support modules.
2. **Technical documentation:** The schema comments now explain the purpose of primary keys, foreign keys, `UNIQUE` constraints, `CHECK` constraints and `ON DELETE` rules.
3. **Cardinalities:** The main relationship types are documented in `docs/RELATIONSHIP_CARDINALITIES.md` using simple English.
4. **Notification and fine logic:** The optional file `sql/04_optional_triggers.sql` explains possible trigger conditions. A notification can be created when a request is accepted, and a fine can be created when a loan becomes overdue.

---

## 8. Main Tables

| Table | Purpose |
|---|---|
| `users` | Stores registered users |
| `user_roles` | Stores platform roles |
| `user_role_assignments` | Connects users and roles |
| `addresses` | Stores address and coordinate data |
| `books` | Stores general book data |
| `authors` | Stores authors |
| `book_authors` | Connects books and authors |
| `publishers` | Stores publishers |
| `genres` | Stores genres |
| `book_genres` | Connects books and genres |
| `languages` | Stores book languages |
| `book_conditions` | Stores physical condition categories |
| `book_listings` | Stores physical book offers |
| `time_slots` | Stores available handover slots |
| `delivery_methods` | Stores delivery/handover methods |
| `listing_delivery_options` | Connects listings and delivery methods |
| `borrow_requests` | Stores borrowing requests |
| `loans` | Stores confirmed loans |
| `loan_status_history` | Tracks loan status changes |
| `reviews` | Stores review data |
| `notifications` | Stores user notifications |
| `reports` | Stores moderation reports |
| `fines` | Stores optional fines |

---

