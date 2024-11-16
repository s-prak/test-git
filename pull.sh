#!/bin/bash

# Set the interval in seconds (e.g., every 3 minutes = 180 seconds)
INTERVAL=180

# Define the directory to run the git pull command
REPO_DIR="/Users/sprak/Documents/merge_conflict_hackathon/test-git-test"

# Output log file
LOG_FILE="/Users/sprak/Documents/merge_conflict_hackathon/log.log"

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
        echo "Facing a merge conflict"
    elif echo "$OUTPUT" | grep -q "changed"; then
        osascript -e 'display notification "change is detected from remote" with title "change!!"'
        echo "Changes detected at $(date)"

        # Extract and display lines after "Fast-forward"
        echo "$OUTPUT" | awk '/Fast-forward/ {found=1; next} found {print}'

        # Log the exact changes using git diff
        DIFF_OUTPUT=$(git diff HEAD@{1} HEAD)
        echo "Git Diff Output: $(date)" >> "$LOG_FILE"
        echo "$DIFF_OUTPUT" >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"

        # Also display the diff on the console
        echo "Exact Changes:"
        echo "$DIFF_OUTPUT"
    fi
}

# Run the pull function immediately, then loop at intervals
while true; do
    pull_from_github
    sleep $INTERVAL
done
