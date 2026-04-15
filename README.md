# CST8283 Business Programming — COBOL Coursework

> **Algonquin College ·  Summer 2025**
> Compiled with GnuCOBOL (`cobc`) on Windows.

A collection of COBOL programs written for CST8283 Business Programming, covering sequential and indexed file I/O, internal table handling, multi-file reporting, and modular program design via `COPY` and `CALL`.

---

## Table of Contents

- [Lab 4 — Stock Recommendation System](#lab-4--stock-recommendation-system)
- [Project 1 — Employee Records Manager](#project-1--employee-records-manager)
- [Project 2 — Investment Portfolio Report](#project-2--investment-portfolio-report)
- [PA3 — Indexed File CRUD (Skills-Based Assessment)](#pa3--indexed-file-crud-skills-based-assessment)
- [Project 3 — Full Portfolio Management Suite](#project-3--full-portfolio-management-suite)
- [Skills Demonstrated](#skills-demonstrated)
- [Build & Run](#build--run)

---

## Lab 4 — Stock Recommendation System

**File:** `LAB4.cbl`

An interactive console program that loads a stock file into an **internal table** (up to 20 entries) and lets the user query stocks by analyst recommendation rating.

**Key features:**
- Loads `STOCKS.TXT` into a 20-element `OCCURS` table at startup
- Validates analyst recommendation codes (1–4); silently skips records with invalid codes (5–9) using `88`-level condition names
- User enters a recommendation label (`STRONG BUY`, `BUY`, `HOLD`, `SELL`, or `QUIT`) — input is validated in a `PERFORM UNTIL` loop before any search runs
- Searches the table with a `PERFORM VARYING` loop and displays all matching stock names and closing prices
- Prints a run summary (records searched vs. records displayed) after each query
- Loops until the user enters `QUIT`

**Concepts:** internal tables (`OCCURS`), `88`-level condition names, `EVALUATE TRUE`, sequential file I/O, input validation loop.

---

## Project 1 — Employee Records Manager

**File:** `PROJECT1.cbl`

A standalone interactive program for creating and reviewing employee records stored in a flat sequential file.

**Key features:**
- Prompts the user whether to add a record before each entry — input validated with `88`-level flags (`INPUT-YES`, `INPUT-NO`, `INPUT-SPACE`)
- Collects six fields per employee: ID (6 digits), Department ID (3 digits), first/last name (20 chars each), and service years (formatted `99.9`)
- Writes records to `EMPLOYEES.TXT` via `OPEN OUTPUT`, then re-opens as `OPEN INPUT` to read back and display all records in a formatted tabular report
- Uses `STRING ... INTO` to build column headers at runtime
- Handles the empty-file edge case with a guard counter (`RECORD-CTL`)

**Concepts:** sequential flat-file I/O (write then read-back), formatted `DISPLAY` output, input validation, `STRING` verb.

---

## Project 2 — Investment Portfolio Report

**File:** `PROJECT2.cbl`  

A batch reporting program that joins two input files and writes a formatted financial report to a third file.

**Key features:**
- Loads up to 20 stock records from `STOCKS.TXT` into an `OCCURS` table at initialisation
- For each record in `PORTFOLIO.TXT`, performs an in-memory table lookup by stock symbol (`PERFORM VARYING ... UNTIL STOCK-FOUND`)
- Computes three derived fields per holding: **cost base** (`avg cost × shares`), **market value** (`closing price × shares`), and **gain/loss** (signed, `S9`)
- Writes a neatly formatted report to `REPORT.TXT` using picture editing characters (`$$,$$$,$$9.99`, `$$,$$$,$$9.99-`) — no post-processing needed
- Footer line reports total records read and written

**Concepts:** multi-file I/O (two inputs + one output), internal table lookup, arithmetic verbs (`MULTIPLY`, `SUBTRACT`), signed numeric fields, picture-edit formatting.

---

## PA3 — Indexed File CRUD (Skills-Based Assessment)

**Directory:** `PA3/` (inside `PA3.zip`)

Three programs working together on the same ISAM indexed file (`IPROD.DAT`), demonstrating full indexed file lifecycle management.

| Program | Purpose |
|---|---|
| `icreate.COB` | Loads `PROD.TXT` into a new indexed file (`ORGANIZATION IS INDEXED`, sequential access). Provided starter. |
| `iread.COB` | Reads and displays all records from the indexed file sequentially. Provided starter. |
| `starter3.COB` | Processes a transaction file (`TRANS.TXT`) and performs ADD / UPDATE / DELETE operations on the indexed file using `RANDOM` access mode. |

**`starter3.COB` highlights:**
- Opens the indexed file with `ACCESS MODE IS RANDOM` (`I-O`)
- Reads each transaction record and branches on the `CMD` field (`ADD`, `UPD`, `DEL`) using `EVALUATE TRUE` with `88`-level condition names
- **ADD:** `WRITE` with `INVALID KEY` duplicate detection
- **UPDATE:** `READ` by key, then `REWRITE` with `INVALID KEY` handling
- **DELETE:** `READ` by key, then `DELETE ... RECORD` with `INVALID KEY` handling
- All operations print a success or failure message; invalid command codes are caught and reported

**Concepts:** ISAM indexed file organisation, `RANDOM` access, `WRITE`/`READ`/`REWRITE`/`DELETE` verbs, file status codes (`FILE STATUS IS`), transaction-driven processing.

---

## Project 3 — Full Portfolio Management Suite

**Directory:** `Project3_V1/` (inside `Project3.zip`)  

A four-module COBOL system that covers the full lifecycle of an investment portfolio, from file conversion through interactive management to financial reporting.

### P3A — Convert Sequential to Indexed (`P3A.cbl`)

Reads the flat `PORTFOLIO.TXT` and writes it to `PORTFOLIO-INDEXED.DAT` as an ISAM indexed file keyed on stock symbol. Handles duplicate-key errors and tracks records written.

### P3B — Interactive Portfolio CRUD (`P3B.cbl`)

A full-featured interactive menu system for managing the indexed portfolio file. Operates with `ACCESS MODE IS DYNAMIC`, enabling both sequential and random access in the same open file.

**Menu operations:**
- **Add** a new holding (validates that the stock symbol exists in `STOCKS.TXT` before writing)
- **Update** shares and average cost for an existing holding
- **Delete** a holding by stock symbol
- **Display** a single record by key
- **List all** holdings sequentially
- **Quit** with a session summary (records added, updated, deleted)

Each operation uses `INVALID KEY` / `NOT INVALID KEY` branching and reports the outcome to the user.

### P3C1 — Report Generator with COPY and CALL (`P3C1.cbl`)

Generates the investment report by reading the indexed portfolio file sequentially and matching against the stocks table (loaded from `STOCKS.TXT`). Demonstrates two modularity techniques:

- **`COPY COPYSTOCKS.txt`** — imports the stocks table data definition from an external copybook
- **`CALL 'P3C2'`** — delegates financial calculations to the subroutine below, passing arguments by reference via the `LINKAGE SECTION`

Writes a formatted report to `REPORT.TXT` with columns for shares, unit cost, closing price, cost base, market value, and signed gain/loss.

### P3C2 — Financial Calculation Subroutine (`P3C2.cbl`)

A called subprogram (compiled to `P3C2.dll`) that receives five numeric arguments via `LINKAGE SECTION` and computes:

```
Cost Base    = Avg Cost × Shares
Market Value = Closing Price × Shares
Gain / Loss  = Market Value − Cost Base
```

Returns control to the calling program with `EXIT PROGRAM`.

**Concepts:** indexed file conversion, `DYNAMIC` access mode, full CRUD on ISAM, `COPY` copybooks, `CALL`/`EXIT PROGRAM` subprogram linkage, `LINKAGE SECTION`, signed arithmetic.

---

## Skills Demonstrated

| Area | Detail |
|---|---|
| File organisation | Sequential (`LINE SEQUENTIAL`), Indexed (`ISAM`) |
| Access modes | Sequential, Random, Dynamic |
| CRUD verbs | `WRITE`, `READ`, `REWRITE`, `DELETE`, `INVALID KEY` handling |
| Data structures | `OCCURS` tables, `88`-level condition names, signed numeric PIC |
| Modularity | `COPY` copybooks, `CALL`/`EXIT PROGRAM` subprograms, `LINKAGE SECTION` |
| Report writing | Multi-file batch joins, picture-edit formatting, header/footer generation |
| User interaction | Input validation loops, menu-driven programs, `EVALUATE TRUE` dispatch |
| Error handling | File status codes, invalid-key guards, empty-file detection |

---

## Build & Run

All programs were compiled with **GnuCOBOL** (`cobc`).

```bash
# Compile a standalone program
cobc -x -free LAB4.cbl -o LAB4

# Compile main program + subroutine (Project 3 C)
cobc -c -free P3C2.cbl               # compile subroutine to object
cobc -x -free P3C1.cbl P3C2.o -o P3C1

# Run
./LAB4
```

Input data files (`STOCKS.TXT`, `PORTFOLIO.TXT`, `EMPLOYEES.TXT`, etc.) are expected one directory level above the executable (`../`), matching the `ASSIGN TO` paths in each program.
