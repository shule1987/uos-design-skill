---
inclusion: manual
---

# 提示组件

## Tooltip
```qml
component Tooltip: Popup {
    id: tooltip
    property string text: ""

    x: parent.width / 2 - width / 2
    y: parent.height + 8
    padding: Theme.spacingS

    background: Rectangle {
        radius: Theme.radiusSm
        color: Theme.dark ? Qt.rgba(0.9, 0.9, 0.9, 0.95) : Qt.rgba(0.2, 0.2, 0.2, 0.95)

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.2)
            shadowBlur: 0.2
        }
    }

    contentItem: Text {
        text: tooltip.text
        font.pixelSize: 12
        color: Theme.dark ? "#333333" : "#FFFFFF"
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 80 }
    }
}
```

## Toast
```qml
component Toast: Rectangle {
    id: toast
    property string message: ""
    property string type: "info"

    width: 400
    height: 48
    radius: Theme.radiusMd
    color: Theme.popupBg
    opacity: 0

    anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
        bottomMargin: 60
    }

    Row {
        anchors.centerIn: parent
        spacing: Theme.spacingM

        AppIcon {
            name: toast.type === "success" ? "check-circle" : "info"
            size: 20
            color: toast.type === "success" ? Theme.success : Theme.accentForeground
        }

        Text {
            text: toast.message
            font.pixelSize: 13
            color: Theme.textPrimary
        }
    }

    function show(msg, duration) {
        message = msg
        opacity = 1
        hideTimer.interval = duration || 3000
        hideTimer.start()
    }

    Timer {
        id: hideTimer
        onTriggered: toast.opacity = 0
    }

    Behavior on opacity { NumberAnimation { duration: 200 } }
}
```
