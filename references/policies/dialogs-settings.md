# Dialogs And Settings Policy

Load this file for dialogs, About surfaces, settings windows, and transient notifications.

- Use standard DTK dialog paths when they exist locally:
  - `D.DialogWindow` for standard desktop dialogs
  - `Settings.SettingsDialog` for multi-group settings windows
  - `D.AboutDialog` for About surfaces
- Treat `D.Dialog` as a popup-style or in-content exception, not as the normal desktop dialog shell.
- Do not custom-draw dialog shells, frames, or button areas.
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
