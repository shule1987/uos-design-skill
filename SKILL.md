---
name: uos-design
description: Reference a UOS and Deepin style QML design system for DTK-first desktop UI work on Linux desktops. Use when designing, implementing, or reviewing theme tokens, layout, window behavior, platform compatibility, blur effects, or common desktop components.
---

# UOS Design

Use this skill when the user is building or reviewing a UOS or Deepin style desktop interface in QML, especially for DTK-first applications.

## When To Use

Use this skill for requests about:
- theme tokens such as colors, typography, spacing, radius, and animation
- desktop layout patterns, sidebars, title bars, and window behavior
- blur effects, glass surfaces, and other UOS visual conventions
- common QML components such as buttons, inputs, dialogs, menus, tables, and forms
- auditing an interface for consistency with the UOS design language

Do not use this skill for generic web design unless the user explicitly wants the UOS or Deepin visual style.

## Workflow

1. Route the request with `references/design-system-modular.yaml` and `references/platform-compatibility.md`.
2. Before proposing or writing QML, inspect the local environment for:
   - target Qt version
   - availability of `org.deepin.dtk` / `Dtk6Declarative`
   - target session type (`Wayland` or `X11`) when windowing or popup behavior matters
   - build integration points (`CMakeLists.txt`, `main.cpp`, QML imports)
   - whether the current Qt/DTK/window-manager combination can actually render a unified titlebar-toolbar as a single window-manager-owned top band; do not infer this from `X11`, `Wayland`, `xcb`, or `wayland` alone
3. Read only the files needed for the task.
4. Map the requested UI to documented components and then to locally available DTK controls.
5. If DTK provides the control, use DTK directly instead of wrapping plain Qt Quick Controls for styling convenience.
6. Only fall back to custom QML or plain Qt Quick Controls when you can state the exact missing DTK capability, version limitation, or platform constraint.
7. Keep every fallback narrow and explicit; do not build a parallel non-DTK design system when DTK is available.
8. For top-level windows, preserve window-manager-owned decorations and behaviors first. If the validated Qt/DTK/platform combination supports a unified titlebar-toolbar presentation without giving up window-manager border, shadow, rounded corners, move, resize, maximize, snap, and related behaviors, use that. Otherwise keep the system-decorated title bar and place the app toolbar directly below it.
9. If the user explicitly requires a unified titlebar-toolbar presentation by default with a system-decorated fallback, treat that as a dual-path requirement. Implement the validated unified-by-default path plus the fallback path, or state the exact platform blocker before coding. Fallback-only is not a completed implementation for that request.
10. For requests that require unified titlebar-toolbar by default, validate the result at runtime after implementation. A unified path is valid only if the final UI shows one top header band rather than a system title bar plus a second in-content toolbar.
11. Reuse documented tokens instead of inventing new values.
12. Verify that any token, property, or component name used in an answer is defined in the referenced files.
13. Run `scripts/audit_uos_qml.sh <repo-root>` before substantial UI edits and again before finishing. Treat every finding as blocking unless you fix it or add a narrow waiver that the skill allows.

## File Routing

Start with the smallest relevant set:

- Theme tokens:
  - `references/foundations/colors.md`
  - `references/foundations/typography.md`
  - `references/foundations/radius.md`
  - `references/foundations/spacing.md`
  - `references/foundations/animation.md`
- Global rules:
  - `references/design-rules.md`
- Platform compatibility:
  - `references/platform-compatibility.md`
- Layout and windows:
  - `references/design-system-layout.md`
  - `references/design-system-window-behavior.md`
- Broad lookup:
  - `references/design-system-quick-reference.md`
- Machine-readable index:
  - `references/design-system-modular.yaml`
- Bundled tools:
  - `scripts/audit_uos_qml.sh`
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

