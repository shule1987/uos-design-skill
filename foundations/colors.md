---
inclusion: always
---

# 颜色系统

## 主题模式
```qml
readonly property bool dark: mode === "dark" ||
    (mode === "system" && Qt.styleHints.colorScheme === Qt.ColorScheme.Dark)
```

## 背景色

### Unote 风格
```qml
readonly property color bg: dark ? "#141414" : "#F5F5F7"
readonly property color bgPanel: dark ? "#1C1C1E" : "#FFFFFF"
readonly property color bgToolbar: dark ? "#1C1C1E" : "#FFFFFF"
readonly property color cardBg: dark ? Qt.rgba(0.16, 0.16, 0.16, 0.96) : Qt.rgba(1, 1, 1, 0.995)
```

### Veyan 风格
```qml
readonly property color bg0: dark ? "#0d0d0f" : "#f0f0f5"
readonly property color bg1: dark ? "#13131a" : "#e4e4ec"
readonly property color bg2: dark ? "#1a1a24" : "#dcdce8"
readonly property color bg3: dark ? "#22222e" : "#d0d0de"
readonly property color blurTint: dark ? Qt.rgba(0.07, 0.07, 0.10, 0.60) : Qt.rgba(0.92, 0.92, 0.96, 0.60)
```

## 表面色
```qml
readonly property color surface: dark ? Qt.rgba(1,1,1,0.06) : Qt.rgba(0,0,0,0.06)
readonly property color surfaceHover: dark ? Qt.rgba(1,1,1,0.10) : Qt.rgba(0,0,0,0.08)
readonly property color surfaceActive: dark ? Qt.rgba(1,1,1,0.14) : Qt.rgba(0,0,0,0.10)
readonly property color glass: dark ? Qt.rgba(1,1,1,0.06) : Qt.rgba(0,0,0,0.04)
readonly property color glassBorder: dark ? Qt.rgba(1,1,1,0.12) : Qt.rgba(0,0,0,0.10)
readonly property color glassHover: dark ? Qt.rgba(1,1,1,0.10) : Qt.rgba(0,0,0,0.07)
```

## 弹窗色
```qml
readonly property color popupBg: dark ? Qt.rgba(20/255, 20/255, 20/255, 0.82) : Qt.rgba(238/255, 238/255, 238/255, 0.82)
readonly property color panelBg: dark ? Qt.rgba(0.094, 0.094, 0.094, 0.80) : Qt.rgba(0.933, 0.933, 0.933, 0.80)
readonly property color scrim: dark ? Qt.rgba(0, 0, 0, 0.30) : Qt.rgba(0, 0, 0, 0.16)
```

## 边框色
```qml
readonly property color border: dark ? Qt.rgba(1,1,1,0.08) : Qt.rgba(0,0,0,0.08)
readonly property color borderStrong: dark ? Qt.rgba(1,1,1,0.14) : Qt.rgba(0,0,0,0.14)
readonly property color divider: dark ? Qt.rgba(1,1,1,0.08) : Qt.rgba(0,0,0,0.08)
```

## 文字色
```qml
readonly property color textPrimary: dark ? "#FFFFFF" : Qt.rgba(0, 0, 0, 1.0)
readonly property color textSecondary: dark ? Qt.rgba(1,1,1,0.7) : Qt.rgba(0, 0, 0, 0.70)
readonly property color textMuted: dark ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0, 0, 0, 0.70)
readonly property color textDisabled: dark ? Qt.rgba(1,1,1,0.25) : Qt.rgba(0,0,0,0.25)
readonly property color placeholder: dark ? "#5a5a72" : "#9090a8"
```

## 强调色
```qml
// Unote
readonly property color accent: "#0081FF"
readonly property color accentLight: "#4DABFF"
readonly property color accentDark: "#0062CC"

// Veyan
readonly property color accent: "#2563eb"
readonly property color accentDim: "#1d4ed8"
readonly property color accentGlow: Qt.rgba(0.14, 0.39, 0.92, 0.35)
```

## 功能色
```qml
readonly property color success: dark ? "#00C853" : "#4caf7d"
readonly property color warning: dark ? "#FF9800" : "#f0a050"
readonly property color danger: dark ? "#F44336" : "#e05555"
```

## 图标色
```qml
readonly property color iconNormal: dark ? Qt.rgba(1,1,1,0.70) : Qt.rgba(0,0,0,0.80)
readonly property color iconHover: dark ? "#f0f0f5" : "#333333"
```

## 颜色工具函数
```qml
function withAlpha(color, alpha) {
    return Qt.rgba(color.r, color.g, color.b, alpha)
}

function mix(colorA, colorB, amount) {
    const t = Math.max(0, Math.min(1, Number(amount)))
    return Qt.rgba(
        colorA.r + (colorB.r - colorA.r) * t,
        colorA.g + (colorB.g - colorA.g) * t,
        colorA.b + (colorB.b - colorA.b) * t,
        colorA.a + (colorB.a - colorA.a) * t
    )
}

function luminance(color) {
    function linearChannel(value) {
        const v = Math.max(0, Math.min(1, Number(value)))
        return v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4)
    }
    return 0.2126 * linearChannel(color.r)
         + 0.7152 * linearChannel(color.g)
         + 0.0722 * linearChannel(color.b)
}

function contrastRatio(colorA, colorB) {
    const l1 = luminance(colorA)
    const l2 = luminance(colorB)
    const lighter = Math.max(l1, l2)
    const darker = Math.min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)
}
```
