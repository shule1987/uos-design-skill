---
name: uos-design
description: Reference a UOS and Deepin style QML design system for DTK-first desktop UI work. Use when designing, implementing, or reviewing theme tokens, layout, window behavior, blur effects, or common desktop components.
---

# UOS Design

Use this skill when the user is building or reviewing a UOS or Deepin style desktop interface in QML, especially for DTK-first applications.

## When To Use

Use this skill for requests about:
- theme tokens such as colors, typography, spacing, and animation
- desktop layout patterns, sidebars, title bars, and window behavior
- blur effects, glass surfaces, and other UOS visual conventions
- common QML components such as buttons, inputs, dialogs, menus, tables, and forms
- auditing an interface for consistency with the UOS design language

Do not use this skill for generic web design unless the user explicitly wants the UOS or Deepin visual style.

## Workflow

1. Route the request with `references/design-system-modular.yaml`.
2. Read only the files needed for the task.
3. Prefer DTK native controls before custom implementations.
4. Reuse documented tokens instead of inventing new values.
5. Treat blur and heavy effects as progressive enhancement, not a hard dependency.

## File Routing

Start with the smallest relevant set:

- Theme tokens:
  - `references/foundations/colors.md`
  - `references/foundations/typography.md`
  - `references/foundations/spacing.md`
  - `references/foundations/animation.md`
- Global rules:
  - `references/design-rules.md`
- Layout and windows:
  - `references/design-system-layout.md`
  - `references/design-system-window-behavior.md`
- Broad lookup:
  - `references/design-system-quick-reference.md`
- Machine-readable index:
  - `references/design-system-modular.yaml`
- Components:
  - `references/components/button.md`
  - `references/components/input.md`
  - `references/components/menu.md`
  - `references/components/dialog.md`
  - `references/components/card.md`
  - `references/components/sidebar.md`
  - `references/components/switch.md`
  - `references/components/slider.md`
  - `references/components/badge.md`
  - `references/components/tab.md`
  - `references/components/combobox.md`
  - `references/components/tooltip.md`
  - `references/components/progress.md`
  - `references/components/list.md`
  - `references/components/blur.md`
  - `references/components/table.md`
  - `references/components/pagination.md`
  - `references/components/skeleton.md`
  - `references/components/drawer.md`
  - `references/components/empty.md`
  - `references/components/avatar.md`
  - `references/components/alert.md`
  - `references/components/notification.md`
  - `references/components/form.md`
  - `references/components/breadcrumb.md`
  - `references/components/stepper.md`

## Implementation Rules

- Prefer `org.deepin.dtk` controls when they satisfy the request.
- Keep color and spacing choices aligned with the documented theme tokens.
- Preserve keyboard navigation, focus states, and contrast requirements.
- Use the window and title-bar rules for desktop shells instead of inventing new chrome.
- When a requested component is not documented, say so plainly instead of pretending it exists.

## Conflict Resolution

If documents disagree, use this order:

1. `references/foundations/*.md` and `references/components/*.md`
2. `references/design-rules.md`
3. `references/design-system-layout.md` and `references/design-system-window-behavior.md`
4. `references/design-system-quick-reference.md`
5. `references/design-system-modular.yaml` for routing and indexing only

## Response Guidance

- Cite the exact files you used.
- Keep answers implementation-oriented.
- When reviewing UI code, call out mismatches against the documented tokens or rules.
- When generating new QML, follow the naming and state conventions already documented here.