- Treat `org.deepin.dtk` as mandatory when the needed control exists locally. `Prefer DTK` here means `use DTK unless you can prove it is unavailable or insufficient`.
- For main windows, first check whether `org.deepin.dtk.ApplicationWindow`, `TitleBar`, `WindowButtonGroup`, `Menu`, `Dialog`, `Button`, `TextField`, `ComboBox`, `Switch`, `CheckBox`, `ProgressBar` and related controls are available locally.
- Any button that opens the application main menu must use the standard DTK menu button affordance. Do not use a custom `AppButton`, plain `Button`, or other custom trigger for the application main menu when DTK provides the menu button.
- Application main-menu placement must follow DTK menu-button behavior and attachment conventions. Do not hardcode window-relative `x` or `y` coordinates for the application main menu unless a validated platform constraint is documented.
- If the user requests network-downloaded SVG icons, keep icon loading separate from control choice. Custom icon sourcing is not a reason to abandon DTK controls.
- Do not implement custom wrappers around plain Qt Quick Controls for `Button`, `TextField`, `ComboBox`, `Switch`, `CheckBox`, `Menu`, `Dialog`, `ProgressBar`, or window buttons when DTK already provides the control.
- When DTK provides a control, do not replace its standard DTK visual template by overriding structural sub-items such as `background`, `contentItem`, `indicator`, `handle`, `popup`, or `delegate` on `D.Button`, `D.TextField`, `D.ComboBox`, `D.Switch`, `D.CheckBox`, `D.Menu`, `D.Dialog`, `D.ProgressBar`, or related DTK controls unless a narrow platform-specific waiver explains the exact missing DTK capability. Inheriting from a DTK control and then redrawing its template still counts as a custom control implementation.
- All application dialogs, including confirmation, warning, destructive-action, progress, and form dialogs, must use DTK-provided dialog types when they are available locally. Project code should provide only the dialog's text content, semantic state, and action signals; let DTK own the dialog frame, spacing, buttons, shadow, and other visual styling. Do not build a custom dialog shell with `Popup`, plain Qt Quick Controls `Dialog`, or a restyled DTK dialog unless a narrow platform-specific waiver explains the exact missing DTK capability.
- Any About entry that opens an About window or dialog must use the DTK standard `AboutDialog` when it is available locally. Do not replace it with a custom about popup or a custom `AppDialog` implementation.
- Any in-app toast, floating message, or transient application notification must use the DTK standard `FloatingMessage` when it is available locally. Do not replace it with a custom `ToastStack`, a custom repeater of notification cards, or another custom in-app notification container unless a narrow platform-specific waiver explains the exact missing DTK capability.
- Do not force `QQuickStyle::setStyle("Basic")`, `Fusion`, `Material`, `Imagine`, or similar non-DTK styles for UOS/Deepin tasks unless the user explicitly asks for that or DTK is unavailable.
- Do not treat `Qt.FramelessWindowHint` or a self-drawn title bar as the default implementation path for UOS/Deepin desktop windows.
- Default to window-manager-owned top-level decorations and behaviors. Use a visually unified header only when the target Qt/DTK/platform combination has been validated to preserve window-manager border, shadow, rounded corners, move, resize, maximize, snap, and related behaviors.
- When the requirement says window rounded corners, border, and shadow must be owned by the window manager, do not tune those effects from app-side QML or application-side DTK decoration properties. Do not use `D.DWindow.windowRadius`, `D.DWindow.borderWidth`, `D.DWindow.borderColor`, `D.DWindow.shadowRadius`, `D.DWindow.shadowOffset`, or `D.DWindow.shadowColor` to visually approximate window-manager decoration ownership unless the user explicitly allows that fallback.
- If a visually unified header path still depends on app-side decoration tuning for top-level rounded corners, border, or shadow, classify that path as not meeting the `window-manager-owned decoration` requirement and fall back to system decorations instead.
- Treat platform identifiers such as `X11`, `Wayland`, `xcb`, `wayland`, Qt version, or DTK version as routing hints only. They are not proof that a unified titlebar-toolbar path is available.
- For desktop applications with a persistent left sidebar, use a mandatory left-right split layout: the left side is the sidebar navigation column and the right side is the main content area. Do not use a top-bottom shell, stacked sidebar-above-content shell, or floating primary navigation as the default desktop structure unless the user explicitly requires that deviation.
- For desktop applications with a persistent left sidebar, the sidebar surface must use a window-manager or compositor-provided blur path validated for the target environment. Do not fake the sidebar blur with a self-drawn shader, screenshot blur, plain translucent fill, or a local content blur substitute when the requirement is window-manager blur.
- For any window or region that is intentionally presented as a blur surface, treat its visual stack as `blur layer + tint/compositing layer`. Prefer DTK or system blur primitives that already bundle both behaviors, such as `blendColor`, a documented system fallback tint, or an equivalent validated platform composition path.
- When a validated DTK, window-manager, or compositor blur path already provides its own tint, overlay, blend, or fallback color layer, do not add a second self-drawn translucent `Rectangle`, `ShaderEffect`, screenshot tint, or other manual overlay above that same blurred area.
- Only add a single explicit self-drawn tint layer for a blurred area when the validated blur path is confirmed not to provide an internal tint or fallback color layer. In that case add a narrow waiver comment in the touched file: `uos-design: allow-manual-blur-overlay`, and state the exact platform, Qt/DTK version, component, and reason.
- Do not assume that the window manager or compositor "probably" provides an overlay or tint layer. Rely only on a validated runtime result or a documented DTK/system primitive contract.
- For desktop applications with a persistent left sidebar, the sidebar navigation list and its items must keep a 10px horizontal inset from the sidebar background on both the left and right sides. Do not increase, decrease, or visually absorb that inset unless the user explicitly requires a different spacing rule.
- For desktop applications with a persistent left sidebar, sidebar width may be adjustable. Do not encode a universal rule that collapse means a fixed `60px` icon rail.
- For sidebars with many entries, collapse support is recommended but optional. If collapse is provided, place the collapse toggle `20px` to the right of the top-left logo.
- For a resizable collapsible sidebar, reaching a minimum width of `100px` through resize, or explicitly activating the collapse toggle, must transition the sidebar to a hidden state. Expand and collapse must use a short animation.
- When the user explicitly requires a unified titlebar-toolbar presentation by default with a system-decorated fallback, do not stop at the fallback implementation. Either implement a validated unified-by-default path plus the fallback path, or state the exact platform blocker before coding.
- A unified titlebar-toolbar path is valid only if the final runtime UI shows a single top header band containing the app logo, the main-menu trigger, and the window-manager controls in that same band while window-manager border, shadow, rounded corners, move, resize, maximize, snap, and related behaviors remain intact.
- If the final runtime UI still shows a separate system title bar above an in-content toolbar, classify that result as fallback-only rather than a unified titlebar-toolbar implementation.
- If the system-decorated title bar still shows an application name, the implementation fails the `logo-only top-left identity` requirement even when the QML `title` is empty.
- If a true merged titlebar-toolbar cannot coexist with window-manager-owned decorations on the target platform, keep the system title bar and place the toolbar immediately below it as the default fallback.
- If a product requirement document conflicts with this design skill, follow this design skill first. Call out the exact conflict and keep the implementation aligned with the design skill unless the user explicitly overrides the skill.
- Only use a frameless main window when the user explicitly accepts client-side decoration tradeoffs or when a platform-specific DTK path has been validated for that exact environment.
- Prefer system-managed popups unless the request clearly requires window-managed popups and the target platform has been validated.
- Do not use `Popup.Window` by default. If you use it, also define the `Popup.Item` fallback path.
- Keep color, radius, and spacing choices aligned with the documented theme tokens.
- For option-card groups or list-like setting cards that have left-aligned descriptive content and right-aligned controls or affordances, the layout must be split-aligned: the left content block aligns to the left edge, the right content block aligns to the right edge, the left block keeps a 10px inset from the card background's left edge, and the right block keeps a 10px inset from the card background's right edge.
- For repeated option rows, setting rows, startup-item rows, or similar list-like cards that place toggles, checkboxes, combo boxes, or trailing action buttons on the right, use a dedicated trailing control slot or control column anchored to the same right inset for every row in that group. Do not place the trailing control directly after variable-width content without an explicit shared trailing slot.
- In a repeated row group with trailing controls, the right edges of those controls must resolve to the same visual column across the whole group, regardless of differences in title length, badges, descriptions, disabled state, or current value text.
- Prefer a reusable split-row primitive for these patterns, such as a `SettingRow`-style component with a left info area and a right control slot, rather than rebuilding each row ad hoc with freeform `RowLayout` children.
- Inside option groups, setting groups, and cards, keep white space purposeful. Beyond the spacing needed for hierarchy, alignment, readability, and hit targets, do not add large decorative empty gaps or oversized padding with no structural meaning.
- Treat the visible content inside the main content area as one composition that must be centered as a whole within that content area. When the content width is capped or otherwise narrower than the available content area, the outer left and right margins must resolve to the same value.
- Do not pin a max-width page column, card stack, dashboard band, or primary content composition to one side of the content area while leaving a visibly different margin on the other side unless the user explicitly requests that asymmetry.
- When multiple cards or dashboard panels share one horizontal content band, use an explicit grid or span plan so the group aligns on the outer top, bottom, left, and right edges. If one side stacks multiple cards while the other side uses a larger card, the stacked side must resolve to the same total height as the adjacent larger card instead of leaving uneven bottoms or floating gaps.
- In wide horizontal header, summary, or action rows, balance visual weight across the row. Do not cluster a large title, key metadata, and a primary action on one side while leaving the opposite side as a visually empty block; redistribute widths, add a counterweight block, or realign actions until the row reads balanced from left to right.
- Bind theme values to DTK or system palette first. If a page needs a new semantic color, add it to the theme layer first instead of hardcoding business colors in page files.
- In production QML, keep hex color literals inside the central theme file only. If a non-theme file needs a literal color for a validated platform-specific reason, add a narrow `uos-design: allow-literal-color` waiver comment in that file and explain the reason in the response.
- For interactive icons, use `Theme.iconNormal` for default state, `Theme.iconStrong` for hover or emphasis, `Theme.accentForeground` for selected or current state, and `Theme.textDisabled` for disabled state. Do not use `Theme.textMuted` as the default tint for navigation, toolbar, button, menu, or list action icons.
- For 16px functional icons, prefer downloading SVG assets from the internet as the default sourcing strategy. Choose assets whose visual language stays consistent with, or at least closely approximates, the target UOS/Deepin/DTK system style. Do not rasterize such icons to PNG or rely on baked source colors for selected, hover, current, or disabled states.
- Downloaded 16px functional icons must preserve recolorable alpha-mask semantics end-to-end, remain visually compatible with adjacent system-style controls, and support using the exact same semantic foreground token as neighboring text.
- For sidebar, navigation, tab, stepper, and list-current states, selected and hover backgrounds plus selected foregrounds must come from named semantic theme tokens such as `Theme.navItemSelectedBg`, `Theme.navItemHoverBg`, and `Theme.navItemSelectedFg`. Do not derive those state colors inline in page or component files with `Theme.mix(...)`, `Theme.withAlpha(...)`, or similar expressions.
- When an application exposes a main menu, that main menu must include theme switching with `System`, `Light`, and `Dark` modes or localized equivalents. Do not hide theme switching only inside a settings page when a main menu exists.
- The main-menu `System` theme mode must stay bound to live system theme changes. Do not implement "follow system" as a one-time snapshot taken only at launch.
- If you must use frameless windows, `Popup.Window`, literal colors outside the theme file, `Theme.textMuted` on an interactive icon, rasterized functional icons, inline derived navigation colors, a custom main-menu button, manual main-menu positioning, a custom About dialog, a custom dialog shell, a custom in-app notification container, a DTK control with a replaced structural template, a manual tint overlay above a blurred area, a freeform repeated trailing-control row that cannot use a dedicated control slot, or app-side tuning of top-level window rounded corners, border, or shadow, add a narrow waiver comment in the touched file: `uos-design: allow-frameless`, `uos-design: allow-popup-window`, `uos-design: allow-literal-color`, `uos-design: allow-textMuted-icon`, `uos-design: allow-icon-rasterization`, `uos-design: allow-derived-nav-color`, `uos-design: allow-custom-main-menu-button`, `uos-design: allow-manual-main-menu-position`, `uos-design: allow-custom-about-dialog`, `uos-design: allow-custom-dialog-shell`, `uos-design: allow-custom-in-app-notification`, `uos-design: allow-dtk-template-override`, `uos-design: allow-manual-blur-overlay`, `uos-design: allow-freeform-trailing-control-row`, or `uos-design: allow-app-side-window-decoration-tuning`. Every waiver must include the exact platform, version, or component reason.
- Preserve keyboard navigation, focus states, and contrast requirements.
- State any Qt/DTK version or Wayland/X11 assumptions when they affect windowing, popup behavior, blur, or drag handling.
- Use the window and title-bar rules for desktop shells instead of inventing new chrome.
- When a requested component is not documented, say so plainly instead of pretending it exists.

