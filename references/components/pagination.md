---
inclusion: manual
---

# 分页组件

## Pagination

```
← [1] [2] [3] ... [10] →
  当前页  普通页  省略  末页

示例：
← 1  2  3  4  5 ... 20 →  (第1页)
← 1 ... 5  6  7 ... 20 →  (第6页)
← 1 ... 18 19 20 →        (第20页)
```

```qml
component Pagination: Row {
    id: pagination
    property int total: 0
    property int pageSize: 10
    property int current: 1
    signal pageChanged(int page)

    spacing: Theme.spacingS

    readonly property int totalPages: Math.ceil(total / pageSize)

    IconButton {
        iconName: "chevron-left"
        enabled: pagination.current > 1
        onClicked: {
            pagination.current--
            pagination.pageChanged(pagination.current)
        }
    }

    Repeater {
        model: {
            const pages = []
            const total = pagination.totalPages
            const current = pagination.current

            if (total <= 7) {
                for (let i = 1; i <= total; i++) pages.push(i)
            } else {
                pages.push(1)
                if (current > 3) pages.push("...")

                const start = Math.max(2, current - 1)
                const end = Math.min(total - 1, current + 1)
                for (let i = start; i <= end; i++) pages.push(i)

                if (current < total - 2) pages.push("...")
                pages.push(total)
            }
            return pages
        }

        delegate: Rectangle {
            id: pageButton
            width: modelData === "..." ? 32 : 32
            height: 32
            radius: Theme.radiusSm
            activeFocusOnTab: modelData !== "..."
            color: {
                if (modelData === pagination.current) return Theme.accentBackground
                if (hovered && modelData !== "...") return Theme.surfaceHover
                return "transparent"
            }

            property bool hovered: false
            Accessible.name: modelData === "..."
                ? qsTr("省略页码")
                : qsTr("第 %1 页").arg(modelData)

            Text {
                anchors.centerIn: parent
                text: modelData
                font.pixelSize: 13
                color: modelData === pagination.current ? Theme.onAccent : Theme.textPrimary
            }

            HoverHandler {
                enabled: modelData !== "..."
                onHoveredChanged: pageButton.hovered = hovered
            }

            TapHandler {
                enabled: modelData !== "..." && modelData !== pagination.current
                onTapped: {
                    pagination.current = modelData
                    pagination.pageChanged(modelData)
                }
            }
            Keys.onReturnPressed: {
                if (modelData === "..." || modelData === pagination.current)
                    return
                pagination.current = modelData
                pagination.pageChanged(modelData)
            }
            Keys.onSpacePressed: {
                if (modelData === "..." || modelData === pagination.current)
                    return
                pagination.current = modelData
                pagination.pageChanged(modelData)
            }

            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }
    }

    IconButton {
        iconName: "chevron-right"
        enabled: pagination.current < pagination.totalPages
        onClicked: {
            pagination.current++
            pagination.pageChanged(pagination.current)
        }
    }
}
```
