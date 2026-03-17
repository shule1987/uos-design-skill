---
inclusion: always
---

# 头像组件

## Avatar
```qml
component Avatar: Rectangle {
    id: avatar
    property string src: ""
    property string text: ""
    property int size: 40

    width: size
    height: size
    radius: size / 2
    color: Theme.surface

    Image {
        anchors.fill: parent
        source: avatar.src
        fillMode: Image.PreserveAspectCrop
        visible: avatar.src !== ""
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: avatar.width
                height: avatar.height
                radius: avatar.radius
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: avatar.text
        font.pixelSize: avatar.size * 0.4
        font.weight: Font.Medium
        color: Theme.textPrimary
        visible: avatar.src === "" && avatar.text !== ""
    }
}

component AvatarGroup: Row {
    property var avatars: []
    property int size: 40
    property int max: 5

    spacing: -size * 0.3

    Repeater {
        model: Math.min(avatars.length, max)
        Avatar {
            src: avatars[index].src || ""
            text: avatars[index].text || ""
            size: parent.size
            z: max - index
        }
    }

    Avatar {
        text: "+" + (avatars.length - max)
        size: parent.size
        visible: avatars.length > max
    }
}
```
