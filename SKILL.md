---
name: uos-design
description: 
---

# 设计系统完整索引

本设计系统基于 **Unote** 和 **Veyan** 项目提炼而成，提供完整的 UI/UX 设计规范。

**版本 2.0 - 已模块化**：核心组件已拆分为独立文件，详见 [README.md](README.md)

---

## 📚 模块化文档

### 基础系统（推荐优先查看）
- **[colors.md](components/colors.md)** - 颜色系统
- **[typography.md](components/typography.md)** - 排版系统
- **[spacing.md](components/spacing.md)** - 间距与圆角
- **[animation.md](components/animation.md)** - 动画系统

### UI 组件库（按需查看）
- **[button.md](components/button.md)** - 按钮组件
- **[input.md](components/input.md)** - 输入框
- **[menu.md](components/menu.md)** - 菜单
- **[dialog.md](components/dialog.md)** - 对话框
- **[card.md](components/card.md)** - 卡片
- **[sidebar.md](components/sidebar.md)** - 侧边栏
- **[switch.md](components/switch.md)** - 开关
- **[slider.md](components/slider.md)** - 滑块
- **[badge.md](components/badge.md)** - 徽章
- **[tab.md](components/tab.md)** - 标签页
- **[combobox.md](components/combobox.md)** - 下拉框
- **[tooltip.md](components/tooltip.md)** - 提示
- **[progress.md](components/progress.md)** - 进度条
- **[list.md](components/list.md)** - 列表
- **[blur.md](components/blur.md)** - 模糊效果

---

## 📚 完整文档（原始版本）

### 1. 核心基础
**design-system.md** - 设计系统基础
- ✅ 设计原则与准则
- ✅ 完整颜色系统（深浅主题）
- ✅ 排版系统（字体、字号、字重）
- ✅ 圆角规范（4 个级别）
- ✅ 间距系统（5 个级别）
- ✅ 动画时长与缓动

### 2. 视觉效果
**design-system-blur-effects.md** - 模糊与特效
- ✅ 背景模糊（GlassLayer）
- ✅ 窗口模糊（WindowBlur）
- ✅ 阴影效果
- ✅ 渐变效果
- ✅ 发光、涟漪等特殊效果
- ✅ 性能优化建议

### 3. 窗口系统
**design-system-window-behavior.md** - 窗口行为
- ✅ 主窗口与弹窗配置
- ✅ 窗口拖动与双击
- ✅ 窗口控制按钮
- ✅ 弹窗定位与边界限制
- ✅ 模态遮罩
- ✅ 响应式布局

### 4. 控件库（第一部分）
**design-system-controls-1.md** - 基础控件
- ✅ 按钮（基础、图标、文字）
- ✅ 输入框（文本、搜索）
- ✅ 菜单组件（菜单项、弹出菜单）
- ✅ 开关组件（Switch、CheckBox、RadioButton）

### 5. 控件库（第二部分）
**design-system-controls-2.md** - 高级控件
- ✅ 标签页（TabItem、TabBar）
- ✅ 滑块（Slider）
- ✅ 进度条（线性、圆形）
- ✅ 提示组件（Tooltip、Toast）
- ✅ 徽章（Badge、StatusDot）

### 6. 控件库（第三部分）
**design-system-controls-3.md** - 容器控件
- ✅ 列表（ListItem、TreeNode）
- ✅ 卡片（基础卡片、信息卡片）
- ✅ 对话框（基础、确认）
- ✅ 下拉选择（ComboBox）
- ✅ 分段控制（SegmentedControl）

### 7. 控件库（第四部分）
**design-system-controls-4.md** - 特殊控件
- ✅ 命令面板（Command Palette）
- ✅ 侧边栏（Sidebar）
- ✅ 浮动操作按钮（FAB）
- ✅ 分割面板（SplitView）
- ✅ 最佳实践
- ✅ 主题管理
- ✅ 图标系统

### 8. 补充规范
**design-system-supplements.md** - 补充内容
- ✅ 浮动工具栏
- ✅ 导航按钮
- ✅ 工具提示延迟系统
- ✅ 窗口遮罩
- ✅ 私密模式标识
- ✅ 加载指示器
- ✅ 缓动函数参考
- ✅ 颜色工具函数
- ✅ 网站主题色适配

### 9. 快速参考
**design-system-quick-reference.md** - 速查手册
- ✅ 常用颜色速查
- ✅ 常用尺寸速查
- ✅ 组件模板
- ✅ 动画模板
- ✅ 布局模式
- ✅ 性能优化清单
- ✅ 可访问性清单
- ✅ 常见问题

---

## 🎨 设计系统覆盖范围

