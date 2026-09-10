# Repository Guidelines

## プロジェクト構成

このリポジトリは、Windows 上で Edge または Chrome の独立プロファイルとデスクトップショートカットを作成する小規模ツールです。

- `BrowserProfileSetup.ps1`: ブラウザ検出、入力検証、プロファイル作成、`.lnk` 作成を担当する本体。
- `Start.bat`: UTF-8 コードページを設定し、本体を `ExecutionPolicy Bypass` で起動するエントリーポイント。

生成物はリポジトリ内ではなく、`Documents\EdgeProfiles` または `Documents\ChromeProfiles` とデスクトップに保存されます。新しいロジックは原則として PowerShell 側へ追加し、バッチファイルは薄い起動ラッパーに保ってください。

## 実行・検証コマンド

ビルド工程や外部依存関係はありません。Windows PowerShell で次を使用します。

```powershell
.\Start.bat
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\BrowserProfileSetup.ps1
powershell.exe -NoProfile -Command "$null = [System.Management.Automation.Language.Parser]::ParseFile('.\BrowserProfileSetup.ps1', [ref]$null, [ref]$errors); $errors"
```

最初の 2 コマンドは対話実行、最後は構文エラーの確認用です。手動検証では Edge/Chrome の選択、空のアカウント名、不正なファイル名文字、既存ショートカットの上書き拒否と許可を確認してください。

## コーディング規約

既存スタイルに合わせ、4 スペースでインデントし、関数は `Verb-Noun`、変数は `PascalCase` を使用します。ユーザー向けメッセージは簡潔な中国語を維持してください。パスは文字列連結ではなく `Join-Path`、存在確認は `Test-Path` を使い、ブラウザ固有値は選択ブロックに集約します。

## テスト方針

現在、自動テストとカバレッジ基準はありません。変更後は構文チェックに加え、Windows Sandbox またはテスト用アカウントで手動確認します。テストを追加する場合は Pester を使用し、`tests/*.Tests.ps1` に配置してください。ファイル作成や COM 操作はモック化します。

## コミットとプルリクエスト

この作業コピーには Git 履歴がないため、履歴由来の慣例は確認できません。コミットは日本語の複数行形式にします。

```text
fix: ショートカット作成時の検証を改善
- 不正なアカウント名の処理を追加しました
- 手動確認手順を更新しました
```

PR には変更理由、影響するブラウザ、実行した検証、生成先への影響を記載してください。画面表示を変更した場合は、コンソール出力のスクリーンショットを添付します。

## セキュリティと設定

実在するブラウザプロファイルをテストに使用しないでください。ユーザー入力を実行可能な引数へ追加する場合は必ず検証し、認証情報、プロファイルデータ、生成された `.lnk` をコミットしないでください。
