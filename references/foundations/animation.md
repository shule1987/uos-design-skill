---
inclusion: manual
---

# 动画系统

## 动画时长
- `animFast`：`120ms`。用于悬停反馈、按钮点击、轻量状态切换等快速响应。
- `animNormal`：`200ms`。用于菜单展开、标签页切换、面板显隐等常规过渡。
- `animSlow`：`350ms`。用于对话框、抽屉、大型布局变化等更完整的进入离场动画。

## 常用动画

### 颜色过渡
- 颜色、边框色、阴影强度等轻量视觉反馈默认使用 `Theme.animFast`。
- 行悬停、卡片悬停、图标 tint、pressed/selected 的轻量状态反馈都属于这一类，不要硬切。

### 尺寸变化
- 宽度、高度或布局占比变化默认使用 `Theme.animNormal`，缓动曲线优先使用 `Easing.OutCubic`。

### 淡入淡出
- 淡入淡出建议为进入和退出两个阶段分别配置透明度过渡；进入阶段通常使用 `120ms`，退出阶段可控制在 `80ms` 到 `120ms` 之间。

### 页面切换
- 主工作区 page loader 或 page stack 的切换默认使用 `Theme.animNormal`。
- 过渡应至少包含透明度变化，并配一个轻量 `x` 或 `y` 位移；不要做无动画硬切。

## 令牌纪律
- Shell 级 `Behavior` 不要直接写裸毫秒值。优先使用 `Theme.animFast`、`Theme.animNormal`、`Theme.animSlow`。
- 如果确实需要更长的品牌或装饰性循环动画，也应先落到集中 theme token，再在业务 QML 中引用。

## 缓动函数
- `Easing.OutCubic`：平滑减速，最常用的默认曲线。
- `Easing.OutQuart`：更明显的减速，适合较强调的进入动作。
- `Easing.InOutCubic`：先加速后减速，适合需要完整节奏感的切换。
- `Easing.OutBack`：轻微回弹，仅用于少量需要强调反馈的场景。
