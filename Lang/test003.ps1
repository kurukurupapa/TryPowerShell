# Windows PowerShell
# サーバから、ZIPファイルダウンロード＆展開を行なってみる。
# 2013/04/03 新規作成

# 当スクリプトのディレクトリ
$basedir = Convert-Path $(Split-Path -Path $MyInvocation.InvocationName -Parent)
Set-Location $basedir

# Webクライアントオブジェクト生成
$webClient = New-Object System.Net.WebClient

# ZIPファイルダウンロード
$srcUrl = "http://ftp.kddilabs.jp/infosystems/apache/ant/binaries/apache-ant-1.9.0-bin.zip"
$zipName = [System.IO.Path]::GetFileName($srcUrl)
$zipPath = [System.IO.Path]::Combine($basedir, $zipName)
Write-Output "ダウンロード開始 $srcUrl"
$webClient.DownloadFile($srcUrl, $zipPath)

# ZIPファイル展開
$sh = New-Object -ComObject Shell.Application
$unzipDirObj = $sh.NameSpace($basedir)
$zipPathObj = $sh.NameSpace($zipPath)
Write-Output "アーカイブ展開開始 $zipPath"
$unzipDirObj.CopyHere($zipPathObj.Items())

Write-Output "終了"

#$url = "http://mirrors.jenkins-ci.org/war/latest/jenkins.war"
#$name = $url.Substring($url.LastIndexOf("/") + 1)
#Write-Output "Downloading $url"
#$webClient.DownloadFile($url, $basedir + "\" + $name)
#Write-Output "Done."

exit 0
