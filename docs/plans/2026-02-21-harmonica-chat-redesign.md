# harmonica-chat Redesign: Conversational Harmonica Companion

**Date:** 2026-02-21
**Status:** Approved

## Problem

The current `/harmonica-chat` slash command is a thin `curl` wrapper around `POST /api/v1/sessions`. Users must know Harmonica's concepts (topics, goals, templates, cross-pollination) upfront and provide them as flags. This makes it a power-user shortcut, not an onboarding tool.

The primary audience — Claude Code users discovering Harmonica for the first time — gets no guidance on what makes a good session, which template to use, or what to do after creation.

## Solution

Redesign harmonica-chat as a **conversational Harmonica companion** that:

1. Walks users through session design one question at a time
2. Uses harmonica-mcp tools as its backend (no duplicated `curl` logic)
3. Handles the full session lifecycle (create, monitor, summarize, follow up)
4. Integrates with communication tools to help invite participants
5. Connects to community-admin to post sessions as participation opportunities

## Architecture

```
User runs /harmonica-chat
        |
   SKILL.md (UX logic, Harmonica expertise, template matching)
        |
   harmonica-mcp (MCP tools: create_session, list_sessions, get_session, etc.)
        |
   Harmonica API v1 (app.harmonica.chat/api/v1)
        |
   community-admin API (participation opportunities, auth via hm_live_ key)
```

The SKILL.md contains all conversational logic and Harmonica domain knowledge. harmonica-mcp handles all API communication. No direct `curl` calls.

## Prerequisite: harmonica-mcp

harmonica-chat requires harmonica-mcp to be installed as an MCP server. On first run, if MCP tools are not available, the skill walks the user through setup:

1. Sign up for Harmonica (free) at https://app.harmonica.chat
2. Generate an API key at Profile > API Keys
3. Install the MCP server:
   ```
   claude mcp add-json harmonica '{"command":"npx","args":["-y","harmonica-mcp"],"env":{"HARMONICA_API_KEY":"hm_live_..."}}' -s user
   ```
4. Restart Claude Code

Uses `user` scope so harmonica-mcp is available across all projects.

## Three Modes

### Mode 1: Guided Session Design (no arguments)

`/harmonica-chat`

Claude walks the user through session creation one question at a time:

1. **Intent** — "What kind of conversation do you want to facilitate?"
2. **Template match** — Claude suggests the best-matching template (or freeform) and explains what it does
3. **Goal** — "What should this session achieve?"
4. **Context** — "Is there background info participants should know?" (optional)
5. **Critical constraint** — "Is there a question that MUST be answered?" (optional)
6. **Cross-pollination** — Recommended for 3+ participants on brainstorming-type sessions
7. **Confirm & create** — Summary card, then create via `create_session` MCP tool
8. **Invite participants** — Help share the join URL (see Invitation Flow below)
9. **Follow-up offer** — "Want me to check back on this session later?"

### Mode 2: Accelerated Creation (with topic)

`/harmonica-chat "Q1 retrospective for the eng team"`

Claude has enough to start further into the flow — skips intent, suggests a template match immediately, asks only for goal and any missing pieces.

#### Project-aware creation

`/harmonica-chat "feedback on the navidrome-jam invite flow"`
`/harmonica-chat retro --project navidrome-jam`

When Claude detects a project reference (explicit `--project` flag or directory name in the topic):

1. Reads the project's CLAUDE.md to understand what it is
2. Checks recent git history (last 1-2 weeks) for what's been happening
3. Auto-fills session context with a concise project summary
4. Suggests a relevant session type based on recent activity

**Project resolution order:**
1. Explicit `--project <dir>` flag
2. Directory name mentioned in the topic (matched against workspace directories)
3. Current working directory if inside a project subdirectory

**Example:**

> User: `/harmonica-chat "retro on community-admin onboarding"`
>
> Claude: "I see community-admin is the shared admin platform for community organizers. Recent work includes self-service onboarding design and Telegram bot integration.
>
> I'd suggest a Retrospective template with this context:
> 'Community-admin is our shared platform for community organizers. We recently shipped self-service onboarding with invite codes, waitlist, and Telegram admin notifications.'
>
> Sound right? What should this retro achieve?"

### Mode 3: Lifecycle Commands (with action keyword)

