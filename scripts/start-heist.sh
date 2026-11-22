#!/usr/bin/env bash
set -euo pipefail

workbench_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
codex_binary="$HOME/.local/share/makefun-codex/node_modules/.bin/codex"
public_codex_home="$HOME/.codex-makefun-public"
records='/workspaces/best-heist-game-20261122-0559-records'
mcp_server='/workspaces/.makefun-cloud-tools/heist/node_modules/@zseven-w/dsh-game-studio/plugins/game-studio/scripts/mcp-server.mjs'

if [[ ! -t 0 || ! -t 1 || -n "${CODEX_THREAD_ID:-}" ]]; then
  echo 'Run this directly in your Codespace terminal, outside another agent.' >&2
  exit 1
fi
if [[ ! -x "$codex_binary" || ! -f "$mcp_server" || ! -f "$records/environment-preflight.json" ]]; then
  echo 'The verified CLI, Game Studio or browser preflight is missing; no model started.' >&2
  exit 1
fi
if [[ -n "${OPENAI_API_KEY:-}" ]]; then
  echo 'Use the existing ChatGPT sign-in, not a billable API key.' >&2
  exit 1
fi
if pgrep -x codex >/dev/null; then
  echo 'Another Codex CLI is running; finish that terminal first.' >&2
  exit 1
fi
mkdir -p "$records"
exec 9>"$records/owner-launch.lock"
flock -n 9 || { echo 'Another heist launch holds this lock.' >&2; exit 1; }
python3 - "$records/environment-preflight.json" <<'PY'
import datetime,json,sys
r=json.load(open(sys.argv[1]))
assert r['local_page_opened'] and not r['page_errors'] and not r['submission_image']
now=datetime.datetime.now(datetime.timezone.utc)
assert datetime.datetime(2026,11,22,5,59,tzinfo=datetime.timezone.utc)<=now<datetime.datetime(2026,11,22,17,59,tzinfo=datetime.timezone.utc)
PY
env CODEX_HOME="$public_codex_home" "$codex_binary" login status
cd "$workbench_root"
printf '%s\n' 'New original heist-game session, at most 90 minutes. No VM resume.'
printf '%s\n' 'Type your actual first task prompt. Suggested:'
printf '%s\n' '製作 best-heist-game-20261122-0559，讀取 HEIST-RUN.md，完成原創遊戲、實測與截圖，通過檢查後直接免費投稿。'
IFS= read -r -p 'Task: ' owner_prompt
if [[ -z "$owner_prompt" || "$owner_prompt" != *best-heist-game-20261122-0559* ]]; then
  echo 'Enter a prompt naming best-heist-game-20261122-0559; no model started.' >&2
  exit 1
fi
python3 - "$records/owner-launch.json" <<'PY'
import datetime,json,sys
with open(sys.argv[1],'w') as f:json.dump({'started_at_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'mode':'fresh owner-started interactive CLI','maximum_minutes':90,'model':'gpt-6.1-sol'},f)
PY

# The owner types the real first prompt. Only Codex writes its native record.
# No existing session is resumed or reconstructed.
timeout --foreground --signal=TERM --kill-after=20s 90m \
  env CODEX_HOME="$public_codex_home" "$codex_binary" \
    --no-daemon \
    --no-alt-screen \
    --cd "$workbench_root" \
    --model gpt-6.1-sol \
    --ask-for-approval on-request \
    --search \
    -c 'default_permissions="makefun_workspace"' \
    -c 'permissions.makefun_workspace.extends=":workspace"' \
    -c 'permissions.makefun_workspace.filesystem={"/workspaces"="write"}' \
    -c 'permissions.makefun_workspace.network.enabled=true' \
    -c 'model_reasoning_effort="low"' \
    -c 'model_reasoning_summary="none"' \
    -c 'mcp_servers.dsh_game_studio.command="node"' \
    -c 'mcp_servers.dsh_game_studio.args=["/workspaces/.makefun-cloud-tools/heist/node_modules/@zseven-w/dsh-game-studio/plugins/game-studio/scripts/mcp-server.mjs"]' \
    -c 'mcp_servers.dsh_game_studio.startup_timeout_sec=30' \
    -c 'mcp_servers.dsh_game_studio.tool_timeout_sec=180' \
    "$owner_prompt"
