---
inclusion: manual
---

# 对话框组件

- 优先使用 DTK 或系统原生对话框。自定义 `Popup` 方案适用于品牌化内容或复杂内部布局。

## Dialog

```
        ┌──────────────────────────────┐
        │                              │
        │  对话框标题                   │
        │                              │
        │  这里是对话框的消息内容，     │
        │  可以换行显示。               │
        │                              │
        │              ┌──────┐ ┌─────┐│
        │              │ 取消 │ │确定 ││
        │              └──────┘ └─────┘│
        └──────────────────────────────┘
         (400px 宽，居中显示，带阴影)
```

```qml
component Dialog: Popup {
    id: dialog
    property string title: ""
    property string message: ""
    property var buttons: []

    width: 400
    height: contentColumn.implicitHeight + 48
    focus: true
    modal: true
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: parent
    Accessible.role: Accessible.Dialog
    Accessible.name: dialog.title

    background: Rectangle {
        radius: Theme.radiusLg
        color: Theme.popupBg

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.3)
            shadowBlur: 0.5
            shadowVerticalOffset: 4
        }
    }

    Overlay.modal: Rectangle {
        color: Theme.scrim
    }

    Column {
        id: contentColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.spacingXL
        }
        spacing: Theme.spacingL

        Text {
            width: parent.width
            text: dialog.title
            font.pixelSize: 18
            font.weight: Font.Medium
            color: Theme.textPrimary
        }

        Text {
            width: parent.width
            text: dialog.message
            font.pixelSize: 14
            color: Theme.textSecondary
            wrapMode: Text.Wrap
        }

        Row {
            anchors.right: parent.right
            spacing: Theme.spacingM

            Repeater {
                model: dialog.buttons
                delegate: BaseButton {
                    text: modelData.text
                    primary: modelData.primary || false
                    onClicked: {
                        if (modelData.callback)
                            modelData.callback()
                        dialog.close()
                    }
                }
            }
        }
    }
}
```
