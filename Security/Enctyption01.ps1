# �Í���/������
# [�yPowershell�zSecureString�̈Í����E������ | �ЂƂ育��2.0](https://atori.xyz/archives/134)
# [senkousya/usingEncryptedStandardStringOnPowershell: Windows PowerShell�ŕ�����̈Í����ƕ�����](https://github.com/senkousya/usingEncryptedStandardStringOnPowershell)


# PowerShell�̔F�؏��I�u�W�F�N�g�iPsCredential�j���쐬
$password = ConvertTo-SecureString "password123" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PsCredential("username123", $password)
# ���̂悤�ɂ���ƁA���̓_�C�A���O/�v�����v�g��\�����āA���[�U���ƃp�X���[�h���擾�ł���B
$credential = Get-Credential


# key�𖾎��I�Ɏw�肹���ADPAPI (Data Protection Application Programming Interface) �ňÍ���
# �R�}���h�����s���̃��[�U�[�̂ݕ������\
$encryptedString = ConvertFrom-SecureString -SecureString $password
# ������
$decryptedSecureString = ConvertTo-SecureString $encryptedString
$decryptedBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($decryptedSecureString)
$decryptedString = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($decryptedBstr)
# ����
$encryptedString
$decryptedString


# key�𖾎��I�Ɏw�肵�āAAES�ňÍ���
# key�̒����́A16, 24, 32 bytes
$encKey = @(1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6)
$encryptedString = ConvertFrom-SecureString -SecureString $password -key $encKey
# ������
$decryptedSecureString = ConvertTo-SecureString $encryptedString -key $encKey
$decryptedBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($decryptedSecureString)
$decryptedString = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($decryptedBstr)
# ����
$encryptedString
$decryptedString
