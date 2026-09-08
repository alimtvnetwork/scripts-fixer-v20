# Plan 04: Local Databases & GUI Clients

## Objective
Implement installation options for local databases (PostgreSQL, MongoDB) and corresponding GUI clients (DBeaver, MongoDB Compass, pgAdmin) across Windows and Ubuntu.

## Custom Rules & Constraints
1. **Idempotency**: All installation scripts must verify if the target software (PostgreSQL, MongoDB, or GUI clients) is already installed before attempting installation to avoid duplicates or overwriting configurations.
2. **Path Variables & Environment**: All installers must properly add executable paths (e.g., `psql`, `mongosh`) to the user's system `PATH` and ensure any related services are enabled to start on boot or available upon request.
3. **Modularity**: For Windows (`run.ps1`), database installers should be separate modular functions/scripts that can be invoked individually from a central databases menu, matching the structure used in `scripts/os/ubuntu/install-databases-menu.sh`.
4. **GUI Pairing**: When a user selects a database to install, prompt optionally to install its common GUI client (e.g., pgAdmin or DBeaver for PostgreSQL, MongoDB Compass for MongoDB).
5. **Links**: Use strictly relative paths from the repository root when linking to other scripts (e.g., `scripts/os/ubuntu/install-dbeaver.sh`).

## Subtasks
- [01-windows-db.md](../subtasks/04-databases/01-windows-db.md) - Windows implementation (`run.ps1` and Scoop extensions)
- [02-ubuntu-db.md](../subtasks/04-databases/02-ubuntu-db.md) - Ubuntu implementation (`scripts/os/ubuntu/*.sh`)
