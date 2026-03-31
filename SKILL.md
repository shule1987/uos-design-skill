---
name: uos-design
description: DTK-first UOS and Deepin QML desktop UI workflow for Linux desktops. Use when designing, implementing, or reviewing UOS/Deepin style interfaces; choosing between DTK and custom QML; validating Qt/DTK or Wayland/X11 constraints; or enforcing control-center style left-sidebar layouts, window behavior, blur surfaces, settings dialogs, lists, charts, and theme variables.
---

# UOS Design

Use this skill for DTK-first Linux desktop UI work in QML. Keep the skill body lean. Load only the smallest relevant reference file instead of pulling broad design docs by default.

For multi-page, multi-window, repo-wide, or explicitly delegated work, pair this skill with `uos-design-orchestrator`. In that pairing, this skill stays the single source of design truth, rule interpretation, and audit authority.

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
   - When the card work includes 2-column equal-height bands or asymmetric overview rows, plan the page around reusable local primitives instead of page-level height glue. Use a primitive equivalent to `EqualizedCardPairBand` for exactly two peer cards and a primitive equivalent to `BalancedTwoColumnCardBand` for asymmetric 2-column compositions.
   - When starting a new repo or hardening a repo that keeps leaking obvious UI regressions, load `references/repo-guardrails.md` and establish repo-local guarded build and page-scaffold paths early instead of waiting for the first release audit. When appropriate, bootstrap that baseline from `scripts/install_repo_guardrails.sh` under this skill instead of rewriting the starter files by hand.
   - Before writing business QML, explicitly name the local primitives you intend to reuse for the touched surface and the open-coded structures you will forbid. If the repo can support a page or surface scaffold, prefer that scaffold over starting from a blank page file.
3. Before substantial edits, define the completion gate for the touched feature:
   - touched windows, dialogs, pages, and other shipped scenes
   - touched controllers, models, or other backend behavior that affects those scenes
   - relevant PRD or acceptance criteria sources
   - build command, static audit command, and automatic dynamic validation command set
   - if runtime visual audit exists and the touched surface has multiple pages, deep scroll sections, or auxiliary windows, maintain repo-local scene coverage instead of relying on the default first viewport only
   - if the shipped window is resizable across a meaningful width or height range, maintain repo-local runtime window-size coverage as well; default-size-only audit is not enough for responsive sign-off
   - if the repo lacks an automatic dynamic validation path for the touched shipped surface, add or wire one before calling the task complete
   - if the repo has a build system, wire the strongest available static audit gate into the normal developer build path or add one repo-local guarded build command so violations fail during routine iteration instead of only at final release validation
4. Prefer DTK controls whenever the local export map says they exist.
5. Use narrow fallbacks only when you can name the exact missing DTK capability, version gap, or platform constraint.
6. Run `scripts/audit_uos_qml.sh <repo-root>` before substantial QML edits and again before finishing. Treat findings as blocking unless fixed or covered by a narrow waiver comment.
   - When the project exposes the `UOS_DESIGN_VISUAL_AUDIT` runtime hook, the audit is not complete until the live runtime geometry pass also runs for the main window and any shipped auxiliary scene windows.
   - Do not treat the static shell heuristics as sufficient by themselves for layout sign-off when runtime geometry is available.
   - When you add or tighten a strong constraint in this skill or its `references/policies/*.md` files, land the corresponding `audit_uos_qml.sh` and, when needed, `validate_uos_release.sh` coverage in the same change so the rule becomes automatically enforceable.
   - Treat audit-tool integrity as part of the gate: detector self-check failures, stderr noise, or other checker runtime errors are blocking even when the script would otherwise print a pass line.
