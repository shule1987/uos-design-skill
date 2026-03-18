---
inclusion: manual
---

# 滑块组件

## Slider
```qml
component Slider: Item {
    id: slider
    property real value: 0.5
    property real from: 0.0
    property real to: 1.0
    signal moved()

    width: 200
    height: 32

    Rectangle {
        id: track
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: 4
        radius: 2
        color: Theme.surface
    }

    Rectangle {
        anchors {
            left: track.left
            verticalCenter: track.verticalCenter
        }
        width: handle.x + handle.width / 2
        height: 4
        radius: 2
        color: Theme.accentBackground
    }

    Rectangle {
        id: handle
        width: 16
        height: 16
        radius: 8
        x: (slider.value - slider.from) / (slider.to - slider.from) * (slider.width - width)
        anchors.verticalCenter: parent.verticalCenter
        color: "#FFFFFF"
        border.color: Theme.accentForeground
        border.width: 2

        DragHandler {
            target: handle
            xAxis.enabled: true
            yAxis.enabled: false
            xAxis.minimum: 0
            xAxis.maximum: slider.width - handle.width
        }
    }
}
```
