# Hard Fails

Treat the task as not done if any completion blocker below remains unresolved.
Use the corresponding policy file for full rule detail. This file is the concise completion gate.

## DTK And Platform

Apply `references/policies/dtk-selection.md`.

- DTK is locally available for the needed control, but the implementation still rebuilds `Button`, `TextField`, `ComboBox`, `Switch`, `CheckBox`, `Menu`, `ProgressBar`, or `ScrollBar` from plain Qt Quick Controls or custom wrappers without a narrow exception.
- The project forces a non-DTK global style such as `Basic`, `Fusion`, or `Material` without a stated platform constraint.
- A DTK-owned control still rewrites `background`, `contentItem`, `indicator`, `handle`, `popup`, or `delegate` without an exact local capability gap and narrow waiver.
- A desktop top-level window uses frameless or popup-window behavior as the default path without a validated reason.

## Windows And Title Bars

Apply `references/policies/windowing.md`.

- A main window still ships with a system title bar or otherwise bypasses the DTK standard unified header path.
- A DTK main-window path still breaks standard title-bar behavior through risky custom flags, missing DTK window controls, a missing main-menu affordance, covered or clipped top-right controls, or a custom menu trigger where `D.TitleBar.menu` should own the menu.
- A main window top-right strip does not expose menu, minimize, maximize or restore, and close, except that fixed-size windows may omit maximize or restore.
- A claimed DTK unified titlebar-toolbar path still shows a system title bar plus a second toolbar.
- Page-switching tabs still live in the page body instead of the DTK unified header toolbar.
- The header still cuts off scrollable content with an opaque toolbar slab instead of reading as the top frosted layer above underlapping content.
- A persistent-sidebar main window still repairs the top band with a separate full-width titleband surface instead of carrying the sidebar surface and right content base up under the DTK header controls.
- A persistent-sidebar content-side titlebar band still uses a plain color surface with no real titlebar blur layer.
- Main work-area page switching still hard cuts between major pages instead of using a short animated transition in the real page host.

## Persistent Sidebar Baseline

Apply `references/policies/sidebar.md`.

- A persistent primary left sidebar layout still misses the required left-right split-pane baseline with explicit sidebar surface, validated blur path, explicit content base, zero gap, and sidebar-edge divider.
- The sidebar baseline still uses a homepage-first or full-width top-band shell instead of entering the required split-pane structure directly.
- A sidebar list still center-aligns labels or the icon-text cluster instead of keeping a left-aligned row plan inside the centered sidebar lane.
- Sidebar navigation rows still render as purely visual surfaces without a real row-level click or tap target.
- Sidebar settings entry points are duplicated in-content despite an application main menu.
- A sidebar-bottom operational card is shown without an explicit product requirement.

## Dialogs And Settings

Apply `references/policies/dialogs-settings.md`.

- Standard desktop dialogs, About surfaces, or settings windows still bypass `D.DialogWindow`, `Settings.SettingsDialog`, or `D.AboutDialog` in favor of custom shells or popup-style `D.Dialog` where those DTK paths exist locally.
- A `D.DialogWindow` still hand-builds its footer with a bare `RowLayout` or `Flow` button row instead of a DTK-owned `D.DialogButtonBox` action area.
- A standard desktop dialog still bypasses a DTK-owned `D.DialogButtonBox` action row, flips the secondary-left / primary-right ordering, leaves a multi-action footer shrinking to content width instead of evenly splitting usable width, wraps that footer in a custom `contentItem` override, or still leaves page-style vertical margins around the action row.
- A `Settings.SettingsDialog` path still omits the root `icon`, bypasses locally exported `Settings.CheckBox`, `Settings.ComboBox`, or `Settings.LineEdit` without justification, or exposes restore-default as a normal settings row.
- In-app transient notifications still bypass locally exported DTK `FloatingMessage` in favor of custom transient shells.

## Theme And Icons

Apply `references/policies/theme-icons.md`.

- Non-theme QML files contain raw hex colors without a narrow waiver.
- Interactive icons default to `Theme.textMuted`.
- Clickable surfaces still ship without visible hover feedback, or they still hard cut hover, pressed, or lightweight selected-state visuals instead of animating them with theme motion tokens.
- A dark-theme interface still mixes in light-theme surfaces, or a light-theme interface still mixes in dark-theme surfaces, without an explicit system-surface waiver.

## Lists, Layout, And Density

Apply `references/policies/layout-density.md`.

