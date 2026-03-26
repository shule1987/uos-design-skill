# Review Close-Out

Load this file before finishing a substantial review close-out or implementation close-out.

- Verify that any required runtime validation was actually performed rather than inferred from platform names alone.
- Verify that every remaining exception carries a narrow `uos-design: allow-*` waiver with the exact platform, version, or component reason.
- Verify that unresolved audit findings, missing DTK usage, and behavior regressions are treated as primary findings in the response.
