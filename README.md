# AI Estate — Disaster Recovery Project
## Owner: Haya

***This project provides backup and restore automation for the AI Estate database (Postgres + pgvector). It includes scripts, documentation, and logs required for DR validation.***
---

**FILES**
- backup_ai_estate.sh
- restore_test.sh
- dr-asset-register.yaml
- dr-runbook.md
- DR-PLAN.txt
- agent-log.txt
- restore-test.log
- init.sql
- README.txt

**HOW TO BACK UP**
./backup_ai_estate.sh
Backups saved in ./backups/<timestamp>/ and copied to /mnt/backup2/.

**HOW TO RESTORE**
Start DB:
docker-compose up -d
Run restore test:
./restore_test.sh | tee restore-test.log

**SUCCESS INDICATOR**

=== Restore Test Completed Successfully ===

RPO: 24 hours  
RTO: 10–15 minutes

Status: DR system fully operational.
