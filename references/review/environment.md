# Environment Review

Load this file when validating setup, DTK exports, and routing discipline.

- Verify that `scripts/audit_uos_qml.sh <repo-root>` was run and reported.
- Verify the local DTK export map in `references/local-dtk-controls.md` against the actual `qmldir` exports when availability matters.
- Verify that build integration imports and links the relevant DTK modules when DTK is used.
- Verify that Qt/DTK and `Wayland` or `X11` assumptions are stated when they affect runtime behavior.
- Verify that the implementation routes to the smallest relevant component or foundation references instead of inventing undocumented controls.
