---
name: uos-design-orchestrator
description: Lead-agent orchestration layer for large UOS and Deepin desktop UI programs that span multiple pages, windows, primitives, audits, or repo-wide hardening. Use when work should be split across sub-agents while keeping uos-design as the single source of design rules and audit authority.
---

# UOS Design Orchestrator

Use this skill only for large-scope UOS or Deepin work. It does not define UI rules. It coordinates delegation while `uos-design` remains the rule base, reference router, and validation authority.

## Activation Gate

Use this skill when at least one of these is true:

- the task spans multiple pages, windows, dialogs, or scene states
- the repo needs new scaffolds, guardrails, and shipped UI work in one effort
- several disjoint file-ownership lanes exist and can run in parallel
- static audit, runtime visual audit, and screenshot review all need explicit coverage planning

Stay on `uos-design` alone for small fixes, single-page tuning, or one-file reviews.

## Workflow

1. Load `uos-design/SKILL.md` first, then only the smallest relevant `uos-design` references.
2. Build a scope map before delegating:
   - touched surfaces, primitives, backend or controller paths
   - required audit scenes and window sizes
   - acceptance or PRD sources
   - shared files that must stay with the lead agent
3. Keep critical-path decisions local:
   - architecture and primitive selection
   - waivers and policy interpretation
   - final integration of shared files
   - final sign-off
4. Split only bounded sidecar work with disjoint ownership. Use `references/role-map.md`.
5. Every sub-agent brief must include:
   - owned files or directories
   - required `uos-design` references to load
   - exact completion gate and commands to run
   - explicit instruction not to sign off the task
6. Reconcile all outputs locally, then run integrated validation from the main workspace:
   - `scripts/audit_uos_qml.sh`
   - `scripts/validate_uos_release.sh`
   - screenshot inspection against obvious visual failures
7. Close the task only from the integrated workspace, never from sub-agent claims.

## Non-Negotiables

- `uos-design` owns design rules. This skill must not redefine or relax them.
- Do not duplicate long policy text here. New hard constraints belong in `uos-design` plus enforceable audits.
- One file, one owner at a time. Shared files stay with the lead agent unless ownership is explicit.
- Sub-agents may explore or implement, but only the lead agent may approve waivers, audit readiness, or release readiness.
- If the work is not meaningfully parallelizable, do not delegate for form's sake.

## References

- `references/role-map.md`
- `references/handoffs.md`
