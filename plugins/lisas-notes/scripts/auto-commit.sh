#!/bin/bash
# Lisa's Notes Plugin - Auto-commit with jj using Claude's last message

# Log file for debugging
LOG_FILE="/tmp/lisas-notes-debug.log"

echo "=== Lisa's Notes Hook Started $(date) ===" >> "$LOG_FILE"

# Read hook input from stdin (entire input, not just one line)
hook_input=$(cat)

echo "Hook input: $hook_input" >> "$LOG_FILE"

# Extract the transcript path and cwd from the JSON input
transcript_path=$(echo "$hook_input" | jq -r '.transcript_path // empty' 2>/dev/null)
cwd=$(echo "$hook_input" | jq -r '.cwd // empty' 2>/dev/null)

echo "Transcript path: $transcript_path" >> "$LOG_FILE"
echo "Working directory: $cwd" >> "$LOG_FILE"

if [ -z "$transcript_path" ]; then
    echo "No transcript path found, exiting" >> "$LOG_FILE"
    exit 0
fi

if [ ! -f "$transcript_path" ]; then
    echo "Transcript file does not exist: $transcript_path" >> "$LOG_FILE"
    exit 0
fi

echo "Transcript file exists, reading..." >> "$LOG_FILE"

# Find the last assistant message with text content
# The transcript format has .type == "assistant" at top level
# and the actual content is in .message.content[]
last_message=""

# Read the transcript and find the last assistant message's full text
while IFS= read -r line || [ -n "$line" ]; do
    msg_type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)
    if [ "$msg_type" = "assistant" ]; then
        # Extract text content from .message.content[]
        text=$(echo "$line" | jq -r '
            if .message.content then
                [.message.content[] | select(.type == "text") | .text] | join("\n")
            else
                empty
            end
        ' 2>/dev/null)

        if [ -n "$text" ]; then
            # Keep the full message text (trimmed of leading/trailing whitespace)
            trimmed=$(echo "$text" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            if [ -n "$trimmed" ]; then
                last_message="$trimmed"
                echo "Found assistant message (${#trimmed} chars)" >> "$LOG_FILE"
            fi
        fi
    fi
done < "$transcript_path"

echo "Last message length: ${#last_message} chars" >> "$LOG_FILE"

# Check if current commit has any file changes
is_empty=$(cd "$cwd" && jj log -r @ --no-graph -T 'empty')

echo "Is current commit empty (no file changes): $is_empty" >> "$LOG_FILE"

# If we found a message and there are actual file changes, commit
if [ "$is_empty" = "true" ]; then
    echo "No file changes, skipping commit" >> "$LOG_FILE"
elif [ -n "$last_message" ]; then
    echo "Running: jj commit in $cwd" >> "$LOG_FILE"
    cd "$cwd" && jj commit -m "$last_message" >> "$LOG_FILE" 2>&1 || echo "jj commit failed with exit code $?" >> "$LOG_FILE"
else
    echo "No message found, skipping commit" >> "$LOG_FILE"
fi

echo "=== Lisa's Notes Hook Finished ===" >> "$LOG_FILE"

# Exit 0 to allow Claude to stop normally
exit 0
