#!/bin/bash
# Install harmonica-chat for Claude Code

set -e

REPO_URL="https://raw.githubusercontent.com/zhiganov/harmonica-chat/main"
CLAUDE_DIR="$HOME/.claude"

echo "Installing harmonica-chat..."

# Create directories
mkdir -p "$CLAUDE_DIR/commands"

# Download command file
curl -fsSL "$REPO_URL/harmonica-chat.md" -o "$CLAUDE_DIR/commands/harmonica-chat.md"
echo "Installed harmonica-chat.md -> ~/.claude/commands/"

echo ""
echo "Installation complete! Set your API key:"
echo "  export HARMONICA_API_KEY=\"hm_live_...\""
echo ""
echo "Then use /harmonica-chat in Claude Code to create sessions."
