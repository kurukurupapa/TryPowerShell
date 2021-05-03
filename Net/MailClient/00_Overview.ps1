<#
# はじめに

PowerShellからメール送信ができるのか気になりました。
まあ、できるんでしょうけど、実際に手を動かして体験してみたかったので、調べてみました。
GmailのSMTPサーバを利用したメール送信は、簡単に実現できましたが、Yahoo!JAPANのSMTPサーバを利用したメール送信に苦労したので、メモを残しておきます。

PowerShell でメール送信を実現するための、主要なコマンドレットやクラスは、次を利用しました。
Microsoftのサイトを見ると、どれも非推奨になっていたけど、他の選択肢が限られるので、使ってみました。

- Send-MailMessageコマンドレット
  - [Send-MailMessage (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/send-mailmessage)
  - 当コマンドレットの-Portオプションを使うには、PowerShell 3.0 以降が必要。
  - GmailのSMTPサーバを利用可能。Yahoo!JAPANのSMTPサーバを使うことはできなかった。
- SmtpClientクラス
  - [SmtpClient クラス (System.Net.Mail) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.net.mail.smtpclient)
  - .NET Framework 2.0 以降（なので PowerShell 2.0 以降）
  - データ転送方式は、STARTTLSのみで、SMTP over SSLには対応していないらしい。
  - GmailのSMTPサーバを利用可能。Yahoo!JAPANのSMTPサーバを使うことはできなかった。
- SmtpMailクラス
  - [SmtpMail クラス (System.Web.Mail) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.web.mail.smtpmail)
  - .NET Framework 1.1 以降（なので PowerShell 1.0 以降）で使用可能だが、使用を推奨されていない。
  - データ転送方式は、STARTTLSではなく、SMTP over SSLとなるらしい。
  - GmailとYahoo!JAPANのSMTPサーバを利用可能。
#>
