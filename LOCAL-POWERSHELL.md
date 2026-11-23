# Local PowerShell execution

The owner requested that tasks after Glasshouse run on local Windows PowerShell. The agent should start a hidden background process, start the official competition recorder before the native Codex session, use a fresh `codex exec` session, test the work, run official checks, submit within the authorized free scope and verify the receipt. The owner should not have to run a launcher or open a Kaggle notebook.

The local command-startup blocker was resolved with the officially documented MXC implementation on 2026-11-23. Codex CLI 0.171.0 successfully executed a fixed command inside MXC with exit code 0. A separate test verified permitted writes, denied writes outside the permitted folder, an explicitly denied synthetic file read, and blocked public outbound TCP. The same synthetic read and outbound connection succeeded in the unrestricted control, so the negative results were meaningful. See [the MXC report](deliveries/local-mxc-preflight-20261123.json) and [official documentation](https://learn.chatgpt.com/docs/windows/windows-sandbox).

Use `windows.sandbox="mxc"` for local `codex exec` runs, scoped to the actual task's workspace and delivery folders. Keep the official recorder outside the restricted worker and start it before the new native session. For diagnostics use `sandbox --include-managed-config --permission-profile <task-profile>` so managed requirements remain in force. No global user configuration, installed service, registered-Core flag or existing runtime was changed to obtain this result.

The initial MXC probes verified restricted command execution without model calls. A subsequent native Codex diagnostic confirmed real command execution and provider usage after the matching official code-mode host and command-runner helpers were installed beside the isolated CLI. No desktop runtime, service or global installation was replaced.

Site Sprint subsequently completed a real original implementation through an agent-started hidden PowerShell process, with MXC and automatic approval review retained. It passed 38 exact-output cases, deterministic driver checks, the official scorer and the official Docker grader on GitHub Actions, then was submitted for free as @freeway. Its [delivery report](deliveries/site-sprint-20261123.json) holds the receipt and latest checked status. This competition's live requirements explicitly make transcripts optional and every transcript/thinking check inapplicable, so no session, instruction context or private parent chat was uploaded. The genuine local native logs and usage remain unchanged.

This verifies the delivery path for transcript-optional free tasks. Official recording, native bundle export and any required parent chain remain separate gates for a competition that requires transcripts. Follow its actual current policy; do not impose that gate where it explicitly does not apply.

For historical comparison, the 0.167.0 legacy print-only restricted command probe failed before its command started:

`windows sandbox failed: registered Core process has no package identity`

Starting hidden PowerShell succeeded. Starting its legacy restricted nested Codex worker did not. A zero outer CLI exit code is not evidence of successful worker execution.

The isolated official 0.171.0 distribution matched the SHA-256 published by the official GitHub release. Its startup also failed with the same package-identity error. See [the diagnostic report](deliveries/local-headless-preflight-20261123.json). The global CLI was not replaced. Do not change services, remove registered-Core environment flags, use a debugging package launcher for production, or turn off sandboxing to obtain a green result.

The matching legacy upstream issue is [openai/codex#60633](https://github.com/openai/codex/issues/60633). It remains open as of the 2026-11-23 check. Using MXC is a verified alternative on this machine, not evidence that the legacy defect has been fixed upstream.

Before any new bounty implementation, independently verify native recording, provider usage, instruction context and any required parent chain with the current official Make.fun kit. An agent-created session must be described truthfully. A recorder wrapper does not grant permission to upload a private parent chat or remove a required parent. Do not reconstruct native logs from app snapshots.

Do not begin a bounty or claim background work is underway while startup or provenance checks are blocked. Preserve existing cloud records and completed submissions; do not silently switch providers.
