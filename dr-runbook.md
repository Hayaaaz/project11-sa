# Disaster Recovery Runbook
Project: project11-sa
Owner: Haya
Environment: practice-lab

------------------------------------------------------------
1. Purpose
------------------------------------------------------------
This runbook provides the exact operational steps to recover the AI estate after a disaster.
It restores:
- PostgreSQL + pgvector database
- Documents
- Embeddings
- HNSW index
- Application environment
- Docker services

------------------------------------------------------------
2. Preconditions
------------------------------------------------------------
Before starting recovery, ensure:
- You have access to GitHub repo: Hayaaaz/project11-sa
- You have access to the backup volume snapshot (db_data)
- Docker and docker-compose are installed
- You can authenticate to GitHub

------------------------------------------------------------
3. Recovery Objectives
------------------------------------------------------------
RPO: 1 hour (database)
RTO: 30 minutes (database)
RPO: 24 hours (source code)
RTO: 4 hours (application)

------------------------------------------------------------
4. Recovery Steps
------------------------------------------------------------

4.1 Restore Source Code (Reproducible)

Step 1 — Clone the repository
git clone https://github.com/Hayaaaz/project11-sa
cd project11-sa

Step 2 — Verify required files exist
docker-compose.yml
init.sql
seed_data.sql
dr-asset-register.yaml
dr-runbook.md

If any are missing, restore from GitHub history.

------------------------------------------------------------
4.2 Restore Database (Irreplaceable)
------------------------------------------------------------

Step 1 — Restore the Docker volume snapshot
If you have a backup of db_data, restore it:

docker volume rm project11-sa_db_data
docker volume create project11-sa_db_data
(restore snapshot into this volume using your backup system)

If no snapshot exists, proceed with full rebuild.

------------------------------------------------------------
4.3 Full Rebuild (Reproducible + Derived)
------------------------------------------------------------

If the database volume is lost, rebuild from scratch.

Step 1 — Start fresh Postgres + pgvector
docker-compose down
sudo rm -rf db_data
docker-compose up -d

Step 2 — Apply schema
docker cp init.sql ai_estate_db:/init.sql
docker exec -it ai_estate_db psql -U aiuser -d aidev -f /init.sql

Expected output:
CREATE EXTENSION
CREATE TABLE
CREATE TABLE
CREATE INDEX

Step 3 — Apply seed data
docker cp seed_data.sql ai_estate_db:/seed_data.sql
docker exec -it ai_estate_db psql -U aiuser -d aidev -f /seed_data.sql

Expected output:
INSERT 0 3
INSERT 0 3

------------------------------------------------------------
4.4 Restore Embeddings (Irreplaceable)
------------------------------------------------------------

If embeddings were backed up:

Step 1 — Import embeddings dump
docker exec -i ai_estate_db psql -U aiuser -d aidev < embeddings_backup.sql

If no backup exists:
Embeddings must be recomputed from original documents using your embedding model.

------------------------------------------------------------
4.5 Restore HNSW Index (Derived)
------------------------------------------------------------

If the index is missing or corrupted:

Step 1 — Rebuild index
docker exec -it ai_estate_db psql -U aiuser -d aidev -c "
DROP INDEX IF EXISTS embeddings_hnsw_idx;
CREATE INDEX embeddings_hnsw_idx ON embeddings USING hnsw (embedding vector_l2_ops);
"

Expected output:
DROP INDEX
CREATE INDEX

------------------------------------------------------------
4.6 Validate Recovery
------------------------------------------------------------

Step 1 — Check documents
docker exec -it ai_estate_db psql -U aiuser -d aidev -c "SELECT COUNT(*) FROM documents;"

Step 2 — Check embeddings
docker exec -it ai_estate_db psql -U aiuser -d aidev -c "SELECT COUNT(*) FROM embeddings;"

Step 3 — Test vector search
docker exec -it ai_estate_db psql -U aiuser -d aidev -c "
SELECT id, document_id FROM embeddings
ORDER BY embedding <-> '[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]'
LIMIT 3;
"

------------------------------------------------------------
4.7 Restore Application Services
------------------------------------------------------------

Step 1 — Restart Docker stack
docker-compose down
docker-compose up -d

Step 2 — Verify container health
docker ps

Expected:
ai_estate_db   Up

------------------------------------------------------------
5. Completion Checklist
------------------------------------------------------------

[ ] Database restored or rebuilt
[ ] Embeddings restored or regenerated
[ ] HNSW index rebuilt
[ ] Application running
[ ] Vector search validated
[ ] GitHub repo intact
[ ] DR asset register updated

------------------------------------------------------------
6. Notes
------------------------------------------------------------

- HNSW index is derived → never backed up
- Embeddings + documents are irreplaceable → must be backed up
- Schema + code are reproducible → stored in GitHub
- Docker volume is the most critical asset

# End of Runbook
