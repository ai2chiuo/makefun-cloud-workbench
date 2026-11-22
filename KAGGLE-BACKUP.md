# Kaggle compute backup

Requested provider order: use included GitHub Codespaces compute first; when that included allowance is actually exhausted, use Kaggle's free Notebook compute for compatible workloads. A repository authorization error is not quota exhaustion. The preference is recorded in compute-providers.json; it is not a claim that a running coding session can already migrate automatically.

The official Kaggle CLI is connected as `ai2chiuo` through the owner's official OAuth login. A real private CPU execution completed successfully on 2026-11-22 at 07:22:09 UTC. Downloaded output integrity was verified on the authorized delivery computer. No access token belongs in chat, Git, kernel source or saved outputs.

## First real probe

The `kaggle/cpu_preflight.py` was uploaded as a new **private**, **CPU-only** Python script with Internet enabled and a 600-second execution limit. It verified the real Kaggle runtime, preinstalled Node v22.23.4, a child process, file output and deterministic output hash. All three public GitHub, Make.fun and OpenAI discovery URL probes returned HTTP 200. It made no model calls and read no credentials. Only the report and benign test files were written under `/kaggle/working`.

Kernel `ai2chiuo/makefun-cpu-preflight-20261122`, version 1, reached official status `COMPLETE`. Server metadata confirmed private visibility and GPU disabled. The downloaded deterministic payload was exactly `makefun-kaggle-preflight-v1:42` followed by a newline, with SHA-256 `b7ad0b93a1c1429645705807fbacb7de1a90da282ae5b0dd4c57747c0cb10cca`; the Node result was 42. The safe evidence summary is in `kaggle/preflight-result.json`.

For future jobs, wait for the official kernel status, download the output, and verify its expected contents before marking execution ready. If Kaggle requires account or phone verification, the owner completes that official process. Do not bypass quotas, time limits or verification.

## Workload boundaries

Kaggle Notebooks are session-based compute. Use them for bounded builds, tests or batch jobs; do not assume a persistent interactive terminal or unlimited uptime. Keep source commits and the complete original native development records outside an expiring runtime as well. No keepalive loops, account cycling, tunnels or paid Google Cloud upgrades are part of this setup.

A CPU probe does not validate Codex sign-in or native transcript export. Before using Kaggle for a rewarded Make.fun implementation, separately verify the genuine native client records, actual provider usage, instruction context and required parent chain. Do not fabricate an export or transfer an existing provider's credential files. Codex model usage remains separate from free computer time.

Official references:

- https://www.kaggle.com/docs/notebooks
- https://github.com/Kaggle/kaggle-cli/blob/main/docs/kernels.md
- https://github.com/Kaggle/kaggle-cli/blob/main/docs/kernels_metadata.md
- https://github.com/Kaggle/kaggle-cli/blob/main/skills/references/auth.md
