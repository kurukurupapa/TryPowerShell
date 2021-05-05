
# サンプルプログラム

## PowerShellスクリプトのテンプレート

私がPowerShellスクリプトを書く時のテンプレートです。

```powershell
<#
.SYNOPSIS
PowerShellスクリプトのテンプレートです。（シンプル版）

.DESCRIPTION
このスクリプトは、PowerShellスクリプトのテンプレートです。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
Template2a.ps1 "D:\tmp\indir" "D:\tmp\outdir"
#>

[CmdletBinding()]
Param(
  [string]$inPath,
  [string]$outPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
#$VerbosePreference = 'Continue'
#$VerbosePreference = 'SilentlyContinue'
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace ("\.ps1$", "")
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ヘルプ
if (!$inPath -and !$outPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
Write-Verbose "$psName Start"

if (!(Test-Path $inPath -PathType Container) -or !(Test-Path $outPath -PathType Container)) {
  throw "入力元/出力先が見つからないか、ディレクトリではありません。"
}

Get-ChildItem $inPath -Recurse -File | %{
  $path = $_.FullName.Replace($inPath, $outPath)
  $dir = Split-Path $path -Parent
  Write-Host "処理開始 $($_.FullName)"
  if (!(Test-Path $dir -PathType Container)) {
    New-Item $dir -ItemType Directory | Out-Null
  }
  Get-Content $_.FullName | Set-Content $path
}

Write-Verbose "$psName End"
```

## テキストファイル操作

### 読み込み、抽出

柔軟にファイル操作ができる。ただし、処理が遅いようなので、数百MB単位などのファイルは取扱注意。
cat, typeは、Get-Contentのエイリアス。
compare, diffは、Compare-Objectのエイリアス。
ファイルへの追記やクリアは、Add-Content、Clear-Contentコマンドレットで可能。

```powershell
# 出力（全量、先頭のみ、末尾のみ）
cat $inpath
cat $inpath -Head 10
cat $inpath -Tail 10
# 行数確認
$(cat $inpath | Measure-Object).Count
# 文字列置換
cat $inpath | %{ $_ -Replace '変更前(正規表現)', '変更後($1など使用可能)' }
# ファイル比較
diff (cat $inpath1) (cat $inpath2) | %{ $_.SideIndicator+' '+$_.InputObject }
```

CSVファイルなどのテキストデータに対する操作。

```powershell
# 行抽出（正規表現、文字列比較・大文字小文字区別、複数パターン・不一致抽出）
cat $inpath | Select-String -Pattern '正規表現' | %{ $_.Line }
cat $inpath | Select-String -Pattern '文字列' -SimpleMatch -CaseSensitive | %{ $_.Line }
cat $inpath | Select-String -Pattern @('パターン1', 'パターン2') -NotMatch | %{ $_.Line }
# カラム抽出
cat $incsv | %{ $arr=$_.Split(','); $arr[0]+','+$arr[1]+','+$arr[3] }
Import-Csv $incsv -Encoding Default | select "ColumnName1", "ColumnName2"
# ソート、ユニーク
cat $incsv | sort | Get-Unique
```

### 文字コード、改行コード変換

文字コードの指定は、Get-Content, Out-File, Set-Contentの-Encodingオプションで行う。
Out-File, Set-Contentの-EncodingオプションでUTF8を指定すると、BOM付きのUTF8になる。
BOMなしUTF8を扱うために、.NET Frameworkの[Text.Encoding]::UTF8を使用した。

