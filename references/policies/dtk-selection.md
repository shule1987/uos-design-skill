# DTK Selection Policy

Load this file when choosing between DTK and custom QML.

- Treat `org.deepin.dtk` and locally exported settings controls as the primary path.
- If the local export map says a DTK control exists, use DTK directly instead of wrapping plain Qt Quick Controls for styling convenience.
- Do not rebuild `Button`, `TextField`, `ComboBox`, `Switch`, `CheckBox`, `Menu`, `Dialog`, `ProgressBar`, or top-level window buttons when DTK already provides the control.
- Do not replace DTK structural templates such as `background`, `contentItem`, `indicator`, `handle`, `popup`, or `delegate` unless an exact local capability gap justifies it.
- If DTK is unavailable or insufficient, state the exact missing control, property, or runtime limitation and keep the fallback narrow.
