<#

# メール送信に関連する処理

## SMTPサーバ認証情報を暗号化してファイル管理

コード内に認証情報を含めてしまうと、セキュリティ的に問題があるので、暗号化してファイル保管する方法をメモしておきます。
Get-Credential、ConvertFrom-SecureString、ConvertTo-SecureStringコマンドレットを使用しました。

#>
# ファイル保存
$path = "D:\tmp\password.json"
$credential = Get-Credential
ConvertTo-Json @{
  userId = $credential.UserName;
  password = $credential.Password | ConvertFrom-SecureString;
  } | Set-Content $path

# ファイル読み込み
$jsonObj = Get-Content $path | ConvertFrom-Json
$password = $jsonObj.password | ConvertTo-SecureString
$credential = New-Object System.management.Automation.PsCredential($jsonObj.userId, $password)

# メール送信
$from = "送信元のGmailメールアドレス"
$to = "送信先メールアドレス"
Send-MailMessage `
  -From $from `
  -To $to `
  -Subject "テストメール" `
  -Body "テストメールです。" `
  -Encoding UTF8 `
  -SmtpServer "smtp.gmail.com" `
  -Port 587 `
  -UseSsl `
  -Credential $credential
<#

## SMTPサーバのポート確認

メール送信処理でエラーが出たとき、ポートが開いていることを確認するためには、次のコマンドレットが使えました。

#>
Test-NetConnection "smtp.gmail.com" -port 465         # OK
Test-NetConnection "smtp.gmail.com" -port 587         # OK
Test-NetConnection "smtp.mail.yahoo.co.jp" -port 465  # OK
Test-NetConnection "smtp.mail.yahoo.co.jp" -port 587  # NG
Test-NetConnection "smtp.mail.yahoo.co.jp" -port 25   # NG
