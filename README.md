# PR Review Agent — Flip the Switch Hackathon

A workflow where Claude Code reviews pull requests as a teammate in Discord, powered by [Switch](https://github.com/sandbox-quantum/switch).

You open a PR, mention the agent in your team's Discord channel, and get a full code review — findings, severity ratings, and a GitHub comment — without leaving chat.

---

## Demo

**You type in Discord:**
```
@switch-buddy-admin pls review this pr https://github.com/Ashish-kumar0707/switch-demo-app/pull/1
```

**The agent responds in Discord:**
```
On it — pulling up the PR now.

Review done on PR #1 — here's the verdict:

🔴 REQUEST CHANGES — the PR introduces the bug it claims to fix.

What the diff does:
- const start = (page - 1) * pageSize;
+ const start = page * pageSize;

Removing the -1 breaks 1-indexed pagination. With the new formula,
page=1 skips the entire first page of data...

Findings:
🔴 Critical: Off-by-one regression — revert to (page - 1) * pageSize
🟡 High: The page >= 1 guard is now logically contradictory with the new formula
🟡 Medium: No unit tests accompany the change

GitHub comment posted: https://github.com/...
```

The agent worked for 3m 44s, made 21 tool calls, posted the review as a GitHub comment, and saved the full review locally — all triggered by one Discord message.

---

## How it works

```
You (Discord)
    │
    │  @switch-buddy-admin please review PR #1
    ▼
Switch  ──────────────────────────────────────────────────
    │   bridges Discord channel ↔ Switch room
    ▼
Claude Code (switch-buddy-admin)
    │   reads the PR diff from GitHub
    │   analyzes the code
    │   posts a review comment on GitHub
    │   reports findings back to Discord
    ▼
#stage-one (Discord)
    │
    │  Review done. REQUEST CHANGES — here's why...
    ▼
You (Discord)
```

Switch is the only reason this works. It bridges the Discord channel into a room, gives Claude Code a persistent identity in that room (`switch-buddy-admin`), and routes messages between your team and the agent. Remove Switch and the agent has no way to receive the message, no room to respond in, and no way to show up as a teammate.

---

## The codebase

A small JavaScript pagination module used as the review target. It has three branches with intentional issues for demo purposes:

| Branch | Description |
|---|---|
| `fix-offset` | Claims to fix an off-by-one bug but introduces one instead |
| `inline-validation` | Moves validation inline in a way that changes error behaviour |
| `add-empty-input-test` | Adds a test but gets the expected output wrong |

Each branch gives the agent something real to find.

```
src/
  paginate.js        pagination function
test/
  paginate.test.js   4 tests using node:test
```

---

## Reproduce it

### Prerequisites

- [Switch Console v0.40.1](https://github.com/sandbox-quantum/switch/releases/tag/switch-console-v0.40.1) — desktop app, no terminal needed
- Docker — required by Switch Console
- Node.js 18+
- An [Anthropic API key](https://console.anthropic.com/settings/keys)
- A [GitHub personal access token](https://github.com/settings/tokens) with `repo` scope
- A Discord server with a bot (see step 3)

### Setup

**1. Clone and add your keys**
```bash
git clone https://github.com/Ashish-kumar0707/switch-demo-app
cd switch-demo-app
cp .env.example .env
# open .env and fill in ANTHROPIC_API_KEY and GITHUB_TOKEN
```

**2. Run the install script**
```bash
chmod +x install.sh && ./install.sh
```

This installs Claude Code if missing and verifies your keys are loaded. No `claude login` needed — Claude Code reads `ANTHROPIC_API_KEY` directly from the environment.

**3. Set up Discord bot**
- Go to [discord.com/developers/applications](https://discord.com/developers/applications) → New Application
- **Bot** tab → copy the token, enable `Server Members Intent` + `Message Content Intent`
- **OAuth2 → URL Generator** → scopes: `bot` + `applications.commands`, all channel/message permissions → authorize bot into your server
- **User Settings → Advanced → Developer Mode** → right-click your server → Copy Server ID

**4. Connect Discord in Switch Console**
- Open Switch Console → "On this computer" → Start
- Home → Messaging apps → **+ Connect** → Discord
- Paste bot token and server ID → Connect
- Link your Discord account

**5. Create a room**
- Switch Console → `switch-buddy-admin` → **Create room**
- Select your Discord connection, name it (e.g. `pr-review`)
- Agent: `switch-buddy-admin` (Claude Code)
- Switch Console passes `ANTHROPIC_API_KEY` and `GITHUB_TOKEN` to Claude Code automatically

**6. Push a demo PR**
```bash
git push origin fix-offset
# Then open a PR on GitHub from fix-offset → main
```

**7. Trigger the review in Discord**
```
@switch-buddy-admin please review this PR: <URL>
```

---

## Stack

| Component | Role |
|---|---|
| [Switch Console](https://docs.switchagents.ai) | Runs the agent, bridges Discord |
| Claude Code | Reviews the PR |
| Discord | Where the team talks |
| GitHub | Where the PR lives |
| Node.js | The codebase under review |

---

## Track

Submitted to **Track 01 — Best Business Workflow**  
Flip the Switch Hackathon · Nov 4–7, 2026 · WeMakeDevs × DevTools Academy
