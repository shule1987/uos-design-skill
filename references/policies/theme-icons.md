# Theme And Icon Policy

Load this file for theme variables, surfaces, palette integration, and icon behavior.

- Treat the foundation files as authoritative for colors, typography, spacing, radius, and animation.
- Keep hex color literals in the central theme file only.
- Keep desktop base surfaces near the neutral UOS and Deepin baseline. Do not invent blue, cyan, teal, navy, or other chromatic desktop base surfaces by default.
- Route accent color back to DTK or system palette instead of hardcoding a product accent.
- Wire actual root, page, panel, and toolbar surfaces to the documented theme variables. Do not define tokens and then leave the live UI on unrelated colors or transparency.
- Use `Theme.iconNormal` for default interactive icons, `Theme.iconStrong` for hover or emphasis, `Theme.accentForeground` for selected state, and `Theme.textDisabled` for disabled state.
- Do not default interactive icons to `Theme.textMuted`.
- Keep selected navigation colors and backgrounds in named semantic theme variables rather than deriving them inline in page files.
- Keep active sidebar state fill-only unless a narrow exception justifies a border.
- Header-toolbar action buttons should prefer symbolic icons over text and should use 16px functional-icon sizing and semantics by default.
- Every symbolic app-side header button should explicitly set `icon.width` and `icon.height` to `16` unless a narrow waiver explains the exception.
- If a header-toolbar action keeps text for comprehension, the icon should still lead unless a product requirement explicitly rejects the icon path.
- Only file lists and app or program lists with a truthful one-to-one item mapping may use live file or app icons. Other option, settings, navigation, and functional lists must prefer downloaded or bundled SVG assets.
- Keep light-theme and dark-theme surfaces internally consistent. Do not mix a light page, light card, or light popup into a dark-theme interface, or vice versa, unless an explicit system-surface exception explains the reason.
- Give every clickable surface a visible hover state in both light and dark themes. Do not ship clickable rows, cards, tiles, or icon affordances that look static on hover.
- Prefer recolorable SVG assets for functional icons.
- Do not rasterize symbolic functional icons unless a narrow exception justifies it.
- For repeated functional rows outside truthful file or app lists, bind icon identity from item-level data to downloaded or bundled SVG assets rather than live file or app icon providers.
