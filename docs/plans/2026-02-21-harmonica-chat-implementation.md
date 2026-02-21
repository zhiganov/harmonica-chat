# harmonica-chat Redesign — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rewrite harmonica-chat from a curl wrapper into a conversational Harmonica companion backed by harmonica-mcp tools.

**Architecture:** Single SKILL.md file (`harmonica-chat.md`) containing all UX logic, Harmonica expertise, and instructions for Claude. Uses harmonica-mcp MCP tools for all API calls. No runtime code — pure markdown instructions.

**Tech Stack:** Markdown (Claude Code slash command format), harmonica-mcp (MCP server, already published)

**Design doc:** `docs/plans/2026-02-21-harmonica-chat-redesign.md`

---

### Task 1: Prerequisites & MCP Detection

**Files:**
- Modify: `harmonica-chat.md` (replace Step 1)

**Step 1: Replace the API key check with MCP tool detection**

Replace the current Step 1 (checking `HARMONICA_API_KEY` env var) with instructions for Claude to detect whether harmonica-mcp tools are available.

The new prerequisite section should instruct Claude to:

1. Attempt to call the `list_sessions` MCP tool (from harmonica-mcp) with `limit: 1`
2. If the tool exists and responds — proceed (MCP is set up)
3. If the tool doesn't exist — walk the user through full setup:

```markdown
## Prerequisites

Before doing anything else, check if harmonica-mcp is available by attempting to call the `list_sessions` tool with `limit: 1`.

If the tool is not available, guide the user through setup:

> **Harmonica MCP server not found.** Let me help you set it up:
>
> 1. **Get a Harmonica account** — [Sign up free](https://app.harmonica.chat)
> 2. **Generate an API key** — Go to [Profile](https://app.harmonica.chat/profile) → API Keys → Generate API Key. Copy the `hm_live_...` key.
> 3. **Install the MCP server** — I'll run this for you:
>    ```
>    claude mcp add-json harmonica '{"command":"npx","args":["-y","harmonica-mcp"],"env":{"HARMONICA_API_KEY":"hm_live_YOUR_KEY"}}' -s user
>    ```
> 4. **Restart Claude Code** to load the new MCP server.
>
> Then run `/harmonica-chat` again.

Then stop — do not proceed until harmonica-mcp is available.
```

**Step 2: Verify by reading the updated file**

Read `harmonica-chat.md` and confirm the Prerequisites section replaces the old Step 1 and no longer references `HARMONICA_API_KEY`, `curl`, or `HARMONICA_BASE_URL` env vars.

**Step 3: Commit**

```bash
git add harmonica-chat.md
git commit -m "refactor: replace curl/env-var prereqs with harmonica-mcp detection"
```

---

### Task 2: Argument Parsing & Mode Detection

**Files:**
- Modify: `harmonica-chat.md` (replace Step 2)

**Step 1: Write the mode detection section**

Replace the current flag-based argument parsing with mode detection. The new section should instruct Claude to parse `$ARGUMENTS` and determine which mode to enter:

**Mode detection rules (in order):**

1. **No arguments** → Mode 1 (Guided Session Design)
2. **Starts with action keyword** (`status`, `check`, `summary`, `follow-up`) → Mode 3 (Lifecycle)
3. **Starts with `--project`** or contains a quoted/unquoted topic → Mode 2 (Accelerated Creation)

```markdown
## Argument Parsing

Parse `$ARGUMENTS` to determine the mode:

1. **Empty or no arguments** → Go to **Mode 1: Guided Session Design**
2. **First word is an action keyword** (`status`, `check`, `summary`, `follow-up`) → Go to **Mode 3: Lifecycle Commands**
   - Everything after the keyword is the session reference (topic text or UUID)
3. **Anything else** (topic text, `--project` flag, etc.) → Go to **Mode 2: Accelerated Creation**
   - Extract the topic: first quoted string, or all text before the first `--flag`
   - Extract `--project <dir>` if present
```

**Step 2: Verify no leftover references to old flags**

Read the file and confirm `--goal`, `--context`, `--context-file`, `--prompt`, `--prompt-file`, `--critical`, `--template`, `--cross-pollination` flags are all removed from the argument parsing section. These options are now gathered conversationally in Mode 1/2, not via flags.

**Step 3: Commit**

```bash
git add harmonica-chat.md
git commit -m "refactor: replace flag parsing with three-mode detection"
```

---

### Task 3: Mode 1 — Guided Session Design

**Files:**
- Modify: `harmonica-chat.md` (replace Steps 3-5 with Mode 1)

**Step 1: Write the guided flow**