7. Before reporting build completion, task completion, or release readiness, perform a full review and automatic dynamic validation on the built artifact.
   - Build success is an intermediate milestone, not a sign-off signal.
   - Prefer `scripts/validate_uos_release.sh <repo-root>` when the repo provides it; otherwise use the skill script at `scripts/validate_uos_release.sh` under this skill plus the focused review references.
   - Load `references/review-checklist.md`, then the smallest matching file under `references/review/`, even for implementation close-out when shipped UI or behavior changed.
   - Full review must cover touched QML surfaces, touched backend and controller behavior, and the relevant PRD or acceptance criteria instead of stopping at layout or compile checks.
   - Automatic dynamic validation must use the strongest available automated path in the repo, in descending order: runtime geometry audit hooks, automated UI or integration tests, purpose-built smoke tests, then executable startup and runtime exercise of the main window and shipped auxiliary windows.
   - When runtime visual audit produces screenshot artifacts, inspect representative captures from the generated dump directory before closing: at minimum one resting scene, one real header-overlap or deep-scroll scene when applicable, and one narrower window-size scene when applicable. Do not treat green logs alone as visual sign-off.
   - For substantive shipped UI changes, also load `references/review/obvious-visual-failures.md` and explicitly screen the generated artifacts for those patterns.
   - Do not declare the build complete while full review or automatic dynamic validation is still pending.
8. When the user asks for a review, load `references/review-checklist.md`, then only the smallest matching file under `references/review/`, and load `references/review/close-out.md` before finalizing a substantial review close-out.

## Reference Routing

- Always start with `references/local-dtk-controls.md`.
- For new main windows, unified-header refactors, or any case where the exact DTK titlebar wiring is unclear, load `references/components/unified-header.md`.
- For header blur tuning, Unote-like frosted toolbars, or cases where scrolling content should read through the header band, load `references/components/unified-header.md` and `references/components/blur.md`.
- Load `references/routing.md` when you need help choosing the smallest matching foundation, component, policy, or review files.
- Load `references/repo-guardrails.md` when establishing repo-local developer workflow, scaffolding, or default guardrails for future projects.
- Do not load broad fallback references unless focused files do not answer the question.
- Use `references/enforcement.md` only as a policy index, not as the detailed payload.
- Use `references/review-checklist.md` only as a review index, not as the detailed payload.
- For exceptions, load `references/policies/waivers.md`.
- For completion decisions, load `references/policies/hard-fails.md`.

## Non-Negotiables

