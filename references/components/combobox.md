---
inclusion: manual
---

# 下拉选择组件

## ComboBox
```qml
component ComboBox: Rectangle {
    id: comboBox
    property var model: []
    property int currentIndex: 0
    property string accessibleName: qsTr("下拉选择")

    width: 200
    height: 36
    radius: Theme.radiusSm
    color: Theme.surface
    activeFocusOnTab: true
    Accessible.name: comboBox.accessibleName

    Row {
        anchors {
            fill: parent
            margins: Theme.spacingM
        }
        spacing: Theme.spacingS

        Text {
            text: comboBox.model[comboBox.currentIndex] || ""
            font.pixelSize: 13
            color: Theme.textPrimary
            width: parent.width - 20
            elide: Text.ElideRight
        }

        AppIcon {
            name: "chevron-down"
            size: 16
            color: Theme.textSecondary
        }
    }

    TapHandler { onTapped: dropdown.open() }
    Keys.onReturnPressed: dropdown.open()
    Keys.onSpacePressed: dropdown.open()

    Popup {
        id: dropdown
        y: parent.height + 4
        width: parent.width
        focus: true
        padding: 6

        background: Rectangle {
            radius: Theme.radiusMd
            color: Theme.popupBg
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: comboBox.model
                delegate: Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.radiusSm
                    color: hovered ? Theme.surfaceHover : "transparent"

                    property bool hovered: false

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: Theme.spacingM
                            verticalCenter: parent.verticalCenter
                        }
                        text: modelData
                        font.pixelSize: 13
                        color: Theme.textPrimary
                    }

                    HoverHandler { onHoveredChanged: parent.hovered = hovered }
                    TapHandler {
                        onTapped: {
                            comboBox.currentIndex = index
                            dropdown.close()
                        }
                    }
                }
            }
        }
    }
}
```
