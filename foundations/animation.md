---
inclusion: always
---

# 动画系统

## 动画时长
```qml
readonly property int animFast: 120
readonly property int animNormal: 200
readonly property int animSlow: 350
```

## 常用动画

### 颜色过渡
```qml
Behavior on color {
    ColorAnimation { duration: Theme.animFast }
}
```

### 尺寸变化
```qml
Behavior on width {
    NumberAnimation {
        duration: Theme.animNormal
        easing.type: Easing.OutCubic
    }
}
```

### 淡入淡出
```qml
enter: Transition {
    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 120 }
}
exit: Transition {
    NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 80 }
}
```

## 缓动函数
```qml
easing.type: Easing.OutCubic     // 平滑减速（最常用）
easing.type: Easing.OutQuart     // 强烈减速
easing.type: Easing.InOutCubic   // 先加速后减速
easing.type: Easing.OutBack      // 回弹效果
```