```powershell
# 文字コード変換 UTF8(CRLF/LF) → SJIS(CRLF)
cat -Encoding UTF8 $utf8path | Out-File -Encoding Default 'out_SJIS_CRLF.txt'
cat -Encoding UTF8 $utf8path | Set-Content -Encoding Default 'out_SJIS_CRLF.txt'
# 文字コード変換 SJIS(CRLF/LF) → BOM付きUTF8(CRLF)
cat $sjispath | Out-File -Encoding UTF8 'out_UTF8-BOM_CRLF.txt'
cat $sjispath | Set-Content -Encoding UTF8 'out_UTF8-BOM_CRLF.txt'
# 文字コード変換 SJIS(CRLF/LF) → BOMなしUTF8(CRLF)
cat $sjispath | %{ [Text.Encoding]::UTF8.GetBytes($_+"`r`n") } | Set-Content -Encoding Byte 'out_UTF8_CRLF.txt'
```

```powershell
# 改行コード変換 CRLF/LF → LF （-NoNewlineオプションはPowerShell 5.0以降で使用可能）
cat $sjispath | %{ $_+"`n" } | Out-File -Encoding Default -NoNewline 'out_SJIS_LF.txt'
cat $sjispath | %{ $_+"`n" } | Set-Content -Encoding Default -NoNewline 'out_SJIS_LF.txt'
# .NET Framework 使用
cat $sjispath | %{ [Text.Encoding]::GetEncoding('SJIS').GetBytes($_+"`n") } | Set-Content -Encoding Byte 'out_SJIS_LF.txt'
```

### ファイル分割

テキストファイルを、指定の行数で、ファイル分割する。

```powershell
$num = 100
$i = 1
cat $inpath -ReadCount $num | %{
  Set-Content -Value $_ ('out_' + ([string]$i).PadLeft(3,'0') + '.txt')
  $i++
}
```

CSVファイルを、指定カラムの値で、ファイルを分割する。次の例では、ヘッダー行（先頭1行）を読み飛ばし、3カラム目の値でファイルを分割する。

```powershell
$column = 3
cat $incsv | Select-Object -Skip 1 | %{
  Out-File -Append -Encoding Default -InputObject $_ ('out_' + ($_.Split(',')[$column-1]) + '.csv')
}
```

### CSVファイル

CSVファイルの入出力は、 Export-Csv, Import-Csv コマンドレットで実現できました。

- [Export-Csv (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/export-csv)
- [Import-Csv (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/import-csv)

```powershell
$csvPath = "D:\tmp\dummy.csv"
$sampleObj = @(
  [PSCustomObject]@{ Column1=1; Column2="A"; 日本語="あ"; }
  [PSCustomObject]@{ Column1=2; Column2="B"; 日本語="い"; }
)

# CSVファイル書き込み
# 各カラムは、ダブルクォーテーションで括られる。
# -Forceオプションで既存ファイルを上書き、-Appendオプションで既存ファイルへ追記。
$sampleObj | Export-Csv $csvPath -NoTypeInformation -Encoding Default

# CSVファイル読み込み
Import-Csv $csvPath -Encoding Default | %{ $_.Column1 }
# CSVファイル読み込み（ヘッダーなし）
Import-Csv $csvPath -Encoding Default -Header ("Column1","Column2","日本語") | %{ $_ }
```

CSV形式の文字列と、データオブジェクトとの変換には、 ConvertFrom-Csv, ConvertTo-Csv コマンドレットが用意されていました。

- [ConvertFrom-Csv (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertfrom-csv)
- [ConvertTo-Csv (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertto-csv)

```powershell
$sampleObj = @(
  [PSCustomObject]@{ Column1=1; Column2="A"; 日本語="あ"; }
  [PSCustomObject]@{ Column1=2; Column2="B"; 日本語="い"; }
)
$sampleCsv = "Column1,Column2,日本語`n1,A,あ`n2,B,い"
$sampleCsv2 = "1,A,あ`n2,B,い"

# オブジェクトからCSV文字列へ変換
# 1行目にヘッダーが付く
$sampleObj | ConvertTo-Csv -NoTypeInformation
#=> @('"Column1","Column2","日本語"', '"1","A","あ"', '"2","B","い"')

