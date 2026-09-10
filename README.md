# Browser Profile Setup

Microsoft Edge または Google Chrome 用の独立したブラウザプロファイルを作成し、専用のデスクトップショートカットを生成する Windows 向けツールです。

複数の店舗、業務アカウント、検証環境などを、それぞれ異なる Cookie・ログイン状態・ブラウザ設定で管理できます。

## 主な機能

- Microsoft Edge と Google Chrome に対応
- インストール済みブラウザを自動検出
- アカウントごとに独立したユーザーデータディレクトリを作成
- 専用のデスクトップショートカットを生成
- 同名ショートカットの上書きを実行前に確認
- 続けて複数のアカウントを作成可能

## 動作環境

- Windows 10 または Windows 11
- Windows PowerShell 5.1 以降
- Microsoft Edge または Google Chrome

追加パッケージのインストールやビルドは不要です。

## 使い方

1. `Start.bat` をダブルクリックします。
2. 使用するブラウザを選択します。
3. アカウント名（例: `店舗A`）を入力します。
4. 必要に応じて、作成したブラウザ環境をそのまま起動します。
5. 次回以降はデスクトップに作成されたショートカットを使用します。

PowerShell から直接起動することもできます。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\BrowserProfileSetup.ps1
```

## 作成されるファイル

選択したブラウザに応じて、プロファイルデータは次の場所へ保存されます。

```text
Documents\EdgeProfiles\<アカウント名>
Documents\ChromeProfiles\<アカウント名>
```

デスクトップには次の形式のショートカットが作成されます。

```text
<アカウント名> - Edge.lnk
<アカウント名> - Chrome.lnk
```

Windows のファイル名として使用できない文字は、自動的に `_` へ置き換えられます。

## 注意事項

- プロファイルディレクトリには Cookie、ログイン情報、閲覧設定などが保存される場合があります。共有や公開リポジトリへの追加は避けてください。
- プロファイルを削除すると、その環境に保存されたブラウザデータも失われます。
- デスクトップショートカットだけを削除しても、Documents 内のプロファイルデータは削除されません。
- 会社や組織が管理する端末では、PowerShell の実行やブラウザオプションがポリシーで制限される場合があります。

## ファイル構成

```text
BrowserProfileSetup.ps1  # メインスクリプト
Start.bat                # ダブルクリック用ランチャー
AGENTS.md                # コントリビューター向けガイド
README.md                # このドキュメント
```

## 開発時の確認

変更後は PowerShell の構文を確認し、テスト用アカウント名で Edge と Chrome の両方を手動検証してください。詳細な規約は [`AGENTS.md`](./AGENTS.md) を参照してください。
