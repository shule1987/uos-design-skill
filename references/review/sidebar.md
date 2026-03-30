# Sidebar Review

Load this file when reviewing desktop apps with a persistent primary left sidebar.

- Verify compliance with `references/policies/sidebar.md`.
- Verify that the persistent sidebar layout still keeps one full-width DTK header band above the split pane instead of a system title bar plus an extra toolbar.
- Verify that the left sidebar surface and right content base still read continuously up to the top edge under the DTK header controls instead of being cut off by a separate full-width titleband background.
- Verify that the sidebar blur path is compositor, window-manager, or DTK validated rather than self-drawn and that the runtime result stays visually neutral in both light and dark themes.
- Verify zero structural gap between sidebar and content, a divider on the sidebar edge, and `10px` horizontal inset for sidebar navigation content.
- Verify that single-group sidebars hide the group header, multi-group sidebars keep `20px` gaps, and the sidebar-bottom operational card area stays empty unless an explicit requirement calls for an operational prompt there.
- If the sidebar collapses, verify that the motion reads as translate-out rather than squeeze-only width collapse.
- Verify that the logo keeps one stable top-left slot at a fixed `32x32` size with its left edge fixed `9px` from the window's left edge, that the header does not add app-name or page-title text by default, that the sidebar does not duplicate a second brand block above navigation, that the sidebar toggle affordance stays correct, and that settings entry points route through the main menu when a main menu exists.
