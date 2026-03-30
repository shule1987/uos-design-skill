---
name: uos-design
description: DTK-first UOS and Deepin QML desktop UI workflow for Linux desktops. Use when designing, implementing, or reviewing UOS/Deepin style interfaces; choosing between DTK and custom QML; validating Qt/DTK or Wayland/X11 constraints; or enforcing control-center style left-sidebar layouts, window behavior, blur surfaces, settings dialogs, lists, charts, and theme variables.
---

# UOS Design

Use this skill for DTK-first Linux desktop UI work in QML. Keep the skill body lean. Load only the smallest relevant reference file instead of pulling broad design docs by default.

## Workflow

1. Inspect local reality first:
   - target Qt version
   - local DTK exports from `references/local-dtk-controls.md` plus the actual `qmldir` files on disk
   - target session type (`Wayland` or `X11`) when windowing, blur, or popup behavior matters
   - build integration points such as `CMakeLists.txt`, `main.cpp`, and QML imports
   - whether the DTK standard unified header path is actually validated on this Qt/DTK/window-manager stack
2. Route to the smallest relevant reference set before proposing code. Use `references/routing.md` when the right file choice is not obvious or the task spans multiple areas.
   - For header glass, toolbar blur, or "content scrolling under a frosted header" work, load `references/components/unified-header.md` and `references/components/blur.md`.
   - For header page-switch controls, header action buttons, or number-first summary surfaces, also load only the needed files from `references/local-dtk-controls.md`, `references/policies/theme-icons.md`, and `references/foundations/typography.md`.
   - For cards, dashboard tiles, overview walls, or any card-heavy surface, load `references/components/card.md` and `references/policies/layout-density.md`, plus `references/foundations/colors.md` when the task touches card surface hierarchy.
3. Before substantial edits, define the completion gate for the touched feature:
   - touched windows, dialogs, pages, and other shipped scenes
   - touched controllers, models, or other backend behavior that affects those scenes
   - relevant PRD or acceptance criteria sources
   - build command, static audit command, and automatic dynamic validation command set
   - if the repo lacks an automatic dynamic validation path for the touched shipped surface, add or wire one before calling the task complete
4. Prefer DTK controls whenever the local export map says they exist.
5. Use narrow fallbacks only when you can name the exact missing DTK capability, version gap, or platform constraint.
6. Run `scripts/audit_uos_qml.sh <repo-root>` before substantial QML edits and again before finishing. Treat findings as blocking unless fixed or covered by a narrow waiver comment.
   - When the project exposes the `UOS_DESIGN_VISUAL_AUDIT` runtime hook, the audit is not complete until the live runtime geometry pass also runs for the main window and any shipped auxiliary scene windows.
   - Do not treat the static shell heuristics as sufficient by themselves for layout sign-off when runtime geometry is available.
7. Before reporting build completion, task completion, or release readiness, perform a full review and automatic dynamic validation on the built artifact.
   - Build success is an intermediate milestone, not a sign-off signal.
   - Prefer `scripts/validate_uos_release.sh <repo-root>` when the repo provides it; otherwise use the skill script at `scripts/validate_uos_release.sh` under this skill plus the focused review references.
   - Load `references/review-checklist.md`, then the smallest matching file under `references/review/`, even for implementation close-out when shipped UI or behavior changed.
   - Full review must cover touched QML surfaces, touched backend and controller behavior, and the relevant PRD or acceptance criteria instead of stopping at layout or compile checks.
   - Automatic dynamic validation must use the strongest available automated path in the repo, in descending order: runtime geometry audit hooks, automated UI or integration tests, purpose-built smoke tests, then executable startup and runtime exercise of the main window and shipped auxiliary windows.
   - Do not declare the build complete while full review or automatic dynamic validation is still pending.
8. When the user asks for a review, load `references/review-checklist.md`, then only the smallest matching file under `references/review/`, and load `references/review/close-out.md` before finalizing a substantial review close-out.

## Reference Routing

