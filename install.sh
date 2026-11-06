#!/usr/bin/env bash
set -euo pipefail

# Load env vars
if [ ! -f .env ]; then
  echo "ERROR: .env file not found."
  echo "Run: cp .env.example .env  then fill in your keys."
  exit 1
fi
set -a; source .env; set +a

# Check required keys
if [[ -z "${ANTHROPIC_API_KEY:-}" || "$ANTHROPIC_API_KEY" == "sk-ant-..." ]]; then
  echo "ERROR: Set ANTHROPIC_API_KEY in your .env file."
  echo "Get one at https://console.anthropic.com/settings/keys"
  exit 1
fi

if [[ -z "${GITHUB_TOKEN:-}" || "$GITHUB_TOKEN" == "ghp_..." ]]; then
  echo "ERROR: Set GITHUB_TOKEN in your .env file."
  echo "Create one at https://github.com/settings/tokens (scope: repo)"
  exit 1
fi

# Install Claude Code if missing
if ! command -v claude &>/dev/null; then
  echo "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
else
  echo "Claude Code already installed: $(claude --version)"
fi

# Verify Claude Code picks up the API key (no login needed)
if claude --version &>/dev/null; then
  echo "Claude Code ready."
fi

echo ""
echo "Setup complete. Keys loaded from .env — no login required."
echo ""
echo "Next: open Switch Console and add this folder as the agent working directory."
echo "Switch Console will pass ANTHROPIC_API_KEY and GITHUB_TOKEN to Claude Code automatically."
