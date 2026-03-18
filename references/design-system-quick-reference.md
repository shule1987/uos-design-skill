---
inclusion: manual
---

# 设计系统 - 快速参考指南

## 快速开始

- 优先使用 DTK 原生控件；以下模板主要用于无法直接复用 DTK 时的 fallback。
- 窗口化弹窗、frameless 标题栏和 blur 都需要先参考 `platform-compatibility.md`。
- 字体默认跟随系统 UI 字体和系统字号层级；不要在常规业务界面里写死字体族或固定 px 字号。

### 导入主题

> 示例描述：这里说明先导入 `QtQuick` 和 `"../theme"`，再在 `Item` 等节点里使用 `Theme.bg`、`Theme.fontSans`、`Theme.bodySize` 和 `Theme.textPrimary` 这些主题 token；其中 `Theme.fontSans` 和 `Theme.bodySize` 应绑定到系统字体与系统字号层级，而不是写死具体数值。

---

## 常用颜色速查

### 背景色
> 示例描述：这里按速查形式说明“背景色”中的主题 token。Theme.bg 用于主窗口背景；Theme.bgPanel 用于侧边栏或附属面板背景；Theme.bgToolbar 用于自绘标题栏与工具栏合一场景的背景；Theme.surface 用于控件表面；Theme.surfaceHover 用于通用悬停态；Theme.surfaceActive 用于激活或选中态；Theme.popupBg 用于菜单等轻量弹出层背景；Theme.panelBg 用于对话框和浮层面板背景；Theme.cardBg 用于卡片背景。

### 文字色
> 示例描述：这里按速查形式说明“文字色”中的主题 token，Theme.textPrimary 用于普通正文 / 默认图标文字；Theme.textStrong 用于标题 / 悬停强调；Theme.textSecondary 用于次要文字；Theme.textMuted 用于弱化文字；Theme.textDisabled 用于禁用文字。

### 强调色
> 示例描述：这里按速查形式说明“强调色”中的主题 token，Theme.systemAccent 用于系统活动色源；Theme.accentForeground 用于激活态前景（文字 / 图标 / 链接）；Theme.accentBackground 用于激活态背景（主按钮 / 选中填充）；Theme.accent 用于兼容别名，等于 accentBackground；Theme.success 用于成功；Theme.warning 用于警告；Theme.danger 用于危险/错误。

### 边框色
> 示例描述：这里按速查形式说明“边框色”中的主题 token，Theme.border 用于常规边框；Theme.borderStrong 用于强调边框；Theme.divider 用于分割线。

---

## 常用尺寸速查

### 圆角
> 示例描述：这里按速查形式说明“圆角”中的主题 token，Theme.radiusSm 表示小圆角，建议值为 `6`；Theme.radiusMd 表示中圆角，建议值为 `12`；Theme.radiusLg 表示大圆角，建议值为 `18`；Theme.radiusXl 用于超大圆角场景，需要按容器尺寸单独评估；Theme.radiusPill 表示胶囊形或全圆角，建议值为 `50%`。

### 间距
> 示例描述：这里按速查形式说明“间距”中的主题 token，Theme.spacingXS 表示超小间距，建议值为 `4`；Theme.spacingS 表示小间距，建议值为 `6`；Theme.spacingM 表示中间距，建议值为 `10`；Theme.spacingL 表示大间距，建议值为 `20`；Theme.spacingXL 表示超大间距，建议值为 `30`。

### 动画时长
> 示例描述：这里按速查形式说明“动画时长”中的主题 token，Theme.animFast 表示快速 (悬停、点击)，建议值为 `120`；Theme.animNormal 表示常规 (展开、切换)，建议值为 `200`；Theme.animSlow 表示慢速 (大型动画)，建议值为 `350`。

---

## 常用组件模板

### 按钮
> 示例描述：这里给出“按钮”的实现思路。优先使用 DTK 按钮；若需要自定义 fallback，则以轻量容器承载文字或图文内容，宽度跟随内容决定并保留足够点击热区，高度与同层级表单控件保持一致，圆角使用 `Theme.radiusSm`。主按钮使用 `Theme.accentBackground`，次要按钮使用 `Theme.surface` 或透明背景；交互上覆盖悬停、按下、焦点、键盘激活和无障碍语义。

### 输入框
> 示例描述：这里给出“输入框”的实现思路。整体以 `Rectangle` 作为根节点，内部主要组织 `TextInput` 等内容。 关键尺寸上宽度为 `200`，高度为 `36`，圆角为 `Theme.radiusSm`。

### 列表项
> 示例描述：这里给出“列表项”的实现思路。整体以 `Rectangle` 作为根节点，内部主要组织 `Text` 等内容。 关键尺寸上宽度为 `parent.width`，高度为 `44`；行为上覆盖过渡动画、无障碍语义。

### 卡片
> 示例描述：这里给出“卡片”的实现思路。整体以 `Rectangle` 作为根节点。 关键尺寸上宽度为 `280`，高度为 `200`，圆角为 `Theme.radiusMd`。

---

## 动画模板

### 颜色过渡
> 示例描述：这里说明 `color` 变化时需要补上过渡动画，时长使用 `Theme.animFast`。

### 尺寸变化
> 示例描述：这里说明 `width` 变化时需要补上过渡动画，时长使用 `Theme.animNormal`，缓动曲线使用 `Easing.OutCubic`。

### 淡入淡出
> 示例描述：这里说明“淡入淡出”需要为进入和退出两个阶段分别配置透明度过渡，进入阶段优先使用 `Theme.animFast` 或接近的短时长，退出阶段可以略短于进入阶段。

