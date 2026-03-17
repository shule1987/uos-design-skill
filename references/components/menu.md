---
inclusion: manual
---

# 菜单组件

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
    signal triggered()

    width: parent.width
    height: 34
    color: hovered ? Theme.surfaceHover : "transparent"

    property bool hovered: false

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
            color: Theme.textPrimary
            visible: menuItem.iconName !== ""
        }

        Text {
            text: menuItem.checked ? "✓" : ""
            font.pixelSize: 14
            color: Theme.accent
            visible: menuItem.checkable
        }

        Text {
            text: menuItem.text
            font.pixelSize: 13
            color: Theme.textPrimary
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
        onTapped: {
            if (menuItem.checkable)
                menuItem.checked = !menuItem.checked
            menuItem.triggered()
        }
    }

    Behavior on color { ColorAnimation { duration: 80 } }
}
```

## PopupMenu
```qml
component PopupMenu: Popup {
    id: menu
    property var entries: []

    width: Math.max(180, menuColumn.implicitWidth + 12)
    padding: 6
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

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
                iconName: modelData.iconSource || ""
                shortcut: modelData.shortcut || ""
                checked: modelData.checked || false
                checkable: modelData.checkable || false
                onTriggered: {
                    if (modelData.callback)
                        modelData.callback()
                    menu.close()
                }
            }
        }
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 120 }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 80 }
    }
}
```
