# Dialogs And Settings Policy

Load this file for dialogs, About surfaces, settings windows, and transient notifications.

- Use standard DTK dialog paths when they exist locally:
  - `D.DialogWindow` for standard desktop dialogs
  - `Settings.SettingsDialog` for multi-group settings windows
  - `D.AboutDialog` for About surfaces
- Treat `D.Dialog` as a popup-style or in-content exception, not as the normal desktop dialog shell.
- Do not custom-draw dialog shells, frames, or button areas.
- For `D.DialogWindow`, let a DTK-owned `D.DialogButtonBox` own the action footer. Do not hand-build a bare `RowLayout` or `Flow` button row in the dialog body.
- Standard desktop dialogs must keep one DTK-owned action row, with the secondary or cancel action on the left and the primary or destructive action on the right.
- When that DTK-owned action row has multiple buttons, they must evenly split the available footer width instead of shrinking to label width. In QML, set `Layout.fillWidth: true` and the same `Layout.preferredWidth` on each action button.
- If the local DTK declarative footer path still refuses to split widths evenly or renders the buttons incorrectly, fall back to one local equal-width footer row built from DTK buttons with a standard top divider, and mark the file with `uos-design: allow-manual-dialog-action-row`. Do not move that fallback into a reusable wrapper component.
- Do not leave page-style vertical margins or wide gaps around that standard dialog footer row.
- Do not wrap `D.DialogButtonBox` in a custom reusable footer component that overrides its `contentItem` structure unless a narrow waiver documents the platform blocker.
- Keep DTK-owned title bars on standard DTK About and Settings surfaces unless a validated platform defect requires a fallback.
- For `Settings.SettingsDialog`, keep a root `title` and root `icon`.
- Use `Settings.CheckBox`, `Settings.ComboBox`, and `Settings.LineEdit` when those controls are locally exported.
- Reserve `Settings.OptionDelegate` fallback rows for controls the local settings module does not wrap directly.
- Keep custom settings fallback rows layout-only. Do not restyle DTK settings rhythm with project-specific fonts, body colors, or spacing systems unless a narrow waiver explains the reason.
- Route restore-default behavior through the DTK-owned footer or `SettingsContainer.resetSettings()` path instead of a normal settings row.
- Prefer a stable reusable settings window instance over recreating the window on every open.
- Use DTK `FloatingMessage` for in-app transient notifications when it exists locally.
- Treat DTK `FloatingMessage` as the default and required owner for in-app transient notifications when local DTK exports it.
- Do not replace DTK-owned in-app transient notifications with custom popup shells, page-level fake toasts, or self-drawn transient banners without a narrow documented platform blocker.
