
#!/bin/bash

# Case folder and report name
CASE_DIR="case"
REPORT="triage-report-auto.txt"

# Ask the user for information
read -p "Enter analyst name: " ANALYST
read -p "Enter case reference: " CASE_REF

# Count files and directories
TOTAL_FILES=$(find "$CASE_DIR" -type f | wc -l)
TOTAL_DIRS=$(find "$CASE_DIR" -type d | wc -l)

# Count different file types
PYTHON=$(find "$CASE_DIR" -type f -name "*.py" | wc -l)
SHELL=$(find "$CASE_DIR" -type f -name "*.sh" | wc -l)
LOGS=$(find "$CASE_DIR" -type f -name "*.log" | wc -l)
CONFIG=$(find "$CASE_DIR" -type f \( -name "*.conf" -o -name "*.cfg" -o -name "*.ini" \) | wc -l)
EMPTY=$(find "$CASE_DIR" -type f -empty | wc -l)
ARCHIVES=$(find "$CASE_DIR" -type f \( -name "*.zip" -o -name "*.tar" -o -name "*.gz" \) | wc -l)

# Add Python and shell scripts
SCRIPTS=$((PYTHON + SHELL))

# Create report header
echo "===== TRIAGE REPORT =====" > "$REPORT"
echo "Analyst: $ANALYST" >> "$REPORT"
echo "Case Reference: $CASE_REF" >> "$REPORT"
echo "Date: $(date)" >> "$REPORT"
echo "=========================" >> "$REPORT"

# Add file counts
echo "Total Files: $TOTAL_FILES" >> "$REPORT"
echo "Total Directories: $TOTAL_DIRS" >> "$REPORT"
echo "Python Files: $PYTHON" >> "$REPORT"
echo "Shell Scripts: $SHELL" >> "$REPORT"
echo "Log Files: $LOGS" >> "$REPORT"
echo "Configuration Files: $CONFIG" >> "$REPORT"
echo "Empty Files: $EMPTY" >> "$REPORT"
echo "Archives: $ARCHIVES" >> "$REPORT"

# Find files containing admin
echo "" >> "$REPORT"
echo "Files containing admin:" >> "$REPORT"
grep -rl "admin" "$CASE_DIR" >> "$REPORT"

# Show evidence file types
echo "" >> "$REPORT"
echo "Evidence file types:" >> "$REPORT"
find "$CASE_DIR/evidence" -type f -exec file {} \; >> "$REPORT"

# Show total scripts
echo "" >> "$REPORT"
echo "Scripts (Python + shell): $SCRIPTS" >> "$REPORT"

echo "Report created: $REPORT"
