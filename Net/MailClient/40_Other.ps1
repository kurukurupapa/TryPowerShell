<#

# ���[�����M�Ɋ֘A���鏈��

## SMTP�T�[�o�F�؏����Í������ăt�@�C���Ǘ�

�R�[�h���ɔF�؏����܂߂Ă��܂��ƁA�Z�L�����e�B�I�ɖ�肪����̂ŁA�Í������ăt�@�C���ۊǂ�����@���������Ă����܂��B
Get-Credential�AConvertFrom-SecureString�AConvertTo-SecureString�R�}���h���b�g���g�p���܂����B

#>
# �t�@�C���ۑ�
$path = "D:\tmp\password.json"
$credential = Get-Credential
ConvertTo-Json @{
  userId = $credential.UserName;
  password = $credential.Password | ConvertFrom-SecureString;
  } | Set-Content $path

# �t�@�C���ǂݍ���
$jsonObj = Get-Content $path | ConvertFrom-Json
$password = $jsonObj.password | ConvertTo-SecureString
$credential = New-Object System.management.Automation.PsCredential($jsonObj.userId, $password)

# ���[�����M
$from = "���M����Gmail���[���A�h���X"
$to = "���M�惁�[���A�h���X"
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
<#

## SMTP�T�[�o�̃|�[�g�m�F

���[�����M�����ŃG���[���o���Ƃ��A�|�[�g���J���Ă��邱�Ƃ��m�F���邽�߂ɂ́A���̃R�}���h���b�g���g���܂����B

#>
Test-NetConnection "smtp.gmail.com" -port 465         # OK
Test-NetConnection "smtp.gmail.com" -port 587         # OK
Test-NetConnection "smtp.mail.yahoo.co.jp" -port 465  # OK
Test-NetConnection "smtp.mail.yahoo.co.jp" -port 587  # NG
Test-NetConnection "smtp.mail.yahoo.co.jp" -port 25   # NG
