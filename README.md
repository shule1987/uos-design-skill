---
inclusion: always
---

# 设计系统总览（模块化版本）

本设计系统已模块化，所有组件和基础规范已拆分为独立文件，便于查找和维护。

## 📚 快速导航

### 基础系统（设计令牌）
- [颜色系统](foundations/colors.md) - 40+ 颜色定义，深浅主题
- [排版系统](foundations/typography.md) - 字体、字号、字重
- [间距与圆角](foundations/spacing.md) - 5 级间距，4 级圆角
- [动画系统](foundations/animation.md) - 时长、缓动函数

### UI 组件
- [按钮](components/button.md) - BaseButton, IconButton, NavButton
- [输入框](components/input.md) - TextField, SearchField
- [菜单](components/menu.md) - MenuItem, PopupMenu
- [对话框](components/dialog.md) - Dialog, ConfirmDialog
- [卡片](components/card.md) - Card, InfoCard
- [侧边栏](components/sidebar.md) - Sidebar
- [开关](components/switch.md) - Switch, CheckBox, RadioButton
- [滑块](components/slider.md) - Slider
- [徽章](components/badge.md) - Badge, StatusDot
- [标签页](components/tab.md) - TabItem, TabBar
- [下拉框](components/combobox.md) - ComboBox
- [提示](components/tooltip.md) - Tooltip, Toast
- [进度条](components/progress.md) - ProgressBar, CircularProgress
- [列表](components/list.md) - ListItem, TreeNode
- [模糊效果](components/blur.md) - GlassLayer, WindowBlur
- [表格](components/table.md) - Table
- [分页](components/pagination.md) - Pagination
- [骨架屏](components/skeleton.md) - Skeleton, SkeletonGroup
- [抽屉](components/drawer.md) - Drawer
- [空状态](components/empty.md) - Empty
- [头像](components/avatar.md) - Avatar, AvatarGroup
- [警告](components/alert.md) - Alert
- [通知](components/notification.md) - Notification
- [表单](components/form.md) - Form, FormItem
- [面包屑](components/breadcrumb.md) - Breadcrumb
- [步骤条](components/stepper.md) - Stepper

### 规范与指南
- [设计规则](design-rules.md) - DTK 优先、窗口规范、毛玻璃效果、无障碍
- [窗口布局](design-system-layout.md) - 布局模式、响应式
- [窗口行为](design-system-window-behavior.md) - 拖动、控制按钮
- [补充规范](design-system-supplements.md) - 工具栏、颜色函数
- [快速参考](design-system-quick-reference.md) - 速查手册

## 🎯 使用方式

### 查找颜色
```qml
// 查看 foundations/colors.md
color: Theme.textPrimary
```

### 查找组件
```qml
// 查看 components/button.md
BaseButton {
    text: "确定"
    primary: true
}
```

### 查找布局
```qml
// 查看 design-system-layout.md
// 侧边栏布局、三栏布局等
```

## 📊 统计
- 基础文件：4 个
- 组件文件：26 个
- 总组件数：46 个
- 总颜色数：40+
