function notify() {
    # local message=$1
    # local title=$2

    # Detect operating system
    OS=$(uname)

    echo "hello hello hello"

    if [[ "$OS" == "Darwin" ]]; then
        echo "Darwin"
        # macOS: Use osascript for notifications
       #  osascript -e "display notification \"$message\" with title \"$title\""
    elif [[ "$OS" == "Linux" ]]; then
        # Linux: Use notify-send for notifications
        echo "Linux"
        # notify-send "$title" "$message"
    elif [[ "$OS" == "CYGWIN"* || "$OS" == "MINGW"* || "$OS" == "MSYS"* ]]; then
        # Windows (via Git Bash or WSL): Use PowerShell for notifications
        echo "Windows"
        # powershell -Command "[System.Windows.Forms.MessageBox]::Show('$message', '$title')"
    else
        # Fallback for unknown OS
        echo "$title: $message"
    fi
}

echo "presentation"
notify "Conflicts in: $CONFLICTED_FILES" "Merge conflicts detected!"

CHANGED_FILES=$(git diff --name-only HEAD@{1} HEAD)
echo $CHANGED_FILES
