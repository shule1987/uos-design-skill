---
inclusion: manual
---

# 输入框组件

## TextField

```
普通状态：
┌─────────────────────────┐
│ 请输入文本...            │
└─────────────────────────┘

聚焦状态：
┏━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 输入的文本|              ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━┛
  (蓝色边框，光标闪烁)
```

## SearchField

```
┌─────────────────────────┐
│ 🔍 搜索...            ✕ │
└─────────────────────────┘
  图标   占位符      清除
```

```qml
component TextField: Rectangle {
    id: field
    property alias text: input.text
    property alias placeholderText: placeholder.text

    width: 200
    height: 36
    radius: Theme.radiusSm
    color: input.activeFocus ? Theme.surfaceActive : Theme.surface
    border.color: input.activeFocus ? Theme.accent : Theme.border
    border.width: 1

    TextInput {
        id: input
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: Theme.spacingM
        }
        font.pixelSize: 13
        color: Theme.textPrimary
        selectionColor: Theme.accent
        selectByMouse: true
        clip: true
    }

    Text {
        id: placeholder
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: Theme.spacingM
        }
        font.pixelSize: 13
        color: Theme.textMuted
        visible: input.text.length === 0 && !input.activeFocus
    }

    Behavior on color { ColorAnimation { duration: 80 } }
}
```

## SearchField
```qml
component SearchField: Rectangle {
    id: searchField
    property alias text: input.text
    signal searchRequested(string query)

    width: 240
    height: 32
    radius: Theme.radiusSm
    color: input.activeFocus ? Theme.surfaceActive : Theme.surface

    AppIcon {
        id: searchIcon
        anchors {
            left: parent.left
            leftMargin: Theme.spacingM
            verticalCenter: parent.verticalCenter
        }
        name: "search"
        size: 16
        color: Theme.textSecondary
    }

    TextInput {
        id: input
        anchors {
            left: searchIcon.right
            leftMargin: Theme.spacingS
            right: clearBtn.left
            rightMargin: Theme.spacingS
            verticalCenter: parent.verticalCenter
        }
        font.pixelSize: 13
        color: Theme.textPrimary
        selectByMouse: true
        clip: true
        onAccepted: searchField.searchRequested(text)
    }

    IconButton {
        id: clearBtn
        anchors {
            right: parent.right
            rightMargin: 4
            verticalCenter: parent.verticalCenter
        }
        iconName: "x"
        iconSize: 12
        visible: input.text.length > 0
        onClicked: input.text = ""
    }

    Behavior on color { ColorAnimation { duration: 80 } }
}
```
