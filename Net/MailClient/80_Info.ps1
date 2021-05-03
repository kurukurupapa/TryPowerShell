<#

# �⑫

## ����m�F��

- Windows 10
- PowerShell 5.1

## �֘A����p��E���

- SMTP
  - �|�[�g 25
- SMTPS (SMTP over SSL)
  - �|�[�g 465
  - TLS (Transport Layer Security)��p����SMTP���Z�L���A�ɂ����@�B
- Transport Layer Security (TLS)
  - [Transport Layer Security - Wikipedia](https://ja.wikipedia.org/wiki/Transport_Layer_Security)
  - 1999�N�� TLS 1.0 �����J����A2020�N���݂̍ŐV�� TLS 1.3�B
- Secure Sockets Layer (SSL)
- STARTTLS
  - [STARTTLS - Wikipedia](https://ja.wikipedia.org/wiki/STARTTLS)
  - �����̒ʐM�v���g�R�����Í����ʐM�Ɋg��������@�̂ЂƂB
  - 2002�N������K�肳��Ă���͗l�B
- Gmail��SMTP�T�[�o
  - [���̃��[�� �v���b�g�t�H�[���� Gmail �̃��[�����`�F�b�N���� - Gmail �w���v](https://support.google.com/mail/answer/7126229)
  - SMTP�T�[�o�Fsmtp.gmail.com�ASSL�̃|�[�g�F465�ATLS/STARTTLS�̃|�[�g�F587
  - �F�؂Ŏg�p����A�J�E���g�ł́A2�i�K�F�؂�ݒ肵�Ă��Ȃ����ƁB�܂��́A2�i�K�F�؂�ݒ肵�Ă���A�J�E���g�ŁA�A�v���p�X���[�h�𕥂��o�����ƁB
- Yahoo!JAPAN��SMTP�T�[�o
  - [���[���\�t�g�ő���M����ɂ́iYahoo!���[���A�h���X�̏ꍇ�j](https://support.yahoo-net.jp/PccMail/s/article/H000007321)
  - [�V�����y�[�W - Yahoo!���[��](https://whatsnewmail.yahoo.co.jp/yahoo/20210119a.html)
  - SMTP�T�[�o�Fsmtp.mail.yahoo.co.jp�ASSL�̃|�[�g�F465
  - 2021/1/19�ŁASMTP�T�[�o�ڑ����̔�Í����|�[�g�i�|�[�g�ԍ� 25, 587�j�̒񋟂��I�������B
  - �F�؂Ŏg�p����A�J�E���g�̃��[���ݒ�ŁA�uIMAP/POP/SMTP�A�N�Z�X�ƃ��[���]���v��SMTP�ݒ��L���ɂ���B

## �Q�l�ɂ����T�C�g

- [Send-MailMessage (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/send-mailmessage)
- [SmtpClient �N���X (System.Net.Mail) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.net.mail.smtpclient)
- [SmtpMail �N���X (System.Web.Mail) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.web.mail.smtpmail)
- [�yPowerShell�zWindows PowerShell ���g�p���� GMail �� Office 365 ���烁�[���𑗐M���� | Microsoft Docs](https://docs.microsoft.com/ja-jp/archive/blogs/junichia/powershellwindows-powershell-gmail-office-365)
- [SMTP�Ń��[���𑗐M���� - .NET Tips (VB.NET,C#...)](https://dobon.net/vb/dotnet/internet/smtpmail.html#section3)
- [SSL/TLS���g�p����SMTP�Ń��[���𑗐M���� - .NET Tips (VB.NET,C#...)](https://dobon.net/vb/dotnet/internet/smtpssltls.html)
- [�yWindows�z���[���[��Web���[�����g�킸�Ƀ��[���𑗐M���� ? �X�C�[�c�D���G���W�j�A�̔��Y�^](https://it-memorandum.net/archives/1024)
#>
