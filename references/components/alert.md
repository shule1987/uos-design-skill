---
inclusion: manual
---

# 警告提示组件

## Alert
```qml
component Alert: Rectangle {
    id: alert
    property string type: "info"  // info, success, warning, error
    property string title: ""
    property string message: ""
    property bool closable: false
    signal closed()

    width: parent.width
    height: contentRow.height + Theme.spacingL * 2
    radius: Theme.radiusSm
    color: {
        switch(type) {
            case "success": return Qt.rgba(0, 0.78, 0.33, 0.1)
            case "warning": return Qt.rgba(1, 0.6, 0, 0.1)
            case "error": return Qt.rgba(0.96, 0.26, 0.21, 0.1)
            default: return Qt.rgba(0, 0.51, 1, 0.1)
        }
    }
    border.color: {
        switch(type) {
            case "success": return Theme.success
            case "warning": return Theme.warning
            case "error": return Theme.danger
            default: return Theme.accent
        }
    }
    border.width: 1

    Row {
        id: contentRow
        anchors {
            left: parent.left
            right: closeBtn.left
            verticalCenter: parent.verticalCenter
            leftMargin: Theme.spacingL
            rightMargin: Theme.spacingM
        }
        spacing: Theme.spacingM

        AppIcon {
            name: {
                switch(alert.type) {
                    case "success": return "check-circle"
                    case "warning": return "alert-triangle"
                    case "error": return "x-circle"
                    default: return "info"
                }
            }
            size: 20
            color: alert.border.color
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            spacing: 4
            width: parent.width - 20 - parent.spacing

            Text {
                text: alert.title
                font.pixelSize: 14
                font.weight: Font.Medium
                color: Theme.textPrimary
                visible: alert.title !== ""
            }

            Text {
                width: parent.width
                text: alert.message
                font.pixelSize: 13
                color: Theme.textSecondary
                wrapMode: Text.Wrap
            }
        }
    }

    IconButton {
        id: closeBtn
        anchors {
            right: parent.right
            rightMargin: Theme.spacingM
            verticalCenter: parent.verticalCenter
        }
        iconName: "x"
        iconSize: 14
        visible: alert.closable
        onClicked: {
            alert.visible = false
            alert.closed()
        }
    }
}
```
