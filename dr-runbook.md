# Disaster Recovery Runbook
Project: project11-sa
Owner: Haya
Environment: practice-lab

------------------------------------------------------------
1. Purpose
------------------------------------------------------------
This runbook provides the exact operational steps to recover the AI Estate after a disaster.
It restores:
- PostgreSQL + pgvector
- documents (irreplaceable)
- embeddings (irreplaceable)
- HNSW index (reproducible)
- Database schema
- Docker environment

This runbook has been validated by restore_test.sh and restore-test.log.

------------------------------------------------------------
2. Preconditions
------------------------------------------------------------
Before starting recovery, ensure:
- Access to GitHub repo: Hayaaaz/project11-sa
- Access to backup folder: ./backups/<timestamp>/
- Docker + docker-compose installed
- Postgres container name: ai_estate_db
- Human sign-off is granted before running restore commands

------------------------------------------------------------
3. Recovery Objectives (RPO/RTO)
------------------------------------------------------------
These values match actual restore timing and DR-PLAN:

RPO: 24 hours (daily backup)
RTO: 10–15 minutes (measured via restore-test.sh)

------------------------------------------------------------
4. Recovery Steps
------------------------------------------------------------

------------------------------------------------------------
4.1 Restore Project Files (Reproducible Assets)
------------------------------------------------------------

Step 1 — Clone repository
git clone https://github.com/Hayaaaz/project11-sa
cd project11-sa

Step 2 — Verify required files
- backup_ai_estate.sh
- restore_test.sh
- init.sql
- dr-asset-register.yaml
- dr-runbook.md
- documents.sql (from backup folder)
- embeddings.sql (from backup folder)

If missing, restore from GitHub history.

------------------------------------------------------------
4.2 Restore Database (Irreplaceable Assets)
------------------------------------------------------------

If the database volume is corrupted or missing, perform a full rebuild.

------------------------------------------------------------
4.3 Full Rebuild (Schema + Empty DB)
------------------------------------------------------------

Step 1 — Stop existing stack
docker-compose down
sudo rm -rf db_data

Step 2 — Start fresh Postgres + pgvector
docker-compose up -d

Step 3 — Apply schema
docker cp init.sql ai_estate_db:/init.sql
docker exec -it ai_estate_db psql -U aiuser -d aidev -f /init.sql

Expected output:
CREATE EXTENSION
CREATE TABLE
CREATE TABLE
CREATE INDEX

------------------------------------------------------------
4.4 Restore Irreplaceable Assets (documents + embeddings)
------------------------------------------------------------

Step 1 — Restore documents
docker exec -i ai_estate_db psql -U aiuser -d aidev < backups/<timestamp>/documents.sql

Step 2 — Restore embeddings
docker exec -i ai_estate_db psql -U aiuser -d aidev < backups/<timestamp>/embeddings.sql

If embeddings.sql is missing:
→ embeddings must be recomputed using your embedding model.

------------------------------------------------------------
4.5 Rebuild HNSW Index (Reproducible Asset)
------------------------------------------------------------

Step 1 — Rebuild index
docker exec -it ai_estate_db psql -U aiuser -d aidev -c "
DROP INDEX IF EXISTS embeddings_hnsw_idx;
CREATE INDEX embeddings_hnsw_idx ON embeddings USING hnsw (embedding vector_l2_ops);
"

Expected:
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
4.7 Restart Services
------------------------------------------------------------

docker-compose down
docker-compose up -d
docker ps

Expected:
ai_estate_db   Up

------------------------------------------------------------
5. Completion Checklist
------------------------------------------------------------

[ ] Schema applied
[ ] documents.sql restored
[ ] embeddings.sql restored
[ ] HNSW index rebuilt
[ ] Vector search validated
[ ] Docker stack running
[ ] DR artifacts verified
[ ] Human sign-off completed

------------------------------------------------------------
6. Notes
------------------------------------------------------------

- documents.sql + embeddings.sql = irreplaceable
- HNSW index = reproducible
- Schema + code = reproducible (GitHub)
- Restore process validated by restore_test.sh
- This runbook follows Chapter 11’s “human stays in the loop” rule