- Variable-length data surfaces still ship as oversized per-item cards, clipped fixed-width rows, or horizontally scrolling desktop lists without a narrow exception.
- A page-level card row still open-codes multiple peer cards directly in `Row` / `RowLayout` instead of routing through the audited equalization host, so near-height alignment remains incidental.
- A card shell still uses a fixed `width`, `height`, `implicitWidth`, or `implicitHeight` instead of responsive sizing with content-driven layout and optional minimum or maximum bounds.
- Text or button content still overlaps, visible content is still cut off horizontally, child content still bleeds outside its host region, card shells still miss the fixed `1px` edge stroke, or card content insets still drop below the `8px` floor.
- Row, heading, or card content still shows obviously broken vertical rhythm, such as collapsed title/subtitle spacing, row content stuck to one edge, or visibly lopsided top-versus-bottom padding.
- A card shell still renders its primary `1px` stroke through an antialiased `Rectangle.border` instead of a dedicated stroke ring or stroke layer.
- A card's live content container still fills or bottoms out against the card shell without a real inner inset, especially when the bottom edge visually reads as `0px`.
- Repeated row surfaces rendered inside a card still run flush to the card content lane instead of keeping a second inner inset, or the bottom-most repeated row still collapses the card floor inset.
- The main scroll surface still shrinks away from the content base, the vertical scrollbar still floats inside an inset gutter, or the visible scrollbar track still runs up into the header or toolbar band.
- A mutually exclusive button row still leaves more than `10px` of visible spacing between adjacent peer buttons.
- A `D.ButtonBox` child button is still rebound into a second external `ButtonGroup` instead of using the box's built-in `group`.
- Single-line or multi-line row delegates still use the wrong leading icon size, non-file/non-app truthful lists still use live file or app icons, list leading icons still draw self-made background tiles, list content still sits off-center in the live list lane, or delegates still rely on self-referential or shadowed bindings.
- Multiple direct live-content containers still center or fill inside the same parent and can visibly stack, or a manually placed list-lane block still shrinks inside a wider host without balanced horizontal centering.
- Buttons still stretch far beyond their content needs without an explicit maximum width or justified exception.
- Desktop work surfaces still leave large unused side gutters while the main content is artificially narrowed without an explicit readability or product requirement.

## Progress And Charts

Apply `references/policies/progress-charts.md`.

- Progress indicators or scrollbars exceed `20px`, or the same ratio is rendered twice in ring and linear form on one surface.
- Rings, gauges, or charts still place detailed copy inside the graphic body.

## Audit

- `scripts/audit_uos_qml.sh` reports findings and the response neither fixes them nor explains the exact remaining waiver.
- `scripts/audit_uos_qml.sh` emitted stderr, detector self-check failed, or any other checker runtime error occurred and the task was still treated as passing.
- A new or tightened strong constraint was added to `SKILL.md` or `references/policies/*.md` without landing the matching `scripts/audit_uos_qml.sh` and, when needed, `scripts/validate_uos_release.sh` coverage in the same change.
- When the repo exposes the `UOS_DESIGN_VISUAL_AUDIT` runtime hook, treat runtime geometry findings as first-class blockers across the main window and any shipped auxiliary scene windows. Do not close the task on the strength of static grep heuristics alone.
- When the repo exposes runtime visual audit and the shipped UI extends beyond the first viewport, do not validate only the default scene. Keep repo-local scene coverage or equivalent explicit `--scene-key` coverage for deeper sections and auxiliary windows.
- When a page uses scroll-driven header glass, do not close the task unless runtime visual audit can drive that page into an actual header-overlap state through repo-local `prepareVisualAuditSection(...)` coverage or an equivalent automated path.
- When the repo exposes runtime visual audit and the shipped main window is resizable between its default and minimum supported size, do not validate only the default size. Keep repo-local window-size coverage or equivalent explicit `--window-size` coverage for at least one narrower supported size.
- When runtime visual audit can emit screenshot artifacts, do not close the task on pass or fail lines alone. Keep the current run's screenshot dump, verify that representative rest-state, stress-state, and narrower-size captures exist for the touched surface, and treat obvious screenshot-level defects as blocking.
- When the task starts or materially hardens a UOS desktop repo with a build system, do not leave the repo without a repo-local guarded build path and a sanctioned page scaffold if repeated UI regressions would otherwise be caught only at final audit.
- Compositor-dependent visuals such as header underlap, sidebar-top continuity, blur layering, or split-pane continuity were signed off from an `offscreen` run even though a live `xcb` or `wayland` session was available.
- Build success, static inspection, or a one-shot startup smoke was used as sign-off without a full review of touched UI, touched backend behavior, and relevant PRD or acceptance criteria.
- A touched shipped surface or behavior was closed without automatic dynamic validation on the built artifact using the strongest available automated path in the repo.
- The repo lacked adequate automatic dynamic validation for a touched shipped surface and the task was still closed without adding that automation or explicitly keeping the task blocked.
