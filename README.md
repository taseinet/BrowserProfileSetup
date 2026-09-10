# Browser Profile Setup

简体中文 | [日本語](./README.ja.md)

这是一个 Windows 工具，用于为 Microsoft Edge 或 Google Chrome 创建相互独立的浏览器配置，并生成对应的桌面快捷方式。

它适合管理多个店铺、工作账户或测试环境。每个环境分别保存 Cookie、登录状态和浏览器设置，互不影响。

## 主要功能

- 支持 Microsoft Edge 和 Google Chrome
- 自动检测已安装的浏览器
- 根据 Windows 用户首选语言设置默认的中文或日文
- 启动时可手动选择界面语言
- 为每个账户创建独立的用户数据目录
- 自动生成专用桌面快捷方式
- 覆盖同名快捷方式前进行确认
- 支持连续创建多个账户环境

## 运行环境

- Windows 10 或 Windows 11
- Windows PowerShell 5.1 或更高版本
- Microsoft Edge 或 Google Chrome

本项目无需安装额外依赖，也不需要构建。

## 使用方法

1. 双击 `Start.bat`。
2. 程序先使用系统默认语言显示选择菜单；直接按 Enter 使用默认语言，或输入 `1`、`2` 手动选择中文、日文。
3. 选择需要使用的浏览器。
4. 输入账户名称，例如 `店铺A`。
5. 根据提示选择是否立即启动新环境。
6. 后续直接使用桌面生成的快捷方式。

也可以通过 PowerShell 直接运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\BrowserProfileSetup.ps1
```

程序读取 Windows 用户语言列表中的第一项；日语默认使用日文，其他语言默认使用中文。也可以通过参数固定界面语言并跳过启动选择：

```powershell
.\BrowserProfileSetup.ps1 -Language zh-CN
.\BrowserProfileSetup.ps1 -Language ja-JP
```

## 生成位置

浏览器配置会根据所选浏览器保存在：

```text
Documents\EdgeProfiles\<账户名称>
Documents\ChromeProfiles\<账户名称>
```

桌面快捷方式采用以下命名格式：

```text
<账户名称> - Edge.lnk
<账户名称> - Chrome.lnk
```

账户名称中不能用于 Windows 文件名的字符会自动替换为 `_`。

## 注意事项

- 配置目录可能包含 Cookie、登录信息和浏览设置，请勿共享或提交到公开仓库。
- 删除配置目录会同时删除该环境中保存的浏览器数据。
- 仅删除桌面快捷方式不会删除 `Documents` 中的配置数据。
- 公司或组织管理的设备可能通过安全策略限制 PowerShell 或浏览器启动参数。

## 文件结构

```text
BrowserProfileSetup.ps1  # 主脚本
Start.bat                # 双击启动入口
locales\zh-CN.psd1       # 简体中文界面文本
locales\ja-JP.psd1       # 日文界面文本
AGENTS.md                # 贡献者与代理协作指南
README.md                # 项目说明
README.ja.md             # 日文项目说明
```

## 开发验证

修改后应检查 PowerShell 语法，并使用测试账户分别验证 Edge 和 Chrome。详细规范请参阅 [`AGENTS.md`](./AGENTS.md)。
