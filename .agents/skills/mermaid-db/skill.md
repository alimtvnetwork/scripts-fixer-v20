---
name: mermaid-db
description: >-
  Generate Mermaid ER diagrams (erDiagram) from any SQLite database schema with entities and relationships using 'gitmap mermaid db', and synchronize SQLite database schema from a Mermaid ER diagram (.mermaid / .marmaid) file using 'gitmap sync-db mermaid'.
---

# Mermaid Database Visualization & Schema Synchronization

## Overview
This skill governs bidirectional schema interoperability between SQLite databases and Mermaid ER diagrams (`erDiagram`).

## 1. Generating Mermaid ER Diagrams (`gitmap mermaid db`)
Extract entities, attributes, primary keys, and foreign key relationships into Mermaid Markdown format:

```bash
# Generate Mermaid ER diagram for conversation_summaries.db
gitmap mermaid db agy

# Export master database schema to a .mermaid file
gitmap mermaid db master -o schema.mermaid

# Generate Mermaid diagram for custom database path
gitmap mermaid db path/to/app.db
```

## 2. Synchronizing Database Schema (`gitmap sync-db mermaid`)
Parse `.mermaid` or `.marmaid` files and automatically generate and apply `CREATE TABLE IF NOT EXISTS` DDL statements:

```bash
# Synchronize database schema from .marmaid file
gitmap sync-db mermaid .marmaid

# Preview generated SQL DDL statements without modifying database
gitmap sync-db schema.mermaid --db agy --dry-run

# Synchronize directly to master database
gitmap sync-db models.mmd --db master
```

## 3. Native MCP Server Tools
- `gitmap_mermaid_db`: Generate Mermaid ER diagrams from database alias or path.
- `gitmap_sync_db_mermaid`: Apply Mermaid schema to database or preview DDL.
