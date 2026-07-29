#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------
# Backup Script for AI Estate
# Project: project11-sa
# Owner: Haya
# ------------------------------------------------------------

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_ROOT="./backups/$TIMESTAMP"
IRREPLACEABLE="$BACKUP_ROOT/irreplaceable"
REPRODUCIBLE="$BACKUP_ROOT/reproducible"
CHECKSUMS="$BACKUP_ROOT/checksums"

mkdir -p "$IRREPLACEABLE" "$REPRODUCIBLE" "$CHECKSUMS"

echo "=== Starting Backup at $TIMESTAMP ==="

# ------------------------------------------------------------
# 1. Backup Irreplaceable Assets
# ------------------------------------------------------------
# These MUST be backed up:
# - documents table
# - embeddings table
# - vector DB source data

echo "Backing up irreplaceable assets..."

docker exec ai_estate_db pg_dump -U aiuser -d aidev -t documents > "$IRREPLACEABLE/documents.sql"
docker exec ai_estate_db pg_dump -U aiuser -d aidev -t embeddings > "$IRREPLACEABLE/embeddings.sql"

# ------------------------------------------------------------
# 2. DO NOT BACK UP REPRODUCIBLE ASSETS
# ------------------------------------------------------------
# These must NOT be backed up:
# - HNSW index (derived)
# - base model checkpoint (pinned by digest)
# - schema (stored in GitHub)
# - docker-compose.yml (stored in GitHub)

echo "Skipping reproducible assets (per DR policy)."

# ------------------------------------------------------------
# 3. Generate Checksums
# ------------------------------------------------------------

echo "Generating checksums..."

sha256sum "$IRREPLACEABLE/documents.sql" > "$CHECKSUMS/documents.sha256"
sha256sum "$IRREPLACEABLE/embeddings.sql" > "$CHECKSUMS/embeddings.sha256"

# ------------------------------------------------------------
# 4. 3-2-1 Backup Strategy
# ------------------------------------------------------------
# 3 copies:
#   - local copy (already created)
#   - secondary local media (copy to /mnt/backup2)
#   - offsite immutable bucket (MinIO / S3 with object lock)
#
# 2 media:
#   - local disk
#   - mounted backup disk (/mnt/backup2)
#
# 1 offsite:
#   - object-locked bucket

echo "Applying 3-2-1 backup strategy..."

# Copy to second local media
mkdir -p /mnt/backup2/$TIMESTAMP
cp -r "$BACKUP_ROOT" /mnt/backup2/$TIMESTAMP/

# Upload to immutable bucket (MinIO or AWS S3)
# NOTE: Replace 'mybucket' with your bucket name.
# Object lock must be enabled in Governance or Compliance mode.

# mc cp -r "$BACKUP_ROOT" myminio/mybucket/$TIMESTAMP/

echo "Backup completed successfully."
echo "Backup location: $BACKUP_ROOT"