`/harmonica-chat status` — List recent sessions with status and participant counts
`/harmonica-chat check "Q1 retro"` — Show participant progress and thematic preview
`/harmonica-chat summary "Q1 retro"` — Get the AI-generated summary
`/harmonica-chat follow-up "Q1 retro"` — Design a new session building on previous results

All lifecycle commands use fuzzy topic matching via `search_sessions` — no need to remember UUIDs.

#### Status overview

```
Your recent sessions:

  Active (2):
    "Q1 Eng Retrospective" — 4 participants, created 2h ago
    "API Design Feedback" — 1 participant, created yesterday

  Completed (3):
    "Onboarding Retro" — 6 participants, summary ready
    "Feature Prioritization" — 8 participants, summary ready
    "Team Pulse Check" — 3 participants, summary ready
```

#### Check on a session

Claude fetches responses and gives a thematic preview:

> "Q1 Eng Retrospective — active, 4 participants. Alice and Bob both flagged deployment friction as a pain point. Want me to pull the full responses, or wait for everyone to finish?"

#### Follow-up session

Claude fetches the original session's summary, proposes a follow-up that builds on findings (e.g., retro findings > Action Planning), and auto-fills context with the previous summary.

## Template Matching

Claude maps user intent to the 9 available templates using semantic matching:

| Template | Trigger intents | When to suggest |
|----------|----------------|-----------------|
| Retrospective | retro, review, reflect, post-mortem, lessons learned | Looking back at completed work |
| Brainstorming | ideate, explore, generate ideas, creative, possibilities | Divergent thinking, no constraints yet |
| SWOT Analysis | strengths, weaknesses, assess, evaluate position | Strategic assessment |
| Theory of Change | impact, outcomes, logic model | Planning how actions lead to outcomes |
| OKRs Planning | goals, objectives, key results, quarterly planning | Setting measurable targets |
| Action Planning | next steps, roadmap, prioritize | Converting decisions into tasks |
| Community Policy | rules, guidelines, governance, community standards | Group norm-setting or policy design |
| Weekly Team Check-ins | standup, sync, weekly pulse | Regular team health check |
| Risk Assessment | risks, concerns, what could go wrong | Identifying and planning for risks |

If nothing matches: "This doesn't fit a standard template — let's design it from scratch."

## Session Design Expertise

The skill includes Harmonica domain knowledge as soft nudges:

**Goal quality:**
- Vague goals > Claude asks for specificity ("Discuss the product" > "What decisions should come out of this?")
- Too many goals > suggest splitting into multiple sessions

**Context calibration:**
- Too little > "Participants will ask the facilitator for context it doesn't have. Even 2-3 sentences help."
- Too much > "Want me to trim this to the key points?"
- Project-sourced > Claude summarizes, doesn't dump the full CLAUDE.md

**Cross-pollination recommendation:**
- 3+ participants > suggest enabling
- Sensitive/anonymous topics > suggest keeping off
- Brainstorming > strong recommend

**Critical question:**
- Suggest adding one if missing: "Is there a question that, if unanswered, means the session failed?"

**What Claude does NOT do:**
- Does not write custom facilitation prompts (API generates good defaults)
- Does not override template structure
- Does not push templates when user wants freeform

## Invitation Flow

After session creation, Claude helps get participants into the session.

### Always available

- **Copy the link** — join URL ready to paste
- **Draft an invite message** — context-aware message explaining what the session is about, what participants will do, and how long it takes. Adapts tone to the template type.

Example invite:

> "Hey team — I've set up a structured conversation on Q1 Eng Retrospective.
>
> It takes about 10 minutes: you'll have a 1-on-1 conversation with an AI facilitator about what went well and what we should improve. Your responses help build a shared summary.
>
> Join here: {join_url}"

### Communication tool integrations

Claude checks what MCP tools are available at runtime:

- **Zapier MCP** > Telegram, Discord, Slack, Email possible
- **Slack MCP** > direct Slack channel posting
- **No integrations** > falls back to "draft a message + copy the link"

Claude tells the user what's available: "I can post directly to Telegram via Zapier, or I can draft a message for you to share."

### Add to community participation feed

Claude offers: "Want to add this as a participation opportunity for a community?"

