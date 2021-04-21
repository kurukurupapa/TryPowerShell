<#

# �R���e���c�̃f�[�^�`��

## HTML

ConvertTo-Html�R�}���h���b�g

- ConvertFrom-Html�͑��݂��Ȃ��B
- [ConvertTo-Html (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertto-html)

#>
# �ȗ�
<#

## XML

.NET Framework �� XmlDocument�N���X���g�p���āAXML�̉�͂�g�ݗ��Ă��s���Ă݂܂����B

- .NET Framework 1.1 �ȍ~�iPowerShell 1.0 �ȍ~�j
- [XmlDocument �N���X (System.Xml) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.xml.xmldocument)

#>
# XML�I�u�W�F�N�g�̍쐬
$doc = New-Object System.Xml.XmlDocument
$doc.AppendChild($doc.CreateXmlDeclaration("1.0", "utf-8", $null)) | Out-Null
$root = $doc.AppendChild($doc.CreateElement("Root"))
$item1 = $root.AppendChild($doc.CreateElement("Item1"))
$item1.AppendChild($doc.CreateTextNode("text")) | Out-Null
# ������\��
Write-Output $doc.OuterXml
# �t�@�C���ɕۑ��iBOM�t��UTF8�j
$doc.Save('D:\tmp\tmp.xml')

# XML������̓ǂݍ���
$doc = [Xml]'<?xml version="1.0" encoding="utf-8"?><Root><Item1>text</Item1></Root>'
$doc = [System.Xml.XmlDocument]'<?xml version="1.0" encoding="utf-8"?><Root><Item1>text</Item1></Root>'
Write-Output $doc.Root.Item1 

# XML�t�@�C������ǂݍ��� 
$doc = New-Object System.Xml.XmlDocument 
$doc.Load('D:\tmp\tmp.xml') 
Write-Output $doc.Root.Item1
<#

## JSON

ConvertFrom-Json�R�}���h���b�g�AConvertTo-Json�R�}���h���b�g�𗘗p���܂����B

- PowerShell 3.0 �ȍ~
- [ConvertFrom-Json (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertfrom-json)
- [ConvertTo-Json (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertto-json)

#>
# �I�u�W�F�N�g��JSON������ɕϊ��BDepth�̍ő�l��100
$jsonstr = ConvertTo-Json @{Key1="value1";Key2='���{�� �L��''"{}<>'} -Depth 100
# JSON��������I�u�W�F�N�g�ɕϊ�
$jsonobj = ConvertFrom-Json '{"Key1":"value1","Key2":"���{�� �L��''\"{}<>"}' 
# MakeMd SKIP_START
$jsonstr
$jsonobj
# MakeMd SKIP_END
