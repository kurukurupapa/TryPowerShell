<#

# メール送信の実装

## Send-MailMessageコマンドレット

下記のように記述して、GmailのSMTPサーバを利用したメール送信ができました。

SMTPサーバへの接続ポートは、TLS/STARTTLSのポート「587」を使用しました。
SSLのポート「465」だと、エラーになってしまいました。
私の書き方が悪いのか、Send-MailMessageコマンドレットが対応していないのか、原因は分かりません。

SMTPサーバ接続の認証情報として利用するGmailのアカウントですが、次の2パターンで利用可能でした。

- 2段階認証を設定されていないアカウントを使用する。
- 2段階認証を設定しているアカウントで、アプリパスワードを払い出し、下記コードの認証情報のパスワードに設定する。

認証情報として設定する下記「Gmailのアカウント名」は、ネットでいくつか実装例をみると、「@gmail.com」を付けないのが多い気がしました。
でも、「@gmail.com」を付けなくても問題なく動作しました。

Yahoo!JAPANのSMTPサーバを使うとエラーになってしまいました。

#>
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
<#

以下は、失敗例です。

#>
# SMTPサーバへの接続ポートに、SSLポート「465」を使用するとエラーになってしまいました。
Send-MailMessage `
  -From $from `
  -To $to `
  -Subject "テストメール" `
  -Body "テストメールです。" `
  -Encoding UTF8 `
  -SmtpServer "smtp.gmail.com" `
  -Port 465 `
  -UseSsl `
  -Credential $credential
#=> 転送接続からデータを読み取れません: net_io_connectionclosed
<#

#>
# 2段階認証を設定しアプリパスワードを払い出していないアカウントを使用した。
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
#=> SMTP サーバーにセキュリティで保護された接続が必要であるか、またはクライアントが認証されていません。 サーバーの応答:5.7.0 Authentication Required.
<#

#>
# Yahoo!JAPANのSMTPサーバを使用
$password = ConvertTo-SecureString "Yahoo!JAPANのパスワード" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential(
  "Yahoo!JAPANのアカウント名", $password)
Send-MailMessage `
  -From $from `
  -To $to `
  -Subject "テストメール" `
  -Body "テストメールです。" `
  -Encoding UTF8 `
  -SmtpServer "smtp.mail.yahoo.co.jp" `
  -Port 465 `
  -UseSsl `
  -Credential $credential
#=> 転送接続からデータを読み取れません: net_io_connectionclosed
