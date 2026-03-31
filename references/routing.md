# Routing Guide

Load this file when `SKILL.md` alone is not enough to choose the smallest relevant reference set. Prefer focused policy, component, and foundation files before broad fallback references.

## Selection Order

1. Confirm local DTK availability with `references/local-dtk-controls.md`.
2. Load the matching policy file first when one exists for the task.
3. Load component or foundation files only when the task directly touches that component family or design token family.
4. Load broad fallback references only when the focused files still do not answer the question.
5. Load review files only for review or close-out tasks.
6. Load `references/policies/waivers.md` only when an exception is actually needed.
7. Load `references/policies/hard-fails.md` when deciding whether the task is complete.

## Minimal Baseline

- DTK availability and local exports:
  - `references/local-dtk-controls.md`
- Repo-local guardrails, page scaffolds, and default developer workflow:
  - `references/repo-guardrails.md`

## Broad Fallback References

- Use these only when focused policy, component, or foundation files are still insufficient:
  - `references/design-rules.md`
  - `references/design-system-quick-reference.md`
  - `references/design-system-modular.yaml`

## Route By Task

- Theme variables and semantic surfaces:
  - Primary policy:
    - `references/policies/theme-icons.md`
  - Optional foundations. Load only the files you actually need:
    - `references/foundations/colors.md`
    - `references/foundations/typography.md`
    - `references/foundations/radius.md`
    - `references/foundations/spacing.md`
    - `references/foundations/animation.md`
- Platform compatibility, Wayland/X11, Qt/DTK runtime caveats:
  - Primary:
    - `references/platform-compatibility.md`
- Repo bootstrap, guarded build integration, page scaffolds, or primitive-first authoring setup:
  - Primary:
    - `references/repo-guardrails.md`
  - Action path when the task is to seed a new repo:
    - `scripts/install_repo_guardrails.sh`
- Window structure, title bars, and top-level layout:
  - Primary policy:
    - `references/policies/windowing.md`
  - Optional detail:
    - `references/components/unified-header.md`
    - `references/components/blur.md` when the task specifically concerns header glass, toolbar blur, or scrolling content reading through the frosted top band
    - `references/design-system-layout.md`
    - `references/design-system-window-behavior.md`
- Header glass, Unote-like toolbar blur, or same-window content sampling under the header:
  - Primary:
    - `references/components/unified-header.md`
    - `references/components/blur.md`
  - Optional:
    - `references/platform-compatibility.md`
    - `references/policies/waivers.md`
- Persistent primary left sidebar or control-center baseline:
  - Primary policy:
    - `references/policies/sidebar.md`
  - Optional detail:
    - `references/components/unified-header.md`
    - `references/components/sidebar.md`
    - `references/components/control-center-sidebar.md`
- Dialogs, About surfaces, and settings windows:
  - Primary policy:
    - `references/policies/dialogs-settings.md`
  - Optional detail:
    - `references/components/dialog.md`
    - `references/components/settings.md`
- DTK-versus-custom control choice:
  - Primary policy:
    - `references/policies/dtk-selection.md`
- Lists, tables, cards, and layout density:
  - Primary policy:
    - `references/policies/layout-density.md`
  - Optional detail:
    - `references/components/card.md`
    - `references/foundations/colors.md`
    - `references/design-system-layout.md` when the task includes dashboard bands, mixed spans, or card wall composition
- Progress, gauges, rings, and charts:
  - Primary policy:
    - `references/policies/progress-charts.md`
  - Optional detail:
    - `references/components/progress.md`
- Exceptions and completion gates:
  - Load only when needed:
    - `references/policies/waivers.md`
    - `references/policies/hard-fails.md`
- Reviews:
  - Primary index:
    - `references/review-checklist.md`
  - Optional scope and environment review. Load when setup, DTK exports, build integration, or routing discipline matter:
    - `references/review/environment.md`
  - Matching review file(s). Load only the smallest set that matches the code under review:
    - `references/review/windowing.md`
    - `references/review/sidebar.md`
    - `references/review/dialogs-settings.md`
    - `references/review/theme-icons.md`
    - `references/review/layout-density.md`
    - `references/review/progress-charts.md`
    - `references/review/obvious-visual-failures.md` when screenshot-level defects are a risk or when closing a shipped UI change
  - Final review close-out. Load before finishing a substantial review close-out or implementation close-out:
    - `references/review/close-out.md`

## Component Routing

Use this as a second-hop list after task routing. Do not load this whole section by default. Prefer foundation and policy files first when they already answer the question.

- Inputs and selection:
  - `references/components/input.md`
  - `references/components/combobox.md`
  - `references/components/switch.md`
  - `references/components/slider.md`
  - `references/components/form.md`
- Actions and menus:
  - `references/components/button.md`
  - `references/components/menu.md`
  - `references/components/dialog.md`
  - `references/components/notification.md`
  - `references/components/alert.md`
- Data display:
  - `references/components/list.md`
  - `references/components/table.md`
  - `references/components/card.md`
  - `references/components/progress.md`
  - `references/components/badge.md`
  - `references/components/tooltip.md`
  - `references/components/pagination.md`
  - `references/components/skeleton.md`
  - `references/components/empty.md`
- Navigation and structure:
  - `references/components/unified-header.md`
  - `references/components/tab.md`
  - `references/components/breadcrumb.md`
  - `references/components/stepper.md`
  - `references/components/drawer.md`
  - `references/components/sidebar.md`
  - `references/components/control-center-sidebar.md`
- Visual surfaces and identity:
  - `references/components/blur.md`
  - `references/components/avatar.md`