# CSV文字列からオブジェクトへ変換（ヘッダーあり）
$sampleCsv | ConvertFrom-Csv | %{ $_.Column1 }
# CSV文字列からオブジェクトへ変換（ヘッダーなし）
$sampleCsv2 | ConvertFrom-Csv -Header ("Column1","Column2","日本語") | %{ $_ }
```

各コマンドレットでは、-Delimiterオプションを使用することで、カンマ区切り以外のファイルも扱える。
次の例では、TSVファイル（タブ区切り）を扱ってみました。

```powershell
$tsvPath = "D:\tmp\dummy.tsv"
$sampleObj = @(
  [PSCustomObject]@{ Column1=1; Column2="A"; 日本語="あ"; }
  [PSCustomObject]@{ Column1=2; Column2="B"; 日本語="い"; }
)
$sampleObj | Export-Csv $tsvPath -NoTypeInformation -Encoding Default -Delimiter "`t"
Import-Csv $tsvPath -Encoding Default -Delimiter "`t" | %{ $_.Column1 }
```

少し工夫して、Markdownの表を読み込んでみました。
なんだか煩雑で、うれしくない感じになってしまいました。

```powershell
$text = @"
| Column1 | Column2 | 日本語 |
| ------- | ------- | ------ |
| 1       | A       | あ     |
| 2       | B       | い     |
"@
$text.Split("`n") |
  % -Begin { $i=0 } -Process { if($i -ne 1){ ($_ -replace " *\| *", "|").Trim("|") }; $i++ } |
  ConvertFrom-Csv -Delimiter "|" |
  %{ $_.Column1 }
