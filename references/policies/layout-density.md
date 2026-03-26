# Layout And Density Policy

Load this file for lists, tables, cards, row density, width strategy, and reusable container sizing.

- Keep variable-length file, app, service, startup-item, and data lists on a compact one-line or two-line row baseline by default.
- Do not render those lists as large standalone cards per item unless the user explicitly asks for a card treatment.
- Keep repeated rows with trailing controls on one shared trailing control column.
- For multi-line list-like rows, keep a leading icon by default.
- Default that leading icon to `24px` or `32px`.
- Use responsive column or slot widths for lists and tables. Do not rely on horizontal scrolling to rescue a desktop layout.
- Do not keep scrollable lists artificially short when the surrounding surface still has obvious unused height.
- Default desktop work surfaces to the maximum practical content width inside the content base. Do not center a narrow content column inside a wide work area unless the surface is intentionally readability-capped or a product requirement explicitly asks for it.
- On data, settings, control, and dashboard surfaces, prefer expanding the live content layout to the available content width over preserving decorative side gutters.
- Let the live scroll container fill the content base directly. Keep page padding inside the content layout itself, not as outer margins on the `ScrollView`, page stack, or content host. Vertical scrollbars should land on the far-right edge of the content area instead of floating inside inset gutters.
- When content visually underlaps a header or a second-level toolbar, keep that underlap for the content only. The scrollbar track and thumb must start at the top of the visible content region, below the header or secondary-toolbar band, rather than passing through those bars.
- Give reusable containers a truthful height contract. Do not compute `implicitHeight` from a plain anchored `Item` with no intrinsic height.
- Avoid self-referential bindings such as `title: title` or `description: description`.
- Avoid shadowing component API property names with same-named required model roles in delegates.
- Keep capped-width page compositions centered as a whole within the available content area.
- Keep cards close to the size their content actually needs. Avoid decorative empty gaps, oversized fixed heights, or obviously over-wide buttons.
- Treat card collections as responsive grids, not loose piles of containers. Define column count, minimum card width, spans, and gutters per breakpoint, then place cards against that grid.
- When adjacent cards in the same visual row differ in height by less than about 40%, including row peers inside multi-column responsive card walls, bias toward matching the tallest card in that row and keeping the top and bottom edges aligned rather than preserving a small accidental mismatch. Deliberate multi-column spanning cards may keep their own height unless the composition explicitly requires full-row alignment.
- Treat each card interior as a grid as well. Media, labels, metrics, body copy, meta rows, and action areas should align to stable internal tracks and baselines instead of freeform anchoring.
- When the window width changes, adapt card layout by changing columns, spans, slot allocation, and stacking order. Do not preserve a broken composition by adding ad hoc margins or by shrinking typography first.
- In normal cards and dialogs, keep multi-button action areas on one horizontal row by default. Do not use a vertical action stack unless the surface is unusually large and the exception is explicit.
