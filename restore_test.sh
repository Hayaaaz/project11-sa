#!/bin/bash
set -uo pipefail
# ------------------------------------------------------------
# Restore Test Script for AI Estate
# Project: project11-sa
# Owner: Haya
# ------------------------------------------------------------

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
LOGFILE="restore-test.log"

echo "=== Starting Restore Test at $TIMESTAMP ===" | tee "$LOGFILE"

# ------------------------------------------------------------
# 1. Stop running stack
# ------------------------------------------------------------
echo "[1] Stopping docker stack..." | tee -a "$LOGFILE"
docker stop ai_estate_db | tee -a "$LOGFILE"
docker rm ai_estate_db | tee -a "$LOGFILE"


# ------------------------------------------------------------
# 2. Remove old database volume
# ------------------------------------------------------------
echo "[2] Removing old db_data volume..." | tee -a "$LOGFILE"
docker volume rm project11-sa_db_data | tee -a "$LOGFILE"

# ------------------------------------------------------------
# 3. Start fresh database
# ------------------------------------------------------------
echo "[3] Starting fresh Postgres + pgvector..." | tee -a "$LOGFILE"
docker-compose up -d | tee -a "$LOGFILE"
sleep 5


# ------------------------------------------------------------
# 4. Apply schema
# ------------------------------------------------------------
echo "[4] Applying schema..." | tee -a "$LOGFILE"
docker cp init.sql ai_estate_db:/init.sql
docker exec ai_estate_db psql -U aiuser -d aidev -f /init.sql | tee -a "$LOGFILE"

# ------------------------------------------------------------
# 5. Restore irreplaceable assets
# ------------------------------------------------------------
echo "[5] Restoring irreplaceable assets..." | tee -a "$LOGFILE"

LATEST_BACKUP=$(ls -td backups/* | head -1)
DOCS="$LATEST_BACKUP/irreplaceable/documents.sql"
EMBS="$LATEST_BACKUP/irreplaceable/embeddings.sql"

docker exec -i ai_estate_db psql -U aiuser -d aidev < "$DOCS" | tee -a "$LOGFILE"
docker exec -i ai_estate_db psql -U aiuser -d aidev < "$EMBS" | tee -a "$LOGFILE"

# ------------------------------------------------------------
# 6. Rebuild HNSW index (derived)
# ------------------------------------------------------------
echo "[6] Rebuilding HNSW index..." | tee -a "$LOGFILE"
docker exec ai_estate_db psql -U aiuser -d aidev -c "
DROP INDEX IF EXISTS embeddings_hnsw_idx;
CREATE INDEX embeddings_hnsw_idx ON embeddings USING hnsw (embedding vector_l2_ops);
" | tee -a "$LOGFILE"

# ------------------------------------------------------------
# 7. Validate restore
# ------------------------------------------------------------
echo "[7] Validating restore..." | tee -a "$LOGFILE"

echo "Documents count:" | tee -a "$LOGFILE"
docker exec ai_estate_db psql -U aiuser -d aidev -c "SELECT COUNT(*) FROM documents;" | tee -a "$LOGFILE"

echo "Embeddings count:" | tee -a "$LOGFILE"
docker exec ai_estate_db psql -U aiuser -d aidev -c "SELECT COUNT(*) FROM embeddings;" | tee -a "$LOGFILE"

echo "Vector search test:" | tee -a "$LOGFILE"
docker exec ai_estate_db psql -U aiuser -d aidev -c "
SELECT id, document_id FROM embeddings
ORDER BY embedding <-> '[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]'
LIMIT 3;
" | tee -a "$LOGFILE"

# ------------------------------------------------------------
# 8. Completion
# ------------------------------------------------------------
# ------------------------------------------------------------
# 8. Completion
# ------------------------------------------------------------
echo "=== Restore Test Completed Successfully ===" | tee -a "$LOGFILE"
