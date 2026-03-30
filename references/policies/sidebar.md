# Persistent Sidebar Policy

Load this file for desktop apps with a persistent primary left sidebar.

- Default to a control-center style left-right split pane.
- Treat startup as entering that left-right split pane directly, not as a homepage-first shell.
- Keep a full-width DTK standard header band at the top of the window and start the left-right split pane below it.
- In that DTK header path, keep the sidebar surface and the right-side content base visually continuous up to the top edge of the window. Do not paint a separate full-width titleband surface that cuts the left and right panels off at the header line.
- Keep two explicit panels: a dedicated sidebar surface on the left and a dedicated content surface on the right.
- Do not ship this layout as a system title bar plus a second in-content toolbar.
- Use a validated compositor, window-manager, or DTK blur path for the sidebar when blur is part of the baseline.
- Keep the sidebar blur visually neutral in light and dark themes. Do not drift into obviously chromatic or nearly solid fallback panels.
- Keep an explicit right-side content base surface driven by documented theme variables.
- Keep zero structural gap between sidebar and content and place the visible divider on the sidebar edge itself.
- Keep `10px` horizontal inset between the sidebar surface and the navigation content on both sides.
- Hide the group title when there is only one navigation group.
- Keep `20px` vertical gaps between multiple navigation groups.
- Keep the sidebar-bottom operational card area empty by default.
- Only show unlock, subscription, paywall, campaign, or similar operational prompts in that area when the product requirement explicitly asks for them.
- When such an operational prompt is explicitly required, dock it to the sidebar-bottom card area with `10px` outer margins.
- If the sidebar collapses, make the motion read as translation out of view and back in, not as a squeeze-only width animation.
- Keep the top-left logo in one stable slot across expanded and collapsed states.
- Keep that logo slot in the DTK header. Do not add a second logo-plus-name or logo-plus-description brand block above the sidebar navigation by default.
- Keep that top-left application logo on a fixed `32x32` size in every application window. Do not shrink or enlarge it per window state or per page.
- Keep the left edge of that top-left application logo exactly `9px` from the window's left edge in every application window and sidebar state. Do not let it drift horizontally.
- In control-center-style persistent-sidebar windows, the DTK header should not display the application name text or page title text by default. Put page titles in the page content header unless an explicit product requirement says otherwise.
- Do not replace the expected dedicated sidebar-toggle affordance with a generic chevron or other arbitrary icon.
- If the app exposes a main menu, route the main settings entry through that menu instead of a second visible `设置` button in the main interface.
