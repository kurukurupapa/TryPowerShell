<#

# コンテンツのデータ形式

## HTML

ConvertTo-Htmlコマンドレット

- ConvertFrom-Htmlは存在しない。
- [ConvertTo-Html (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertto-html)

#>
# 省略
<#

## XML

.NET Framework の XmlDocumentクラスを使用して、XMLの解析や組み立てを行ってみました。

- .NET Framework 1.1 以降（PowerShell 1.0 以降）
- [XmlDocument クラス (System.Xml) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.xml.xmldocument)

#>
# XMLオブジェクトの作成
$doc = New-Object System.Xml.XmlDocument
$doc.AppendChild($doc.CreateXmlDeclaration("1.0", "utf-8", $null)) | Out-Null
$root = $doc.AppendChild($doc.CreateElement("Root"))
$item1 = $root.AppendChild($doc.CreateElement("Item1"))
$item1.AppendChild($doc.CreateTextNode("text")) | Out-Null
# 文字列表現
Write-Output $doc.OuterXml
# ファイルに保存（BOM付きUTF8）
$doc.Save('D:\tmp\tmp.xml')

# XML文字列の読み込み
$doc = [Xml]'<?xml version="1.0" encoding="utf-8"?><Root><Item1>text</Item1></Root>'
$doc = [System.Xml.XmlDocument]'<?xml version="1.0" encoding="utf-8"?><Root><Item1>text</Item1></Root>'
Write-Output $doc.Root.Item1 

# XMLファイルから読み込み 
$doc = New-Object System.Xml.XmlDocument 
$doc.Load('D:\tmp\tmp.xml') 
Write-Output $doc.Root.Item1
<#

## JSON

ConvertFrom-Jsonコマンドレット、ConvertTo-Jsonコマンドレットを利用しました。

- PowerShell 3.0 以降
- [ConvertFrom-Json (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertfrom-json)
- [ConvertTo-Json (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertto-json)

#>
# オブジェクトをJSON文字列に変換。Depthの最大値は100
$jsonstr = ConvertTo-Json @{Key1="value1";Key2='日本語 記号''"{}<>'} -Depth 100
# JSON文字列をオブジェクトに変換
$jsonobj = ConvertFrom-Json '{"Key1":"value1","Key2":"日本語 記号''\"{}<>"}' 
# MakeMd SKIP_START
$jsonstr
$jsonobj
# MakeMd SKIP_END
