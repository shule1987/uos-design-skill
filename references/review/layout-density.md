# Layout And Density Review

Load this file when reviewing lists, tables, cards, row density, width strategy, and reusable container sizing.

- Verify compliance with `references/policies/layout-density.md`.
- Verify that variable-length data surfaces default to compact responsive rows rather than oversized standalone cards unless the user explicitly asked for a card layout.
- Verify that repeated rows with trailing controls align to one shared trailing control column, that single-line rows keep a `16px` leading icon box, and that multi-line row primitives keep a `24px` leading icon box unless a narrow exception explains otherwise.
- Verify that compact rows keep balanced top and bottom whitespace, and that the visible text or control block does not sit obviously high or low inside the row even when containment technically passes.
- Verify that the leading icon in multi-line list rows aligns to the top of the text block instead of reading as vertically centered inside the whole row.
- Verify that the leading icon in compact single-line rows aligns to the primary text block's vertical centerline instead of floating high or low relative to the label.
- Verify that non-file and non-app truthful lists use downloaded or bundled SVG leading icons instead of live file or app icon providers, and that list leading icons never sit on self-drawn background chips.
- Verify that list and table layouts use responsive widths, that scrollable regions consume available height, and that the primary desktop layout does not depend on horizontal scrolling.
- Verify that the live list content block stays horizontally centered within the list lane instead of pinning a narrow row composition to one side.
- Verify that any available runtime geometry audit reports no text overlap, horizontal clipping, host-region overflow, or unresolved near-height card-row mismatch in the rendered main window and auxiliary scene windows.
- Verify that runtime geometry also reports no main-scroll-host inset, no vertical scrollbar gutter drift, and no scrollbar track extending into the header or toolbar bands.
- Verify that runtime geometry also reports no collapsed or obviously loose page-heading text gaps and no row-level vertical rhythm drift that would still look visibly off by eye.
- Verify that runtime visual audit also covers at least one narrower supported window size when the shipped main window is resizable between a larger default size and a smaller minimum size.
- Verify that desktop work surfaces use the available content width truthfully and do not preserve a narrow centered column inside a wide content base unless a readability cap or product requirement explicitly explains it.
- Verify that any surface larger than `60px` that centers one numeric value as its primary message renders that number at `24px` or larger, unless the same card or region intentionally presents multiple peer numeric values.
- Verify that reusable containers keep a truthful height contract and that delegates avoid self-referential bindings or same-name model-role shadowing.
- Verify that card shells use responsive sizing contracts instead of fixed `width`, `height`, `implicitWidth`, or `implicitHeight`, and that any explicit shell bounds are minimum or maximum constraints rather than pinned dimensions.
- Verify that capped-width content compositions remain centered as a whole, that cards keep an explicit fixed `1px` shell stroke and at least `8px` of interior inset, and that cards avoid oversized empty space, edge-crowded focal content, and obviously over-wide buttons.
- Verify that repeated row surfaces inside cards keep a second inner inset from the card content lane instead of spanning edge-to-edge across the full card interior width, and that the bottom-most repeated row still leaves a visible floor inset.
- Verify that metric, scene, gallery, or similar row-aware card primitives are hosted by the intended responsive grid primitive rather than a plain `GridLayout`; otherwise same-row equalization rules are silently bypassed.
- Verify that auto-generated structural thumbnails inside cards use an explicit subdued mode or token path so the preview stays visually below the card's real text, metrics, and interactive controls.
- Verify that the near-height equalization rule is enforced not only in simple 2-column bands but also across each visual row of multi-column responsive card grids, while deliberate multi-column spanning cards are only exempt when that structure is explicit.
- Verify that equal-height 2-column card rows do not leave a sparse peer with a large dead vertical gap. When one card clearly has much less content, the layout should redistribute structure by spans, stacking, or a real lower section instead of preserving a tall shell with a large empty floor.
- Verify that page-level QML does not open-code `matchedCardHeight`, `Theme.equalizedCardPairHeight(...)`, or equivalent pair-equalization glue. Those patterns should live only inside reviewed reusable primitives, with any exception explicitly waived and justified.
- Verify that runtime visual audit covers more than the default first viewport when the touched UI includes deep scroll sections, lower card bands, alternate page states, or auxiliary windows.
- When screenshot artifacts exist, also screen them against `references/review/obvious-visual-failures.md` so obvious spacing, seam, alignment, or card-floor defects do not survive on the strength of a green log.
