#!/usr/bin/env bash
set -euo pipefail

workbench_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
codex_binary="$HOME/.local/share/makefun-codex/node_modules/.bin/codex"
public_codex_home="$HOME/.codex-makefun-public"
session_id='01a201cf-4b2e-7493-96b0-dd50d6380fdc'
records='/workspaces/tiny-stack-vm-01-run-20261122-records'
native_record="$public_codex_home/sessions/2026/11/22/rollout-2026-11-22T05-51-32-$session_id.jsonl"

if [[ ! -t 0 || ! -t 1 || -n "${CODEX_THREAD_ID:-}" ]]; then
  echo 'Run this directly in your Codespace terminal, outside another agent.' >&2
  exit 1
fi
continuation_doc="${MAKEFUN_CONTINUATION_DOC:-TINY-VM-REVISION.md}"
continuation_minutes="${MAKEFUN_CONTINUATION_MINUTES:-45}"
case "$continuation_doc" in
  TINY-VM-REVISION.md|TINY-VM-TOP10-RUN.md) ;;
  *) echo 'Unknown public continuation document; no model started.' >&2; exit 1 ;;
esac
case "$continuation_minutes" in
  30|45) ;;
  *) echo 'Continuation limit must be 30 or 45 minutes; no model started.' >&2; exit 1 ;;
esac
if [[ ! -x "$codex_binary" || ! -f "$native_record" ]]; then
  echo 'The original CLI or native record is missing; no model started.' >&2
  exit 1
fi
if [[ -n "${OPENAI_API_KEY:-}" ]]; then
  echo 'Use the existing ChatGPT sign-in, not a billable API key.' >&2
  exit 1
fi
if pgrep -x codex >/dev/null; then
  echo 'Another Codex CLI is running; finish or use that terminal first.' >&2
  exit 1
fi
mkdir -p "$records"
exec 9>"$records/revision-continuation.lock"
flock -n 9 || { echo 'A continuation already holds this lock.' >&2; exit 1; }
python3 - "$native_record" "$session_id" <<'PY'
import hashlib,json,pathlib,sys
p=pathlib.Path(sys.argv[1]); data=p.read_bytes()
first=json.loads(data.splitlines()[0])
assert first['type']=='session_meta' and first['payload']['id']==sys.argv[2]
assert len(data)>=1441209
assert hashlib.sha256(data[:1441209]).hexdigest()=='fb00be3ba3976cf0b03be51354553ad2ca441b5d46797570753ec718205053f6'
print('Original native record prefix verified; it will be resumed without rewriting.')
PY
env CODEX_HOME="$public_codex_home" "$codex_binary" login status
cd "$workbench_root"
printf '%s\n' "This resumes the original recorded session for at most $continuation_minutes minutes."
printf '%s\n' 'Type your actual continuation prompt. Suggested:'
printf '%s\n' "讀取 $continuation_doc，繼續 tiny-stack-vm-01-run-20261122，依文件條件完成修改與測試。"
IFS= read -r -p 'Continue: ' owner_prompt
if [[ -z "$owner_prompt" || "$owner_prompt" != *tiny-stack-vm-01-run-20261122* ]]; then
  echo 'Enter a prompt naming tiny-stack-vm-01-run-20261122; no model started.' >&2
  exit 1
fi

# The owner starts this continuation and enters its actual message. The native
# CLI appends its own record; this launcher creates or rewrites no transcript.
timeout --foreground --signal=TERM --kill-after=20s "${continuation_minutes}m" \
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
    resume "$session_id" "$owner_prompt"