This is the core of the redesign. Write a complete Mode 1 section that instructs Claude to walk the user through session design one question at a time.

The section MUST include:

**Opening:**
```markdown
### Mode 1: Guided Session Design

Start with a warm introduction:

> "What kind of conversation do you want to facilitate? For example: team retrospective, product feedback, brainstorming, stakeholder alignment, research interviews..."
```

**Question flow (one at a time, in order):**

1. **Intent** — Ask what kind of conversation. Free text response.
2. **Template match** — Using the Template Matching Table (Task 5), suggest the best-matching template. Explain what it does in 1-2 sentences. Ask: "Want to use this template, or design something custom?"
3. **Goal** — "What should this session achieve? What decisions or insights do you want at the end?"
   - Apply goal quality nudge: if vague, ask for specificity. If too many goals, suggest splitting.
4. **Context** — "Is there background info participants should know going in? (You can skip this)"
   - Apply context calibration nudge.
5. **Critical constraint** — "Is there a specific question that MUST be answered, or a constraint to keep in mind? (You can skip this)"
   - Nudge: "Think of it as: if this question goes unanswered, the session failed."
6. **Cross-pollination** — "Will there be 3 or more participants? Cross-pollination shares emerging ideas between threads — great for brainstorming, less so for sensitive topics. Enable it?"
7. **Confirm** — Present a summary card with all fields, ask to confirm:

```
Here's your session:

  Topic:              {topic}
  Template:           {template name or "Custom"}
  Goal:               {goal}
  Context:            {context or "None"}
  Critical question:  {critical or "None"}
  Cross-pollination:  {Yes/No}

Create this session?
```

8. **Create** — Call the `create_session` MCP tool with the gathered fields. Display the result:

```
Session created!

  Topic:    {topic}
  Join URL: {join_url}

Share the join URL with participants.
```

9. **Transition to invitation flow** — Go to the Invitation Flow section (Task 7).

**Step 2: Verify the flow is complete**

Read the Mode 1 section and confirm it covers all 9 steps. Verify it references `create_session` MCP tool (not `curl`). Verify each question is asked ONE AT A TIME (not bundled).

**Step 3: Commit**

```bash
git add harmonica-chat.md
git commit -m "feat: add Mode 1 — guided session design flow"
```

---

### Task 4: Mode 2 — Accelerated & Project-Aware Creation

**Files:**
- Modify: `harmonica-chat.md` (add Mode 2 section after Mode 1)

**Step 1: Write the accelerated creation flow**

This mode activates when the user provides a topic. Claude skips the intent question and jumps further into the flow.

```markdown
### Mode 2: Accelerated Creation

The user provided a topic in `$ARGUMENTS`. Skip the intent question and proceed:

1. **Template match** — Suggest a template based on the topic text (use the Template Matching Table). If no match, proceed freeform.
2. **Goal** — Ask: "What should this session achieve?"
3. **Remaining questions** — Ask about context, critical constraint, and cross-pollination only if relevant. Skip what's inferrable.
4. **Confirm & create** — Same summary card and creation as Mode 1, then transition to Invitation Flow.
```

**Step 2: Write the project-aware extension**

Add project detection logic within Mode 2:

```markdown
#### Project-Aware Creation

If `--project <dir>` was provided, or if a workspace directory name appears in the topic text:

**Project resolution order:**
1. Explicit `--project <dir>` flag
2. Directory name mentioned in topic (matched against sibling directories in the workspace)
3. Current working directory if inside a project subdirectory

**When a project is detected:**
1. Read the project's `CLAUDE.md` using the Read tool to understand what it is
2. Check recent git history: run `git log --oneline --since='2 weeks ago'` in the project directory
3. Summarize the project and recent work in 2-3 sentences
4. Auto-fill the session's `context` field with this summary
5. Suggest a session type based on recent activity:
   - Many recent commits / completed milestone → Retrospective
   - New feature branch / early design → Design Feedback or Brainstorming
   - Bug fixes / incidents → Risk Assessment or Post-Mortem
   - No recent activity → skip suggestion, ask normally

Present the auto-generated context and suggestion to the user for confirmation before proceeding.
```

**Step 3: Verify project detection doesn't hardcode directory names**

Read the section and confirm it uses generic resolution logic, not hardcoded project names from the workspace.

**Step 4: Commit**

```bash
git add harmonica-chat.md
git commit -m "feat: add Mode 2 — accelerated and project-aware creation"
```

---

### Task 5: Template Matching Table & Session Design Expertise

**Files:**
- Modify: `harmonica-chat.md` (add reference section after the three modes)

