# harmonica-chat

A slash command for [Claude Code](https://claude.ai/code) that creates [Harmonica](https://harmonica.chat) deliberation sessions from the terminal.

[Harmonica](https://harmonica.chat) is a structured deliberation platform where groups coordinate through AI-facilitated async conversations. You create a session with a topic and goal, share a link with participants, and each person has a private 1:1 conversation with an AI facilitator. Responses are then synthesized into actionable insights. [Learn more](https://docs.harmonica.chat).

## Installation

### Quick Install (bash)

```bash
curl -fsSL https://raw.githubusercontent.com/zhiganov/harmonica-chat/main/install.sh | bash
```

### Quick Install (PowerShell)

```powershell
irm https://raw.githubusercontent.com/zhiganov/harmonica-chat/main/install.ps1 | iex
```

### Manual Installation

Copy `create-session.md` to `~/.claude/commands/create-session.md`

## Setup

### 1. Create a Harmonica account

Sign up at [app.harmonica.chat](https://app.harmonica.chat) (free).

### 2. Generate an API key

Go to your [Profile page](https://app.harmonica.chat/profile) > **API Keys** tab > **Generate API Key**.

Your key starts with `hm_live_`. Copy it — it's only shown once.

### 3. Set the environment variable

```bash
# Add to ~/.bashrc, ~/.zshrc, or equivalent
export HARMONICA_API_KEY="hm_live_your_key_here"
```

Restart your terminal or run `source ~/.bashrc`.

## Usage

```
/create-session "Session Topic" --goal "What this session should achieve"
```

This creates a session and returns a join URL you can share with participants.

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
| `HARMONICA_API_KEY` | (required) | Your API key ([get one here](https://app.harmonica.chat/profile)) |
| `HARMONICA_BASE_URL` | `https://app.harmonica.chat` | API base URL (for self-hosted instances) |

## API Reference

This command wraps `POST /api/v1/sessions`. See the [Harmonica API docs](https://docs.harmonica.chat/api-reference) for full details.

## License

MIT