- Treat local DTK availability as authoritative. If `org.deepin.dtk` or the settings module exposes the needed control, use it instead of rebuilding an equivalent from plain Qt Quick Controls.
- If this skill is paired with `uos-design-orchestrator`, child agents must still follow this skill and its references. The orchestration layer may split work, but it must not redefine or relax any rule here.
- Main windows must not ship with a window-manager-owned or system title bar. Use the DTK standard unified header path instead.
- Main windows must expose the top-right DTK control strip as menu, minimize, maximize or restore, and close. Omit maximize or restore only when the window is intentionally fixed-size.
- When the exact main-window DTK wiring is needed, follow `references/components/unified-header.md` instead of improvising the header, menu, and window-button structure from scratch.
- Desktop content surfaces should use the available content width truthfully. Do not leave a narrow centered column floating inside a wide work area unless the surface is intentionally readability-capped or the user explicitly asks for it.
- Page-switching tabs belong in the DTK unified header toolbar via `D.TitleBar.content`, not in a second in-page toolbar band.
- Header-toolbar page switching must use a locally exported DTK grouped mutually-exclusive button path such as `D.ButtonBox`, `D.ButtonGroup`, or `D.ControlGroup`. Do not use `TabBar` for main page switching in the unified header.
- When `D.ButtonBox` is the chosen path, use its built-in `group` instead of rebinding child buttons into a second external `ButtonGroup`.
- Adjacent buttons inside any mutually exclusive mode, filter, or state group must keep their visible spacing at `10px` or less. Do not leave wide decorative gaps between peer options.
- Buttons placed in the unified header toolbar must prefer symbolic functional icons over text labels. Use 16px functional-icon semantics for those header actions unless text is strictly required for comprehension or explicitly required by the product.
- When app-side controls share `D.TitleBar.content`, the visible control cluster must stay horizontally centered within the live header lane after reserving balanced safe areas for `leftContent` and the DTK top-right strip. Do not let a fill-width search field or similar expanding control pin the whole header cluster to the left.
- Every symbolic app-side header button other than the application logo slot, including page-switch buttons and functional `leftContent` affordances such as sidebar toggles, must explicitly use a `16x16` icon box unless a narrow waiver explains the exception.
- Every symbolic icon rendered inside any button-like control, not only in the header, must use the same `16x16` box as pure icon buttons. Do not enlarge icons inside text buttons, grouped buttons, menu-trigger buttons, or other button variants.
- Card shells and card background layers must keep an explicit fixed `1px` edge stroke. Do not scale that stroke with UI scale helpers, DPR math, or device-pixel formulas.
- Do not render that primary `1px` card stroke through an antialiased `Rectangle.border` on the same shell surface. Use a dedicated fixed-width stroke ring or stroke layer so the edge keeps reading as `1px`.
- In every application window, the top-left application logo in the DTK header must use a fixed `32x32` size. Do not choose ad hoc logo sizes per window, per page, or per scene.
- In every application window, that top-left application logo must keep its left edge exactly `9px` from the window's left edge. Do not center it inside a wider slot, animate it sideways, or otherwise shift its x-position.
- That `9px` logo offset must be measured from the `D.TitleBar` root's left edge, not from a padded helper slot. Do not place a static application logo inside `leftContent` when that slot introduces extra DTK inset; anchor the logo directly to the live header root instead.
- Text, labels, and buttons inside one surface must not visually overlap. Negative spacing, stacked centered siblings, or fill-parent text/button overlays that collapse into one another are invalid.
- Visible content must not be cut off horizontally. Any width-constrained dynamic text must declare an explicit wrap or elide strategy instead of relying on clipping, chance string length, or hidden overflow.
- Content must stay inside the bounds of its card, list, viewport, or host region. Do not use negative margins, negative positional offsets, or oversize child geometry that bleeds beyond the owning surface.
- Vertical rhythm must stay intentional. Do not let row content stick to the top or bottom edge, collapse title/subtitle gaps to near-zero, or leave obviously lopsided top-versus-bottom padding inside rows, cards, or heading stacks.
- Card shells may use minimum or maximum width and height bounds, but they must not lock the shell with fixed `width`, `height`, `implicitWidth`, or `implicitHeight` values. Keep card dimensions responsive to content and window width, and do not let card content overflow the shell.
- Card backgrounds must keep at least `8px` of live content inset on every active edge. Do not compress explicit card padding below that floor.
- List-row surfaces rendered inside cards must keep a second inner inset from the card content lane. Do not let repeated row backgrounds run flush to the card's live content width, and do not collapse the bottom floor inset under the last repeated row.
- Only file lists and app or program lists with a truthful one-to-one item mapping may use live file or app icons. Other option, settings, navigation, and functional lists must prefer downloaded or bundled SVG icons instead of live icon-provider lookups.
- Single-line list rows must use a `16x16` leading icon box. Multi-line list rows must use a `24x24` leading icon box. Do not add self-drawn background tiles, chips, or capsules behind list leading icons.
- Keep list content visually centered on the row's horizontal centerline and horizontally centered within the live list lane. Do not leave a narrow row plan pinned to one side of a wider list surface.
- In compact single-line rows, keep the leading icon vertically centered to the primary text block. In multi-line rows, keep the leading icon aligned to the text block's top edge while preserving balanced row padding above and below the combined content.
- In persistent-sidebar lists, keep the icon-text content left-aligned inside each row background. Do not center sidebar list labels or the icon-text cluster; keep the row background and its left-aligned content lane centered together only through symmetric sidebar insets.
- If the repo provides a runtime geometry audit path, these layout-density rules must also pass at runtime, not only in static QML inspection, across the main window and any real auxiliary scene windows. Blocking runtime findings include text or button overlap, horizontal text cutoff, content escaping a card, preview, list, or viewport host, main scroll surfaces that shrink away from the content base, vertical scrollbars that drift off the far-right edge or run up into the header band, near-height card rows that remain visibly staggered inside the threshold window, and equal-height 2-column card rows where one sparse card leaves a visibly large dead vertical gap.
- When a window is resizable between a larger default size and a smaller supported minimum size, runtime audit must cover at least one narrower supported size in addition to the default size. Do not sign off responsive card, list, sidebar, or header layouts from one default-size run only.
- Clickable areas must expose a visible hover state in both light and dark themes.
- Hover, pressed, and lightweight selected-state surface changes must not hard cut. Animate color, border, opacity, and icon-tint feedback with the documented theme animation tokens.
- Scrollable content should visually continue under the DTK header band, with the header rendered as the top frosted layer above the scrolling content instead of as a separate opaque strip that cuts content off at the header line.
- If `D.StyledBehindWindowBlur` alone does not visually reveal same-window content motion through the header on the target stack, use the documented live-sampled header fallback in `references/components/unified-header.md` and `references/components/blur.md` instead of improvising a custom titlebar.
- In persistent-sidebar main windows, the content-side DTK header band must mount a real titlebar blur layer. A plain `Theme.bg` or panel-colored header rectangle without titlebar blur is not compliant.
- Header-toolbar overlay tint must use the main window background color as its RGB base, not a separate toolbar color. Keep the documented alpha values, but reduce the sampled blur layer opacity to half of the prior full-strength recipe.
- When a window has no secondary toolbar under the header, the header overlay should not read as a permanently painted slab at rest. Keep it visually absent by default and fade it in only once scrolling content actually starts overlapping the header lane.
- When header glass depends on scroll overlap, every scene-covered page that declares scroll-driven `headerGlassProgress` must expose `prepareVisualAuditSection(...)` and drive the main `Flickable` into a real overlap state so runtime audit validates the active frosted header, not only the resting state.
- If runtime visual audit emits screenshot dumps, those artifacts are part of the completion gate. Keep them for the current run, verify they cover the touched rest-state and stress-state scenes, and treat screenshot-level defects as blockers even when the log itself stays green.
- Page-switch loaders in the main work area must not hard cut between major pages. Use a short opacity-plus-position transition with theme animation tokens so the state change reads as intentional rather than abrupt.
- Scroll views must fill the content base directly. Keep page padding inside the page content, not by shrinking the `ScrollView` or page stack with outer margins; the scrollbar should sit on the far-right edge of the content area with no decorative seam around the scrolling surface, and its visible track must start below the visible header or secondary-toolbar boundary instead of running up through those bands.
- Lowest-layer card backgrounds should prefer a neutral color about 20% brighter than the window background before falling back to heavier panel or popup surfaces.
- All card surfaces must follow an explicit grid system at both levels: the card collection itself and the internal card layout. Card shells, media, titles, metrics, supporting text, and actions must align to responsive rows and columns with stable gutters and spans instead of freeform placement.
- When a repo already has a sanctioned local primitive or scaffold for a recurring page, card, sidebar, or list pattern, use it instead of drafting that structure directly in business QML. If the pattern is missing, create the primitive first and then consume it from pages.
- When a repo already supports a build system and ships multiple pages or scenes, do not leave strict design compliance to manual end-of-task memory alone. Prefer a repo-local guarded build entry, a runtime validation entry, and at least one sanctioned page scaffold so future projects inherit the constraints structurally.
- Card primitives that rely on row-aware responsive equalization, such as metric, scene, or gallery cards that read a parent `equalizedHeightForItem(...)` contract, must live inside the matching responsive grid primitive instead of a plain `GridLayout`. Do not bypass the equalization host and then expect row-height constraints to still apply.
- Cards that share one horizontal row must default to top alignment before any equal-height logic is applied. Do not vertically center or baseline-drift neighboring cards that are meant to read as one band.
- When adjacent cards in the same visual row differ in height by less than about 40%, whether in a 2-column band or a multi-column responsive card wall, prefer equalizing them to the tallest card in that row and keeping their outer edges aligned instead of leaving a near-miss stagger. Cards that intentionally span multiple columns may keep an independent height contract unless the composition explicitly says otherwise.
- In a 2-column horizontal card band, equal-height alignment is only valid when the shorter card still uses the borrowed height gracefully. If matching the taller neighbor would leave roughly a third or more of the shorter card body as purposeless vertical blank space, change the composition instead of stretching the shell: rebalance spans, split the sparse card into stacked cards, or add a genuine lower section such as summary or actions. Do not keep a tiny top content cluster floating above a large empty floor.
- Land these 2-column card-row patterns through reusable local primitives instead of repeating row-height glue in business QML. Use a local primitive equivalent to `EqualizedCardPairBand` for exactly two peer cards and a local primitive equivalent to `BalancedTwoColumnCardBand` when one side is intentionally denser or stacked.
- Do not open-code `matchedCardHeight`, `Theme.equalizedCardPairHeight(...)`, or similar page-level row equalization helpers in business QML. If a new primitive is genuinely needed, isolate that logic in one reusable component, document the reason narrowly, and extend the audit coverage instead of copying the pattern into pages.
- Auto-generated structural thumbnails inside cards must use a subdued, low-contrast treatment so they support orientation without visually outranking the card's main text, metrics, or interactive controls.
- Every structural thumbnail must keep an explicit fixed 1px edge stroke. Do not scale that border with UI scale helpers or derive it from device-pixel formulas.
- Structural thumbnails that depict layout or typography must not render their preview ink as pure black or pure white. Use subdued, weak-contrast preview tones instead of direct strong foreground colors.
- Persistent-sidebar bottom operational cards are opt-in. Do not show them unless the product requirement explicitly calls for one.
- Every shipped surface must adapt cleanly to dark theme. Do not mix light-theme and dark-theme surfaces in one interface without an explicit system-surface reason.
- In-app transient notifications must be DTK-owned when local DTK exports that path. Do not replace DTK toast behavior with custom transient notification shells.
- Use standard DTK desktop surfaces when they exist locally instead of custom equivalents. Follow the matching `references/policies/*.md` file for exact sidebar, dialog, theme, layout-density, and chart constraints.
- Standard desktop dialogs should prefer a DTK-owned `D.DialogButtonBox` action row, keep cancel or secondary on the left and primary or destructive on the right, and avoid page-style top or bottom margins around that action row. When the footer contains multiple actions, the buttons must evenly split the usable footer width instead of shrinking to content width. In QML, declare the equal split explicitly, for example with `Layout.fillWidth: true` plus the same `Layout.preferredWidth` on each action button. If the local DTK declarative footer path proves visually incorrect or hides the buttons on the target stack, fall back to one local equal-width footer row built from DTK buttons plus the standard top divider, and mark the file with `uos-design: allow-manual-dialog-action-row`. Do not hide that fallback inside a reusable custom wrapper.
- Keep theme tokens centralized. Do not scatter raw design values across business QML when foundation variables or DTK semantics already cover them.
- In any surface larger than 60px where one numeric value is the primary information, the rendered numeric size must not fall below 24px-equivalent at 1x. If the same card or region presents multiple peer numeric values, this minimum does not apply.
- If a requested control or behavior is not documented or not locally exported, say so plainly instead of inventing it.
- Do not treat a successful compile, a passing static QML audit, or a one-shot startup smoke as sufficient release sign-off by itself.
- Do not treat an audit run as valid when the checker itself emitted stderr, failed detector self-check, or otherwise showed runtime tool errors. A green summary line does not override a broken checker.
- Completion requires both a full review of touched behavior and automatic dynamic validation on the built artifact.
- When the repo exposes runtime visual audit and the touched UI extends beyond one first viewport, completion also requires repo-local scene coverage for those deeper sections instead of validating only the default scene.
- When the repo exposes runtime visual audit and the main window is meaningfully resizable, completion also requires repo-local window-size coverage for at least one narrower supported size instead of validating only the default size.
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
