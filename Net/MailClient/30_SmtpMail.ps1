<#

## SmtpMail�N���X

���̕��@�ŁAYahoo!JAPAN��SMTP�T�[�o���g�p���邱�Ƃ��ł��܂����B
Gmail��SMTP�T�[�o�ɂ��ẮASSL�̃|�[�g�u465�v�Ŏg�p�ł��܂������ATLS/STARTTLS�̃|�[�g�u587�v�ł͎g�p�ł��܂���ł����B

SmtpMail�N���X�ł́A�f�[�^�]��������STARTTLS�ł͂Ȃ��ASMTP over SSL�ƂȂ�炵���̂ŁASSL�|�[�g�u465�v�����g�p�ł��Ȃ��̂�������܂���B

#>
Add-Type -AssemblyName System.Web
$to = "���M�惁�[���A�h���X"

# Gmail��SMTP�T�[�o��SSL�|�[�g�u465�v�Ŏg�p
$user = "Gmail�̃A�J�E���g��"
$password = "Gmail�̃p�X���[�h"
$from = "���M����Gmail���[���A�h���X"
$mail = New-Object System.Web.Mail.MailMessage
$mail.From = $from
$mail.To = $to
$mail.Subject = "�e�X�g���[��"
$mail.Body = "�e�X�g���[���ł��B"
$mail.Attachments.Add(
  (New-Object System.Web.Mail.MailAttachment("D:\tmp\dummy.txt", [System.Web.Mail.MailEncoding]::Base64))
  ) | Out-Null
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusing"] = 2 # �O�����[���T�[�o�ւ̐ڑ�
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserver"] = "smtp.gmail.com"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserverport"] = 465
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"] = 1 # 1�FBasic�F�؁A2�FNTLM�F��
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusername"] = $user
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendpassword"] = $password
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpusessl"] = $true # SMTP over SSL
[System.Web.Mail.SmtpMail]::SmtpServer = "smtp.gmail.com"
[System.Web.Mail.SmtpMail]::Send($mail)
<#

#>
# Yahoo!JAPAN��SMTP�T�[�o���g�p
$user = "Yahoo!JAPAN�̃A�J�E���g��"
$password = "Yahoo!JAPAN�̃p�X���[�h"
$from = "���M����Yahoo!JAPAN���[���A�h���X"
$mail = New-Object System.Web.Mail.MailMessage
$mail.From = $from
$mail.To = $to
$mail.Subject = "�e�X�g���[��"
$mail.Body = "�e�X�g���[���ł��B"
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

���́A���s��ł��B

#>
# Gmail��SMTP�T�[�o��TLS/STARTTLS�|�[�g�u587�v�Ŏg�p
$mail = New-Object System.Web.Mail.MailMessage
$mail.From = $from
$mail.To = $to
$mail.Subject = "�e�X�g���[��"
$mail.Body = "�e�X�g���[���ł��B"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusing"] = 2
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserver"] = "smtp.gmail.com"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserverport"] = 587
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"] = 1
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusername"] = $user
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendpassword"] = $password
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpusessl"] = $true
[System.Web.Mail.SmtpMail]::SmtpServer = "smtp.gmail.com"
[System.Web.Mail.SmtpMail]::Send($mail)
#=> "1" �̈������w�肵�� "Send" ���Ăяo�����ɗ�O���������܂���: "�]���ɂ����ăT�[�o�[�ɐڑ��ł��܂���ł����B
<#

#>
# Gmail��SMTP�T�[�o��TLS/STARTTLS�̃|�[�g�u587�v�Ŏg�p�Bsmtpusessl=false
$mail = New-Object System.Web.Mail.MailMessage
$mail.From = $from
$mail.To = $to
$mail.Subject = "�e�X�g���[��"
$mail.Body = "�e�X�g���[���ł��B"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusing"] = 2
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserver"] = "smtp.gmail.com"
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpserverport"] = 587
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"] = 1
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendusername"] = $user
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/sendpassword"] = $password
$mail.Fields["http://schemas.microsoft.com/cdo/configuration/smtpusessl"] = $false
[System.Web.Mail.SmtpMail]::SmtpServer = "smtp.gmail.com"
[System.Web.Mail.SmtpMail]::Send($mail)
#=> "1" �̈������w�肵�� "Send" ���Ăяo�����ɗ�O���������܂���: "�T�[�o�[�ɂ���đ��M�҃A�h���X�����ۂ���܂����B�T�[�o�[����̉����͎��̂Ƃ���ł��B530 5.7.0 Must issue a STARTTLS command first. w1sm5388841pfu.153 - gsmtp"