**Step 1: Write the template matching table**

Add a reference section that Claude uses when matching user intent to templates. This goes after the three modes, as shared reference material.

```markdown
## Reference: Template Matching

Use this table to match user intent to the best template. If multiple templates could fit, suggest the strongest match and briefly mention alternatives. If nothing matches well, say so and proceed freeform.

| Template | ID | Trigger Intents | When to Suggest |
|----------|-----|-----------------|-----------------|
| Retrospective | retrospective | retro, review, reflect, post-mortem, lessons learned, what went well | Looking back at completed work |
| Brainstorming | brainstorming | ideate, explore, generate ideas, creative, possibilities, what if | Divergent thinking, no constraints yet |
| SWOT Analysis | swot-analysis | strengths, weaknesses, assess, evaluate position, competitive | Strategic assessment of a project/product |
| Theory of Change | theory-of-change | impact, outcomes, logic model, how do we get to X | Planning how actions lead to desired outcomes |
| OKRs Planning | okrs-planning | goals, objectives, key results, quarterly planning, metrics | Setting measurable targets |
| Action Planning | action-planning | next steps, roadmap, what do we do, prioritize, action items | Converting decisions into tasks |
| Community Policy | community-policy | rules, guidelines, governance, community standards, norms | Group norm-setting or policy design |
| Weekly Team Check-ins | weekly-check-ins | standup, sync, how's everyone, weekly pulse, check-in | Regular team health check |
| Risk Assessment | risk-assessment | risks, concerns, what could go wrong, mitigation, threats | Identifying and planning for risks |
```

Note: Template IDs come from `harmonica-web-app/src/lib/templates.json`. If the user's Harmonica instance has different templates, the `create_session` call will fail with a validation error — handle gracefully by falling back to freeform.

**Step 2: Write the session design expertise section**

```markdown
## Reference: Session Design Expertise

Apply these as soft nudges during the guided flow. Never force them — if the user disagrees, defer to their judgment.

### Goal Quality
- **Too vague** ("Discuss the product") → Ask for specificity: "What decisions should come out of this? e.g., 'Decide which 3 features to prioritize for Q2'"
- **Too many goals** → Suggest splitting: "A focused session with one clear goal gets better results. Want to split this into two sessions?"

### Context Calibration
- **Too little** → "Participants will ask the AI facilitator for context it doesn't have. Even 2-3 sentences help."
- **Too much** (over ~500 words) → "Long context can overwhelm. Want me to trim this to the key points participants need?"
- **Project-sourced** → Summarize to 3-5 sentences. Never dump a full CLAUDE.md or README.

### Cross-Pollination Recommendation
- **3+ participants + brainstorming** → Strongly recommend: "Seeing others' emerging ideas sparks new ones."
- **3+ participants + other types** → Suggest: "Cross-pollination shares insights between participant threads as people contribute."
- **Sensitive or anonymous topics** → Suggest keeping it off: "For sensitive topics, participants may be more candid without seeing others' responses."
- **< 3 participants** → Don't mention it (not useful with few threads).

### Critical Question
- If the user hasn't added one, gently suggest: "Is there a question that, if unanswered, means the session failed? That's your critical question."
- Don't push if they skip it — it's optional.

### What NOT to Do
- Do not write custom facilitation prompts — the API generates good defaults from goal + context.
- Do not override template structure — if a template is selected, trust it.
- Do not push templates when the user wants freeform.
```

**Step 3: Commit**

```bash
git add harmonica-chat.md
git commit -m "feat: add template matching table and session design expertise"
```

---

### Task 6: Mode 3 — Lifecycle Commands

**Files:**
- Modify: `harmonica-chat.md` (add Mode 3 section)

**Step 1: Write the lifecycle commands section**

