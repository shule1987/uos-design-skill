# Obvious Visual Failures

Load this file during implementation close-out or review whenever shipped UI changed. Use it as a screenshot-level blocker list for defects that should be caught by eye even when a heuristic audit stays green.

## Blocking Patterns

- Sidebar-top continuity breaks: the sidebar reads as two stacked surfaces because an extra titleband or top rectangle was painted instead of keeping one continuous column.
- Split-pane seams: a gap, stray gutter, or duplicated divider appears between sidebar and content.
- Header slab drift: the content-side header reads as a permanent painted band or a transparent strip at rest instead of a real frosted overlay above underlapping content.
- Sidebar row misalignment: persistent-sidebar list items stop reading as one left-aligned lane because icons or labels drift, center, or sit on mismatched baselines.
- List-lane drift: the content block inside a row is visibly pinned to one side of a wider lane instead of staying centered in the usable row width.
- Card floor collapse: the last repeated row or the main content block lands on the card bottom edge with effectively zero breathing room.
- Card overflow or stacking: text, buttons, charts, or repeated rows overlap, clip, or escape the card or viewport bounds.
- Near-height card stagger: cards in the same visual row are close in height but their top or bottom edges still visibly misalign.
- Decorative list icon backgrounds: list leading icons sit on self-drawn chips, capsules, or tiles that visually outrank the row content.
- Stroke drift: card or structural-thumbnail borders stop reading as a true fixed `1px` edge because scaling, antialiasing, or shell composition thickened the line.

## Review Use

- Treat these patterns as blockers even if the current audit scripts do not report them.
- When a defect repeats across projects, either add a stronger reusable primitive or extend the audit coverage so the pattern becomes mechanically harder to ship.
