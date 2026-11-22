#!/usr/bin/env bash
set -euo pipefail

workbench_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
codex_binary="$HOME/.local/share/makefun-codex/node_modules/.bin/codex"
public_codex_home="$HOME/.codex-makefun-public"

if [[ ! -t 0 ]]; then
  echo 'Open the Codespace terminal yourself and run this script there.' >&2
  exit 1
fi
if [[ -n "${CODEX_THREAD_ID:-}" ]]; then
  echo 'Start this directly from your terminal, outside another Codex session.' >&2
  exit 1
fi
if [[ ! -x "$codex_binary" ]]; then
  echo 'The official Codex CLI has not been installed in this Codespace.' >&2
  exit 1
fi
if [[ -n "${OPENAI_API_KEY:-}" ]]; then
  echo 'This launcher requires ChatGPT sign-in, not a billable API key.' >&2
  exit 1
fi
mkdir -p "$public_codex_home"
env CODEX_HOME="$public_codex_home" "$codex_binary" login status
cd "$workbench_root"

printf '%s\n' 'Enter your task prompt below. It becomes the real first user message in a new native CLI session.'
printf '%s\n' 'Suggested prompt: Read AGENTS.md, TASK-SPEC.md and EXPORT-COMPATIBILITY.md. Build tiny-stack-vm-01-run-20261122 in GitHub cloud. First verify your own native JSONL record and actual provider usage with the official kit; only then implement and test. Use a separate entry repository and prepare a free submission as @freeway.'
IFS= read -r -p 'Task: ' owner_prompt
if [[ -z "$owner_prompt" || "$owner_prompt" != *tiny-stack-vm-01-run-20261122* ]]; then
  echo 'Enter a nonempty prompt naming tiny-stack-vm-01-run-20261122.' >&2
  exit 1
fi

# No model or session starts before the owner enters the actual prompt above.
# The CLI, not this script, writes its genuine native records and provider usage.
timeout --signal=TERM --kill-after=20s 90m \
  env CODEX_HOME="$public_codex_home" "$codex_binary" \
    --no-daemon \
    --cd "$workbench_root" \
    --model gpt-6.1-sol \
    --ask-for-approval on-request \
    -c 'default_permissions="makefun_workspace"' \
    -c 'permissions.makefun_workspace.extends=":workspace"' \
    -c 'permissions.makefun_workspace.filesystem={"/workspaces"="write"}' \
    -c 'permissions.makefun_workspace.network.enabled=true' \
    -c 'model_reasoning_effort="low"' \
    -c 'model_reasoning_summary="none"' \
    "$owner_prompt"
