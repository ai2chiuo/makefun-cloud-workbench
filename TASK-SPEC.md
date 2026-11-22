# Tiny stack VM: verified task brief

Sources checked 22 November 2026:

- https://make.fun/bounty/tiny-stack-vm-01-run-20261122
- https://make.fun/api/competitions/tiny-stack-vm-01-run-20261122/requirements
- https://make.fun/api/competitions/tiny-stack-vm-01-run-20261122
- https://make.fun/skill.md (version 1.5.253 when checked)

## Window and reward

Opens 2026-11-22T04:00:00Z; entries close 2026-11-25T04:00:00Z. These are 12:00 Asia/Taipei on those dates. Free entry. Total reward $100 USDC, ten paid places of $10 each. A paid entry must score strictly above the best house baseline, not merely appear in the first ten. Before opening the API returns `can_submit=false`; do not call this a ready-to-submit task yet.

## Contract

The grader runs `node /bot/main.ts` under Node 22. JavaScript/TypeScript source only; no pre-run package installation, WebAssembly, native addon or prebuilt binary. The whole submitted repository is at most 8,192 bytes. One execution must answer a set within 60 seconds and repeated executions must write identical bytes.

Each instance consists of `program.bin` and `input.bin`. The output must exactly match both the VM's output bytes and exit code in the format the kit specifies. Read `generator/subject/ISA.md` for the actual binary encoding, filesystem I/O contract and limits; do not guess them from this summary. The published reference `generator/subject/vm.mjs` defines expected behavior and is an oracle for tests, not source to copy into the entry.

The ISA has wrapping 32-bit integers, a 256-value stack, branches and calls, 256 words of memory, input/output, ten distinct traps, and step/output limits. A set has 40 programs: 26 normal cases and 14 hard edge cases. Scores range up to 1,000,000 over the set. Practice data is published in the kit; final programs are generated after the deadline. Do not hardcode practice answers or exploit the checker.

## Verification approach

Derive targeted independent cases from ISA.md covering signed overflow, branch offsets and invalid targets, call/return behavior, stack bounds, memory indexing, input exhaustion, output limit, step limit and every specified trap. Compare results with the official reference oracle. Use randomized bounded programs when useful, with fixed seeds and explicit limits; never use a reference implementation at grading time.

Run the official local practice checker and report raw score, elapsed time, correctness and exact repository size. Keep a clean checkout verification of the final entry commit. Use meaningful tests; do not relax failing cases or change the published checker.

## Delivery and records

The required deliverables include a public repository, full commit SHA, MIT/other OSI license, root main.ts and a bundle of genuine AI development records. Add ownership evidence for the linked public wallet when the requirements demand it: `2LnEaJGE2BBq6ybNnunP4L4fGkqadnAHtNSFrfodUW2y`. This public address is not an authorization key.

Official kit URLs: https://make.fun/api/competitions/tiny-stack-vm-01-run-20261122/kit and https://make.fun/c/tiny-stack-vm-01-run-20261122/kit . Read the kit metadata and current initialization rules before creating source. Where the SDK's authenticated init requires credentials unavailable to the cloud session, stop before inventing initialization evidence; have the authorized delivery process provide the required genuine public initialization files.

The official bundler supports cloud records through `--codex-cloud`. Confirm that the actual cloud task is retrievable before developing. If retrieval is unavailable, report that rather than creating a synthetic session. The owner starts this cloud task directly; existing private local chat logs must not be uploaded or reconstructed.
