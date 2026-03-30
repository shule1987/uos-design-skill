# Layout And Density Review

Load this file when reviewing lists, tables, cards, row density, width strategy, and reusable container sizing.

- Verify compliance with `references/policies/layout-density.md`.
- Verify that variable-length data surfaces default to compact responsive rows rather than oversized standalone cards unless the user explicitly asked for a card layout.
- Verify that repeated rows with trailing controls align to one shared trailing control column, that single-line rows keep a `16px` leading icon box, and that multi-line row primitives keep a `24px` leading icon box unless a narrow exception explains otherwise.
- Verify that the leading icon in multi-line list rows aligns to the top of the text block instead of reading as vertically centered inside the whole row.
- Verify that non-file and non-app truthful lists use downloaded or bundled SVG leading icons instead of live file or app icon providers, and that list leading icons never sit on self-drawn background chips.
- Verify that list and table layouts use responsive widths, that scrollable regions consume available height, and that the primary desktop layout does not depend on horizontal scrolling.
- Verify that the live list content block stays horizontally centered within the list lane instead of pinning a narrow row composition to one side.
- Verify that any available runtime geometry audit reports no text overlap, horizontal clipping, host-region overflow, or unresolved near-height card-row mismatch in the rendered main window and auxiliary scene windows.
- Verify that desktop work surfaces use the available content width truthfully and do not preserve a narrow centered column inside a wide content base unless a readability cap or product requirement explicitly explains it.
- Verify that any surface larger than `60px` that centers one numeric value as its primary message renders that number at `24px` or larger, unless the same card or region intentionally presents multiple peer numeric values.
- Verify that reusable containers keep a truthful height contract and that delegates avoid self-referential bindings or same-name model-role shadowing.
- Verify that capped-width content compositions remain centered as a whole, that cards keep an explicit fixed `1px` shell stroke and at least `8px` of interior inset, and that cards avoid oversized empty space, edge-crowded focal content, and obviously over-wide buttons.
- Verify that metric, scene, gallery, or similar row-aware card primitives are hosted by the intended responsive grid primitive rather than a plain `GridLayout`; otherwise same-row equalization rules are silently bypassed.
- Verify that auto-generated structural thumbnails inside cards use an explicit subdued mode or token path so the preview stays visually below the card's real text, metrics, and interactive controls.
- Verify that the near-height equalization rule is enforced not only in simple 2-column bands but also across each visual row of multi-column responsive card grids, while deliberate multi-column spanning cards are only exempt when that structure is explicit.
- Verify that equal-height 2-column card rows do not leave a sparse peer with a large dead vertical gap. When one card clearly has much less content, the layout should redistribute structure by spans, stacking, or a real lower section instead of preserving a tall shell with a large empty floor.
- Verify that page-level QML does not open-code `matchedCardHeight`, `Theme.equalizedCardPairHeight(...)`, or equivalent pair-equalization glue. Those patterns should live only inside reviewed reusable primitives, with any exception explicitly waived and justified.
