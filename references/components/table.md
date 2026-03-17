---
inclusion: manual
---

# 表格组件

## Table

```
┌─────────┬──────────┬──────────┬─────────┐
│ 姓名    │ 年龄     │ 邮箱     │ 操作    │
├─────────┼──────────┼──────────┼─────────┤
│ 张三    │ 25       │ zhang@   │ [编辑]  │
├─────────┼──────────┼──────────┼─────────┤
│ 李四    │ 30       │ li@      │ [编辑]  │
├─────────┼──────────┼──────────┼─────────┤
│ 王五    │ 28       │ wang@    │ [编辑]  │
└─────────┴──────────┴──────────┴─────────┘
```

```qml
component Table: Item {
    id: table
    property var columns: []  // [{title, width, key}]
    property var dataSource: []

    Column {
        anchors.fill: parent
        spacing: 0

        // 表头
        Rectangle {
            width: parent.width
            height: 40
            color: Theme.surface

            Row {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: table.columns
                    delegate: Rectangle {
                        width: modelData.width || (table.width / table.columns.length)
                        height: 40
                        color: "transparent"

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: Theme.spacingM
                                verticalCenter: parent.verticalCenter
                            }
                            text: modelData.title
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Theme.textPrimary
                        }

                        Rectangle {
                            anchors.right: parent.right
                            width: 1
                            height: parent.height
                            color: Theme.divider
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Theme.divider
            }
        }

        // 表格内容
        ListView {
            width: parent.width
            height: parent.height - 40
            clip: true
            model: table.dataSource

            delegate: Rectangle {
                width: table.width
                height: 48
                color: hovered ? Theme.surfaceHover : "transparent"

                property bool hovered: false

                Row {
                    anchors.fill: parent
                    spacing: 0

                    Repeater {
                        model: table.columns
                        delegate: Rectangle {
                            width: modelData.width || (table.width / table.columns.length)
                            height: 48
                            color: "transparent"

                            Text {
                                anchors {
                                    left: parent.left
                                    leftMargin: Theme.spacingM
                                    verticalCenter: parent.verticalCenter
                                }
                                text: table.dataSource[index][modelData.key] || ""
                                font.pixelSize: 13
                                color: Theme.textPrimary
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Theme.divider
                }

                HoverHandler { onHoveredChanged: parent.hovered = hovered }
            }
        }
    }
}
```
