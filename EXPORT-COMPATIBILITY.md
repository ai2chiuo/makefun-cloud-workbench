# Record export preflight: blocked

Verified on 22 November 2026, before entry source was written. No competition entry repository was created. The existing Cloud task is retained.

## Observations

1. The app can read the newer Cloud task, reported on host `durable`.
2. The local official Codex CLI reports `Logged in using ChatGPT`.
3. With that valid local login, `codex cloud list --json` returns an empty tasks array, not an authentication error.
4. Looking up the actual Cloud thread UUID with `codex cloud status` returns HTTP 404, `Invalid task ID`, from the legacy `/backend-api/wham/tasks/` route.
5. A fresh official Make.fun kit was downloaded and its CLI bytes verified against the kit manifest. The verified CLI SHA-256 is `c61843ba3b8140207e6ae1103710e18042e628f31b7e060442075176a6254075`.
6. That kit's `bundle --codex-cloud --dry-run --json`, using the public workbench repository and empty local Codex/Claude stores to exclude unrelated local records, exits 1 with `no session ... was found`.
7. The current Make.fun Codex cloud adapter still discovers GitHub repository environments and fetches task details through the legacy API. No native record or actual provider usage for this newer Cloud task was obtained.

These observations show that a valid local login did not resolve this task's export failure. They do not prove that every type of Codex Cloud task is unsupported. A reported HTTP 401 inside the Cloud computer and the local legacy-task lookup failure are separate observations.

## Consequences

Do not start an implementation intended for a paid Make.fun place in this client until a complete native record can actually be retrieved. Do not replace it with an app history snapshot, a manually reconstructed session, guessed token counts or a shared conversation page. Do not omit recorded instructions or reasoning. The task's `handed_over_places` is `none`: a hand-over is not a route to a reward.

## Compatible direction to verify next

A GitHub-hosted Codespace with the normal Codex CLI uses the CLI's own native session files rather than the legacy cloud task export API. The account owner should start the CLI session directly under public, shareable instructions. Verify a real native JSONL record and its provider usage through the official kit before entry coding, and retain the original files unchanged. Keep the kit and record files outside the 8,192-byte entry repository.

This is a proposed execution route, not a completed preflight: Codespaces access, remaining included compute/storage usage, the owner-started session and its actual record still need verification. No Codespace or billable compute was started during this repair. GitHub Actions image tests already passed for the old news project; that does not validate AI record export.

## Primary references

- Make.fun recording and submission rules: https://make.fun/skill.md
- Official CLI reference: https://learn.chatgpt.com/docs/developer-commands?surface=cli
- Legacy/current Cloud distinction: https://learn.chatgpt.com/docs/environments/cloud-environment
- Matching issue in the official Codex repository: https://github.com/openai/codex/issues/50182
- GitHub Codespaces overview and included-use policy: https://docs.github.com/en/codespaces/about-codespaces/what-are-codespaces
