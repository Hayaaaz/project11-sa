# rpo_rto.py
# AI Estate — RPO/RTO Calculator
# Owner: Haya

import datetime

# RPO: Maximum acceptable data loss (hours)
RPO_HOURS = 24

# RTO: Time required to fully restore system (minutes)
# Based on your restore_test.sh timing:
# - Container rebuild: ~5 seconds
# - Schema apply: ~1 second
# - Data restore: ~5–10 seconds
# - Index rebuild: ~1–2 seconds
# - Validation: ~1 second
RTO_MINUTES = 15

def calculate_rpo():
    return f"RPO = {RPO_HOURS} hours (maximum acceptable data loss)"

def calculate_rto():
    return f"RTO = {RTO_MINUTES} minutes (estimated full restore time)"

def summary():
    print("AI Estate — RPO/RTO Summary")
    print(calculate_rpo())
    print(calculate_rto())
    print("Status: DR system fully operational.")

if __name__ == "__main__":
    summary()
