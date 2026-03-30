# Review Close-Out

Load this file before finishing a substantial review close-out or implementation close-out.

- Verify that any required runtime validation was actually performed rather than inferred from platform names alone.
- Verify that build success was not presented as task completion before full review and automatic dynamic validation both passed.
- Verify that the close-out reviewed changed pages, windows, dialogs, and touched backend or controller behavior against the relevant PRD or acceptance criteria, not just DTK shell compliance.
- Verify that the strongest available automatic dynamic validation path actually ran on the built artifact and that the exact commands or automation surfaces were reported.
- Verify that missing automatic dynamic validation was treated as a blocking gap or was fixed during the task rather than silently accepted.
- Verify that every remaining exception carries a narrow `uos-design: allow-*` waiver with the exact platform, version, or component reason.
- Verify that unresolved audit findings, missing DTK usage, and behavior regressions are treated as primary findings in the response.
