# Environment Review

Load this file when validating setup, DTK exports, and routing discipline.

- Verify that `scripts/audit_uos_qml.sh <repo-root>` was run and reported.
- Verify that any available `UOS_DESIGN_VISUAL_AUDIT` runtime geometry pass also ran through `scripts/audit_uos_qml.sh <repo-root>` before sign-off.
- Verify the local DTK export map in `references/local-dtk-controls.md` against the actual `qmldir` exports when availability matters.
- Verify that build integration imports and links the relevant DTK modules when DTK is used.
- Verify that Qt/DTK and `Wayland` or `X11` assumptions are stated when they affect runtime behavior.
- Verify that the implementation routes to the smallest relevant component or foundation references instead of inventing undocumented controls.
- Verify that build success was not treated as completion before a full review of touched UI, touched backend behavior, and relevant PRD or acceptance criteria.
- Verify that automatic dynamic validation ran on the built artifact by using the strongest available automated path in the repo instead of relying on compile success or static inspection alone.
- Verify that the exact dynamic validation commands or automation surfaces were reported, and that missing automation was treated as a blocking gap rather than silently waived.
