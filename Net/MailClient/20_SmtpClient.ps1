<#

## SmtpClient�N���X

�ȉ��̂悤�ɂ��āAGmail��SMTP�T�[�o��TLS/STARTTLS�̃|�[�g�u587�v���g�p�������[�����M���ł��܂����B
�ł����AGmail��SMTP�T�[�o��SSL�̃|�[�g�u465�v���g�p�����ꍇ��AYahoo!JAPAN��SMTP�T�[�o���g�p�����ꍇ�́A�G���[�ƂȂ��Ă��܂��܂����B

Send-MailMessage�R�}���h���b�g�Ƃ̈Ⴂ�́ASend-MailMessage�R�}���h���b�g�����Â����ł����삷�邱�ƁB

#>
$user = "Gmail�̃A�J�E���g��"
$password = "Gmail�̃p�X���[�h"
$from = "���M����Gmail���[���A�h���X"
$to = "���M�惁�[���A�h���X"
$client = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 587)
$client.EnableSsl = $true
$client.Credentials = New-Object System.Net.NetworkCredential($user, $password)
$client.Send($from, $to, "�e�X�g���[��", "�e�X�g���[���ł��B")
$client.Dispose()
<#

���́A���s��ł��B

#>
# Gmail��SMTP�T�[�o��SSL�|�[�g�u465�v
$client = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 465)
$client.EnableSsl = $true
$client.Credentials = New-Object System.Net.NetworkCredential($user, $password)
$client.Send($from, $to, "�e�X�g���[��", "�e�X�g���[���ł��B")
#=> "4" �̈������w�肵�� "Send" ���Ăяo�����ɗ�O���������܂���: "���[���𑗐M�ł��܂���ł����B"
<#

#>
# Yahoo!JAPAN��SMTP�T�[�o
$user = "Yahoo!JAPAN�̃A�J�E���g��"
$password = "Yahoo!JAPAN�̃p�X���[�h"
$from = "���M����Yahoo!JAPAN���[���A�h���X"
$client = New-Object Net.Mail.SmtpClient("smtp.mail.yahoo.co.jp", 465)
$client.EnableSsl = $true
$client.Credentials = New-Object System.Net.NetworkCredential($user, $password)
$client.Send($from, $to, "�e�X�g���[��", "�e�X�g���[���ł��B")
#=> "4" �̈������w�肵�� "Send" ���Ăяo�����ɗ�O���������܂���: "���[���𑗐M�ł��܂���ł����B"
