#!/bin/bash

read -p "Enter a username to look up: " TARGET_USER
read -p "Enter a department: " TARGET_DEPT

echo "Searching for username: $TARGET_USER"
grep "$TARGET_USER" intel/users.csv | grep "$TARGET_DEPT"
