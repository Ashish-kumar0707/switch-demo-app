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

- [Switch Console](https://github.com/sandbox-quantum/switch/releases/tag/switch-console-v0.40.1) installed and running
- Claude Code configured as your agent provider
- A Discord server with the Switch bot added
- Docker (required by Switch Console)
- Node.js 18+
- GitHub CLI (`gh`)

### Setup

**1. Clone and install**
```bash
git clone https://github.com/Ashish-kumar0707/switch-demo-app
cd switch-demo-app
npm test   # 4 tests should pass
```

**2. Bootstrap the demo branches**
```bash
# The three demo branches are already in the repo
git branch -a
```

**3. Set up Switch**
- Open Switch Console → "On this computer" → Start
- Home → Messaging apps → Connect → Discord
- Paste your bot token and server (Guild) ID
- Link your Discord account

**4. Create a room**
- Switch Console → switch-buddy-admin → Create room
- Select your Discord connection, name it (e.g. `pr-review`)
- Agent: switch-buddy-admin (Claude Code)

**5. Push a demo PR**
```bash
git push origin fix-offset
gh pr create --base main --head fix-offset \
  --title "Fix offset bug in pagination" \
  --body "Off-by-one error in page offset calculation"
```

**6. Trigger the review in Discord**
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
