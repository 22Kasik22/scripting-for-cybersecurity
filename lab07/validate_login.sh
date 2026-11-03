#!/bin/bash

read -p "Enter a username: " USERNAME

if [ -z "$USERNAME" ]; then
    echo "Error: no username entered" >&2
    exit 1
fi

if grep -q "^$USERNAME," intel/users.csv; then
    DETAILS=$(grep "^$USERNAME," intel/users.csv)
    ROLE=$(echo "$DETAILS" | cut -d',' -f2)
    STATUS=$(echo "$DETAILS" | cut -d',' -f3)
    echo "$USERNAME: CURRENT account"
    echo "Role: $ROLE"
    echo "Status: $STATUS"
    EXIT_CODE=0
elif grep -qx "$USERNAME" case/backups/users.old; then
    echo "$USERNAME: LEGACY account (only in the old backup list)"
    EXIT_CODE=2
else
    echo "$USERNAME: UNKNOWN account (in neither list)"
    EXIT_CODE=3
fi

FAILED=$(grep -c "Failed password for $USERNAME " case/logs/auth.log)
ACCEPTED=$(grep -c "Accepted password for $USERNAME " case/logs/auth.log)

echo "Failed logins: $FAILED"
echo "Accepted logins: $ACCEPTED"

if [ "$FAILED" -eq 0 ]; then
    echo "Risk: NONE (no failed attempts)"
elif [ "$FAILED" -lt 5 ]; then
    echo "Risk: LOW ($FAILED failed attempts)"
elif [ "$FAILED" -lt 15 ]; then
    echo "Risk: MEDIUM ($FAILED failed attempts)"
elif [ "$FAILED" -ge 30 ]; then
    echo "Risk: CRITICAL ($FAILED failed attempts)"
else
    echo "Risk: HIGH ($FAILED failed attempts)"
fi

if [ "$EXIT_CODE" -eq 0 ] && [ "$STATUS" = "disabled" ] && [ "$ACCEPTED" -gt 0 ]; then
    echo "WARNING: disabled account has accepted logins"
fi

if [ "$EXIT_CODE" -ne 0 ] && [ "$FAILED" -gt 0 ]; then
    echo "WARNING: attacker tried a legacy or unknown username"
fi

if [ "$EXIT_CODE" -eq 0 ] && [ "$ACCEPTED" -gt 0 ]; then
    if grep -q "^$USERNAME:" case/evidence/passwords.txt; then
        echo "WARNING: current account has accepted logins and exposed plaintext credentials"
    fi
fi

exit "$EXIT_CODE"
