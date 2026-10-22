#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 <logfile>" >&2
    exit 1
fi
LOGFILE=$1
if [ ! -f "$LOGFILE" ]; then
    echo "Error: file not found" >&2
    exit 2
fi
FAILED=$(grep -c "Failed password" "$LOGFILE")
echo "Total failed logins: $FAILED"
TOP_IP=$(grep "Failed password" "$LOGFILE" | awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
echo "Top attacker: $TOP_IP"
echo "Top 3 attackers:"
./top3.sh "$LOGFILE"
echo "Top 3 targeted usernames:"
grep "Failed password" "$LOGFILE" | awk '{for(i=1;i<=NF;i++) if($i=="for") print $(i+1)}' | sort | uniq -c | sort -nr | head -n 3
exit 0
