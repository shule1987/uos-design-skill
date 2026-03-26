---
inclusion: manual
---

# 本机 DTK 控件映射

本参考用于消除“构建时盲猜本机 DTK 有没有某个控件、该从哪里导入、该优先用哪个”的问题。

## 已验证的本机 QML 模块路径

- 公共 DTK 控件模块：`/usr/lib/x86_64-linux-gnu/qt6/qml/org/deepin/dtk/qmldir`
- DTK 设置模块：`/usr/lib/x86_64-linux-gnu/qt6/qml/org/deepin/dtk/settings/qmldir`

## 导入方式

```qml
import org.deepin.dtk 1.0 as D
import org.deepin.dtk.settings 1.0 as Settings
```

## 已验证存在的公共控件

- 顶层窗口与窗口控件：
  - `D.ApplicationWindow`
  - `D.TitleBar`
  - `D.DialogTitleBar`
  - `D.WindowButton`
  - `D.WindowButtonGroup`
- 菜单与通知：
  - `D.Menu`
  - `D.MenuItem`
  - `D.MenuSeparator`
  - `D.ThemeMenu`
  - `D.FloatingMessage`
- 对话框：
  - `D.Dialog`
  - `D.AboutDialog`
  - `Settings.SettingsDialog`
- 输入与常用控件：
  - `D.ButtonBox`
  - `D.ButtonGroup`
  - `D.SearchEdit`
  - `D.LineEdit`
  - `D.PasswordEdit`
  - `D.ComboBox`
  - `D.Switch`
  - `D.CheckBox`
  - `D.ControlGroup`
  - `D.ControlGroupItem`
  - `D.ProgressBar`
  - `D.RecommandButton`
  - `D.WarningButton`
  - `D.ToolButton`
- 视觉与表面：
  - `D.StyledBehindWindowBlur`

## 必须优先使用的映射

### 1. 主窗口按钮

- 如果顶层窗口需要最小化、最大化 / 还原、关闭按钮，并且本机 DTK 已导出 `D.WindowButtonGroup`，默认必须直接使用 `D.WindowButtonGroup`。
- 对主窗口，`D.WindowButtonGroup` 必须与 `D.TitleBar.menu` 一起组成右上角四按钮带：菜单、最小化、最大化 / 还原、关闭。固定尺寸窗口可以省略最大化 / 还原。
- 新项目不要盲猜 header、menu 和右上角按钮怎么接；直接读取 `references/components/unified-header.md` 并按其中的主窗口范式落地。
- 不要再用一组 `D.ToolButton`、`Button` 或自绘 icon row 重做一套窗口按钮。
- 只有在 `D.WindowButtonGroup` 明确无法满足目标布局时，才允许窄范围 fallback，并且必须写 `uos-design: allow-custom-window-buttons`。

### 2. 设置对话框

- 应用级设置页 / 设置对话框默认使用 `Settings.SettingsDialog`。
- 不要为设置界面另起自定义 `Popup`、`Dialog` 容器或自绘设置窗框。

### 3. About

- About 入口默认使用 `D.AboutDialog`。

### 4. 菜单

- 主菜单内容默认使用 `D.Menu`、`D.MenuItem`、`D.MenuSeparator`。
- 主题切换默认优先复用 `D.ThemeMenu` 或在 `D.Menu` 内组织 `System / Light / Dark` 三态菜单项。
- `D.WindowButtonGroup` 不包含主菜单按钮。它只负责最小化、最大化 / 还原、关闭这一组窗口控制。
- 本机公开导出的 `D.ThemeMenu` 不是一个可直接放进 `RowLayout` / `anchors` 的按钮控件，它更接近 DTK 提供的菜单对象或主题菜单内容，而不是公开的顶层 menu-button。
- 本机公开导出的 DTK 模块里没有单独的 `MenuButton` 类型。不要因此去发明自定义 `AppButton` 或 plain `Button`。
- 主窗口一律通过 `D.TitleBar.menu` 暴露菜单按钮，不使用额外的 `D.ToolButton`、plain `Button` 或自绘按钮替代。
- `leftContent` 默认放左上角 logo 或侧栏切换按钮，`content` 只在确实需要顶部搜索、标签或工具控件时才使用；具体写法同样直接参考 `references/components/unified-header.md`。
- 不得手绘按钮背景或重做菜单触发模板。
- 不得手动写死菜单 `x` / `y`。
- 不得把“本机没有 MenuButton 导出”当成放弃 `D.TitleBar.menu` 的理由。
- 所有用于主页面切换的标签，一律放进 `D.TitleBar.content`，不要在页面内容区再复制一条二级标签工具栏。

### 4.1 应用内通知

- 应用内瞬时通知默认使用 `D.FloatingMessage`。
- 不要用自绘 `Rectangle`、自定义 `Popup`、页面内假 toast 或业务组件自行接管应用内瞬时通知。
- 页面内说明条、持久状态横幅和空态说明不算“应用内瞬时通知”；瞬时通知仍应交给 DTK。

### 5. 侧栏 blur

- 侧栏 blur 默认使用 `D.StyledBehindWindowBlur`。
- 这只是 blur primitive，不等于你可以随意写混色层。具体颜色和透明度必须回到 `references/foundations/colors.md` 和 `references/components/control-center-sidebar.md`。

### 6. 搜索输入

- 侧栏或页面顶部搜索框默认使用 `D.SearchEdit`，不要自己拼一个 `LineEdit + icon`。

### 7. 互斥按钮组

- 当两个及以上互斥过滤、模式或状态按钮需要成组出现，且本机已导出 `D.ButtonBox`、`D.ButtonGroup` 或 `D.ControlGroup` 时，默认优先使用这些 DTK 组按钮路径。
- 默认保持整组按钮在一行内完整显示；不要把互斥选项做成散装 `D.Button` / `D.ToolButton` 列表，也不要让整组自动换行成多行。
- 只有在窗口宽度、平台限制或本机控件缺陷被明确证明时，才允许偏离这一规则，并且必须写 `uos-design: allow-wrapped-mutually-exclusive-group`。

## 直接禁用的误用

- 不要因为图标要用 SVG，就把 `D.WindowButtonGroup`、`D.Menu`、`D.Dialog`、`Settings.SettingsDialog` 替换成自定义控件。
- 不要因为顶层是左右分栏，就把窗口按钮整套改写为 `ToolButton` 集合。
- 不要因为控件外观“看起来不够像设计稿”，就跳过本机 DTK 已明确存在的控件实现路径。
