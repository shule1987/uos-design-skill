---
inclusion: manual
---

# 通知组件

## Notification
```qml
component Notification: Rectangle {
    id: notification
    property string type: "info"
    property string title: ""
    property string message: ""
    property int duration: 4500

    width: 320
    height: contentColumn.height + Theme.spacingL * 2
    radius: Theme.radiusMd
    color: Theme.popupBg
    opacity: 0
    visible: opacity > 0

    x: parent.width - width - Theme.spacingXL
    y: Theme.spacingXL

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.2)
        shadowBlur: 0.4
        shadowVerticalOffset: 2
    }

    Column {
        id: contentColumn
        anchors {
            left: parent.left
            right: closeBtn.left
            top: parent.top
            margins: Theme.spacingL
        }
        spacing: Theme.spacingS

        Row {
            spacing: Theme.spacingM
            width: parent.width

            AppIcon {
                name: {
                    switch(notification.type) {
                        case "success": return "check-circle"
                        case "warning": return "alert-triangle"
                        case "error": return "x-circle"
                        default: return "info"
                    }
                }
                size: 20
                color: {
                    switch(notification.type) {
                        case "success": return Theme.success
                        case "warning": return Theme.warning
                        case "error": return Theme.danger
                        default: return Theme.accent
                    }
                }
            }

            Text {
                text: notification.title
                font.pixelSize: 14
                font.weight: Font.Medium
                color: Theme.textPrimary
            }
        }

        Text {
            width: parent.width
            text: notification.message
            font.pixelSize: 13
            color: Theme.textSecondary
            wrapMode: Text.Wrap
        }
    }

    IconButton {
        id: closeBtn
        anchors {
            right: parent.right
            top: parent.top
            margins: Theme.spacingM
        }
        iconName: "x"
        iconSize: 14
        onClicked: notification.close()
    }

    function show() {
        opacity = 1
        if (duration > 0) {
            hideTimer.interval = duration
            hideTimer.start()
        }
    }

    function close() {
        opacity = 0
    }

    Timer {
        id: hideTimer
        onTriggered: notification.close()
    }

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }
}
```
