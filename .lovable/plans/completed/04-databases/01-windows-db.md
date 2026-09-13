# Subtask: Windows Databases & GUI Clients Implementation

## Objective
Add PostgreSQL, MongoDB, and associated GUI clients (DBeaver, Compass, pgAdmin) to the Windows installer script (`run.ps1` / `scoop.ps1`).

## Tasks

1. **Update `scoop.ps1` (or create database install functions):**
   - Add a function/block to install PostgreSQL (e.g., `scoop install postgresql`).
   - Add a function/block to install MongoDB (e.g., `scoop install mongodb`).
   - Add functions to install DBeaver, MongoDB Compass, and pgAdmin. Note that some GUI clients might require `scoop bucket add extras` or similar.

2. **Integrate into `run.ps1` Database Menu:**
   - Create or update the Database menu in `run.ps1`.
   - Add options for:
     - 1) PostgreSQL
     - 2) MongoDB
     - 3) DBeaver
     - 4) MongoDB Compass
     - 5) pgAdmin
   - Ensure idempotency checks (e.g., `if (Get-Command psql -ErrorAction SilentlyContinue)`).
   
3. **Environment & Services:**
   - Configure PostgreSQL and MongoDB to start automatically or register as Windows services if installed via Scoop.
   - Verify `PATH` inclusion for `psql` and `mongosh`.

## Relevant Files
- `run.ps1`
- `scoop.ps1`
