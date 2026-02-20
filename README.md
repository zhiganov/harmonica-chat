# claude-create-session

A slash command for [Claude Code](https://claude.ai/code) that creates [Harmonica](https://harmonica.chat) deliberation sessions from the terminal.

## What it does

`/create-session` calls the Harmonica API to create a new session and returns a shareable join URL. Supports all session options: topic, goal, context, custom prompts, templates, and cross-pollination.

## Installation

### Quick Install (bash)

```bash
curl -fsSL https://raw.githubusercontent.com/zhiganov/claude-create-session/main/install.sh | bash
```

### Quick Install (PowerShell)

```powershell
irm https://raw.githubusercontent.com/zhiganov/claude-create-session/main/install.ps1 | iex
```

### Manual Installation

Copy `create-session.md` to `~/.claude/commands/create-session.md`

## Setup

You need a Harmonica API key:

1. Go to [app.harmonica.chat](https://app.harmonica.chat) > Settings > API Keys
2. Generate a key (starts with `hm_live_`)
3. Add to your shell profile:

```bash
# ~/.bashrc or ~/.zshrc
export HARMONICA_API_KEY="hm_live_your_key_here"
```

## Usage

```
/create-session "Session Topic" --goal "What this session should achieve"
```

### Options

| Flag | Description |
|------|-------------|
| `--goal "..."` | What the session aims to achieve (required) |
| `--context "..."` | Background context for participants |
| `--context-file <path>` | Read context from a file (e.g., SESSION.md from a prior session) |
| `--prompt "..."` | Custom facilitation prompt |
| `--prompt-file <path>` | Read facilitation prompt from a file |
| `--critical "..."` | Critical question or constraint |
| `--template <id>` | Template ID to use |
| `--cross-pollination` | Enable idea sharing between participant threads |

### Examples

```
# Simple session
/create-session "Team Retrospective" --goal "Review Q1 and identify improvements"

# Chain sessions using prior context
/create-session "Phase 2 Deep Dive" --goal "Evaluate solutions" --context-file ./SESSION.md

# Custom facilitation prompt
/create-session "Expert Panel" --goal "Assess risks" --prompt-file ./facilitator.md --cross-pollination

# Interactive (asks for topic and goal)
/create-session
```

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HARMONICA_API_KEY` | (required) | Your API key |
| `HARMONICA_BASE_URL` | `https://app.harmonica.chat` | API base URL (for self-hosted instances) |

## API Reference

This command wraps `POST /api/v1/sessions`. See the [Harmonica API docs](https://docs.harmonica.chat/api-reference) for full details.

## License

MIT
