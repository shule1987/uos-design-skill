---
inclusion: manual
---

# 菜单组件

- 优先使用 DTK 菜单和菜单项。自定义菜单主要用于复杂 delegate、混排内容或平台控件不足的场景。

## MenuItem

```
┌─────────────────────────┐
│ 🔍 搜索         Ctrl+F  │
│ 📄 新建         Ctrl+N  │
│ 💾 保存         Ctrl+S  │
├─────────────────────────┤
│ ✓ 显示行号              │
│   自动换行              │
├─────────────────────────┤
│ ⚙️ 设置                 │
└─────────────────────────┘
  图标  文本      快捷键
```

```qml
component MenuItem: Rectangle {
    id: menuItem
    property string text: ""
    property string iconName: ""
    property string shortcut: ""
    property bool checked: false
    property bool checkable: false
    property bool enabled: true
    signal triggered()

    width: parent.width
    height: 34
    opacity: enabled ? 1.0 : 0.5
    activeFocusOnTab: enabled
    color: hovered ? Theme.surfaceHover : "transparent"

    property bool hovered: false
    Accessible.role: Accessible.MenuItem
    Accessible.name: menuItem.text

    Row {
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
        spacing: 10

        AppIcon {
            name: menuItem.iconName
            size: 16
            color: menuItem.hovered ? Theme.iconStrong : Theme.iconNormal
            visible: menuItem.iconName !== ""
        }

        Text {
            text: menuItem.checked ? "✓" : ""
            font.pixelSize: 14
            color: Theme.accentForeground
            visible: menuItem.checkable
        }

        Text {
            text: menuItem.text
            font.pixelSize: 13
            color: menuItem.hovered ? Theme.textStrong : Theme.textPrimary
        }
    }

    Text {
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        text: menuItem.shortcut
        font.pixelSize: 11
        font.family: Theme.fontMono
        color: Theme.textMuted
        visible: menuItem.shortcut !== ""
    }

    HoverHandler { onHoveredChanged: menuItem.hovered = hovered }
    TapHandler {
        enabled: menuItem.enabled
        onTapped: {
            if (menuItem.checkable)
                menuItem.checked = !menuItem.checked
            menuItem.triggered()
        }
    }
    Keys.onReturnPressed: if (menuItem.enabled) menuItem.triggered()
    Keys.onSpacePressed: if (menuItem.enabled) menuItem.triggered()

    Behavior on color { ColorAnimation { duration: Theme.animFast } }
}
```

## PopupMenu
```qml
component PopupMenu: Popup {
    id: menu
    property var entries: []

    width: Math.max(180, menuColumn.implicitWidth + 12)
    focus: true
    padding: 6
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    background: Rectangle {
        radius: Theme.radiusMd
        color: Theme.popupBg

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Theme.dark ? Qt.rgba(0,0,0,0.34) : Qt.rgba(0,0,0,0.18)
            shadowBlur: 0.36
            shadowVerticalOffset: 2
        }
    }

    Column {
        id: menuColumn
        width: parent.width
        spacing: 2

        Repeater {
            model: menu.entries
            delegate: MenuItem {
                text: modelData.text || ""
                iconName: modelData.iconName || modelData.iconSource || ""
                shortcut: modelData.shortcut || ""
                checked: modelData.checked || false
                checkable: modelData.checkable || false
                enabled: modelData.enabled !== false
                onTriggered: {
                    if (modelData.callback)
                        modelData.callback()
                    menu.close()
                }
            }
        }
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.animFast }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.animFast }
    }
}
```
