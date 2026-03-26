# Dialogs And Settings Review

Load this file when reviewing dialogs, settings windows, About surfaces, and transient notifications.

- Verify compliance with `references/policies/dialogs-settings.md`.
- Verify that custom dialog shells, frames, and action bars are not introduced without a narrow exception.
- Verify that every `Settings.SettingsDialog` root sets both `title` and `icon`.
- Verify that custom `Settings.OptionDelegate` fallback rows stay layout-only and do not restyle DTK settings rhythm.
- Verify that settings windows are reused rather than recreated on every open unless a documented exception explains why.
- Verify that in-app transient notifications are still owned by DTK `FloatingMessage` rather than a custom transient shell.
