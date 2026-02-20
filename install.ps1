# Install claude-create-session for Claude Code

$ErrorActionPreference = "Stop"

$RepoUrl = "https://raw.githubusercontent.com/zhiganov/claude-create-session/main"
$ClaudeDir = "$env:USERPROFILE\.claude"

Write-Host "Installing claude-create-session..."

# Create directories
New-Item -ItemType Directory -Force -Path "$ClaudeDir\commands" | Out-Null

# Download command file
Invoke-WebRequest -Uri "$RepoUrl/create-session.md" -OutFile "$ClaudeDir\commands\create-session.md"
Write-Host "Installed create-session.md -> ~/.claude/commands/"

Write-Host ""
Write-Host "Installation complete! Set your API key:"
Write-Host '  $env:HARMONICA_API_KEY = "hm_live_..."'
Write-Host ""
Write-Host "Then use /create-session in Claude Code to create sessions."