```


## 画像ファイル操作

### リサイズ

次のようにして画像をリサイズすることもできました。これを[スクリプト化](https://github.com/kurukurupapa/TryPowerShell/tree/master/File/ResizeImage)したものをGitHubにも置いておきます。


```powershell
Add-Type -AssemblyName System.Drawing
$maxw, $maxh = 300, 200
$srcpath = "D:\tmp\srcimage.jpg"
# 画像取得・リサイズ
$srcbmp = [System.Drawing.Bitmap]::FromFile($srcpath)
$k = [Math]::Min($maxw / $srcbmp.Width, $maxh / $srcbmp.Height)
$w = [int][Math]::Round($srcbmp.Width * $k)
$h = [int][Math]::Round($srcbmp.Height * $k)
$destbmp = [System.Drawing.Bitmap]::new($w, $h)
$g = [System.Drawing.Graphics]::FromImage($destbmp)
$g.DrawImage($srcbmp, 0, 0, $w, $h)
# 保存
$destpath = $srcpath -replace "(.*)(\..*?)", "`$1_${w}x${h}`$2"
$destbmp.Save($destpath, $srcbmp.RawFormat.Guid)
# 後片付け
$g.Dispose()
$destbmp.Dispose()
$srcbmp.Dispose()
```

## ファイル操作

### ファイル/フォルダ一覧

Get-ChildItemコマンドレットを使用する。エイリアスとして、gci, ls, dirが定義されている。

```powershell
# ファイル/フォルダ一覧
ls 'D:\tmp'
# ファイル一覧（フルパスのみ）
ls 'D:\tmp' -Recurse -File | %{ $_.FullName }
# ファイル/フォルダ一覧（属性、タイムスタンプ、サイズ、フルパス）
ls 'D:\tmp' -Recurse | select Attributes, LastWriteTime, Length, FullName
```

### ファイルをロック

下記コードで、Openメソッドの第4引数で、他プロセスに対するファイルアクセスの種類を制御できます。たとえば、'None'は共有を拒否、'Read'は読み取りを許可。詳細は、次を参照。

- [FileShare 列挙型 (System.IO) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.io.fileshare?view=netcore-3.1)

```powershell
$f = [System.IO.File]::Open($inpath, 'Open', 'Read', 'None')
Start-Sleep -Seconds 10
$f.Close()
```

### タイムスタンプを変更

次のようにして、ファイルの作成日時や更新日時を変更することができました。

※ネットを見ると、Set-ItemPropertyで変更している例ばかりだけど、下の`$_.LastWriteTime = 日時`でも変更できた。どういう違いがあるか不明。

```powershell
# 1つのファイルの作成日時・更新日時を変更
Set-ItemProperty $inpath -Name CreationTime -Value '2020-01-01 00:00:00'
Set-ItemProperty $inpath -Name LastWriteTime -Value '2020-01-01 00:00:00'
# 複数ファイルまとめて更新日時を変更
Get-ChildItem -Path 'D:\tmp\dummy*.txt' | %{
  $_.LastWriteTime = '2020-01-01 00:00:00'
}
```

### 更新されたファイルをコピー

Get-ChildItemで、ファイル一覧やタイムスタンプを取得できるので、ちょっとした処理を書いてみました。

```powershell
# 日時設定（特定日時、現在日時10分前、コマンド起動からキー入力までの時間帯）
$time = Get-Date "2020-01-01 00:00"
$time = (Get-Date).AddMinutes(10)
$time = Get-Date; Pause
# コピー処理
$dirs = @('D:\tmp\dir1', 'D:\tmp\dir2')
$otop = 'out'
$dirs | Get-ChildItem -File -Recurse | where { $_.LastWriteTime -gt $time } | foreach {
  $odir = Join-Path $otop ($_.DirectoryName -replace ':', '')
  if (!(Test-Path $odir)) {
    New-Item $odir -ItemType directory
  }
  Copy-Item $_.FullName -Destination $odir
} | Out-Null
# 結果確認
Get-ChildItem $otop -File -Recurse
```

### ファイル削除

ファイルを削除します。
Remove-Itemだけで実装してもよいのですが、対象ファイルが存在しないとエラーメッセージが表示されてしまうので、それを回避するために、存在チェックしてから、削除しています。

```powershell
$delPath = "D:\tmp\dummy.txt"
if (Test-Path $delPath) { Remove-Item $delPath }
```

次のようにして、ファイルをWindowsのごみ箱へ入れることもできました。

```powershell
$delPath = "D:\tmp\dummy.txt"
$dir = Split-Path $delPath -Parent
$name = Split-Path $delPath -Leaf
# MakeAllMd SKIP_START
echo "DUMMY" | Set-Content $delPath
# MakeAllMd SKIP_END
$shell = New-Object -ComObject Shell.Application
$dirObj = $shell.Namespace($dir)
$fileObj = $dirObj.ParseName($name)
$fileObj.InvokeVerb("delete")
# 1行にまとめてみた
(New-Object -ComObject Shell.Application).Namespace($dir).ParseName($name).InvokeVerb("delete")
```

### ファイル/フォルダ圧縮

Compress-Archiveコマンドレットを使うと、ファイルやディレクトリの圧縮アーカイブを作成できました。

- [Compress-Archive (Microsoft.PowerShell.Archive) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.archive/compress-archive)
- -Forceオプションで、既存ZIPが存在するとき上書き。
- -Updateオプションで、既存ZIPが存在するとき追加。なければ、新規作成。
- たぶん、PowerShell 5.0 以降

```powershell
# MakeAllMd SKIP_START
cd "D:\tmp"
# MakeAllMd SKIP_END
Compress-Archive ".\dummy1.txt" ".\dummy.zip" -Force
Compress-Archive (".\dummy2.txt", ".\subdir") ".\dummy.zip" -Update
```

展開するときは、Expand-Archiveコマンドレットを使用しました。

```powershell
# MakeAllMd SKIP_START
cd "D:\tmp"
# MakeAllMd SKIP_END
Expand-Archive ".\dummy.zip" ".\output" -Force
```

## ネットワーク通信

### HTTP/FTPクライアント

HTTP/FTP通信で、Webページやファイルをダウンロードし、ファイルに保存します。Invoke-WebRequestコマンドレットのエイリアスには、wget, curlが定義されています。

PowerShellから離れてしまいますが、Windows10には、curl.exeが存在するので、こちらを使うのも良いかもしれません。

```powershell
# .NET Framework使用（出力ファイルをフルパスで書く必要がありそう）
$client = New-Object System.Net.WebClient
$client.DownloadFile($url, 'D:\tmp\out.txt')
# PowerShell 3.0以降
Invoke-WebRequest -Uri $url -OutFile 'out.txt'
```

もっと細かい話は、[PowerShellで HTTPアクセスする いくつかの方法 - Qiita](https://qiita.com/kurukurupapa@github/items/c77b7be7f3c05453e75e) に記述しました。

### メール送信

GmailのSMTPサーバを利用して、メール送信することができました。

```powershell
$password = ConvertTo-SecureString "Gmailのパスワード" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential(
  "Gmailのアカウント名", $password)
