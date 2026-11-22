# Start the recorded CLI in GitHub Codespaces

The Codespace is a GitHub-hosted Linux computer. The normal Codex CLI writes its own native session files there; it does not use the legacy cloud task export route that failed for the newer default Cloud.

Preparation has installed the official `@openai/codex` version `0.167.0` in the Codespace user's `~/.local/share/makefun-codex`. Its separate configuration and native records go under `~/.codex-makefun-public`. Authenticate the CLI using its own official ChatGPT device-login flow. Do not copy a local auth.json or paste tokens into a chat or repository.

After that sign-in, open the Codespace terminal yourself and run:

```bash
bash scripts/start-recorded-codex.sh
```

At `Task:` paste this as your own first message:

```text
Read AGENTS.md, TASK-SPEC.md and EXPORT-COMPATIBILITY.md. Build tiny-stack-vm-01-run-20261122 in GitHub cloud. First verify your own native JSONL record and actual provider usage with the official kit; only then implement and test. Use a separate entry repository and prepare a free submission as @freeway.
```

The launcher starts a new native CLI session with `gpt-6.1-sol`, a workspace-write sandbox and public project instructions. It limits that run to 90 minutes; an approval request can be handled directly in your terminal. It does not start a model before you enter your prompt. Keep the genuine native JSONL files unchanged. The coding session must verify actual record export before entry implementation; installing the CLI or signing in is not that verification.

The named `makefun_workspace` permissions profile extends the built-in workspace policy, permits writes under `/workspaces`, and enables network access for the authorized GitHub/Make.fun development workflow. A model-free probe verified a real workspace file write, a Node subprocess with exact captured output and no spawn error, and denial of writes outside the workspace. The default network-disabled profile reproduced a known Node synchronous-subprocess error; this probe uses the actual development profile rather than treating that unrelated default as the launcher configuration.

This workbench is not the entry. The VM entry gets a fresh separate repository after the competition has opened; its 8,192-byte limit must not include this workbench or its tools. If the Codespace's GitHub token cannot create or push to a different repository, report that permission issue and preserve the local Git commits for the authorized delivery process to publish. Never copy account credentials to get around a permission boundary.

The machine uses 2 cores and a 15-minute idle timeout. A running agent may keep it active, so the launcher additionally bounds the CLI to 90 minutes. Stop the Codespace after retrieving the original records and deliverables. Retain its files until the records have been safely preserved.
