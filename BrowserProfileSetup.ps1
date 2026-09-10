# ============================================
# 多账号浏览器环境一键创建工具
# 支持 Microsoft Edge / Google Chrome
# ============================================

$Host.UI.RawUI.WindowTitle = "多账号浏览器环境创建工具"

Clear-Host

function Show-Header {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "      多账号浏览器环境创建工具" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
}

Show-Header

# ------------------------------------------------
# 获取系统目录
# ------------------------------------------------

$DesktopPath   = [Environment]::GetFolderPath("Desktop")
$DocumentsPath = [Environment]::GetFolderPath("MyDocuments")

# ------------------------------------------------
# 选择浏览器
# ------------------------------------------------

while ($true) {

    Write-Host "请选择浏览器：" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. Microsoft Edge"
    Write-Host "  2. Google Chrome"
    Write-Host ""

    $BrowserChoice = Read-Host "请输入 1 或 2"

    if ($BrowserChoice -eq "1") {

        $BrowserName = "Microsoft Edge"
        $BrowserShortName = "Edge"
        $ProfileRootName = "EdgeProfiles"

        $BrowserPaths = @(
            "$env:ProgramFiles(x86)\Microsoft\Edge\Application\msedge.exe",
            "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
            "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe"
        )

        break
    }
    elseif ($BrowserChoice -eq "2") {

        $BrowserName = "Google Chrome"
        $BrowserShortName = "Chrome"
        $ProfileRootName = "ChromeProfiles"

        $BrowserPaths = @(
            "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
            "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe",
            "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
        )

        break
    }
    else {

        Write-Host ""
        Write-Host "输入错误，请输入 1 或 2。" -ForegroundColor Yellow
        Write-Host ""
    }
}

# ------------------------------------------------
# 自动查找浏览器
# ------------------------------------------------

$BrowserPath = $null

foreach ($Path in $BrowserPaths) {

    if (Test-Path $Path) {
        $BrowserPath = $Path
        break
    }
}

if (-not $BrowserPath) {

    Write-Host ""
    Write-Host "错误：没有找到 $BrowserName。" -ForegroundColor Red
    Write-Host ""
    Write-Host "请确认电脑上已经安装 $BrowserName。"
    Write-Host ""

    Read-Host "按 Enter 键退出"
    exit
}

Write-Host ""
Write-Host "✓ 已找到 $BrowserName" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------
# 创建浏览器数据总目录
# ------------------------------------------------

$BaseProfilePath = Join-Path $DocumentsPath $ProfileRootName

