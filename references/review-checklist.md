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
- Screenshot-level obvious regressions that must not slip through a green log:
  - `references/review/obvious-visual-failures.md`
- Final review close-out:
  - `references/review/close-out.md`

## Audit Coverage Discipline

- When maintaining this skill, treat strong constraints as incomplete until the matching blocking audit or runtime validation rule lands in the same change.
- Current automatic DTK fallback coverage includes plain `Button`, `TextField`, `ComboBox`, `Switch`, `CheckBox`, `Menu`, `ProgressBar`, and `ScrollBar`, plus settings `CheckBox`, `ComboBox`, and `LineEdit`.
- Also expect blocking audit coverage for DTK template overrides, DTK-owned dialog footers, custom window-button rows, DTK titlebar menu ownership, missing content-side titlebar blur, fixed card shell sizes, antialiased card-shell stroke misuse, centered sidebar list content, live card-content inset failures, card-internal list rows that run edge-to-edge or collapse the bottom floor inset, visible layered-content stacking, and off-center list-lane blocks.
- Also expect blocking runtime coverage for page-heading gap collapse, compact-row top-and-bottom padding drift, and compact-row icon-text vertical misalignment when those failures would still read as obviously wrong by eye.
- Also expect blocking audit coverage for hover-feedback hard cuts, raw shell-behavior duration literals, and main page hosts that hard cut between major pages with no real transition.
- Also expect blocking audit coverage for page-level raw card `Row` / `RowLayout` bands that still place multiple peer cards directly instead of routing through the audited equalization host.
- Also expect the static audit tool itself to stay clean: detector self-check must pass and audit stderr noise is a blocking tool failure, not an ignorable warning.
- Also expect blocking audit or runtime coverage for non-interactive sidebar navigation rows that visually appear selectable but do not expose a real row-level click or tap target.
- Also expect runtime coverage for persistent-sidebar split seams that remain visible beyond the allowed divider and for header top-edge or content-side title bands that still read as separate painted strips at rest.
- Also expect pages with scroll-driven header glass to expose repo-local visual-audit scene prep that actually scrolls the main viewport into header overlap, so active frosted-header behavior is validated instead of inferred.
- Also expect runtime coverage for the main scroll surface filling the content base directly and for the vertical scrollbar staying on the far-right edge below the header or secondary-toolbar boundary.
- Also expect runtime visual audit to leave screenshot artifacts for the current run, plus an explicit review of representative rest-state, stress-state, and narrow-width captures instead of treating a green console log as the full visual sign-off.
- Also expect screenshot-level review against the obvious-failure atlas for recurring defects such as sidebar-top breaks, split seams, header slabs, list-lane drift, card bottom crowding, or near-height card stagger.
- Also expect repeated list-row surfaces to expose one `visualAuditContentNode` host so runtime audit can verify row-lane centering instead of guessing from arbitrary descendants.
- When the repo exposes runtime visual audit, expect repo-local scene coverage for deep scroll sections, secondary page states, and auxiliary windows instead of validating only the default first viewport.
- When the repo exposes runtime visual audit and the main window is meaningfully resizable, also expect repo-local window-size coverage for at least one narrower supported size instead of validating only the default window size.

## Usage

- When file choice is unclear, consult `references/routing.md` first.
- Do not load the whole `references/review/` directory by default.
- Load only the review files that match the code under review.
- When closing an implementation that changed shipped UOS UI or behavior, load this review router even if the user did not explicitly ask for a review.
- Use `references/policies/hard-fails.md` with these review files only when deciding whether the task is complete.
- Use `references/policies/waivers.md` only when validating an exception.
- Run `scripts/audit_uos_qml.sh <repo-root>` before closing the review.
- When a policy change adds or tightens a strong constraint, verify the same diff also updates the audit or runtime validation coverage.
- Surface concrete findings first. Treat missing DTK usage, unresolved audit findings, and behavioral regressions as primary issues.
