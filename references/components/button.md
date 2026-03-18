---
inclusion: manual
---

# 按钮组件

- 优先使用 DTK 按钮与标题栏按钮；以下组件是无法直接复用 DTK 时的 fallback。

## BaseButton

```
┌─────────────────┐     ┌─────────────────┐
│  [图标] 按钮文本 │     │     按钮文本     │
└─────────────────┘     └─────────────────┘
   带图标按钮              纯文本按钮

主按钮 (primary)         次要按钮 (default)
┌─────────────────┐     ┌─────────────────┐
│ ■ 保存 (白字)    │     │ □ 取消 (黑字)    │
└─────────────────┘     └─────────────────┘
  活动色背景               灰色背景
```

```qml
component BaseButton: Rectangle {
    id: button
    property string text: ""
    property string iconName: ""
    property bool primary: false
    property bool enabled: true
    property string accessibleName: text
    signal clicked()

    width: Math.max(88, contentRow.implicitWidth + Theme.spacingL * 2)
    height: 36
    radius: Theme.radiusSm
    opacity: enabled ? 1.0 : 0.5
    activeFocusOnTab: enabled
    border.width: activeFocus ? 2 : 0
    border.color: activeFocus ? Theme.focusRing : "transparent"
    color: {
        if (!enabled) return primary ? Theme.accentLight : Theme.surface
        if (pressed) return primary ? Theme.accentDark : Theme.surfaceActive
        if (hovered) return primary ? Theme.accentLight : Theme.surfaceHover
        return primary ? Theme.accentBackground : Theme.surface
    }

    property bool hovered: false
    property bool pressed: false
    Accessible.role: Accessible.Button
    Accessible.name: button.accessibleName

    HoverHandler { onHoveredChanged: button.hovered = hovered }
    TapHandler {
        enabled: button.enabled
        onPressedChanged: button.pressed = pressed
        onTapped: button.clicked()
    }
    Keys.onReturnPressed: if (button.enabled) button.clicked()
    Keys.onSpacePressed: if (button.enabled) button.clicked()

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        AppIcon {
            name: button.iconName
            size: 16
            color: button.primary ? Theme.onAccent : Theme.textStrong
            visible: button.iconName !== ""
        }

        Text {
            text: button.text
            font.pixelSize: 13
            color: button.primary ? Theme.onAccent : Theme.textStrong
        }
    }

    Behavior on color { ColorAnimation { duration: Theme.animFast } }
}
```

## IconButton
```qml
component IconButton: Rectangle {
    id: iconBtn
    property string iconName: ""
    property int iconSize: 16
    property bool enabled: true
    property string accessibleName: ""
    property color hoverColor: Theme.surfaceHover
    property color iconColor: Theme.iconNormal
    property color iconHoverColor: Theme.iconStrong
    signal clicked()

    width: 32
    height: 32
    radius: 16
    opacity: enabled ? 1.0 : 0.5
    activeFocusOnTab: enabled
    border.width: activeFocus ? 2 : 0
    border.color: activeFocus ? Theme.focusRing : "transparent"
    color: hovered ? hoverColor : "transparent"

    property bool hovered: false
    Accessible.role: Accessible.Button
    Accessible.name: accessibleName !== "" ? accessibleName : iconName

    AppIcon {
        anchors.centerIn: parent
        name: iconBtn.iconName
        size: iconBtn.iconSize
        color: !iconBtn.enabled
            ? Theme.textDisabled
            : (iconBtn.hovered ? iconBtn.iconHoverColor : iconBtn.iconColor)
    }

    HoverHandler { onHoveredChanged: iconBtn.hovered = hovered }
    TapHandler {
        enabled: iconBtn.enabled
        onTapped: iconBtn.clicked()
    }
    Keys.onReturnPressed: if (iconBtn.enabled) iconBtn.clicked()
    Keys.onSpacePressed: if (iconBtn.enabled) iconBtn.clicked()

    Behavior on color { ColorAnimation { duration: Theme.animFast } }
}
```

## NavButton
```qml
component NavButton: Rectangle {
    id: navBtn
    property string iconName: ""
    property bool highlighted: false
    property string accessibleName: ""
    signal clicked()

    width: 32
    height: 32
    radius: 8
    activeFocusOnTab: true
    color: {
        if (highlighted) return Theme.titlebarActive
        if (hovered) return Theme.titlebarHover
        return "transparent"
    }

    property bool hovered: false
    Accessible.role: Accessible.Button
    Accessible.name: accessibleName !== "" ? accessibleName : iconName

    AppIcon {
        anchors.centerIn: parent
        name: navBtn.iconName
        size: 16
        color: navBtn.hovered ? Theme.iconHover : Theme.iconNormal
    }

    HoverHandler { onHoveredChanged: navBtn.hovered = hovered }
    TapHandler { onTapped: navBtn.clicked() }
    Keys.onReturnPressed: navBtn.clicked()
    Keys.onSpacePressed: navBtn.clicked()

    Behavior on color { ColorAnimation { duration: Theme.animFast } }
}
```