```markdown
### Mode 3: Lifecycle Commands

The first word of `$ARGUMENTS` is an action keyword. Parse the rest as the session reference (topic text or UUID).

#### `status` — List Recent Sessions

Call `list_sessions` with no filters (or `limit: 20`). Group by status and display:

> Your recent sessions:
>
>   Active (N):
>     "Topic" — X participants, created {relative time}
>
>   Completed (N):
>     "Topic" — X participants, summary ready

Do not show UUIDs. If the user needs to reference a session later, they use the topic text.

#### `check <session reference>` — Check on a Session

1. Call `search_sessions` with the session reference as the query
2. If multiple matches, ask the user to clarify: "I found N sessions matching '{reference}'. Which one?"
3. Call `get_session` with the matched session ID to get details
4. Call `get_responses` with the session ID to get participant responses
5. Present a thematic preview — don't dump raw responses. Summarize what participants are saying:

> "{Topic}" — {status}, {N} participants.
>
> {Brief thematic summary of responses so far.}
>
> Want me to show the full responses, or wait for more participants?

#### `summary <session reference>` — Get Summary

1. Resolve the session (same search logic as `check`)
2. Call `get_summary` with the session ID
3. If summary exists, display it
4. If no summary yet: "No summary yet — {N} participants are still in conversation. Check back later, or I can show you the raw responses."

#### `follow-up <session reference>` — Design a Follow-Up Session

1. Resolve the session
2. Call `get_summary` to get the original session's findings
3. Propose a follow-up session that builds on the findings:
   - Suggest a natural next-step template (e.g., Retrospective findings → Action Planning)
   - Auto-fill `context` with the previous session's summary
   - Propose a topic: "Action items from {original topic}"
   - Propose a goal based on the summary themes
4. Present the proposal and ask for confirmation
5. If confirmed, proceed with session creation (same as Mode 1 step 7 onward)
```

**Step 2: Verify fuzzy matching logic**

Read the section and confirm all lifecycle commands use `search_sessions` for topic-based fuzzy lookup, and handle the case where multiple sessions match.

**Step 3: Commit**

```bash
git add harmonica-chat.md
git commit -m "feat: add Mode 3 — lifecycle commands (status, check, summary, follow-up)"
```

---

### Task 7: Invitation Flow

**Files:**
- Modify: `harmonica-chat.md` (add Invitation Flow section after the three modes)

**Step 1: Write the invitation flow**

This section runs after any successful session creation (from Mode 1 or Mode 2).

```markdown
## Invitation Flow

After session creation, help get participants into the session.

### Step 1: Show the join URL

Always display the join URL prominently:

> **Join URL:** {join_url}
>
> Share this with participants. Each person gets their own 1-on-1 conversation with the AI facilitator.

### Step 2: Offer invitation options

Ask: "How do you want to invite participants?"

**Always available:**
- **"I'll share it myself"** — done, stop here
- **"Draft an invite message"** — generate a short, context-aware invite message:

> Hey team — I've set up a structured conversation on **{topic}**.
>
> It takes about 10 minutes: you'll have a 1-on-1 conversation with an AI facilitator about {goal, rephrased briefly}. Your responses help build a shared summary.
>
> Join here: {join_url}

Adapt the tone to the template type: brainstorming invites should sound energetic, retrospectives more reflective, risk assessments more serious.

**If communication tools are detected:**

Check at runtime which MCP tools are available. For each, offer as an option:

- **Zapier MCP available** → "I can send this via Telegram, Discord, or Slack through Zapier. Which channel/group?"
- **Slack MCP available** → "I can post this directly to a Slack channel. Which one?"
- **Neither available** → only offer "draft a message" and "share it yourself"

Tell the user what's available: "I can post directly to Telegram via Zapier, or I can draft a message for you to share however you'd like."

### Step 3: Offer to add as community participation opportunity

Ask: "Want to add this to a community's participation feed?"

If the user says yes:

1. Call community-admin `GET /api/communities` with `Authorization: Bearer {HARMONICA_API_KEY}` (the same key used for harmonica-mcp). This returns only communities the user has organizer access to.
2. If the API is not reachable or returns an error: "Community participation feeds aren't available yet. Share the join URL directly instead."
3. If the response has zero communities: "You're not an organizer for any communities. Share the join URL directly, or ask a community admin to add you."
4. If communities are returned, list them and ask the user to pick one.
5. Post to community-admin:

```
POST /api/events/manual
Authorization: Bearer {HARMONICA_API_KEY}

{
  "community": "{selected_community_slug}",
  "title": "{session_topic}",
  "description": "{session_goal}",
  "type": "deliberation",
  "url": "{join_url}",
  "datetime": "{ISO 8601 timestamp, now}"
}
```

6. On success: "Added to {community name}'s participation feed. Members will see it in My Community and Dear Neighbors."
7. On auth error (403): "You don't have permission to post to {community}. Ask the community admin to add you as an organizer."

### Step 4: Offer follow-up check

After invitations are handled:

> "Want me to check back on this session later? Just run `/harmonica-chat check \"{topic}\"` anytime to see who's joined and read responses."
```

**Step 2: Verify graceful degradation**

Read the section and confirm every integration (Zapier, Slack, community-admin) has a fallback path when the tool/API is unavailable.

**Step 3: Commit**

```bash
git add harmonica-chat.md
git commit -m "feat: add invitation flow with communication tools and community-admin"
```

---

### Task 8: File Structure & Frontmatter

**Files:**
- Modify: `harmonica-chat.md` (restructure the full file)

**Step 1: Restructure the file with proper ordering**

Ensure the final file follows this structure:

```
1. Title: "# Harmonica — Session Companion"
2. One-line description
3. ## Arguments — `$ARGUMENTS` description
4. ## Prerequisites — MCP detection (Task 1)
5. ## Instructions
   5a. ### Argument Parsing — Mode detection (Task 2)
   5b. ### Mode 1: Guided Session Design (Task 3)
   5c. ### Mode 2: Accelerated Creation (Task 4)
   5d. ### Mode 3: Lifecycle Commands (Task 6)
