#!/bin/bash

FILES=0
FLAGGED=0
TOTAL_IOC=0

for FILE in case/evidence/* case/scripts/* case/logs/*; do
    [ -f "$FILE" ] || continue

    FILES=$((FILES + 1))
    SIZE=$(wc -c < "$FILE")
    TYPE=$(file -b "$FILE")

    echo "File: $FILE"
    echo "Size: $SIZE bytes"
    echo "Type: $TYPE"

    if [[ "$TYPE" == *text* ]]; then
        LINES=$(wc -l < "$FILE")
        echo "Lines: $LINES"
    fi

    sha256sum "$FILE"

    if [[ "$FILE" == *.png ]]; then
        EXPECT="PNG"
    elif [[ "$FILE" == *.zip ]]; then
        EXPECT="Zip"
    elif [[ "$FILE" == *.txt || "$FILE" == *.md ]]; then
        EXPECT="text"
    elif [[ "$FILE" == *.bin ]]; then
        EXPECT="empty"
    elif [[ "$FILE" == *.dat ]]; then
        EXPECT="data"
    elif [[ "$FILE" == *.sh ]]; then
        EXPECT="shell script"
    elif [[ "$FILE" == *.py ]]; then
        EXPECT="Python"
    elif [[ "$FILE" == *.log ]]; then
        EXPECT="text"
    else
        EXPECT=""
    fi

    if [ -z "$EXPECT" ]; then
        echo "?? No expectation for this extension"
    elif [[ "$TYPE" == *"$EXPECT"* ]]; then
        echo "OK: file type matches"
    else
        echo "!! Expected $EXPECT, detected: $TYPE"
        FLAGGED=$((FLAGGED + 1))
    fi

    if [[ "$FILE" == *.log ]]; then
        IOC_COUNT=0

        for INDICATOR in $(cat intel/iocs.txt); do
            if grep -qwF "$INDICATOR" "$FILE"; then
                IOC_COUNT=$((IOC_COUNT + 1))
            fi
        done

        echo "IOC matches: $IOC_COUNT"
        TOTAL_IOC=$((TOTAL_IOC + IOC_COUNT))
    fi

    echo ""
done

echo "Files surveyed: $FILES"
echo "Files flagged: $FLAGGED"
echo "Total IOC matches: $TOTAL_IOC"
