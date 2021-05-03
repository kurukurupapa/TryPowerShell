<#

# 補足

## 動作確認環境

- Windows 10
- PowerShell 5.1

## 関連する用語・情報

- SMTP
  - ポート 25
- SMTPS (SMTP over SSL)
  - ポート 465
  - TLS (Transport Layer Security)を用いてSMTPをセキュアにする手法。
- Transport Layer Security (TLS)
  - [Transport Layer Security - Wikipedia](https://ja.wikipedia.org/wiki/Transport_Layer_Security)
  - 1999年に TLS 1.0 が公開され、2020年現在の最新は TLS 1.3。
- Secure Sockets Layer (SSL)
- STARTTLS
  - [STARTTLS - Wikipedia](https://ja.wikipedia.org/wiki/STARTTLS)
  - 平文の通信プロトコルを暗号化通信に拡張する方法のひとつ。
  - 2002年頃から規定されている模様。
- GmailのSMTPサーバ
  - [他のメール プラットフォームで Gmail のメールをチェックする - Gmail ヘルプ](https://support.google.com/mail/answer/7126229)
  - SMTPサーバ：smtp.gmail.com、SSLのポート：465、TLS/STARTTLSのポート：587
  - 認証で使用するアカウントでは、2段階認証を設定していないこと。または、2段階認証を設定しているアカウントで、アプリパスワードを払い出すこと。
- Yahoo!JAPANのSMTPサーバ
  - [メールソフトで送受信するには（Yahoo!メールアドレスの場合）](https://support.yahoo-net.jp/PccMail/s/article/H000007321)
  - [新着情報ページ - Yahoo!メール](https://whatsnewmail.yahoo.co.jp/yahoo/20210119a.html)
  - SMTPサーバ：smtp.mail.yahoo.co.jp、SSLのポート：465
  - 2021/1/19で、SMTPサーバ接続時の非暗号化ポート（ポート番号 25, 587）の提供が終了した。
  - 認証で使用するアカウントのメール設定で、「IMAP/POP/SMTPアクセスとメール転送」のSMTP設定を有効にする。

## 参考にしたサイト

- [Send-MailMessage (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/send-mailmessage)
- [SmtpClient クラス (System.Net.Mail) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.net.mail.smtpclient)
- [SmtpMail クラス (System.Web.Mail) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.web.mail.smtpmail)
- [【PowerShell】Windows PowerShell を使用して GMail や Office 365 からメールを送信する | Microsoft Docs](https://docs.microsoft.com/ja-jp/archive/blogs/junichia/powershellwindows-powershell-gmail-office-365)
- [SMTPでメールを送信する - .NET Tips (VB.NET,C#...)](https://dobon.net/vb/dotnet/internet/smtpmail.html#section3)
- [SSL/TLSを使用してSMTPでメールを送信する - .NET Tips (VB.NET,C#...)](https://dobon.net/vb/dotnet/internet/smtpssltls.html)
- [【Windows】メーラーやWebメールを使わずにメールを送信する ? スイーツ好きエンジニアの備忘録](https://it-memorandum.net/archives/1024)
#>