if (-not (Test-Path $BaseProfilePath)) {

    New-Item `
        -ItemType Directory `
        -Path $BaseProfilePath `
        -Force | Out-Null
}

# ------------------------------------------------
# 创建账号
# ------------------------------------------------

while ($true) {

    Write-Host "------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    $AccountName = Read-Host "请输入账号名称，例如：店铺A"

    $AccountName = $AccountName.Trim()

    if ([string]::IsNullOrWhiteSpace($AccountName)) {

        Write-Host ""
        Write-Host "账号名称不能为空，请重新输入。" -ForegroundColor Yellow
        Write-Host ""

        continue
    }

    # ------------------------------------------------
    # 清理 Windows 文件名非法字符
    # ------------------------------------------------

    $SafeName = $AccountName

    foreach ($InvalidChar in [IO.Path]::GetInvalidFileNameChars()) {

        $SafeName = $SafeName.Replace($InvalidChar, "_")
    }

    # ------------------------------------------------
    # 数据目录
    # ------------------------------------------------

    $ProfilePath = Join-Path $BaseProfilePath $SafeName

    # ------------------------------------------------
    # 桌面快捷方式
    # ------------------------------------------------

    # 快捷方式文件名使用普通字符，避免 WScript.Shell 对 emoji 路径兼容性问题
    $ShortcutDisplayName = "$AccountName - $BrowserShortName"
    $ShortcutName = "$ShortcutDisplayName.lnk"
    $ShortcutPath = Join-Path $DesktopPath $ShortcutName

    Write-Host ""

    # ------------------------------------------------
    # Step 1：创建数据目录
    # ------------------------------------------------

    Write-Host "[1/3] 创建浏览器数据目录..." -NoNewline

    if (-not (Test-Path $ProfilePath)) {

        New-Item `
            -ItemType Directory `
            -Path $ProfilePath `
            -Force | Out-Null
    }

    Write-Host " ✓" -ForegroundColor Green

    # ------------------------------------------------
    # 判断快捷方式是否已经存在
    # ------------------------------------------------

    $CreateShortcut = $true

    if (Test-Path $ShortcutPath) {

        Write-Host ""
        Write-Host "桌面已经存在：" -NoNewline
        Write-Host $ShortcutDisplayName -ForegroundColor Yellow

        Write-Host ""

        $Overwrite = Read-Host "是否覆盖？(Y/N)"

        if ($Overwrite -match '^[Yy]$') {

            Remove-Item $ShortcutPath -Force
        }
        else {

            $CreateShortcut = $false
        }
    }

    # ------------------------------------------------
    # Step 2：创建快捷方式
    # ------------------------------------------------

    if ($CreateShortcut) {

        Write-Host "[2/3] 创建桌面快捷方式..." -NoNewline

        try {

            $Shell = New-Object -ComObject WScript.Shell

            $Shortcut = $Shell.CreateShortcut($ShortcutPath)

            $Shortcut.TargetPath = $BrowserPath

            $Shortcut.Arguments = "--user-data-dir=`"$ProfilePath`""

            $Shortcut.WorkingDirectory = Split-Path $BrowserPath

            $Shortcut.IconLocation = "$BrowserPath,0"

            $Shortcut.Description = "$AccountName - 独立 $BrowserName 浏览器环境"

            $Shortcut.Save()

            Write-Host " ✓" -ForegroundColor Green
        }
        catch {

            Write-Host " 失败" -ForegroundColor Red

            Write-Host ""
            Write-Host "快捷方式创建失败：" -ForegroundColor Red
            Write-Host $_.Exception.Message

            Write-Host ""
        }
    }
    else {

        Write-Host "[2/3] 保留原有桌面快捷方式..." -NoNewline
        Write-Host " ✓" -ForegroundColor Green
    }

    # ------------------------------------------------
    # Step 3：完成
    # ------------------------------------------------

    Write-Host "[3/3] 完成设置..." -NoNewline

    Start-Sleep -Milliseconds 300

    Write-Host " ✓" -ForegroundColor Green

    # ------------------------------------------------
    # 显示结果
    # ------------------------------------------------

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "              创建完成！" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "浏览器：" -NoNewline
    Write-Host $BrowserName -ForegroundColor Cyan

    Write-Host "账号名称：" -NoNewline
    Write-Host $AccountName -ForegroundColor Cyan

    Write-Host "桌面快捷方式：" -NoNewline
    Write-Host $ShortcutDisplayName -ForegroundColor Cyan

    Write-Host "浏览器数据：" -NoNewline
    Write-Host $ProfilePath -ForegroundColor Cyan

    Write-Host ""
    Write-Host "以后直接双击桌面的快捷方式即可。" -ForegroundColor White
    Write-Host ""

    # ------------------------------------------------
    # 是否立即启动
    # ------------------------------------------------

    $LaunchNow = Read-Host "是否现在打开这个浏览器账号？(Y/N)"

    if ($LaunchNow -match '^[Yy]$') {

        Start-Process `
            -FilePath $BrowserPath `
            -ArgumentList "--user-data-dir=`"$ProfilePath`""
    }

    Write-Host ""

    # ------------------------------------------------
    # 是否继续创建
    # ------------------------------------------------

    $Continue = Read-Host "是否继续创建其他账号？(Y/N)"

    if ($Continue -notmatch '^[Yy]$') {
        break
    }

    Clear-Host
    Show-Header

    Write-Host "当前浏览器：" -NoNewline
    Write-Host $BrowserName -ForegroundColor Cyan
    Write-Host ""
}

Write-Host ""
Write-Host "全部完成。" -ForegroundColor Green
Write-Host ""

Read-Host "按 Enter 键退出"