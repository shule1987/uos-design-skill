---
inclusion: manual
---

# 表单组件

## Form

```
┌─────────────────────────────────────┐
│  用户名 *                            │
│  ┌───────────────────────────────┐  │
│  │ 请输入用户名                   │  │
│  └───────────────────────────────┘  │
│                                     │
│  邮箱 *                              │
│  ┌───────────────────────────────┐  │
│  │ 请输入邮箱                     │  │
│  └───────────────────────────────┘  │
│  ⚠ 邮箱格式不正确                   │
│                                     │
│  密码 *                              │
│  ┌───────────────────────────────┐  │
│  │ ••••••••                       │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌──────┐  ┌──────┐                │
│  │ 提交 │  │ 取消 │                │
│  └──────┘  └──────┘                │
└─────────────────────────────────────┘
```

## FormItem
```qml
component Form: Column {
    id: form
    spacing: Theme.spacingL
    width: parent.width
}
```

## FormItem
```qml
component FormItem: Column {
    id: formItem
    property string label: ""
    property bool required: false
    property string error: ""
    property alias content: contentLoader.sourceComponent

    spacing: Theme.spacingS
    width: parent.width

    Row {
        spacing: 4

        Text {
            text: formItem.label
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Theme.textPrimary
        }

        Text {
            text: "*"
            font.pixelSize: 13
            color: Theme.danger
            visible: formItem.required
        }
    }

    Loader {
        id: contentLoader
        width: parent.width
    }

    Text {
        text: formItem.error
        font.pixelSize: 12
        color: Theme.danger
        visible: formItem.error !== ""
    }
}
```

## 使用示例
```qml
Form {
    width: 400

    FormItem {
        label: "用户名"
        required: true
        error: usernameError

        content: TextField {
            width: parent.width
            placeholderText: "请输入用户名"
            onTextChanged: validateUsername(text)
        }
    }

    FormItem {
        label: "邮箱"
        required: true

        content: TextField {
            width: parent.width
            placeholderText: "请输入邮箱"
        }
    }

    FormItem {
        label: "密码"
        required: true

        content: TextField {
            width: parent.width
            placeholderText: "请输入密码"
            echoMode: TextInput.Password
        }
    }

    Row {
        spacing: Theme.spacingM

        BaseButton {
            text: "提交"
            primary: true
            onClicked: submitForm()
        }

        BaseButton {
            text: "取消"
            onClicked: resetForm()
        }
    }
}
```
