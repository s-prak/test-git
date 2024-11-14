const { exec } = require('child_process');

// Define the interval in milliseconds (e.g., 10 minutes)
const INTERVAL = 3 * 60 * 1000; // 10 minutes

// Define the function that pulls from GitHub
function pullFromGitHub() {
    exec('git pull origin main', { cwd: '/Users/sprak/Documents/merge_conflict_hackathon/test-git' }, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error during git pull: ${error.message}`);
            return;
        }
        if (stderr) {
            console.error(`Git pull stderr: ${stderr}`);
            return;
        }
        console.log(`Git pull stdout:\n${stdout}`);
    });
}

// Run the pull immediately and then set it to repeat at the specified interval
pullFromGitHub();
setInterval(pullFromGitHub, INTERVAL);