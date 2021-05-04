# 暗号化/復号化
# [【Powershell】SecureStringの暗号化・復号化 | ひとりごと2.0](https://atori.xyz/archives/134)
# [senkousya/usingEncryptedStandardStringOnPowershell: Windows PowerShellで文字列の暗号化と復号化](https://github.com/senkousya/usingEncryptedStandardStringOnPowershell)


# PowerShellの認証情報オブジェクト（PsCredential）を作成
$password = ConvertTo-SecureString "password123" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PsCredential("username123", $password)
# 次のようにすると、入力ダイアログ/プロンプトを表示して、ユーザ名とパスワードを取得できる。
$credential = Get-Credential


# keyを明示的に指定せず、DPAPI (Data Protection Application Programming Interface) で暗号化
# コマンドを実行時のユーザーのみ復号化可能
$encryptedString = ConvertFrom-SecureString -SecureString $password
# 復号化
$decryptedSecureString = ConvertTo-SecureString $encryptedString
$decryptedBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($decryptedSecureString)
$decryptedString = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($decryptedBstr)
# 結果
$encryptedString
$decryptedString


# keyを明示的に指定して、AESで暗号化
# keyの長さは、16, 24, 32 bytes
$encKey = @(1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6)
$encryptedString = ConvertFrom-SecureString -SecureString $password -key $encKey
# 復号化
$decryptedSecureString = ConvertTo-SecureString $encryptedString -key $encKey
$decryptedBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($decryptedSecureString)
$decryptedString = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($decryptedBstr)
# 結果
$encryptedString
$decryptedString
