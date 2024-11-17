#!/bin/bash

# Set the interval in seconds (e.g., every 3 minutes = 180 seconds)
INTERVAL=180

# Define the repository directory and log file
REPO_DIR="/Users/sprak/Documents/merge_conflict_hackathon/test-git-test"
LOG_FILE="/Users/sprak/Documents/merge_conflict_hackathon/log.log"

# Function for cross-platform notifications
function notify {
    local message="$1"
    local title="$2"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "hello from here"
        osascript -e "display notification \"$message\" with title \"$title\""
    elif command -v notify-send &> /dev/null; then
        notify-send "$title" "$message"
    elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
        powershell.exe -Command "New-BurntToastNotification -Text '$title', '$message'"
    else
        echo "Notification: $title - $message"
    fi
}

# Function to check for changes and commit if necessary
function commit_changes {
    local timestamp=$(date)

    # Check for uncommitted changes (tracked or untracked)
    if git status --porcelain | grep -qE "^( M|A |D |R |??)"; then
        echo "Changes detected, committing..."
        git add .
        git commit -m "Auto-commit: $timestamp"
    else
        echo "No changes to commit."
    fi
}

# Function to handle git pull and process output
function pull_from_github {
    cd "$REPO_DIR" || { echo "Failed to navigate to $REPO_DIR"; exit 1; }

    # Commit any local changes before pulling
    commit_changes

    # Fetch and compare local and remote branches
    git fetch origin main
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/main)

    if [ "$LOCAL" != "$REMOTE" ]; then
        OUTPUT=$(git pull origin main 2>&1)
        {
            echo "==== Git Operation Log: $(date) ===="
            echo "$OUTPUT"
            echo "===================================="
        } >> "$LOG_FILE"

        # Handle conflicts
        if echo "$OUTPUT" | grep -q "CONFLICT"; then
            CONFLICTED_FILES=$(git ls-files -u | awk '{print $4}' | sort | uniq)
            notify "Conflicts in: $CONFLICTED_FILES" "Merge conflicts detected!"
            echo "Merge conflict detected in:"
            echo "$CONFLICTED_FILES"
        # Handle fast-forward changes
        elif echo "$OUTPUT" | grep -q "Fast-forward"; then
            CHANGED_FILES=$(git diff --name-only HEAD@{1} HEAD)
            notify "Changes in: $CHANGED_FILES" "Changes detected!"
            echo "Changes detected in:"
            echo "$CHANGED_FILES"

            # Log exact differences for review
            DIFF_OUTPUT=$(git diff HEAD@{1} HEAD)
            {
                echo "==== Git Diff Log: $(date) ===="
                echo "$DIFF_OUTPUT"
                echo "================================="
            } >> "$LOG_FILE"
        fi
    else
        echo "Already up to date: $(date)" >> "$LOG_FILE"
    fi
}

# Trap to handle script interruptions
trap "echo 'Script interrupted. Exiting...'; exit" SIGINT SIGTERM

# Main loop to run pull function at intervals
while true; do
    start_time=$(date +%s)
    pull_from_github
    end_time=$(date +%s)

    # Calculate sleep time to maintain interval
    elapsed=$((end_time - start_time))
    sleep_time=$((INTERVAL - elapsed))

    if [ "$sleep_time" -gt 0 ]; then
        sleep "$sleep_time"
    fi
done
