# Subtask: Ubuntu Databases & GUI Clients Implementation

## Objective
Enhance the existing `scripts/os/ubuntu/install-databases-menu.sh` and add missing scripts to support PostgreSQL, MongoDB, and associated GUI clients (DBeaver, Compass, pgAdmin).

## Tasks

1. **Enhance `scripts/os/ubuntu/install-databases-menu.sh`:**
   - Update the existing menu to include GUI clients options (DBeaver, MongoDB Compass, pgAdmin).
   - Ensure the menu uses other scripts for installation to keep it modular (e.g., calling `./install-postgres.sh`), or properly implements idempotency directly inside the menu script.

2. **Create/Update Installation Scripts:**
   - Modify `scripts/os/ubuntu/install-databases-menu.sh` for PostgreSQL and MongoDB to include checking if `psql` or `mongod` is installed before attempting installation.
   - Create `scripts/os/ubuntu/install-mongodb-compass.sh` to download and install the Compass `.deb` package.
   - Create `scripts/os/ubuntu/install-pgadmin.sh` to install pgAdmin 4.
   - Update `scripts/os/ubuntu/install-dbeaver.sh` if it's not fully functional (currently seems to be 41 bytes long, needs expansion to actually install DBeaver).

3. **Services and Paths:**
   - Ensure `systemctl enable --now postgresql` and `systemctl enable --now mongod` are run after installation.
   - For GUI clients, ensure `.desktop` files are properly created so they appear in the application launcher.

## Relevant Files
- `scripts/os/ubuntu/install-databases-menu.sh`
- `scripts/os/ubuntu/install-dbeaver.sh`
- `scripts/os/ubuntu/install-mongodb-compass.sh` (new)
- `scripts/os/ubuntu/install-pgadmin.sh` (new)
