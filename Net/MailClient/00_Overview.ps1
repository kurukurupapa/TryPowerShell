<#
# �͂��߂�

PowerShell���烁�[�����M���ł���̂��C�ɂȂ�܂����B
�܂��A�ł����ł��傤���ǁA���ۂɎ�𓮂����đ̌����Ă݂��������̂ŁA���ׂĂ݂܂����B
Gmail��SMTP�T�[�o�𗘗p�������[�����M�́A�ȒP�Ɏ����ł��܂������AYahoo!JAPAN��SMTP�T�[�o�𗘗p�������[�����M�ɋ�J�����̂ŁA�������c���Ă����܂��B

PowerShell �Ń��[�����M���������邽�߂́A��v�ȃR�}���h���b�g��N���X�́A���𗘗p���܂����B
Microsoft�̃T�C�g������ƁA�ǂ���񐄏��ɂȂ��Ă������ǁA���̑I������������̂ŁA�g���Ă݂܂����B

- Send-MailMessage�R�}���h���b�g
  - [Send-MailMessage (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/send-mailmessage)
  - ���R�}���h���b�g��-Port�I�v�V�������g���ɂ́APowerShell 3.0 �ȍ~���K�v�B
  - Gmail��SMTP�T�[�o�𗘗p�\�BYahoo!JAPAN��SMTP�T�[�o���g�����Ƃ͂ł��Ȃ������B
- SmtpClient�N���X
  - [SmtpClient �N���X (System.Net.Mail) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.net.mail.smtpclient)
  - .NET Framework 2.0 �ȍ~�i�Ȃ̂� PowerShell 2.0 �ȍ~�j
  - �f�[�^�]�������́ASTARTTLS�݂̂ŁASMTP over SSL�ɂ͑Ή����Ă��Ȃ��炵���B
  - Gmail��SMTP�T�[�o�𗘗p�\�BYahoo!JAPAN��SMTP�T�[�o���g�����Ƃ͂ł��Ȃ������B
- SmtpMail�N���X
  - [SmtpMail �N���X (System.Web.Mail) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.web.mail.smtpmail)
  - .NET Framework 1.1 �ȍ~�i�Ȃ̂� PowerShell 1.0 �ȍ~�j�Ŏg�p�\�����A�g�p�𐄏�����Ă��Ȃ��B
  - �f�[�^�]�������́ASTARTTLS�ł͂Ȃ��ASMTP over SSL�ƂȂ�炵���B
  - Gmail��Yahoo!JAPAN��SMTP�T�[�o�𗘗p�\�B
#>