### 缩放动画
> 示例描述：这里说明 `scale` 变化时需要补上过渡动画，时长使用 `120`，缓动曲线使用 `Easing.OutBack`。

---

## 布局模式

### 水平布局
> 示例描述：这里给出“水平布局”的实现思路。整体以 `Row` 作为根节点，内部主要组织 `AppIcon` 和 `Text` 等内容。 关键尺寸上间距为 `Theme.spacingM`。

### 垂直布局
> 示例描述：这里给出“垂直布局”的实现思路。整体以 `Column` 作为根节点，内部主要组织 `Text` 等内容。 关键尺寸上间距为 `Theme.spacingS`，宽度为 `parent.width`。

### 网格布局
> 示例描述：这里给出“网格布局”的实现思路。整体以 `Grid` 作为根节点，内部主要组织 `Repeater` 等内容。 关键尺寸上间距为 `Theme.spacingL`；行为上覆盖重复项生成。

---

## 响应式设计

### 断点定义
> 示例描述：这里给出“断点定义”的实现思路。整体以 `QtObject` 作为根节点。

### 自适应布局
> 示例描述：这里给出“自适应布局”的实现思路。整体以 `Item` 作为根节点。 关键尺寸上宽度为 `breakpoints.isCompact ? 60 : 240`；行为上覆盖过渡动画。

---

## 性能优化清单

### ✅ 推荐做法
- 使用 `Behavior` 而非手动 `Animation`
- 限制 `clip: true` 的使用
- 使用 `Loader` 延迟加载重型组件
- 避免深层嵌套的绑定
- 使用 `readonly property` 优化只读属性

### ❌ 避免做法
- 不要在循环中创建大量对象
- 避免频繁的 `grabToImage` 调用
- 不要过度使用模糊效果
- 避免复杂的 JavaScript 表达式绑定

---

## 可访问性清单

### 键盘导航
> 示例描述：这里给出“键盘导航”的实现思路。整体以 `Item` 作为根节点。

### 对比度要求
- 正文文字：至少 4.5:1
- 大号文字：至少 3:1
- 图标和控件：至少 3:1

### 焦点指示
> 示例描述：这里给出“焦点指示”的实现思路。整体以 `Rectangle` 作为根节点。

---

## 调试技巧

### 显示边界
> 示例描述：这里给出“显示边界”的实现思路。整体以 `Rectangle` 作为根节点。

### 性能计时
> 示例描述：这里表示在组件初始化完成后执行一次逻辑，通常用于恢复状态、记录时间点或启动后续流程。

### 属性监控
> 示例描述：这里给出一个宽度变化监听示例，用于在布局调试时输出当前尺寸。

---

## 设计决策流程

### 选择颜色
1. 背景层 → `Theme.bg` / `Theme.bgPanel`
2. 控件表面 → `Theme.surface`
3. 交互状态 → `Theme.surfaceHover` / `Theme.surfaceActive`
4. 系统活动色源 → `Theme.systemAccent`
5. 激活前景 → `Theme.accentForeground`
6. 激活背景 → `Theme.accentBackground`
7. 功能色 → `Theme.success` / `Theme.warning` / `Theme.danger`

### 选择圆角
- 小控件（按钮、输入框）→ `radiusSm` (6px)
- 中型容器（卡片、面板）→ `radiusMd` (12px)
- 大型容器（对话框、浮层）→ `radiusLg` (18px)
- 胶囊按钮、标签、状态点 → `radiusPill` (50%)

### 选择间距
- 紧密元素 → `spacingXS` (4px)
- 相关元素 → `spacingS` (6px)
- 常规间距 → `spacingM` (10px)
- 区块间距 → `spacingL` (20px)
- 页面边距 → `spacingXL` (30px)

### 选择动画
- 即时反馈（悬停）→ 80-120ms
- 状态切换 → 200ms
- 布局变化 → 350ms

---

## 常见问题

### Q: 如何实现毛玻璃效果？
> 示例描述：这里给出“Q: 如何实现毛玻璃效果？”的实现思路。整体以 `GlassLayer` 作为根节点。 关键尺寸上圆角为 `Theme.radiusMd`。

### Q: 如何实现深浅主题切换？
> 示例描述：这里说明“Q: 如何实现深浅主题切换？”相关的主题属性，主要包括 `dark`。 这些定义都考虑了浅色与深色模式之间的切换。

### Q: 如何优化列表性能？
> 示例描述：这里给出“Q: 如何优化列表性能？”的实现思路。整体以 `ListView` 作为根节点。 行为上覆盖列表承载。

### Q: 如何实现拖动排序？
> 示例描述：这里给出“Q: 如何实现拖动排序？”的实现思路。整体以 `DragHandler` 作为根节点。 行为上覆盖窗口拖动。

---

## 资源链接

### 相关文档
- `references/foundations/colors.md` - 颜色与主题变量
- `references/foundations/typography.md` - 字体、字号、字重
- `references/foundations/radius.md` - 圆角规范
- `references/foundations/spacing.md` - 间距规范
- `references/foundations/animation.md` - 动画时长与缓动
- `references/design-system-window-behavior.md` - 窗口行为规范
- `references/design-system-layout.md` - 布局模式与响应式规范
- `references/components/` - 各组件的独立参考文档

### 示例项目
- Unote - 笔记应用设计参考
- Veyan - 浏览器界面设计参考

---

## 版本历史

**v1.0** - 2026-03-17
- 基于 Unote 和 Veyan 项目整理
- 完整的颜色系统
- 排版和间距规范
- 圆角和动画系统
- 模糊效果实现
- 窗口行为规范
- 完整的控件库
- 最佳实践指南
