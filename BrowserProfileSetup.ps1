# ============================================
# 多账号浏览器环境一键创建工具
# 支持 Microsoft Edge / Google Chrome
# ============================================

param(
    [ValidateSet("auto", "zh-CN", "ja-JP")]
    [string]$Language = "auto"
)

if ($Language -eq "auto") {

    $SystemLanguage = (Get-WinUserLanguageList | Select-Object -First 1).LanguageTag

    if ([string]::IsNullOrWhiteSpace($SystemLanguage)) {
        $SystemLanguage = [Globalization.CultureInfo]::CurrentCulture.Name
    }

    $DefaultLanguage = if ($SystemLanguage -like "ja*") { "ja-JP" } else { "zh-CN" }
    $MenuMessagesPath = Join-Path $PSScriptRoot "locales\$DefaultLanguage.psd1"
    $MenuMessages = Import-PowerShellDataFile $MenuMessagesPath
    $DefaultLanguageName = if ($DefaultLanguage -eq "ja-JP") {
        $MenuMessages.JapaneseLanguageName
    }
    else {
        $MenuMessages.ChineseLanguageName
    }

    Clear-Host

    while ($true) {

        Write-Host $MenuMessages.SelectLanguage -ForegroundColor White
        Write-Host ""
        Write-Host ("  1. {0}" -f $MenuMessages.ChineseLanguageName)
        Write-Host ("  2. {0}" -f $MenuMessages.JapaneseLanguageName)
        Write-Host ""
        Write-Host ($MenuMessages.UseSystemDefaultLanguage -f $DefaultLanguageName)
        Write-Host ""

        $LanguageChoice = Read-Host $MenuMessages.EnterLanguageChoice

        if ([string]::IsNullOrWhiteSpace($LanguageChoice)) {
            $Language = $DefaultLanguage
            break
        }
        elseif ($LanguageChoice -eq "1") {
            $Language = "zh-CN"
            break
        }
        elseif ($LanguageChoice -eq "2") {
            $Language = "ja-JP"
            break
        }
        else {
            Write-Host ""
            Write-Host $MenuMessages.InvalidLanguageChoice -ForegroundColor Yellow
            Write-Host ""
        }
    }
}

$MessagesPath = Join-Path $PSScriptRoot "locales\$Language.psd1"
$Messages = Import-PowerShellDataFile $MessagesPath

$Host.UI.RawUI.WindowTitle = $Messages.WindowTitle

Clear-Host

function Show-Header {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "      $($Messages.HeaderTitle)" -ForegroundColor Cyan
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

    Write-Host $Messages.SelectBrowser -ForegroundColor White
    Write-Host ""
    Write-Host "  1. Microsoft Edge"
    Write-Host "  2. Google Chrome"
    Write-Host ""

    $BrowserChoice = Read-Host $Messages.EnterBrowserChoice

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
        Write-Host $Messages.InvalidBrowserChoice -ForegroundColor Yellow
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
    Write-Host ($Messages.BrowserNotFound -f $BrowserName) -ForegroundColor Red
    Write-Host ""
    Write-Host ($Messages.InstallBrowser -f $BrowserName)
    Write-Host ""

    Read-Host $Messages.PressEnterToExit
    exit
}

Write-Host ""
Write-Host ($Messages.BrowserFound -f $BrowserName) -ForegroundColor Green
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

    $AccountName = Read-Host $Messages.EnterAccountName

    $AccountName = $AccountName.Trim()

    if ([string]::IsNullOrWhiteSpace($AccountName)) {

        Write-Host ""
        Write-Host $Messages.AccountNameEmpty -ForegroundColor Yellow
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

    Write-Host $Messages.StepCreateProfile -NoNewline

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
        Write-Host $Messages.DesktopAlreadyExists -NoNewline
        Write-Host $ShortcutDisplayName -ForegroundColor Yellow

        Write-Host ""

        $Overwrite = Read-Host $Messages.ConfirmOverwrite

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

        Write-Host $Messages.StepCreateShortcut -NoNewline

        try {

            $Shell = New-Object -ComObject WScript.Shell

            $Shortcut = $Shell.CreateShortcut($ShortcutPath)

            $Shortcut.TargetPath = $BrowserPath

            $Shortcut.Arguments = "--user-data-dir=`"$ProfilePath`""

            $Shortcut.WorkingDirectory = Split-Path $BrowserPath

            $Shortcut.IconLocation = "$BrowserPath,0"

            $Shortcut.Description = $Messages.ShortcutDescription -f $AccountName, $BrowserName

            $Shortcut.Save()

            Write-Host " ✓" -ForegroundColor Green
        }
        catch {

            Write-Host $Messages.Failed -ForegroundColor Red

            Write-Host ""
            Write-Host $Messages.ShortcutCreationFailed -ForegroundColor Red
            Write-Host $_.Exception.Message

            Write-Host ""
        }
    }
    else {

        Write-Host $Messages.StepKeepShortcut -NoNewline
        Write-Host " ✓" -ForegroundColor Green
    }

    # ------------------------------------------------
    # Step 3：完成
    # ------------------------------------------------

    Write-Host $Messages.StepFinishSetup -NoNewline

    Start-Sleep -Milliseconds 300

    Write-Host " ✓" -ForegroundColor Green

    # ------------------------------------------------
    # 显示结果
    # ------------------------------------------------

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "              $($Messages.CreationCompleted)" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""

    Write-Host $Messages.BrowserLabel -NoNewline
    Write-Host $BrowserName -ForegroundColor Cyan

    Write-Host $Messages.AccountNameLabel -NoNewline
    Write-Host $AccountName -ForegroundColor Cyan

    Write-Host $Messages.DesktopShortcutLabel -NoNewline
    Write-Host $ShortcutDisplayName -ForegroundColor Cyan

    Write-Host $Messages.BrowserDataLabel -NoNewline
    Write-Host $ProfilePath -ForegroundColor Cyan

    Write-Host ""
    Write-Host $Messages.ShortcutReady -ForegroundColor White
    Write-Host ""

    # ------------------------------------------------
    # 是否立即启动
    # ------------------------------------------------

    $LaunchNow = Read-Host $Messages.ConfirmLaunch

    if ($LaunchNow -match '^[Yy]$') {

        Start-Process `
            -FilePath $BrowserPath `
            -ArgumentList "--user-data-dir=`"$ProfilePath`""
    }

    Write-Host ""

    # ------------------------------------------------
    # 是否继续创建
    # ------------------------------------------------

    $Continue = Read-Host $Messages.ConfirmContinue

    if ($Continue -notmatch '^[Yy]$') {
        break
    }

    Clear-Host
    Show-Header

    Write-Host $Messages.CurrentBrowserLabel -NoNewline
    Write-Host $BrowserName -ForegroundColor Cyan
    Write-Host ""
}

Write-Host ""
Write-Host $Messages.AllCompleted -ForegroundColor Green
Write-Host ""

Read-Host $Messages.PressEnterToExit
