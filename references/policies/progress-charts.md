# Progress And Charts Policy

Load this file for progress bars, rings, gauges, charts, and numeric overlays.

- Keep every visible progress strip, bar, or track at `20px` thickness or below.
- Keep every scrollbar at `20px` thickness or below.
- Do not render the same numeric ratio as both a ring or gauge and a horizontal progress indicator on the same surface.
- Give progress fills, strokes, and chart lines a same-color shadow treatment that stays light and unclipped.
- For charts, expose labeled `x` and `y` axes, tick marks, and animated value changes.
- For chart curves or polylines, add a same-hue top-to-bottom gradient plus same-color shadow rather than shipping a flat line.
- For ring or gauge center text, keep only the number or the number plus one short status title inside the graphic.
- Keep explanatory copy, hints, and timestamps outside the ring or chart body.
- Render units such as `%`, `ms`, storage, or bandwidth at a smaller size than the main number.
