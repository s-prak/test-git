#!/bin/bash

# Set the interval in seconds (e.g., every 3 minutes = 180 seconds)
INTERVAL=180

# Define the directory to run the git pull command
REPO_DIR="/Users/sprak/Documents/merge_conflict_hackathon/test-git-test"

# Output log file
LOG_FILE="/Users/sprak/Documents/merge_conflict_hackathon/log.log"

# Function to detect the OS and display notifications accordingly
function notify() {
    local message=$1
    local title=$2

    # Detect operating system
    OS=$(uname)

    if [[ "$OS" == "Darwin" ]]; then
        echo "Darwin"
        # macOS: Use osascript for notifications
        osascript -e "display notification \"$message\" with title \"$title\""
    elif [[ "$OS" == "Linux" ]]; then
        echo "Linux"
        # Linux: Use notify-send for notifications
        notify-send "$title" "$message"
    elif [[ "$OS" == "CYGWIN"* || "$OS" == "MINGW"* || "$OS" == "MSYS"* ]]; then
        echo "Windows"
        # Windows (via Git Bash or WSL): Use PowerShell for notifications
        powershell -Command "[System.Windows.Forms.MessageBox]::Show('$message', '$title')"
    else
        # Fallback for unknown OS
        echo "$title: $message"
    fi
}

# Function to perform git pull and process the output
function pull_from_github() {
    cd "$REPO_DIR" || { echo "Failed to navigate to $REPO_DIR"; exit 1; }
    timestamp=$(date)

    # Run git pull and save the output to a log file
    git add .
    git commit -m "$timestamp"
    OUTPUT=$(git pull origin main 2>&1)
    echo "Git Pull Output: $(date)" >> "$LOG_FILE"
    echo "$OUTPUT" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"  # Add an empty line for separation

    # Check for the string "Already up to date"
    if echo "$OUTPUT" | grep -q "Already up to date"; then
        echo "Nothing to do: Already up to date"
    elif echo "$OUTPUT" | grep -q "CONFLICT"; then
        # Extract conflicted files
        CONFLICTED_FILES=$(git diff --name-only --diff-filter=U)
        notify "Conflicts in: $CONFLICTED_FILES" "Merge conflicts detected!"
        echo "Facing a merge conflict in the following files:"
        echo "$CONFLICTED_FILES"
    elif echo "$OUTPUT" | grep -q "changed"; then
        # Extract changed files using git diff between current and previous commit
        CHANGED_FILES=$(git diff --name-only HEAD@{1} HEAD)
        
        if [ -z "$CHANGED_FILES" ]; then
            echo "No file changes detected."
        else
            # Notify about the changes
            notify "Changes in: $CHANGED_FILES" "Clean changes incorporated ;)"
            echo "Changes detected in the following files:"
            echo "$CHANGED_FILES"

            # Log the exact changes using git diff
            DIFF_OUTPUT=$(git diff HEAD@{1} HEAD)
            echo "Git Diff Output: $(date)" >> "$LOG_FILE"
            echo "$DIFF_OUTPUT" >> "$LOG_FILE"
            echo "" >> "$LOG_FILE"

            # Display the diff on the console
            echo "Exact Changes:"
            echo "$DIFF_OUTPUT"
        fi
    fi
}


# Run the pull function immediately, then loop at intervals
while true; do
    pull_from_github
    sleep $INTERVAL
done
