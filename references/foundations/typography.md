---
inclusion: manual
---

# 排版系统

## 字体家族
```qml
readonly property string fontSans: "Noto Sans SC, Source Han Sans SC, PingFang SC, Inter, sans-serif"
readonly property string fontMono: "JetBrains Mono, Fira Code, monospace"
readonly property string menuFontFamily: "Noto Sans SC, Source Han Sans SC, PingFang SC, Inter, sans-serif"
```

## 字体大小
```qml
readonly property int captionSize: 12
readonly property int menuSize: 12
readonly property int labelSize: 13
readonly property int bodySize: 14
readonly property int titleSize: 16
readonly property int headingSize: 20
```

## 字重
```qml
readonly property int fontWeightNormal: 400
readonly property int fontWeightMedium: 500
readonly property int fontWeightSemiBold: 600
```

## 使用示例
```qml
// 正文
Text {
    font.pixelSize: 14
    font.family: Theme.fontSans
    font.weight: Theme.fontWeightNormal
    color: Theme.textPrimary
}

// 标题
Text {
    font.pixelSize: 16
    font.family: Theme.fontSans
    font.weight: Theme.fontWeightSemiBold
    color: Theme.textPrimary
}

// 代码
Text {
    font.pixelSize: 13
    font.family: Theme.fontMono
    color: Theme.textPrimary
}
```