- Always start with `references/local-dtk-controls.md`.
- For new main windows, unified-header refactors, or any case where the exact DTK titlebar wiring is unclear, load `references/components/unified-header.md`.
- For header blur tuning, Unote-like frosted toolbars, or cases where scrolling content should read through the header band, load `references/components/unified-header.md` and `references/components/blur.md`.
- Load `references/routing.md` when you need help choosing the smallest matching foundation, component, policy, or review files.
- Do not load broad fallback references unless focused files do not answer the question.
- Use `references/enforcement.md` only as a policy index, not as the detailed payload.
- Use `references/review-checklist.md` only as a review index, not as the detailed payload.
- For exceptions, load `references/policies/waivers.md`.
- For completion decisions, load `references/policies/hard-fails.md`.

## Non-Negotiables

- Treat local DTK availability as authoritative. If `org.deepin.dtk` or the settings module exposes the needed control, use it instead of rebuilding an equivalent from plain Qt Quick Controls.
- Main windows must not ship with a window-manager-owned or system title bar. Use the DTK standard unified header path instead.
- Main windows must expose the top-right DTK control strip as menu, minimize, maximize or restore, and close. Omit maximize or restore only when the window is intentionally fixed-size.
- When the exact main-window DTK wiring is needed, follow `references/components/unified-header.md` instead of improvising the header, menu, and window-button structure from scratch.
- Desktop content surfaces should use the available content width truthfully. Do not leave a narrow centered column floating inside a wide work area unless the surface is intentionally readability-capped or the user explicitly asks for it.
- Page-switching tabs belong in the DTK unified header toolbar via `D.TitleBar.content`, not in a second in-page toolbar band.
- Header-toolbar page switching must use a locally exported DTK grouped mutually-exclusive button path such as `D.ButtonBox`, `D.ButtonGroup`, or `D.ControlGroup`. Do not use `TabBar` for main page switching in the unified header.
- Buttons placed in the unified header toolbar must prefer symbolic functional icons over text labels. Use 16px functional-icon semantics for those header actions unless text is strictly required for comprehension or explicitly required by the product.
- When app-side controls share `D.TitleBar.content`, the visible control cluster must stay horizontally centered within the live header lane after reserving balanced safe areas for `leftContent` and the DTK top-right strip. Do not let a fill-width search field or similar expanding control pin the whole header cluster to the left.
- Every symbolic app-side header button other than the application logo slot, including page-switch buttons and functional `leftContent` affordances such as sidebar toggles, must explicitly use a `16x16` icon box unless a narrow waiver explains the exception.
- Every symbolic icon rendered inside any button-like control, not only in the header, must use the same `16x16` box as pure icon buttons. Do not enlarge icons inside text buttons, grouped buttons, menu-trigger buttons, or other button variants.
- In every application window, the top-left application logo in the DTK header must use a fixed `32x32` size. Do not choose ad hoc logo sizes per window, per page, or per scene.
- In every application window, that top-left application logo must keep its left edge exactly `9px` from the window's left edge. Do not center it inside a wider slot, animate it sideways, or otherwise shift its x-position.
- That `9px` logo offset must be measured from the `D.TitleBar` root's left edge, not from a padded helper slot. Do not place a static application logo inside `leftContent` when that slot introduces extra DTK inset; anchor the logo directly to the live header root instead.
- Text, labels, and buttons inside one surface must not visually overlap. Negative spacing, stacked centered siblings, or fill-parent text/button overlays that collapse into one another are invalid.
- Visible content must not be cut off horizontally. Any width-constrained dynamic text must declare an explicit wrap or elide strategy instead of relying on clipping, chance string length, or hidden overflow.
- Content must stay inside the bounds of its card, list, viewport, or host region. Do not use negative margins, negative positional offsets, or oversize child geometry that bleeds beyond the owning surface.
- Card backgrounds must keep at least `6px` of live content inset on every active edge. Do not compress explicit card padding below that floor.
- If the repo provides a runtime geometry audit path, these layout-density rules must also pass at runtime, not only in static QML inspection, across the main window and any real auxiliary scene windows. Blocking runtime findings include text or button overlap, horizontal text cutoff, content escaping a card, preview, list, or viewport host, and near-height card rows that remain visibly staggered inside the threshold window.
- Clickable areas must expose a visible hover state in both light and dark themes.
- Scrollable content should visually continue under the DTK header band, with the header rendered as the top frosted layer above the scrolling content instead of as a separate opaque strip that cuts content off at the header line.
- If `D.StyledBehindWindowBlur` alone does not visually reveal same-window content motion through the header on the target stack, use the documented live-sampled header fallback in `references/components/unified-header.md` and `references/components/blur.md` instead of improvising a custom titlebar.
- Header-toolbar overlay tint must use the main window background color as its RGB base, not a separate toolbar color. Keep the documented alpha values, but reduce the sampled blur layer opacity to half of the prior full-strength recipe.
- Scroll views must fill the content base directly. Keep page padding inside the page content, not by shrinking the `ScrollView` or page stack with outer margins; the scrollbar should sit on the far-right edge of the content area with no decorative seam around the scrolling surface, and its visible track must start below the visible header or secondary-toolbar boundary instead of running up through those bands.
- Lowest-layer card backgrounds should prefer a neutral color about 20% brighter than the window background before falling back to heavier panel or popup surfaces.
- All card surfaces must follow an explicit grid system at both levels: the card collection itself and the internal card layout. Card shells, media, titles, metrics, supporting text, and actions must align to responsive rows and columns with stable gutters and spans instead of freeform placement.
- Cards that share one horizontal row must default to top alignment before any equal-height logic is applied. Do not vertically center or baseline-drift neighboring cards that are meant to read as one band.
- When adjacent cards in the same visual row differ in height by less than about 40%, whether in a 2-column band or a multi-column responsive card wall, prefer equalizing them to the tallest card in that row and keeping their outer edges aligned instead of leaving a near-miss stagger. Cards that intentionally span multiple columns may keep an independent height contract unless the composition explicitly says otherwise.
- Auto-generated structural thumbnails inside cards must use a subdued, low-contrast treatment so they support orientation without visually outranking the card's main text, metrics, or interactive controls.
- Every structural thumbnail must keep an explicit fixed 1px edge stroke. Do not scale that border with UI scale helpers or derive it from device-pixel formulas.
- Structural thumbnails that depict layout or typography must not render their preview ink as pure black or pure white. Use subdued, weak-contrast preview tones instead of direct strong foreground colors.
- Persistent-sidebar bottom operational cards are opt-in. Do not show them unless the product requirement explicitly calls for one.
- Every shipped surface must adapt cleanly to dark theme. Do not mix light-theme and dark-theme surfaces in one interface without an explicit system-surface reason.
- In-app transient notifications must be DTK-owned when local DTK exports that path. Do not replace DTK toast behavior with custom transient notification shells.
- Use standard DTK desktop surfaces when they exist locally instead of custom equivalents. Follow the matching `references/policies/*.md` file for exact sidebar, dialog, theme, layout-density, and chart constraints.
- Keep theme tokens centralized. Do not scatter raw design values across business QML when foundation variables or DTK semantics already cover them.
- In any surface larger than 60px where one numeric value is the primary information, the rendered numeric size must not fall below 24px-equivalent at 1x. If the same card or region presents multiple peer numeric values, this minimum does not apply.
- If a requested control or behavior is not documented or not locally exported, say so plainly instead of inventing it.
- Do not treat a successful compile, a passing static QML audit, or a one-shot startup smoke as sufficient release sign-off by itself.
- Completion requires both a full review of touched behavior and automatic dynamic validation on the built artifact.
- If the repo still lacks adequate automatic dynamic validation for a touched shipped surface, keep the task open and report that gap as blocking rather than silently signing off.
- Preserve keyboard navigation, focus handling, and contrast.

## Conflict Order

1. This `SKILL.md`
2. `references/policies/*.md`
3. `references/foundations/*.md` and `references/components/*.md`
4. `references/platform-compatibility.md`
5. `references/design-rules.md`
6. `references/design-system-layout.md` and `references/design-system-window-behavior.md`
7. `references/design-system-quick-reference.md`
8. `references/design-system-modular.yaml` for routing only

## Response Guidance

- Cite the exact files you used.
- Keep answers implementation-oriented.
- State Qt/DTK and Wayland/X11 assumptions when they affect runtime behavior.
- If you choose a non-DTK fallback, name the exact missing DTK capability or platform blocker.
- Do not describe a system-titlebar main window as compliant with this skill.
- In reviews, load `references/review-checklist.md` plus the smallest relevant file under `references/review/`, load `references/review/close-out.md` before finalizing a substantial review close-out, lead with concrete findings, and treat missing DTK usage or unresolved audit findings as primary issues.
