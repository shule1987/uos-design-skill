# Layout And Density Review

Load this file when reviewing lists, tables, cards, row density, width strategy, and reusable container sizing.

- Verify compliance with `references/policies/layout-density.md`.
- Verify that variable-length data surfaces default to compact responsive rows rather than oversized standalone cards unless the user explicitly asked for a card layout.
- Verify that repeated rows with trailing controls align to one shared trailing control column and that multi-line row primitives keep a correctly sized leading icon unless a narrow exception explains otherwise.
- Verify that list and table layouts use responsive widths, that scrollable regions consume available height, and that the primary desktop layout does not depend on horizontal scrolling.
- Verify that desktop work surfaces use the available content width truthfully and do not preserve a narrow centered column inside a wide content base unless a readability cap or product requirement explicitly explains it.
- Verify that any surface larger than `60px` that centers one numeric value as its primary message renders that number at `24px` or larger, unless the same card or region intentionally presents multiple peer numeric values.
- Verify that reusable containers keep a truthful height contract and that delegates avoid self-referential bindings or same-name model-role shadowing.
- Verify that capped-width content compositions remain centered as a whole and that cards avoid oversized empty space, edge-crowded focal content, and obviously over-wide buttons.
- Verify that auto-generated structural thumbnails inside cards use an explicit subdued mode or token path so the preview stays visually below the card's real text, metrics, and interactive controls.
- Verify that the near-height equalization rule is enforced not only in simple 2-column bands but also across each visual row of multi-column responsive card grids, while deliberate multi-column spanning cards are only exempt when that structure is explicit.
