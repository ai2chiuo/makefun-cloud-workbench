# Local PowerShell execution

The owner requested that tasks after Glasshouse run on local Windows PowerShell. The agent should start a hidden background process, start the official competition recorder before the native Codex session, use a fresh `codex exec` session, test the work, run official checks, submit within the authorized free scope and verify the receipt. The owner should not have to run a launcher or open a Kaggle notebook.

This is the requested workflow, not a claim that it is operational. The 0.167.0 print-only restricted command probe failed before its command started:

`windows sandbox failed: registered Core process has no package identity`

Starting hidden PowerShell succeeded. Starting its restricted nested Codex worker did not. No model was called and no account credential was copied for these probes. A zero outer CLI exit code is not evidence of successful worker execution.

The isolated official 0.171.0 distribution matched the SHA-256 published by the official GitHub release. Its startup also failed with the same package-identity error. See [the diagnostic report](deliveries/local-headless-preflight-20261123.json). The global CLI was not replaced. Do not change services, remove registered-Core environment flags, use a debugging package launcher for production, or turn off sandboxing to obtain a green result.

The matching upstream issue is [openai/codex#60633](https://github.com/openai/codex/issues/60633). It remains open as of the 2026-11-23 check. The installed CLI and actual restricted command must be verified again after a supported fix is available.

Before any new bounty implementation, independently verify native recording, provider usage, instruction context and any required parent chain with the current official Make.fun kit. An agent-created session must be described truthfully. A recorder wrapper does not grant permission to upload a private parent chat or remove a required parent. Do not reconstruct native logs from app snapshots.

Do not begin a bounty or claim background work is underway while startup or provenance checks are blocked. Preserve existing cloud records and completed submissions; do not silently switch providers.
