<#

## SmtpClientクラス

以下のようにして、GmailのSMTPサーバでTLS/STARTTLSのポート「587」を使用したメール送信ができました。
ですが、GmailのSMTPサーバでSSLのポート「465」を使用した場合や、Yahoo!JAPANのSMTPサーバを使用した場合は、エラーとなってしまいました。

Send-MailMessageコマンドレットとの違いは、Send-MailMessageコマンドレットよりも古い環境でも動作すること。

#>
$user = "Gmailのアカウント名"
$password = "Gmailのパスワード"
$from = "送信元のGmailメールアドレス"
$to = "送信先メールアドレス"
$client = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 587)
$client.EnableSsl = $true
$client.Credentials = New-Object System.Net.NetworkCredential($user, $password)
$client.Send($from, $to, "テストメール", "テストメールです。")
$client.Dispose()
<#

次は、失敗例です。

#>
# GmailのSMTPサーバでSSLポート「465」
$client = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 465)
$client.EnableSsl = $true
$client.Credentials = New-Object System.Net.NetworkCredential($user, $password)
$client.Send($from, $to, "テストメール", "テストメールです。")
#=> "4" 個の引数を指定して "Send" を呼び出し中に例外が発生しました: "メールを送信できませんでした。"
<#

#>
# Yahoo!JAPANのSMTPサーバ
$user = "Yahoo!JAPANのアカウント名"
$password = "Yahoo!JAPANのパスワード"
$from = "送信元のYahoo!JAPANメールアドレス"
$client = New-Object Net.Mail.SmtpClient("smtp.mail.yahoo.co.jp", 465)
$client.EnableSsl = $true
$client.Credentials = New-Object System.Net.NetworkCredential($user, $password)
$client.Send($from, $to, "テストメール", "テストメールです。")
#=> "4" 個の引数を指定して "Send" を呼び出し中に例外が発生しました: "メールを送信できませんでした。"
