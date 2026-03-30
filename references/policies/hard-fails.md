# Hard Fails

Treat the task as not done if any completion blocker below remains unresolved.
Use the corresponding policy file for full rule detail. This file is the concise completion gate.

## DTK And Platform

Apply `references/policies/dtk-selection.md`.

- DTK is locally available for the needed control, but the implementation still rebuilds the control from plain Qt Quick Controls or custom wrappers without a narrow exception.
- The project forces a non-DTK global style such as `Basic`, `Fusion`, or `Material` without a stated platform constraint.
- A desktop top-level window uses frameless or popup-window behavior as the default path without a validated reason.

## Windows And Title Bars

Apply `references/policies/windowing.md`.

- A main window still ships with a system title bar or otherwise bypasses the DTK standard unified header path.
- A DTK main-window path still breaks standard title-bar behavior through risky custom flags, missing DTK window controls, a missing main-menu affordance, covered or clipped top-right controls, or a custom menu trigger where `D.TitleBar.menu` should own the menu.
- A main window top-right strip does not expose menu, minimize, maximize or restore, and close, except that fixed-size windows may omit maximize or restore.
- A claimed DTK unified titlebar-toolbar path still shows a system title bar plus a second toolbar.
- Page-switching tabs still live in the page body instead of the DTK unified header toolbar.
- The header still cuts off scrollable content with an opaque toolbar slab instead of reading as the top frosted layer above underlapping content.

## Persistent Sidebar Baseline

Apply `references/policies/sidebar.md`.

- A persistent primary left sidebar layout still misses the required left-right split-pane baseline with explicit sidebar surface, validated blur path, explicit content base, zero gap, and sidebar-edge divider.
- The sidebar baseline still uses a homepage-first or full-width top-band shell instead of entering the required split-pane structure directly.
- Sidebar settings entry points are duplicated in-content despite an application main menu.
- A sidebar-bottom operational card is shown without an explicit product requirement.

## Dialogs And Settings

Apply `references/policies/dialogs-settings.md`.

- Standard desktop dialogs, About surfaces, or settings windows still bypass `D.DialogWindow`, `Settings.SettingsDialog`, or `D.AboutDialog` in favor of custom shells or popup-style `D.Dialog` where those DTK paths exist locally.
- A `Settings.SettingsDialog` path still omits the root `icon`, bypasses locally exported settings controls without justification, or exposes restore-default as a normal settings row.
- In-app transient notifications still bypass locally exported DTK `FloatingMessage` in favor of custom transient shells.

## Theme And Icons

Apply `references/policies/theme-icons.md`.

- Non-theme QML files contain raw hex colors without a narrow waiver.
- Interactive icons default to `Theme.textMuted`.
- Clickable surfaces still ship without visible hover feedback.
- A dark-theme interface still mixes in light-theme surfaces, or a light-theme interface still mixes in dark-theme surfaces, without an explicit system-surface waiver.

## Lists, Layout, And Density

Apply `references/policies/layout-density.md`.

- Variable-length data surfaces still ship as oversized per-item cards, clipped fixed-width rows, or horizontally scrolling desktop lists without a narrow exception.
- Text or button content still overlaps, visible content is still cut off horizontally, child content still bleeds outside its host region, or card content insets still drop below the 6px floor.
- Multi-line row delegates still lack a leading icon by default, hardcode one shared icon for all items, use untruthful height contracts, or rely on self-referential or shadowed bindings.
- Buttons still stretch far beyond their content needs without an explicit maximum width or justified exception.
- Desktop work surfaces still leave large unused side gutters while the main content is artificially narrowed without an explicit readability or product requirement.

## Progress And Charts

Apply `references/policies/progress-charts.md`.

- Progress indicators or scrollbars exceed `20px`, or the same ratio is rendered twice in ring and linear form on one surface.
- Rings, gauges, or charts still place detailed copy inside the graphic body.

## Audit

- `scripts/audit_uos_qml.sh` reports findings and the response neither fixes them nor explains the exact remaining waiver.
- When the repo exposes the `UOS_DESIGN_VISUAL_AUDIT` runtime hook, treat runtime geometry findings as first-class blockers across the main window and any shipped auxiliary scene windows. Do not close the task on the strength of static grep heuristics alone.
- Build success, static inspection, or a one-shot startup smoke was used as sign-off without a full review of touched UI, touched backend behavior, and relevant PRD or acceptance criteria.
- A touched shipped surface or behavior was closed without automatic dynamic validation on the built artifact using the strongest available automated path in the repo.
- The repo lacked adequate automatic dynamic validation for a touched shipped surface and the task was still closed without adding that automation or explicitly keeping the task blocked.
