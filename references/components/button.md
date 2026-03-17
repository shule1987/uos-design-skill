---
inclusion: manual
---

# 按钮组件

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
  蓝色背景                 灰色背景
```

```qml
component BaseButton: Rectangle {
    id: button
    property string text: ""
    property string iconName: ""
    property bool primary: false
    signal clicked()

    width: implicitWidth
    height: 36
    radius: Theme.radiusSm
    color: {
        if (pressed) return primary ? Theme.accentDark : Theme.surfaceActive
        if (hovered) return primary ? Theme.accentLight : Theme.surfaceHover
        return primary ? Theme.accent : Theme.surface
    }

    property bool hovered: false
    property bool pressed: false

    HoverHandler { onHoveredChanged: button.hovered = hovered }
    TapHandler {
        onPressedChanged: button.pressed = pressed
        onTapped: button.clicked()
    }

    Row {
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        AppIcon {
            name: button.iconName
            size: 16
            color: button.primary ? "#FFFFFF" : Theme.textPrimary
            visible: button.iconName !== ""
        }

        Text {
            text: button.text
            font.pixelSize: 13
            color: button.primary ? "#FFFFFF" : Theme.textPrimary
        }
    }

    Behavior on color { ColorAnimation { duration: 80 } }
}
```

## IconButton
```qml
component IconButton: Rectangle {
    id: iconBtn
    property string iconName: ""
    property int iconSize: 16
    signal clicked()

    width: 32
    height: 32
    radius: 16
    color: hovered ? Theme.surfaceHover : "transparent"

    property bool hovered: false

    AppIcon {
        anchors.centerIn: parent
        name: iconBtn.iconName
        size: iconBtn.iconSize
        color: iconBtn.hovered ? Theme.iconHover : Theme.iconNormal
    }

    HoverHandler { onHoveredChanged: iconBtn.hovered = hovered }
    TapHandler { onTapped: iconBtn.clicked() }

    Behavior on color { ColorAnimation { duration: 80 } }
}
```

## NavButton
```qml
component NavButton: Rectangle {
    id: navBtn
    property string iconName: ""
    property bool highlighted: false
    signal clicked()

    width: 32
    height: 32
    radius: 8
    color: {
        if (highlighted) return Colors.chromeTopActiveFill
        if (hovered) return Colors.chromeTopHoverFill
        return "transparent"
    }

    property bool hovered: false

    AppIcon {
        anchors.centerIn: parent
        name: navBtn.iconName
        size: 16
        color: navBtn.hovered ? Colors.chromeTopIconHover : Colors.chromeTopIconNormal
    }

    HoverHandler { onHoveredChanged: navBtn.hovered = hovered }
    TapHandler { onTapped: navBtn.clicked() }

    Behavior on color { ColorAnimation { duration: 100 } }
}
```
