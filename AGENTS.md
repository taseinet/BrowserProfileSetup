# 仓库指南

## 项目级文档约束

本仓库的 Markdown 文档（`*.md`）默认必须使用简体中文编写，包括 README、贡献指南、设计说明、计划、变更记录及 AI 生成的辅助文档。日文本地化文档是唯一例外，必须使用 `*.ja.md` 命名，并与对应的中文文档保持结构、命令和功能说明同步。代码、命令、文件路径、API 名称和无法准确翻译的技术术语可保留原文。新增或修改 Markdown 文件时，提交前必须检查正文语言；引用外部原文时，应优先提供中文概述。

## 项目结构

本项目是一个 Windows 小型工具，用于创建相互独立的 Edge 或 Chrome 浏览器配置和桌面快捷方式。

- `BrowserProfileSetup.ps1`：负责浏览器检测、输入验证、配置目录和 `.lnk` 快捷方式创建。
- `Start.bat`：设置 UTF-8 代码页并启动 PowerShell 主脚本。
- `locales/zh-CN.psd1`、`locales/ja-JP.psd1`：分别保存简体中文和日文界面文本。
- `assets/`：保存 README 使用的项目图片等静态资源。

生成内容位于 `Documents\EdgeProfiles`、`Documents\ChromeProfiles` 和桌面，不应写入仓库。新增业务逻辑应放在 PowerShell 脚本中，批处理文件仅作为轻量启动入口。

## 运行与验证命令

项目无需构建，也没有外部依赖。在 Windows PowerShell 中运行：

```powershell
.\Start.bat
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\BrowserProfileSetup.ps1
```

手动验证应覆盖浏览器选择、空账户名、非法文件名字符，以及已有快捷方式的保留和覆盖流程。

## 编码与命名规范

沿用现有样式：使用 4 个空格缩进，函数采用 `Verb-Noun`，变量采用 `PascalCase`。面向用户的提示文字必须从 `locales` 语言资源读取，中文和日文资源键应保持一致。路径使用 `Join-Path` 组合，存在性使用 `Test-Path` 检查；浏览器特有配置集中放在选择分支中。

## 测试要求

目前没有自动化测试或覆盖率要求。修改后必须进行 PowerShell 语法检查，并在测试账户下手动验证 Edge 和 Chrome。新增测试时使用 Pester，放在 `tests/*.Tests.ps1`，并模拟文件写入和 COM 操作。

## 提交与拉取请求

Git 提交信息必须使用日语多行格式：首行为 `type: 概要`，后续使用 `- ` 描述具体变更。`type` 可使用 `feat`、`fix`、`chore`、`docs`、`refactor` 或 `test`。

```text
docs: <使用日语填写提交概要>
- <使用日语填写具体变更>
- <使用日语填写具体变更>
```

拉取请求应说明修改原因、影响的浏览器、已执行的验证和生成目录影响。控制台显示发生变化时，应附截图。

## 安全与配置

不得使用真实浏览器配置进行测试。将用户输入加入可执行参数前必须验证。禁止提交认证信息、浏览器配置数据和生成的 `.lnk` 文件。
