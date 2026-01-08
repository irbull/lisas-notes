#!/bin/bash
# Lisa's Notes Plugin - Create new jj commit on prompt submit if current commit has work

# Log file for debugging
LOG_FILE="/tmp/lisas-notes-debug.log"

echo "=== Lisa's Notes UserPromptSubmit Hook $(date) ===" >> "$LOG_FILE"

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

# Check if current commit is truly empty (no changes AND no description)
is_truly_empty=$(cd "$cwd" && jj log -r @ --no-graph -T 'if(empty && !description, "true", "false")')

echo "Is current commit truly empty: $is_truly_empty" >> "$LOG_FILE"

if [ "$is_truly_empty" = "false" ]; then
    # Current commit has work (changes or description), create a new one
    echo "Running: jj new in $cwd" >> "$LOG_FILE"
    cd "$cwd" && jj new >> "$LOG_FILE" 2>&1 || echo "jj new failed with exit code $?" >> "$LOG_FILE"
else
    echo "Current commit is empty, skipping jj new" >> "$LOG_FILE"
fi

echo "=== Lisa's Notes UserPromptSubmit Hook Finished ===" >> "$LOG_FILE"

exit 0
