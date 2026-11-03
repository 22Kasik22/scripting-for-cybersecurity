#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <logfile> <ip_or_username>" >&2
    exit 1
fi

LOGFILE=$1
TERM_ARG=$2

if [ ! -e "$LOGFILE" ]; then
    echo "Error: '$LOGFILE' does not exist" >&2
    exit 2
fi

if [ ! -f "$LOGFILE" ]; then
    echo "Error: '$LOGFILE' is not a regular file" >&2
    exit 3
fi

if [ ! -r "$LOGFILE" ]; then
    echo "Error: '$LOGFILE' is not readable" >&2
    exit 4
fi

if [ -z "$TERM_ARG" ]; then
    echo "Error: empty search term" >&2
    exit 5
fi

if echo "$TERM_ARG" | grep -Eq '^[0-9]+(\.[0-9]+){3}$'; then
    COUNT=$(grep -cwF "$TERM_ARG" "$LOGFILE")
    FAILED=$(grep "Failed password" "$LOGFILE" | grep -cwF "$TERM_ARG")

    echo "IP address: $TERM_ARG"
    echo "Occurrences: $COUNT"
    echo "Failed logins: $FAILED"

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

    if grep -qwF "$TERM_ARG" case/logs/firewall.log; then
        echo "Firewall entries:"
        grep -wF "$TERM_ARG" case/logs/firewall.log
    else
        echo "No firewall entries for $TERM_ARG"
    fi

    if grep -qxF "$TERM_ARG" intel/iocs.txt; then
        echo "$TERM_ARG is in the IOC list"
    else
        echo "$TERM_ARG is not in the IOC list"
    fi

    if [ "$COUNT" -gt 0 ]; then
        exit 0
    else
        exit 6
    fi
else
    FAILED=$(grep -c "Failed password for $TERM_ARG " "$LOGFILE")
    ACCEPTED=$(grep -c "Accepted password for $TERM_ARG " "$LOGFILE")

    echo "Username: $TERM_ARG"
    echo "Failed logins: $FAILED"
    echo "Accepted logins: $ACCEPTED"

    if grep -q "^$TERM_ARG," intel/users.csv; then
        echo "$TERM_ARG: CURRENT account"
    elif grep -qx "$TERM_ARG" case/backups/users.old; then
        echo "$TERM_ARG: LEGACY account"
    else
        echo "$TERM_ARG: UNKNOWN account"
    fi

    if [ "$FAILED" -gt 0 ] || [ "$ACCEPTED" -gt 0 ]; then
        exit 0
    else
        exit 6
    fi
fi