## Hard Fail Conditions

Treat the task as not done if any of the following remain true:

- DTK is available locally but the project still lacks DTK QML imports or DTK build integration for controls that DTK provides.
- The project forces `QQuickStyle::setStyle("Basic")`, `Fusion`, `Material`, `Imagine`, or another non-DTK global style without a stated platform constraint.
- A top-level Linux desktop window uses `Qt.FramelessWindowHint` without a validated DTK path or an explicit `uos-design: allow-frameless` waiver.
- A popup uses `Popup.Window` without a validated need, a fallback path, or an explicit `uos-design: allow-popup-window` waiver.
- A non-theme QML file contains a hex color literal without an explicit `uos-design: allow-literal-color` waiver.
- An interactive icon uses `Theme.textMuted` as its default tint without an explicit `uos-design: allow-textMuted-icon` waiver.
- The application main menu is opened by a custom button instead of a DTK menu button without an explicit platform-specific waiver.
- The application main menu uses hardcoded manual popup coordinates instead of DTK menu-button placement without an explicit platform-specific waiver.
- The user explicitly required a unified titlebar-toolbar presentation by default with a system-decorated fallback, but the implementation only ships the fallback path or omits the exact validated fallback conditions.
- The implementation uses a heuristic platform check such as `X11`, `Wayland`, `xcb`, or `wayland` to select a unified titlebar-toolbar path without proving that the resulting runtime window satisfies the unified-header acceptance criteria.
- The final runtime UI shows both a system title bar and a separate in-content toolbar, but the response still claims that the unified titlebar-toolbar requirement was implemented.
- A desktop application with a persistent left sidebar does not ship a left-right split shell as its primary desktop layout and no explicit user override justifies the deviation.
- A desktop application with a persistent left sidebar does not use a validated window-manager or compositor-provided blur path for that sidebar and no explicit user override justifies the deviation.
- A blurred window or region duplicates a tint or overlay layer by stacking a self-drawn translucent surface above a validated DTK, window-manager, or compositor blur primitive that already provides `blendColor`, fallback tint, or an equivalent documented internal compositing layer, and no explicit `uos-design: allow-manual-blur-overlay` waiver justifies the duplication.
- A desktop application with a persistent left sidebar does not keep the required 10px left and right inset between the sidebar background and the sidebar navigation list or items and no explicit user override justifies the deviation.
- A collapsible persistent left sidebar hardcodes a universal `60px` collapsed rail, places the collapse toggle away from the required logo-adjacent position, or fails to hide the sidebar when resize reaches the `100px` minimum or the collapse toggle is activated, and no explicit user override justifies that behavior.
- A repeated option-row or list-card group with trailing controls does not use a dedicated shared trailing control slot or column, or the controls' right edges do not align to the same visual column across the group, and no explicit `uos-design: allow-freeform-trailing-control-row` waiver justifies the deviation.
- An option-group or card composition contains large internal blank areas that do not serve hierarchy, alignment, readability, or hit targets, and no explicit user override justifies that extra empty space.
- A capped-width or visually grouped main-content composition is not centered within the content area as a whole and leaves visibly unequal outer left and right margins without an explicit user override.
- A horizontal dashboard or card band that is clearly intended to read as one shared composition does not align its outer top, bottom, left, and right edges or leaves stacked cards at a different total height from the adjacent larger card without an explicit user override.
- A top-level window that is required to use window-manager-owned rounded corners, border, or shadow still sets `D.DWindow.windowRadius`, `D.DWindow.borderWidth`, `D.DWindow.borderColor`, `D.DWindow.shadowRadius`, `D.DWindow.shadowOffset`, or `D.DWindow.shadowColor` from app-side QML without an explicit `uos-design: allow-app-side-window-decoration-tuning` waiver.
- A DTK control such as `D.Switch`, `D.CheckBox`, `D.ComboBox`, `D.Button`, `D.TextField`, `D.Menu`, `D.Dialog`, or `D.ProgressBar` has its structural template replaced with custom `background`, `contentItem`, `indicator`, `handle`, `popup`, or `delegate` items without an explicit `uos-design: allow-dtk-template-override` waiver.
- An application dialog uses a custom popup or custom shell instead of a DTK dialog type, or product code takes over dialog chrome and styling instead of only providing content and action signals, without an explicit `uos-design: allow-custom-dialog-shell` waiver.
- A 16px functional icon pipeline rasterizes a downloaded or bundled SVG icon to PNG, or otherwise loses recolorable symbolic or alpha semantics without an explicit `uos-design: allow-icon-rasterization` waiver.
- Sidebar, navigation, tab, stepper, or list-current colors are derived inline outside the theme layer without an explicit `uos-design: allow-derived-nav-color` waiver.
- An application main menu exists but does not expose `System`, `Light`, and `Dark` theme switching, or its `System` mode does not remain bound to live system theme changes.
- An About entry opens a custom about dialog instead of DTK `AboutDialog` without an explicit platform-specific waiver.
- An in-app toast, floating message, or transient application notification uses a custom toast or notification container instead of DTK `FloatingMessage` without an explicit platform-specific waiver.
- An option-card group or list-like setting card with left descriptive content and right controls or affordances does not keep left-right split alignment with 10px insets on both sides and no explicit user override justifies the deviation.
- The main application header or toolbar shows an application name next to the top-left logo instead of using a logo-only presentation.
- The final runtime UI shows an application name in the top-left title bar when the skill requires a logo-only top-left identity.
- `scripts/audit_uos_qml.sh` reports findings and the response neither fixes them nor explains the exact remaining waiver.