$from = "送信元のGmailメールアドレス"
$to = "送信先メールアドレス"
Send-MailMessage `
  -From $from `
  -To $to `
  -Subject "テストメール" `
  -Body "テストメールです。" `
  -Attachments "D:\tmp\dummy.txt" `
  -Encoding UTF8 `
  -SmtpServer "smtp.gmail.com" `
  -Port 587 `
  -UseSsl `
  -Credential $credential
```

SMTPサーバの認証情報を暗号化してファイル保存するのは、次のようにしてできました。

```powershell
# GmailのSMTPサーバに対する認証情報をファイル保存
$path = Join-Path ([System.Environment]::GetFolderPath('MyDocuments')) "ps_mail.json"
$credential = Get-Credential
ConvertTo-Json @{
  userName = $credential.UserName;
  password = $credential.Password | ConvertFrom-SecureString;
  } | Set-Content $path

# 上記ファイルの読み込み
$jsonObj = Get-Content $path | ConvertFrom-Json
$password = $jsonObj.password | ConvertTo-SecureString
$credential = New-Object System.management.Automation.PsCredential($jsonObj.userName, $password)
```

メール送信についての詳細は、[PowerShellで Gmail/Yahoo!JAPAN SMTPを利用したメール送信 - Qiita](https://qiita.com/kurukurupapa@github/items/2e16e9bc05dccafcb4fe) に記述しました。

## アプリケーション操作

### IE操作

IEを起動して、指定ページを表示し、その内容の一部を標準出力するサンプルです。

```powershell
$url = 'https://ja.wikipedia.org/wiki/PowerShell'
$ie = New-Object -ComObject InternetExplorer.Application
$ie.Visible = $true
$ie.Navigate($url)
while ($ie.busy -or $ie.readystate -ne 4) {
  Start-Sleep -Seconds 1
}
$doc = $ie.Document
echo $doc.title
$doc.all | where { $_.tagName -eq 'H1' } | foreach { $_.innerText }
$ie.Quit()
```

### ブラウザサイズ変更

ブラウザのサイズを変更することもできました。

- [見た目もスッキリ！ ウインドウの配置・サイズを変更する方法 - Qiita](https://qiita.com/kurukurupapa@github/items/944b89c7b653b9e92585)
- [画面解像度 - Wikipedia](https://ja.wikipedia.org/wiki/%E7%94%BB%E9%9D%A2%E8%A7%A3%E5%83%8F%E5%BA%A6)

```powershell
$names = "msedge","iexplore","chrome","firefox"
$w, $h = 1024, 768  #XGA
$w, $h = 1280, 800  #WXGA
$x, $y = 0, 0
Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class Win32Api {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
  }
