# Windowing Review

Load this file when reviewing top-level windows, title bars, menus, and unified-header behavior.

- Verify compliance with `references/policies/windowing.md`.
- Verify that every main window uses the DTK standard unified header path instead of a system title bar.
- Verify that the top-right DTK control strip is not clipped, obscured, or covered by app-side overlays.
- Verify that custom window flags do not undermine DTK title-bar behavior in normal or maximized state.
- Verify that the top-right strip exposes menu, minimize, maximize or restore, and close. Fixed-size windows may omit maximize or restore.
- Verify at runtime that the final result shows one DTK-owned top band rather than a system title bar plus a second toolbar.
- Verify that main page-switching controls live in the unified header toolbar rather than in a second in-page toolbar and that the header path uses a DTK grouped mutually-exclusive button control instead of `TabBar`.
- Verify that header-toolbar action buttons prefer symbolic 16px functional icons over text-heavy button treatments unless a requirement explicitly justifies text.
- Verify that the visible app-side control cluster in `D.TitleBar.content` is horizontally centered within the live header lane rather than left-pinned by an expanding search field or similar filler.
- Verify that every symbolic app-side header button, including `leftContent` affordances and grouped page-switch buttons, explicitly uses `16x16` icon sizing unless a narrow waiver explains otherwise.
- Verify that the header reads as the frosted top layer above underlapping scrollable content and that the scroller's top and bottom extents account for the header overlap.
