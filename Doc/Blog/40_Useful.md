
# 便利機能

動作環境の確認

```powershell
$PSVersionTable
```

## PowerShellスクリプトを呼び出すバッチファイル

ps1ファイルを実行するとき、セキュリティポリシーを指定して実行するためのバッチファイルです。ps1ファイルの名前が ps1sample.ps1 の場合、ps1sample.bat という名前で、次のバッチファイルを作成します。

```bat:ps1sample.bat
@echo off
set batdir=%~dp0
set basename=%~n0
powershell -ExecutionPolicy RemoteSigned -File "%batdir%%basename%.ps1" %*
if errorlevel 1 (
  pause
  exit /b 1
)
timeout 5
exit /b 0
```

## プロファイル

プロファイルを作成しておくと、PowerShellのコンソールを起動したときに、自分の初期設定を行える。デフォルトではファイルがないので、必要あれば自分でファイル作成する。セキュリティポリシーの設定で、ps1ファイルの実行が許可されている必要がある。

```powershell
# プロファイルの場所
$profile
# プロファイル作成
New-Item $profile -ItemType file -Force
notepad $profile
```

## エイリアス

単純に別名をつけるならSet-Aliasでできる。引数をつけたり、複数コマンドをまとめて実行したいときは、関数で定義すると便利。

```powershell
# エイリアス
Set-Alias sakura 'C:\Program Files (x86)\sakura\sakura.exe'
# エイリアス風に使う関数
function mydesk() {
  start chrome 'https://mail.google.com/'
  start chrome 'https://qiita.com/kurukurupapa@github/items/37fc3fe4ec27612ab7df'
  start 'D:\tmp'
}
```

## デバッグ

```powershell
$obj = 'dummy'
$obj.GetType().FullName  #データ型
$obj | Get-Member        #メソッドやプロパティの一覧
```