6. ## Invitation Flow (Task 7)
7. ## Reference: Template Matching (Task 5)
8. ## Reference: Session Design Expertise (Task 5)
```

**Step 2: Clean up any remaining references to the old design**

Search for and remove any leftover references to:
- `curl` commands
- `HARMONICA_BASE_URL` env var
- `HARMONICA_API_KEY` env var (except in the setup walkthrough)
- `--goal`, `--context`, `--prompt`, `--template`, `--critical`, `--cross-pollination` flags (except in argument parsing for backward-compat note if needed)
- Direct API endpoint URLs (all API calls go through MCP tools now)

**Step 3: Verify the file reads cleanly end-to-end**

Read the complete file. Confirm it's coherent, no orphaned sections, no internal contradictions between modes.

**Step 4: Commit**

```bash
git add harmonica-chat.md
git commit -m "chore: restructure file into final section ordering"
```

---

### Task 9: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Rewrite README to reflect the redesign**

The README should cover:

1. **What it is** — A conversational Harmonica companion for Claude Code (not "a slash command that creates sessions")
2. **Prerequisites** — harmonica-mcp must be installed (link to its repo, show install command)
3. **Installation** — same as before (curl installer, manual copy)
4. **Usage** — three modes with examples:
   - `/harmonica-chat` — guided session design
   - `/harmonica-chat "topic"` — accelerated creation
   - `/harmonica-chat "topic" --project navidrome-jam` — project-aware creation
   - `/harmonica-chat status` — list sessions
   - `/harmonica-chat check "topic"` — check on a session
   - `/harmonica-chat summary "topic"` — get summary
   - `/harmonica-chat follow-up "topic"` — design follow-up
5. **Features** — template matching, session design expertise, invitation flow, community integration
6. **See Also** — link to harmonica-mcp, Harmonica docs, Harmonica web app
7. **License** — MIT (unchanged)

Remove the old flags table (`--goal`, `--context`, etc.) and environment variables table (`HARMONICA_API_KEY`, `HARMONICA_BASE_URL`). These are handled by harmonica-mcp now.

**Step 2: Verify links are correct**

Check that all links in the README point to valid URLs (harmonica.chat, docs.harmonica.chat, github repos).

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README for conversational companion redesign"
```

---

### Task 10: Manual End-to-End Verification

**Files:**
- Read: `harmonica-chat.md` (full file)

**Step 1: Read the complete skill file end-to-end**

Read the full `harmonica-chat.md` and verify:

- [ ] Prerequisites section detects harmonica-mcp and walks through setup if missing
- [ ] Argument parsing correctly routes to Mode 1, 2, or 3
- [ ] Mode 1 asks questions ONE AT A TIME (not bundled)
- [ ] Mode 1 references `create_session` MCP tool (not curl)
- [ ] Mode 2 detects `--project` flag and workspace directory names
- [ ] Mode 2 uses Read tool for CLAUDE.md and Bash for git log
- [ ] Mode 3 uses `list_sessions`, `search_sessions`, `get_session`, `get_responses`, `get_summary` MCP tools
- [ ] Mode 3 follow-up creates a new session with prior summary as context
- [ ] Template matching table has all 9 templates with IDs
- [ ] Session design expertise has nudges for goal, context, cross-pollination, critical question
- [ ] Invitation flow detects available communication tools at runtime
- [ ] Community-admin integration uses `hm_live_` key and degrades gracefully
- [ ] No references to `curl`, `HARMONICA_BASE_URL`, or direct API URLs remain
- [ ] No orphaned sections or internal contradictions

**Step 2: Fix any issues found**

If any checklist items fail, fix them and commit:

```bash
git add harmonica-chat.md
git commit -m "fix: address issues found in end-to-end review"
```

**Step 3: Final commit — tag the release**

```bash
git tag -a v2.0.0 -m "v2.0.0: Conversational Harmonica companion"
```
