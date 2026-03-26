# Enforcement Index

Use this file as a router, not the detailed rule payload.

## Route By Task

- DTK selection and fallback choice:
  - `references/policies/dtk-selection.md`
- Top-level windows, title bars, and menus:
  - `references/policies/windowing.md`
- Persistent primary left sidebar and control-center baseline:
  - `references/policies/sidebar.md`
- Dialogs, settings windows, About surfaces, and transient notifications:
  - `references/policies/dialogs-settings.md`
- Theme variables, icon semantics, surfaces, and palette behavior:
  - `references/policies/theme-icons.md`
- Lists, tables, cards, row density, width strategy, and reusable container sizing:
  - `references/policies/layout-density.md`
- Progress bars, gauges, rings, charts, and numeric overlays:
  - `references/policies/progress-charts.md`
- Exception comments and waiver naming:
  - `references/policies/waivers.md`
- Completion blockers and must-fix conditions:
  - `references/policies/hard-fails.md`

## Usage

- When file choice is unclear, consult `references/routing.md` first.
- Load only the files that match the active task.
- Treat `references/policies/hard-fails.md` as the concise completion gate, not the full rule payload.
- Treat `references/policies/waivers.md` as the source of truth for exception comments.
- Prefer a small set of focused policy files over loading the whole policy directory.