**Flow:**
1. Claude calls community-admin `GET /api/communities` (passing `hm_live_` key) — returns only communities the user has organizer access to
2. If no communities: "You're not an organizer for any communities. Share the join URL directly, or ask a community admin to add you."
3. User picks a community
4. Claude posts to community-admin:

```
POST /api/events/manual
Authorization: Bearer hm_live_...

{
  "community": "nsrt",
  "title": "Q1 Eng Retrospective",
  "description": "Structured reflection on what went well and what to improve",
  "type": "deliberation",
  "url": "https://app.harmonica.chat/chat?s={id}",
  "datetime": "2026-02-21T15:00:00Z"
}
```

The opportunity appears in My Community and Dear Neighbors extensions for that community's members.

**Auth model:**
- User's `HARMONICA_API_KEY` (`hm_live_`) serves as identity across both systems
- community-admin calls Harmonica `/api/v1/me` to resolve the key to a user (email)
- community-admin checks if that email has organizer/admin role on the target community
- If authorized > opportunity created. If not > "You don't have permission to post to this community."

**Implications for community-admin:**
1. Accept `hm_live_` Bearer tokens (not just magic link sessions)
2. Call Harmonica `/api/v1/me` to resolve identity
3. Map Harmonica user email to community-admin organizer role
4. Expose `GET /api/communities` (filtered by caller's access) and `POST /api/events/manual`

**Graceful degradation:** If community-admin's API isn't live yet, Claude says: "Community participation feeds aren't available yet. I'll share the join URL directly instead."

### What invitations do NOT include

- No contact list management
- No automated reminders for non-joiners
- No mass email sending

## SKILL.md Structure

```
1. Frontmatter (name, description)
2. Prerequisites check
   - Detect harmonica-mcp tools availability
   - Setup walkthrough if missing
3. Argument parsing & mode detection
4. Mode 1: Guided Session Design
   - Intent question
   - Template matching table
   - Goal / context / critical flow
   - Session design expertise (nudges)
   - Cross-pollination recommendation
   - Confirm & create (via create_session MCP tool)
5. Mode 2: Accelerated Creation
   - Topic parsing
   - Project detection & context gathering (CLAUDE.md + git history)
   - Abbreviated guided flow
6. Mode 3: Lifecycle Commands
   - status (list_sessions)
   - check (search_sessions + get_session + get_responses)
   - summary (get_summary)
   - follow-up (get_summary + guided creation with prior context)
7. Invitation Flow
   - Draft invite message
   - Communication tool detection & sending
   - Community participation opportunity (community-admin integration)
8. Post-creation offer (check back later)
```

## Changes vs. Current

| Aspect | Current | New |
|--------|---------|-----|
| API calls | Direct `curl` in bash | harmonica-mcp tools |
| Session design | User provides all fields upfront via flags | Guided conversation, one question at a time |
| Templates | Manual `--template <id>` | Claude suggests based on intent |
| Context | Manual `--context` or `--context-file` | Auto-generated from project context when applicable |
| After creation | Done, here's your URL | Invitation flow + lifecycle commands |
| Onboarding | "Set HARMONICA_API_KEY" error | Full setup walkthrough including MCP install |
| Arguments | Required: topic + goal | Everything flows conversationally |
| Lifecycle | None | Status, check, summary, follow-up |
| Community integration | None | Post as participation opportunity via community-admin |

## What stays the same

- Published as standalone repo at github.com/zhiganov/harmonica-chat
- Installed via `claude install github.com/zhiganov/harmonica-chat`
- Single SKILL.md file, no runtime dependencies beyond harmonica-mcp
- Works on macOS, Linux, Windows

## Dependencies

| Dependency | Type | Status |
|------------|------|--------|
| harmonica-mcp | Required | Published, working |
| Harmonica API v1 | Required | Live at app.harmonica.chat |
| Zapier/Slack MCP | Optional | For invitation sending |
| community-admin API | Optional | WIP — graceful degradation until live |

## Open Questions

1. **Session scheduling** — Should Mode 1 ask "When should this session start?" or assume immediate? Currently assumes immediate.
2. **Participant count estimation** — Cross-pollination recommendation depends on expected participant count. Should Claude ask, or infer from context?
3. **community-admin API spec** — The `GET /api/communities` and `POST /api/events/manual` endpoints are designed here but not yet specified in community-admin. Need to align when community-admin ships R9.
