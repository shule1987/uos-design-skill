---
inclusion: always
---

# 卡片组件

## Card

```
┌──────────────────────┐
│                      │
│    [缩略图区域]       │
│     (200x160)        │
│                      │
├──────────────────────┤
│  卡片标题             │
│                      │
│  这里是卡片的描述     │
│  文本内容...          │
│                      │
└──────────────────────┘
   (280x320, 带阴影)
```

```qml
component Card: Rectangle {
    id: card
    property string title: ""
    property string description: ""
    property string thumbnail: ""

    width: 280
    height: 320
    radius: Theme.radiusMd
    color: Theme.cardBg
    border.color: Theme.border
    border.width: 1

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Theme.dark ? Qt.rgba(0,0,0,0.3) : Qt.rgba(0,0,0,0.1)
        shadowBlur: 0.3
        shadowVerticalOffset: 2
    }

    Column {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            width: parent.width
            height: 180
            radius: Theme.radiusMd
            color: Theme.cardThumbBg
            clip: true

            Image {
                anchors.fill: parent
                source: card.thumbnail
                fillMode: Image.PreserveAspectCrop
                visible: card.thumbnail !== ""
            }
        }

        Column {
            width: parent.width
            padding: Theme.spacingL
            spacing: Theme.spacingS

            Text {
                width: parent.width - parent.padding * 2
                text: card.title
                font.pixelSize: 15
                font.weight: Font.Medium
                color: Theme.textPrimary
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }

            Text {
                width: parent.width - parent.padding * 2
                text: card.description
                font.pixelSize: 13
                color: Theme.textSecondary
                elide: Text.ElideRight
                maximumLineCount: 3
                wrapMode: Text.Wrap
            }
        }
    }

    property bool hovered: false
    HoverHandler { onHoveredChanged: card.hovered = hovered }
    scale: hovered ? 1.02 : 1.0
    Behavior on scale { NumberAnimation { duration: 120 } }
}
```
