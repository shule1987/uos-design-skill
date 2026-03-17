---
inclusion: manual
---

# 步骤条组件

## Stepper

```
  ①────────②────────③────────④
 完成     进行中    待处理    待处理
 ✓        2        3        4
[绿色]   [蓝色]   [灰色]   [灰色]

步骤1    步骤2    步骤3    步骤4
已完成   进行中   等待中   等待中
```

```qml
component Stepper: Row {
    id: stepper
    property var steps: []  // [{title, description}]
    property int current: 0

    spacing: 0

    Repeater {
        model: stepper.steps
        delegate: Row {
            spacing: 0

            Column {
                spacing: Theme.spacingS
                width: 120

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: {
                        if (index < stepper.current) return Theme.success
                        if (index === stepper.current) return Theme.accent
                        return Theme.surface
                    }
                    border.color: {
                        if (index <= stepper.current) return "transparent"
                        return Theme.border
                    }
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: index < stepper.current ? "✓" : (index + 1)
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: index <= stepper.current ? "#FFFFFF" : Theme.textSecondary
                    }

                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Text {
                    width: parent.width
                    text: modelData.title
                    font.pixelSize: 13
                    font.weight: index === stepper.current ? Font.Medium : Font.Normal
                    color: index <= stepper.current ? Theme.textPrimary : Theme.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                }

                Text {
                    width: parent.width
                    text: modelData.description || ""
                    font.pixelSize: 11
                    color: Theme.textMuted
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    visible: modelData.description
                }
            }

            Rectangle {
                width: 60
                height: 2
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -20
                color: index < stepper.current ? Theme.success : Theme.surface
                visible: index < stepper.steps.length - 1

                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }
}
```
