---
inclusion: manual
---

# 开关组件

## Switch
```qml
component Switch: Item {
    id: switchControl
    property bool checked: false
    signal toggled()

    width: 44
    height: 24
    activeFocusOnTab: true
    Accessible.name: qsTr("开关")

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: switchControl.checked ? Theme.accentBackground : Theme.surface
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Rectangle {
        width: 20
        height: 20
        radius: 10
        x: switchControl.checked ? parent.width - width - 2 : 2
        y: 2
        color: "#FFFFFF"

        Behavior on x {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.2)
            shadowBlur: 0.3
        }
    }

    TapHandler {
        onTapped: {
            switchControl.checked = !switchControl.checked
            switchControl.toggled()
        }
    }
    Keys.onReturnPressed: {
        switchControl.checked = !switchControl.checked
        switchControl.toggled()
    }
    Keys.onSpacePressed: {
        switchControl.checked = !switchControl.checked
        switchControl.toggled()
    }
}
```

## CheckBox
```qml
component CheckBox: Row {
    id: checkbox
    property string text: ""
    property bool checked: false
    signal toggled()

    spacing: Theme.spacingS
    activeFocusOnTab: true
    Accessible.name: checkbox.text

    Rectangle {
        width: 18
        height: 18
        radius: 4
        color: checkbox.checked ? Theme.accentBackground : Theme.surface
        border.color: checkbox.checked ? Theme.accentForeground : Theme.border
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "✓"
            font.pixelSize: 12
            color: "#FFFFFF"
            visible: checkbox.checked
        }

        Behavior on color { ColorAnimation { duration: 80 } }
    }

    Text {
        text: checkbox.text
        font.pixelSize: 13
        color: Theme.textPrimary
    }

    TapHandler {
        onTapped: {
            checkbox.checked = !checkbox.checked
            checkbox.toggled()
        }
    }
    Keys.onReturnPressed: {
        checkbox.checked = !checkbox.checked
        checkbox.toggled()
    }
    Keys.onSpacePressed: {
        checkbox.checked = !checkbox.checked
        checkbox.toggled()
    }
}
```

## RadioButton
```qml
component RadioButton: Row {
    id: radio
    property string text: ""
    property bool checked: false
    signal toggled()

    spacing: Theme.spacingS
    activeFocusOnTab: true
    Accessible.name: radio.text

    Rectangle {
        width: 18
        height: 18
        radius: 9
        color: Theme.surface
        border.color: radio.checked ? Theme.accentForeground : Theme.border
        border.width: 1

        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: Theme.accentBackground
            visible: radio.checked
        }
    }

    Text {
        text: radio.text
        font.pixelSize: 13
        color: Theme.textPrimary
    }

    TapHandler {
        onTapped: {
            radio.checked = true
            radio.toggled()
        }
    }
    Keys.onReturnPressed: {
        radio.checked = true
        radio.toggled()
    }
    Keys.onSpacePressed: {
        radio.checked = true
        radio.toggled()
    }
}
```
