# Create Harmonica Session

Create a new Harmonica deliberation session via the API and get a shareable join URL.

## Arguments

- `$ARGUMENTS` — topic (quoted or unquoted), plus optional flags

## Instructions

### Step 1: Check API Key

Check if the `HARMONICA_API_KEY` environment variable is set by running:

```bash
echo "${HARMONICA_API_KEY:+set}"
```

If it's not set (empty output), tell the user:

> **HARMONICA_API_KEY not set.** To use this command:
>
> 1. [Sign up for Harmonica](https://app.harmonica.chat) if you don't have an account (free)
> 2. Go to your [Profile page](https://app.harmonica.chat/profile) → **API Keys** tab → **Generate API Key**
> 3. Add to your shell profile: `export HARMONICA_API_KEY="hm_live_..."`
> 4. Restart your terminal or run `source ~/.bashrc`

Then stop.

### Step 2: Parse Arguments

Parse `$ARGUMENTS` to extract:

- **topic** — the first quoted string, or all text before the first `--flag`. Required (ask interactively if missing).
- **--goal "..."** — what the session aims to achieve. Required (ask interactively if missing).
- **--context "..."** — inline background context for participants
- **--context-file \<path\>** — read context from a local file (e.g., a SESSION.md from a prior session)
- **--prompt "..."** — custom facilitation prompt (if omitted, the API uses a default)
- **--prompt-file \<path\>** — read prompt from a local file
- **--critical "..."** — critical question or constraint
- **--template \<id\>** — template ID to use
- **--cross-pollination** — enable cross-pollination between participant threads (flag, no value)

If **topic** is missing, ask: "What's the topic for this session?"
If **--goal** is missing, ask: "What should this session achieve?"

### Step 3: Load File Content

If `--context-file` was provided, read the file at that path using the Read tool and use its contents as the context value.

If `--prompt-file` was provided, read the file at that path using the Read tool and use its contents as the prompt value.

### Step 4: Create the Session

Determine the base URL:
```bash
echo "${HARMONICA_BASE_URL:-https://app.harmonica.chat}"
```

Build a JSON payload with the parsed fields. Only include optional fields if they were provided.

Make the API call:
```bash
curl -s -X POST "${HARMONICA_BASE_URL:-https://app.harmonica.chat}/api/v1/sessions" \
  -H "Authorization: Bearer $HARMONICA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '<json payload>'
```

### Step 5: Display Result

Parse the JSON response. If successful (has `id` field), display:

```
Session created!

  Topic:    <topic>
  ID:       <id>
  Status:   <status>
  Join URL: <join_url>

Share the join URL with participants to start the session.
```

If the response contains an `error` field, display the error message and suggest fixes:
- `unauthorized` → check HARMONICA_API_KEY
- `validation_error` → show which field is missing/invalid
- `rate_limited` → wait and retry
