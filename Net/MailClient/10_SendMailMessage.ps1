<#

# ���[�����M�̎���

## Send-MailMessage�R�}���h���b�g

���L�̂悤�ɋL�q���āAGmail��SMTP�T�[�o�𗘗p�������[�����M���ł��܂����B

SMTP�T�[�o�ւ̐ڑ��|�[�g�́ATLS/STARTTLS�̃|�[�g�u587�v���g�p���܂����B
SSL�̃|�[�g�u465�v���ƁA�G���[�ɂȂ��Ă��܂��܂����B
���̏������������̂��ASend-MailMessage�R�}���h���b�g���Ή����Ă��Ȃ��̂��A�����͕�����܂���B

SMTP�T�[�o�ڑ��̔F�؏��Ƃ��ė��p����Gmail�̃A�J�E���g�ł����A����2�p�^�[���ŗ��p�\�ł����B

- 2�i�K�F�؂�ݒ肳��Ă��Ȃ��A�J�E���g���g�p����B
- 2�i�K�F�؂�ݒ肵�Ă���A�J�E���g�ŁA�A�v���p�X���[�h�𕥂��o���A���L�R�[�h�̔F�؏��̃p�X���[�h�ɐݒ肷��B

�F�؏��Ƃ��Đݒ肷�鉺�L�uGmail�̃A�J�E���g���v�́A�l�b�g�ł�������������݂�ƁA�u@gmail.com�v��t���Ȃ��̂������C�����܂����B
�ł��A�u@gmail.com�v��t���Ȃ��Ă����Ȃ����삵�܂����B

Yahoo!JAPAN��SMTP�T�[�o���g���ƃG���[�ɂȂ��Ă��܂��܂����B

#>
$password = ConvertTo-SecureString "Gmail�̃p�X���[�h" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential(
  "Gmail�̃A�J�E���g��", $password)
$from = "���M����Gmail���[���A�h���X"
$to = "���M�惁�[���A�h���X"
Send-MailMessage `
  -From $from `
  -To $to `
  -Subject "�e�X�g���[��" `
  -Body "�e�X�g���[���ł��B" `
  -Attachments "D:\tmp\dummy.txt" `
  -Encoding UTF8 `
  -SmtpServer "smtp.gmail.com" `
  -Port 587 `
  -UseSsl `
  -Credential $credential
<#

�ȉ��́A���s��ł��B

#>
# SMTP�T�[�o�ւ̐ڑ��|�[�g�ɁASSL�|�[�g�u465�v���g�p����ƃG���[�ɂȂ��Ă��܂��܂����B
Send-MailMessage `
  -From $from `
  -To $to `
  -Subject "�e�X�g���[��" `
  -Body "�e�X�g���[���ł��B" `
  -Encoding UTF8 `
  -SmtpServer "smtp.gmail.com" `
  -Port 465 `
  -UseSsl `
  -Credential $credential
#=> �]���ڑ�����f�[�^��ǂݎ��܂���: net_io_connectionclosed
<#

#>
# 2�i�K�F�؂�ݒ肵�A�v���p�X���[�h�𕥂��o���Ă��Ȃ��A�J�E���g���g�p�����B
Send-MailMessage `
  -From $from `
  -To $to `
  -Subject "�e�X�g���[��" `
  -Body "�e�X�g���[���ł��B" `
  -Encoding UTF8 `
  -SmtpServer "smtp.gmail.com" `
  -Port 587 `
  -UseSsl `
  -Credential $credential
#=> SMTP �T�[�o�[�ɃZ�L�����e�B�ŕی삳�ꂽ�ڑ����K�v�ł��邩�A�܂��̓N���C�A���g���F�؂���Ă��܂���B �T�[�o�[�̉���:5.7.0 Authentication Required.
<#

#>
# Yahoo!JAPAN��SMTP�T�[�o���g�p
$password = ConvertTo-SecureString "Yahoo!JAPAN�̃p�X���[�h" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential(
  "Yahoo!JAPAN�̃A�J�E���g��", $password)
Send-MailMessage `
  -From $from `
  -To $to `
  -Subject "�e�X�g���[��" `
  -Body "�e�X�g���[���ł��B" `
  -Encoding UTF8 `
  -SmtpServer "smtp.mail.yahoo.co.jp" `
  -Port 465 `
  -UseSsl `
  -Credential $credential
#=> �]���ڑ�����f�[�^��ǂݎ��܂���: net_io_connectionclosed
