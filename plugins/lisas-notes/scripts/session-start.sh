#!/bin/bash
# Lisa's Notes Plugin - Create new jj commit on session start

# Log file for debugging
LOG_FILE="/tmp/lisas-notes-debug.log"

echo "=== Lisa's Notes SessionStart Hook $(date) ===" >> "$LOG_FILE"

# Read hook input from stdin
hook_input=$(cat)

echo "Hook input: $hook_input" >> "$LOG_FILE"

# Extract the cwd from the JSON input
cwd=$(echo "$hook_input" | jq -r '.cwd // empty' 2>/dev/null)

echo "Working directory: $cwd" >> "$LOG_FILE"

if [ -z "$cwd" ]; then
    echo "No working directory found, exiting" >> "$LOG_FILE"
    exit 0
fi

# Create a new empty commit for the upcoming work
echo "Running: jj new in $cwd" >> "$LOG_FILE"
cd "$cwd" && jj new >> "$LOG_FILE" 2>&1 || echo "jj new failed with exit code $?" >> "$LOG_FILE"

echo "=== Lisa's Notes SessionStart Hook Finished ===" >> "$LOG_FILE"

exit 0