"@
Get-Process | ?{ $_.MainWindowTitle -ne "" } | ?{ $_.Name -in $names } | %{
  [Win32Api]::MoveWindow($_.MainWindowHandle, $x, $y, $w, $h, $true) | Out-Null
}
```

### バルーン表示

Windowsの画面右下へ通知メッセージをバルーン表示し、アクションセンターに登録することもできました。ただし、バルーンよりもトーストのほうが多機能です。

```powershell
Add-Type -AssemblyName System.Windows.Forms
$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -Id $pid).Path)
$notify.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$notify.BalloonTipTitle = "タイトル"
$notify.BalloonTipText = "テキストです"
$notify.Visible = $true
$notify.ShowBalloonTip(5 * 1000)
Start-Sleep -Seconds 5
```

### トースト表示

トースト表示もできました。このサンプルですと、上述のバルーン表示とほぼ同じ見た目になってしまいますが、画像や進捗率を表示したり、音を出したり、再通知や解除を選択したりできるようです。

```powershell
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
$title = "タイトル"
$message = "トースト通知のサンプルメッセージです。"
$app_id = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$content = @"
<?xml version="1.0" encoding="Shift_JIS"?>
<toast>
  <visual>
    <binding template="ToastGeneric">
      <text>${title}</text>
      <text>${message}</text>
    </binding>
  </visual>
</toast>
"@
$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($content)
$toast = New-Object Windows.UI.Notifications.ToastNotification $xml
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app_id).Show($toast)
```

### クリップボード操作

PowerShell 5.0 以降では、Get-Clipboard, Set-Clipboard コマンドレットで、クリップボードを操作できるようです。
色々使い道がありそうなので、簡単なサンプルを作ってみました。
ここでは、クリップボードを監視して、クリップボードに何か入ったら、ファイルに保存やコピーをしています。

```powershell
$workdir = ".\clip"
$workdir = $workdir -replace "^\.\\", ((pwd).Path + "\")
mkdir $workdir -Force | Out-Null
Set-Clipboard $null
while ($true) {
  # テキスト取得（String）
  Get-Clipboard | %{
    echo $_
    $_ | Out-File -Append -Encoding default "${workdir}\text.txt"
  }

  # ファイル取得（FileInfo）
  Get-Clipboard -Format FileDropList | %{ $_ | where { $_ -ne $null } | %{
    echo $_
    $path = $_.FullName -replace ":", ""
    $path = "${workdir}\${path}"
    $dir = Split-Path $path -Parent
    mkdir $dir -Force | Out-Null
    cp $_ $dir -Recurse -Force
  }}

  # 画像の取得（Bitmap）
  Get-Clipboard -Format Image | where { $_ -ne $null } | %{
    echo $_
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $path = "${workdir}\${timestamp}.png"
    $_.Save($path)
  }

  Set-Clipboard $null
  Start-Sleep 1
}
```

### Windowsフォーム

Windowのフォームを表示させることもできました。
次の例では、3つのボタンが縦に並んだフォームを表示し、ボタンが押されると、押されたボタンの番号を $global:formResult へ保存し、フォームを閉じます。

- [Form クラス (System.Windows.Forms) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.form)
- [コントロールのレイアウト オプション - Windows Forms .NET | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/desktop/winforms/controls/layout)
- [Button クラス (System.Windows.Forms) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.button)

```powershell
Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.AutoSize = $true
$form.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.Text = "サンプルフォーム"

$layout = New-Object System.Windows.Forms.FlowLayoutPanel
$layout.AutoSize = $true
$layout.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
$layout.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$form.Controls.Add($layout)

$button = @()
for ($i = 0; $i -lt 3; $i++) {
  $button += New-Object System.Windows.Forms.Button
  $button[$i].AutoSize = $true
  $button[$i].AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
  $button[$i].Tag = $i
  $button[$i].Text = "サンプルフォームのサンプルボタン $($i + 1)"
  $button[$i].Add_Click({
    param($sender, $eventArgs)
    $dummy = "Click! $($sender.Tag) $(Get-Date)"
    Write-Host $dummy
    $sender.Text = $dummy
    $global:formResult = $sender.Tag
    $form.Close()
  })
  $layout.Controls.Add($button[$i])
}

$form.ShowDialog() | Out-Null
$form.Dispose()
echo $global:formResult
```
