# Review Checklist Index

Use this file as the review router, not as the full checklist payload.

## Selection Order

1. Confirm the review scope first. When control availability matters, verify local exports with `references/local-dtk-controls.md`.
2. Load only the smallest matching file under `references/review/`.
3. Use the corresponding `references/policies/*.md` file named by that review file for rule detail.
4. Load component, foundation, or broad fallback references only when the review file and policy file still do not answer the question.
5. Load `references/policies/waivers.md` only when exceptions remain or need validation.
6. Load `references/policies/hard-fails.md` when deciding whether the task is complete.
7. Load `references/review/close-out.md` before finalizing a substantial review close-out or implementation close-out.

## Scope And Environment

- Load this file when setup, DTK exports, build integration, or routing discipline are part of the review:
  - `references/review/environment.md`

## Route By Review Focus

- Environment, DTK export validation, build integration, and routing discipline:
  - `references/review/environment.md`
- Window strategy, title bars, menu placement, and unified-header validation:
  - `references/review/windowing.md`
- Persistent primary left sidebar baseline and control-center behavior:
  - `references/review/sidebar.md`
- Dialogs, settings windows, About surfaces, and transient notifications:
  - `references/review/dialogs-settings.md`
- Theme variables, icon semantics, surfaces, and palette integration:
  - `references/review/theme-icons.md`
- Lists, tables, cards, row density, width strategy, and reusable container sizing:
  - `references/review/layout-density.md`
- Progress bars, gauges, rings, charts, and numeric overlays:
  - `references/review/progress-charts.md`
- Final review close-out:
  - `references/review/close-out.md`

## Usage

- When file choice is unclear, consult `references/routing.md` first.
- Do not load the whole `references/review/` directory by default.
- Load only the review files that match the code under review.
- When closing an implementation that changed shipped UOS UI or behavior, load this review router even if the user did not explicitly ask for a review.
- Use `references/policies/hard-fails.md` with these review files only when deciding whether the task is complete.
- Use `references/policies/waivers.md` only when validating an exception.
- Run `scripts/audit_uos_qml.sh <repo-root>` before closing the review.
- Surface concrete findings first. Treat missing DTK usage, unresolved audit findings, and behavioral regressions as primary issues.
