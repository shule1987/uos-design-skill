# Windowing Policy

Load this file for top-level windows, title bars, menus, and unified-header requests.

- Main windows must not ship with a window-manager-owned or system title bar.
- Use the DTK standard unified header path as the default main-window path.
- When you need the exact DTK wiring instead of only policy constraints, load `references/components/unified-header.md` and follow that recipe.
- Do not use app-side frameless or popup-window behavior as the default desktop path; use the DTK standard header path instead.
- Do not treat `X11`, `Wayland`, `xcb`, `wayland`, Qt version, or DTK version alone as proof that the DTK unified header path is valid.
- Validate the DTK unified header path at runtime in both normal and maximized states.
- A valid main-window path shows one DTK-owned top header band, not a system title bar plus a second in-content toolbar.
- If local `D.WindowButtonGroup` exists, use it for the minimize, maximize, and close cluster.
- Main windows must expose the top-right strip as menu, minimize, maximize or restore, and close. Omit maximize or restore only when the window is intentionally fixed-size.
- Place `D.WindowButtonGroup` at the real top-right edge of the live header region. Do not center it inside a wrapper or leave decorative dead space on the right.
- Reserve the top-right DTK menu and window-control strip as a safe area. Do not let app-side titlebar content or drag overlays cover it.
- When app-side controls occupy `D.TitleBar.content`, keep the visible control cluster horizontally centered within the live header lane after reserving balanced left and right safe areas.
- Do not place `D.TitleBar`, `D.WindowButtonGroup`, or the DTK-owned top-right strip inside a clipped ancestor chain.
- When local `D.TitleBar` is available, attach the main menu through `D.TitleBar.menu`. On main windows this menu affordance is mandatory; do not add a separate custom menu trigger button for the same menu.
- Page-switching tabs belong in `D.TitleBar.content`. Do not place a second page-switch toolbar or tab strip inside the page body when the unified header already exists.
- Symbolic app-side header buttons other than the application logo slot, including functional `leftContent` affordances and grouped page-switch buttons, must explicitly use `16x16` icon sizing unless a narrow waiver explains the exception.
- The top-left application logo in every application window must stay on a fixed `32x32` size. Do not set custom logo sizes window by window.
- Clickable titlebar and page-switch controls must expose visible hover and pressed states in both light and dark themes.
- Do not hardcode manual menu popup coordinates unless a validated platform constraint leaves no alternative.
- On the normal DTK main-window path, do not use `Qt.CustomizeWindowHint`, and do not drop `Qt.WindowTitleHint` when explicitly setting flags.
- If the main window is transparent and uses an embedded or unified DTK top band, provide a theme-backed title-band surface and extend the content-side base surface under that band.
- Treat the frosted DTK header as the top layer above scrollable content. Do not end the visible content at the header line with a separate opaque toolbar slab.
- When scrollable content visually underlaps the header band, account for that overlap in the scrollable content height and top inset so the first and last meaningful content blocks remain fully reachable.
- Main work-area page switching must not hard cut. When a `Loader`, page stack, or equivalent host swaps major pages, give the transition a short opacity-plus-position animation using theme motion tokens.
- Do not force a main window back to a system title bar with `D.DWindow.enabled: false` or an equivalent app-side override.
- Do not tune `D.DWindow` decoration properties from app-side QML unless a narrow exception requires it.
