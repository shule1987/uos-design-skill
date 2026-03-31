# Handoff Contract

Every sub-agent final message should be short, but it must contain these fields:

- `scope:` exact responsibility completed
- `files:` absolute paths changed, or `none`
- `uos_refs:` the `uos-design` files loaded
- `commands:` commands run and whether they passed
- `risks:` remaining blockers, missing validation, or visual suspects
- `shared_files:` whether shared files were intentionally left untouched

## Required Rules

- Report only the owned lane. Do not claim whole-task completion.
- If runtime or visual validation was not run, say so explicitly.
- If a waiver was needed, point to the exact file and reason, then stop. The lead agent decides whether to keep it.
- If screenshots reveal visible defects, report the scene key and image path instead of summarizing loosely.

## Example

```text
scope: implemented sidebar primitive hover and selected states
files: /repo/src/qml/components/SidebarNavigation.qml
uos_refs: references/components/sidebar.md, references/policies/sidebar.md
commands: bash scripts/audit_uos_qml.sh /repo (pass)
risks: runtime screenshot review still pending for flat-sidebar at 1040x720
shared_files: App.qml untouched
```
