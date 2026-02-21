# Install harmonica-chat for Claude Code

$ErrorActionPreference = "Stop"

$RepoUrl = "https://raw.githubusercontent.com/zhiganov/harmonica-chat/main"
$ClaudeDir = "$env:USERPROFILE\.claude"

Write-Host "Installing harmonica-chat..."

# Create directories
New-Item -ItemType Directory -Force -Path "$ClaudeDir\commands" | Out-Null

# Download command file
Invoke-WebRequest -Uri "$RepoUrl/harmonica-chat.md" -OutFile "$ClaudeDir\commands\harmonica-chat.md"
Write-Host "Installed harmonica-chat.md -> ~/.claude/commands/"

Write-Host ""
Write-Host "Installation complete! Set your API key:"
Write-Host '  $env:HARMONICA_API_KEY = "hm_live_..."'
Write-Host ""
Write-Host "Then use /harmonica-chat in Claude Code to create sessions."
