# Script 70: Install WordPress on Windows

## Overview
Automates WordPress CMS deployment with MySQL, PHP, and Nginx integration on Windows.

## Verbs
- `.\run.ps1 install wordpress` or `.\run.ps1 -I 70` -- Install WordPress stack
- `.\run.ps1 -I 70 check` -- Verify wp-config.php and database configuration
- `.\run.ps1 -I 70 repair` -- Re-download and re-generate configuration
- `.\run.ps1 -I 70 uninstall` -- Clean up WordPress files and credential records

## Credentials
Generated credentials are saved to `.installed/70-wordpress-credentials.json`.
