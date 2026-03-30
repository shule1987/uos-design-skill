# Theme And Icon Review

Load this file when reviewing theme variables, surfaces, palette integration, and icon behavior.

- Verify compliance with `references/policies/theme-icons.md`.
- Verify that non-theme QML files do not hardcode raw hex colors unless a narrow waiver explains the reason.
- Verify that root, panel, page, and toolbar surfaces actually use documented theme variables instead of defining them without applying them.
- Verify that selected navigation state and interactive icon behavior stay on semantic theme variables rather than inline derivation or muted defaults.
- Verify that header-toolbar action buttons prefer symbolic 16px functional icons and do not regress into text-first toolbar buttons without an explicit product reason.
- Verify that only truthful file and app or program lists use live object icons, and that other list categories use downloaded or bundled SVG icons.
- Verify that clickable rows, cards, tiles, and icon affordances expose visible hover feedback in both light and dark themes.
- Verify that dark-theme screens remain fully dark-adapted and light-theme screens remain fully light-adapted instead of mixing opposite-theme surfaces.
- Verify that symbolic functional icons remain recolorable SVGs and that repeated functional rows derive icon identity from item-level data or a resolver.
