# Role Map

Use the smallest role set that keeps ownership clean.

## Lead Agent

- Owns architecture, primitive choices, policy interpretation, shared files, and final sign-off.
- Keeps final ownership of high-fanout files such as `App.qml`, `Theme.qml`, shared window shells, audit manifests, and repo guardrails unless one worker is explicitly assigned.
- Runs the final integrated static audit, runtime validation, and screenshot review.

## Capability Scout

- Prefer an `explorer`.
- Read-only scope: Qt and DTK exports, windowing stack, build hooks, existing primitives, acceptance docs.
- Returns facts and constraints, not code changes.

## Primitive Worker

- Prefer a `worker`.
- Owns reusable components, theme tokens, scaffolds, repo guardrails, and other shared building blocks.
- Typical scope: `src/qml/components/`, `src/qml/theme/`, `scripts/uos_*`, `cmake/`, repo-local scaffolds.

## Surface Worker

- Prefer one `worker` per disjoint UI lane.
- Owns page, dialog, or module files plus lane-local assets and models.
- Must treat shared primitives as read-only unless the brief explicitly transfers ownership.

## Audit Scout

- Prefer an `explorer` for read-only review or a `worker` when audit wiring must change.
- Owns scene and window-size coverage checks, preliminary audit runs, and screenshot triage notes.
- The lead agent still reruns the final integrated validation.

## Split Rules

- Keep concurrent workers small in number. Two or three clear ownership lanes are usually better than many shallow agents.
- Split by file ownership, not by abstract intent.
- Do not give the same file to multiple workers.
