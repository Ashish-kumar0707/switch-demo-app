# PR Review Agent — Flip the Switch Hackathon

A workflow where Claude Code reviews pull requests as a teammate in Discord, powered by [Switch](https://github.com/sandbox-quantum/switch).

You open a PR, mention the agent in your team's Discord channel, and get a full code review — findings, severity ratings, and a GitHub comment — without leaving chat.

**Demo video: https://youtu.be/c0EKTkF57ZY**

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
    │   reads the PR diff via gh CLI
    │   analyzes the code
    │   posts a review comment on GitHub
    │   reports findings back to Discord
    ▼
#pr-review (Discord)
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

Each branch gives the agent something real to find. Point the agent at any of the three PRs and it will catch the issue.

```
src/
  paginate.js        pagination function
test/
  paginate.test.js   4 tests using node:test
```

---

## Reproduce it

### Prerequisites

- [Switch Console v0.40.1](https://github.com/sandbox-quantum/switch/releases/tag/switch-console-v0.40.1) — download and install the desktop app
- Docker — must be running before you open Switch Console
- Node.js 18+
- A Discord server (free, takes 2 minutes to create)

### Setup

**1. Install Claude Code and authenticate**
```bash
npm install -g @anthropic-ai/claude-code
claude login
```
Opens a browser — sign in with your Anthropic account. Credentials are saved to `~/.claude.json`. Switch Console picks this up automatically when it starts the agent.

**2. Authenticate GitHub**
```bash
gh auth login
```
Opens a browser — sign in with your GitHub account. Credentials are saved to `~/.config/gh/hosts.yml`. Claude Code uses `gh` for all GitHub operations — reading PRs and posting review comments.

**3. Clone the repo**
```bash
git clone https://github.com/Ashish-kumar0707/switch-demo-app
cd switch-demo-app
npm test   # 4 tests should pass
```

**4. Create a Discord bot**
- Go to [discord.com/developers/applications](https://discord.com/developers/applications) → New Application
- **Bot** tab → copy the token → enable `Server Members Intent` + `Message Content Intent`
- **OAuth2 → URL Generator** → scopes: `bot` + `applications.commands` → permissions: View Channels, Send Messages, Send Messages in Threads, Manage Channels, Manage Roles, Manage Webhooks, Read Message History, Attach Files, Add Reactions → open the generated URL → authorize bot into your server
- In Discord: **User Settings → Advanced → Developer Mode ON** → right-click your server icon → **Copy Server ID**

**5. Connect Discord in Switch Console**
- Open Switch Console → **"On this computer"** → Start
- Home → Messaging apps → **+ Connect** → Discord
- Paste bot token + server ID → Connect
- Click **Link account** → search your Discord username → confirm

**6. Create a room**
- Switch Console → `switch-buddy-admin` → **Create room**
- Name: `pr-review` → messaging app: your Discord connection → agent: `switch-buddy-admin` (Claude Code)
- Click **Create room** → **Open in Discord**

**7. Push a demo PR**
```bash
git push origin fix-offset
```
Then open a PR on GitHub: `fix-offset → main`

**8. Trigger the review in Discord**
```
@switch-buddy-admin please review this PR: <GitHub PR URL>
```

The agent reviews the PR, posts findings in Discord, and comments directly on the GitHub PR — no terminal, no manual steps.

> The agent can review any public GitHub PR, not just this repo. Pass any PR URL and it works.

---

## Stack

| Component | Role |
|---|---|
| [Switch Console](https://docs.switchagents.ai) | Runs Claude Code, bridges it to Discord |
| Claude Code | Reviews the PR, posts GitHub comments |
| `gh` CLI | GitHub auth — reads PRs, posts comments |
| Discord | Where the team talks |
| GitHub | Where the PR lives |
| Node.js | The codebase under review |

---

## Track

Submitted to **Track 01 — Best Business Workflow**  
Flip the Switch Hackathon · Nov 4–7, 2026 · WeMakeDevs × DevTools Academy
