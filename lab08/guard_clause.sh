#!/bin/bash

FILE=$1

if [ -z "$FILE" ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "$FILE: not a regular file" >&2
    exit 2
elif [ ! -r "$FILE" ]; then
    echo "$FILE: not readable" >&2
    exit 3
elif [ ! -s "$FILE" ]; then
    echo "$FILE: empty file" >&2
    exit 4
else
    echo "$FILE is a readable, non-empty file — proceeding."
fi
