<#

## SmtpMailクラス

この方法で、Yahoo!JAPANのSMTPサーバを使用することができました。
GmailのSMTPサーバについては、SSLのポート「465」で使用できましたが、TLS/STARTTLSのポート「587」では使用できませんでした。

SmtpMailクラスでは、データ転送方式がSTARTTLSではなく、SMTP over SSLとなるらしいので、SSLポート「465」しか使用できないのかもしれません。

#>
Add-Type -AssemblyName System.Web
$to = "送信先メールアドレス"

# GmailのSMTPサーバをSSLポート「465」で使用
$user = "Gmailのアカウント名"
$password = "Gmailのパスワード"
$from = "送信元のGmailメールアドレス"
$mail = New-Object System.Web.Mail.MailMessage
$mail.From = $from
$mail.To = $to
$mail.Subject = "テストメール"
$mail.Body = "テストメールです。"
$mail.Attachments.Add(
  (New-Object System.Web.Mail.MailAttachment("D:\tmp\dummy.txt", [System.Web.Mail.MailEncoding]::Base64))
  ) | Out-Null
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusing"] = 2 # 外部メールサーバへの接続
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserver"] = "smtp.gmail.com"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserverport"] = 465
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"] = 1 # 1：Basic認証、2：NTLM認証
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusername"] = $user
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendpassword"] = $password
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpusessl"] = $true # SMTP over SSL
[System.Web.Mail.SmtpMail]::SmtpServer = "smtp.gmail.com"
[System.Web.Mail.SmtpMail]::Send($mail)
<#

#>
# Yahoo!JAPANのSMTPサーバを使用
$user = "Yahoo!JAPANのアカウント名"
$password = "Yahoo!JAPANのパスワード"
$from = "送信元のYahoo!JAPANメールアドレス"
$mail = New-Object System.Web.Mail.MailMessage
$mail.From = $from
$mail.To = $to
$mail.Subject = "テストメール"
$mail.Body = "テストメールです。"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusing"] = 2
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserver"] = "smtp.mail.yahoo.co.jp"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserverport"] = 465
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"] = 1
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusername"] = $user
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendpassword"] = $password
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpusessl"] = $true
[System.Web.Mail.SmtpMail]::SmtpServer = "smtp.mail.yahoo.co.jp"
[System.Web.Mail.SmtpMail]::Send($mail)
<#

次は、失敗例です。

#>
# GmailのSMTPサーバをTLS/STARTTLSポート「587」で使用
$mail = New-Object System.Web.Mail.MailMessage
$mail.From = $from
$mail.To = $to
$mail.Subject = "テストメール"
$mail.Body = "テストメールです。"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusing"] = 2
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserver"] = "smtp.gmail.com"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserverport"] = 587
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"] = 1
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusername"] = $user
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendpassword"] = $password
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpusessl"] = $true
[System.Web.Mail.SmtpMail]::SmtpServer = "smtp.gmail.com"
[System.Web.Mail.SmtpMail]::Send($mail)
#=> "1" 個の引数を指定して "Send" を呼び出し中に例外が発生しました: "転送においてサーバーに接続できませんでした。
<#

#>
# GmailのSMTPサーバをTLS/STARTTLSのポート「587」で使用。smtpusessl=false
$mail = New-Object System.Web.Mail.MailMessage
$mail.From = $from
$mail.To = $to
$mail.Subject = "テストメール"
$mail.Body = "テストメールです。"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusing"] = 2
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserver"] = "smtp.gmail.com"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserverport"] = 587
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"] = 1
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusername"] = $user
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendpassword"] = $password
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpusessl"] = $false
[System.Web.Mail.SmtpMail]::SmtpServer = "smtp.gmail.com"
[System.Web.Mail.SmtpMail]::Send($mail)
#=> "1" 個の引数を指定して "Send" を呼び出し中に例外が発生しました: "サーバーによって送信者アドレスが拒否されました。サーバーからの応答は次のとおりです。530 5.7.0 Must issue a STARTTLS command first. w1sm5388841pfu.153 - gsmtp"