### 颜色系统 ✅
- 背景层次（5 层）
- 表面颜色（3 态）
- 玻璃表面
- 弹窗/浮层
- 边框与分割线
- 文字颜色（4 级）
- 强调色（Unote/Veyan 双风格）
- 功能色（成功/警告/危险）
- 菜单高亮（DTK 集成）
- 标签栏颜色
- 图标颜色
- SVG 图标处理

### 排版系统 ✅
- 字体家族（无衬线/等宽/菜单）
- 字体大小（6 个级别）
- 字重（3 个级别）
- 排版示例

### 尺寸系统 ✅
- 圆角（4 个级别 + 胶囊）
- 间距（5 个级别）
- 图标尺寸（5 个级别）

### 动画系统 ✅
- 动画时长（3 个级别）
- 颜色过渡
- 透明度渐变
- 尺寸动画
- 位置动画
- 缓动函数（10+ 种）

### 视觉效果 ✅
- 背景模糊（实时/快照）
- 窗口模糊
- 阴影效果
- 线性渐变
- 径向渐变
- 发光效果
- 毛玻璃卡片
- 进度条渐变
- 涟漪效果

### 窗口行为 ✅
- 主窗口配置
- 弹窗类型
- 拖动处理
- 窗口控制按钮
- 弹窗定位
- 边界限制
- 模态遮罩
- 响应式断点

### 交互行为 ✅
- 悬停状态
- 点击反馈
- 焦点管理
- 键盘导航

### 控件库 ✅
**基础控件（8 个）**
- BaseButton, IconButton, TextButton
- TextField, SearchField
- MenuItem, PopupMenu
- Switch, CheckBox, RadioButton

**高级控件（8 个）**
- TabItem, TabBar
- Slider
- ProgressBar, CircularProgress
- Tooltip, Toast
- Badge, StatusDot

**容器控件（8 个）**
- ListItem, TreeNode
- Card, InfoCard
- Dialog, ConfirmDialog
- ComboBox
- SegmentedControl

**特殊控件（7 个）**
- CommandPalette
- Sidebar
- FloatingActionButton
- SplitView
- SelectionToolbar
- NavButton
- BusyIndicator, ProgressRing

**总计：31 个可复用组件**

---

## 🚀 快速开始

### 1. 导入主题
```qml
import "../theme"

Rectangle {
    color: Theme.bg
}
```

### 2. 使用颜色
```qml
Text {
    color: Theme.textPrimary
    font.family: Theme.fontSans
    font.pixelSize: 14
}
```

### 3. 添加动画
```qml
Rectangle {
    color: hovered ? Theme.surfaceHover : Theme.surface
    Behavior on color { ColorAnimation { duration: 80 } }
}
```

### 4. 使用组件
```qml
BaseButton {
    text: "确定"
    primary: true
    onClicked: console.log("Clicked")
}
```

---

## 📋 检查清单

### 设计完整性 ✅
- [x] 颜色系统（深浅主题）
- [x] 排版系统
- [x] 间距与圆角
- [x] 动画与过渡
- [x] 模糊与阴影
- [x] 窗口行为
- [x] 31 个控件组件
- [x] 响应式布局
- [x] 可访问性
- [x] 性能优化

### 特色功能 ✅
- [x] 毛玻璃效果
- [x] DTK 集成
- [x] 网站主题色适配（Veyan）
- [x] 工具提示延迟系统
- [x] 浮动工具栏
- [x] 私密模式标识
- [x] 颜色工具函数
- [x] 主题切换

### 文档质量 ✅
- [x] 代码示例完整
- [x] 使用场景说明
- [x] 最佳实践指南
- [x] 性能优化建议
- [x] 常见问题解答
- [x] 快速参考手册

---

## 🎯 使用建议

1. **新项目**：从 `design-system.md` 开始，建立颜色和排版基础
2. **添加控件**：参考 `design-system-controls-*.md` 复制组件模板
3. **视觉效果**：需要模糊时查看 `design-system-blur-effects.md`
4. **快速查询**：使用 `design-system-quick-reference.md` 速查
5. **特殊需求**：查看 `design-system-supplements.md` 补充内容

---

## ⚠️ 注意事项

1. **性能优先**：模糊效果默认禁用，让用户选择开启
2. **渐进增强**：基础功能稳定，视觉效果可降级
3. **一致性**：所有组件遵循统一的视觉语言
4. **可访问性**：确保对比度和键盘导航

---

## 📊 统计信息

- **文档数量**：9 个
- **总字数**：约 50,000 字
- **代码示例**：100+ 个
- **组件数量**：31 个
- **颜色定义**：40+ 个
- **动画示例**：20+ 个

---

## 版本信息

**版本**：v1.0
**日期**：2026-03-17
**基于**：Unote + Veyan 项目
**状态**：✅ 完整且可用
