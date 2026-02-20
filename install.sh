#!/bin/bash
# Install harmonica-chat for Claude Code

set -e

REPO_URL="https://raw.githubusercontent.com/zhiganov/harmonica-chat/main"
CLAUDE_DIR="$HOME/.claude"

echo "Installing harmonica-chat..."

# Create directories
mkdir -p "$CLAUDE_DIR/commands"

# Download command file
curl -fsSL "$REPO_URL/create-session.md" -o "$CLAUDE_DIR/commands/create-session.md"
echo "Installed create-session.md -> ~/.claude/commands/"

echo ""
echo "Installation complete! Set your API key:"
echo "  export HARMONICA_API_KEY=\"hm_live_...\""
echo ""
echo "Then use /create-session in Claude Code to create sessions."
