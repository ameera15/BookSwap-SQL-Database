# Installation Guide

## Project

BookSwap SQL Database Project  
Student name: Amirah  
Course: DLBDSPBDM01_D

## Required Software

Install the following:

1. Visual Studio Code
2. SQLite extension for VS Code
3. SQLite command line tool or DB Browser for SQLite

## Running with SQLite Command Line

Open this project folder in VS Code.

Run:

```bash
sqlite3 bookswap_app.db ".read sql/00_full_setup.sql"
```

Then run the test queries:

```bash
sqlite3 bookswap_app.db ".read sql/03_test_queries.sql"
```

Optional: load the trigger file if you want to demonstrate automatic notification and fine logic:

```bash
sqlite3 bookswap_app.db ".read sql/04_optional_triggers.sql"
```

## Running with DB Browser for SQLite

1. Open DB Browser for SQLite.
2. Open `bookswap_app.db`.
3. Go to **Execute SQL**.
4. Paste queries from `sql/03_test_queries.sql`.
5. Run each query and take screenshots for the Phase 2 presentation.
6. Optional: open `sql/04_optional_triggers.sql` to review the trigger logic.

## Expected Result

The database should contain 23 tables. Each table should have at least 10 records. The test queries should show available books, users, loan records, borrow requests, ratings, reports, fines and metadata. The optional trigger file should create two triggers when it is loaded.