## Required Review Checks

When reviewing or generating code, explicitly check the following:

- Run `scripts/audit_uos_qml.sh <repo-root>` and report the result before closing the task.
- Whether the build or runtime imports `org.deepin.dtk` and links the relevant DTK package when DTK is available locally.
- Whether a UOS/Deepin task incorrectly uses plain Qt Quick Controls plus custom wrappers where DTK controls exist.
- Whether a DTK control is only used as a state container while its visual template is effectively replaced by custom `background`, `contentItem`, `indicator`, `handle`, `popup`, or `delegate` items.
- Whether the code forces a non-DTK global style such as `Basic`, `Fusion`, or `Material`.
- Whether the main window strategy states the Qt version and `Wayland`/`X11` assumption when frameless behavior is used.
- Whether the chosen window strategy preserves window-manager-owned border, shadow, rounded corners, move, resize, maximize, snap, and related behaviors for top-level windows.
- Whether the code incorrectly assumes a macOS-style merged titlebar-toolbar is generically available on Linux/UOS without platform-specific validation.
- Whether any desktop application with a persistent left sidebar uses the required left-right split shell with navigation on the left and main content on the right.
- Whether any desktop application with a persistent left sidebar uses a validated window-manager or compositor-provided blur path for the sidebar rather than a self-drawn or fake blur substitute.
- Whether any blurred window or region incorrectly adds a second self-drawn tint or overlay layer on top of a DTK or system blur primitive that already provides `blendColor`, fallback tint, or an equivalent internal compositing layer.
- Whether any manual tint overlay above a blurred region is limited to a single explicit layer, carries `uos-design: allow-manual-blur-overlay`, and documents the exact platform and component reason.
- Whether any desktop application with a persistent left sidebar keeps the required 10px horizontal inset between the sidebar background and the sidebar navigation list or items on both sides.
- Whether any collapsible persistent left sidebar avoids a fixed `60px` icon-rail assumption, places the collapse toggle `20px` to the right of the top-left logo, and hides the sidebar when resize reaches `100px` minimum or the collapse toggle is activated.
- Whether repeated option rows, setting rows, startup-item rows, and similar list-like cards with trailing controls use a dedicated shared trailing control slot and keep the controls aligned to one right-side visual column across the entire group.
- Whether option groups, setting groups, and cards avoid large internal blank areas beyond the spacing needed for hierarchy, alignment, readability, and hit targets.
- Whether the main content composition remains centered within the content area as a whole, with equal outer left and right margins whenever the visible content width is capped or otherwise narrower than the available space.
- Whether shared horizontal dashboard or card bands align their outer edges and make stacked groups resolve to the same total height as adjacent larger cards.
- Whether top-level window rounded corners, border, and shadow are truly owned by the window manager rather than tuned from app-side `D.DWindow` decoration properties.
- Whether wide horizontal header, summary, or action rows maintain left-right visual balance instead of concentrating major visual weight on one side and leaving the opposite side visually empty.
- Whether every application main-menu trigger uses a DTK menu button rather than a custom app button, and whether its popup placement is left to DTK conventions instead of hardcoded coordinates.
- Whether every application main menu includes `System`, `Light`, and `Dark` theme switching or localized equivalents, and whether the `System` mode stays synchronized with live system theme changes instead of only restoring an initial snapshot.
- When the user requests a unified titlebar-toolbar presentation by default with a fallback, whether the implementation actually contains both paths and states the exact trigger for falling back to system decorations.
- When the user requests a unified titlebar-toolbar presentation by default with a fallback, whether runtime validation confirms a single top header band rather than a system title bar plus a second in-content toolbar.
- Whether the implementation incorrectly treats `X11`, `Wayland`, `xcb`, `wayland`, Qt version, or DTK version alone as proof that a unified titlebar-toolbar path is available.
- Whether the final runtime UI still shows an application name in the system title bar despite a logo-only requirement.
- Whether dialogs, menus, and popups return focus correctly and preserve keyboard access.
- Whether every application dialog uses a DTK dialog type, and whether project code limits itself to text content, semantic state, and action signals instead of taking over dialog visual styling.
- Whether every About entry that opens an About surface uses DTK `AboutDialog` instead of a custom About popup.
- Whether every in-app toast, floating message, or transient application notification uses DTK `FloatingMessage` instead of a custom toast or notification container.
- Whether page code hardcodes brand or business colors instead of going through theme tokens.
- Whether non-theme QML files contain hex color literals or waiver comments.
- Whether interactive icons incorrectly default to `Theme.textMuted` instead of `Theme.iconNormal`.
- Whether 16px functional icons are sourced from downloaded SVG assets whose style stays consistent with or close to the target system style, and whether they preserve symbolic or alpha recoloring semantics end-to-end rather than being rasterized and then tinted.
- Whether selected navigation icons visually match the same semantic foreground token as the selected navigation text.
- Whether sidebar, navigation, tab, stepper, and list-current backgrounds and foregrounds come from semantic theme tokens instead of inline derived expressions in component or page files.
- Whether option-card groups or list-like setting cards with left descriptive content and right controls or affordances keep left-right split alignment with 10px insets from both card edges.
- Whether the top-left application identity uses a logo-only presentation and incorrectly adds an application name.
- Whether icon strategy, control strategy, and window strategy are treated as separate decisions instead of being conflated.

## Conflict Resolution

If documents disagree, use this order:

1. This `SKILL.md`
2. `references/foundations/*.md` and `references/components/*.md`
3. `references/platform-compatibility.md`
4. `references/design-rules.md`
5. `references/design-system-layout.md` and `references/design-system-window-behavior.md`
6. `references/design-system-quick-reference.md`
7. `references/design-system-modular.yaml` for routing and indexing only

If a PRD or requirement document conflicts with this order, use the skill and its references first unless the user explicitly instructs otherwise.

## Response Guidance

- Cite the exact files you used.
- Keep answers implementation-oriented.
- If you choose a non-DTK fallback, say exactly why DTK could not be used in that case.
- Call out Qt/DTK version constraints and Wayland/X11 assumptions when they matter.
- Distinguish clearly between a runtime-validated unified titlebar-toolbar path and a fallback-only result. Do not describe a fallback result as unified.
- When reviewing UI code, call out mismatches against the documented tokens or rules.
- When reviewing UI code, treat missing DTK usage as a primary finding when DTK controls are available locally.
- When generating new QML, follow the naming and state conventions already documented here.
