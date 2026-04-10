# gateway-demo

A live demo of [Wombat](https://github.com/usewombat/gateway) — resource-level permissions for AI agents.

Fork this repo, run `claude` inside it, and watch Wombat allow some tool calls and deny others — based on the manifest, not the tool name.

---

## What this demo shows

The manifest grants:

| Resource | Mode | Meaning |
|---|---|---|
| `github/you/gateway-demo` | `r-x-` | Read the repo and trigger CI workflows |
| `github/you/gateway-demo/main` | `r---` | Main is read-only — no direct pushes |
| `github/you/gateway-demo/feature/*` | `rw--` | Push freely to feature branches |

The agent never sees tools it can't use. Denials are silent and instant.

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) — the GitHub MCP server runs via `ghcr.io/github/github-mcp-server`
- A GitHub personal access token with `repo` and `workflow` scopes, exported as `GITHUB_TOKEN`
- Wombat installed: `npm install -g @usewombat/gateway`
- [Claude Code](https://claude.ai/code) installed: `npm install -g @anthropic-ai/claude-code`

---

## Setup

**1. Fork this repo** on GitHub, then clone your fork:

```bash
git clone https://github.com/your-username/gateway-demo
cd gateway-demo
```

**2. Set your GitHub token:**

```bash
export GITHUB_TOKEN=your_token_here
```

**3. Run Claude Code:**

```bash
claude
```

The `.claude.json` in this repo wires up Wombat automatically. No other configuration needed — `wombat-demo.sh` detects your fork from the git remote.

---

## Try it

**Trigger the demo workflow (allowed):**

> "Trigger the demo workflow on this repo with the reason 'testing Wombat'"

The agent calls `actions_run_trigger`. Wombat checks: `r-x-` on `github/you/gateway-demo` — allowed. Watch it run in your [Actions tab](../../actions).

**Push to main (denied):**

> "Push a commit directly to main"

The agent calls `push_files` targeting `main`. Wombat checks: `r---` on `github/you/gateway-demo/main` — write denied. The push never reaches GitHub.

**Push to a feature branch (allowed):**

> "Create a file on a branch called feature/test"

The agent calls `push_files` targeting `feature/test`. Wombat checks: `rw--` on `github/you/gateway-demo/feature/*` — allowed.

---

## How it works

`wombat-demo.sh` detects your fork from `git remote get-url origin`, expands `permissions.template.json` with your repo name, and starts Wombat pointing at `ghcr.io/github/github-mcp-server`.

To use a different repo: `WOMBAT_REPO=owner/repo claude`

---

## Dashboard

Open [http://localhost:7842](http://localhost:7842) while Wombat is running to see every tool call — allowed (green) or denied (red) — in real time.

---

## Learn more

- [Wombat gateway](https://github.com/usewombat/gateway) — the full package with docs, plugin system, and CLI reference
- [permissions.template.json](./permissions.template.json) — the manifest driving this demo
