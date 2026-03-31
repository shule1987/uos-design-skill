# Repo Guardrails

Load this file when starting a new UOS/Deepin desktop repo, when the repo still lacks a disciplined authoring path, or when repeated UI regressions suggest the design rules are landing too late in the workflow.

## Goal

Move the strongest repeatable constraints into the repo's default authoring path so developers fail early during normal iteration instead of discovering obvious defects only at final review.

## Minimum Guardrail Set

- Add one repo-local guarded build entry that runs the UOS static audit before compile. Do not leave raw `cmake --build` or equivalent as the only routine path when the repo can support a stronger gate.
- Add one repo-local full validation entry that runs runtime geometry validation, screenshot capture, and the executable smoke path on the built artifact.
- Keep repo-local visual-audit scene and narrower-size manifests under version control when the app has multiple scenes or meaningful window resizing.
- Add one repo-local page scaffold or generator for new business pages. The scaffold should stamp the baseline `pageScrollViewport`, header-glass overlap prep, page padding, `PageHeading`, and the approved shell primitives instead of starting from a blank file.
- Keep a small approved primitive set in the repo and make business pages consume those primitives first. If a recurring pattern is missing, add a primitive before open-coding the same structure across pages.
- Add repo-local contributor guidance such as `AGENTS.md` or an equivalent file that names the guarded commands, the approved primitives, and the highest-risk forbidden structures.

## Skill Bootstrap

- When the skill is installed locally, prefer bootstrapping the first repo-local guardrails from `scripts/install_repo_guardrails.sh` under this skill instead of rewriting the same starter files by hand.
- The bundled `assets/repo_guardrails/` templates are a baseline, not a sign-off. Patch the generated files to the repo's real QML module URI, singleton names, approved primitives, and scene coverage.

## High-Risk Structures To Ban In Repo Guidance

- Page-level `Row` / `RowLayout` bands with multiple peer cards instead of the sanctioned equalization host.
- Ad hoc sidebars, titlebars, frosted headers, and split-pane seams in business QML.
- Fixed card shell width or height as a layout shortcut.
- Row surfaces inside cards that run flush to the card content lane.
- Blank page files that bypass the page scaffold and therefore omit runtime visual-audit hooks.

## Completion Bias

- If a new repo is expected to ship more than one page or window, prefer adding the guardrails early rather than waiting for the first visual regression cycle.
- If recurring screenshot-level defects keep escaping static review, treat missing repo guardrails as a workflow bug, not only an implementation bug.
