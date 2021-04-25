<#

# コンテンツのデータ形式

HTTPレスポンスで受信するコンテンツのデータ形式について、メモしておきます。
JSONはリクエスト時にも使用する場合あり。
もしかすると、XMLでリクエストすることもあり得るかも。

## HTML

ConvertTo-Htmlコマンドレット

- ConvertFrom-Htmlは存在しない。
- [ConvertTo-Html (Microsoft.PowerShell.Utility) - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/convertto-html)

COMを使用して、HTMLをパースする方法です。

#>
$sample = "<html><head><title>サンプル</title></head>" +
  "<body><span id='text1' name='text1'>サンプルページです。</span></body></html>"
$html = New-Object -com "HTMLFILE"
$html.IHTMLDocument2_write($sample)
$html.Close()
echo $html.title
echo $html.getElementById("text1").innerText
$html.getElementsByName("text1") | %{ echo $_.innerText }
$html.getElementsByTagName("span") | %{ echo $_.innerText }
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
$jsonstr = ConvertTo-Json -Depth 100 @{
  Number = 123;
  String = '日本語 記号''"{}<>';
  DateTimeStr = Get-Date -Format "yyyy/MM/dd HH:mm:ss";
  Array = @(1,2,3);
  Hash = @{Key1="value1"; Key2="value2"};
  Null = $null;
}
# JSON文字列をオブジェクトに変換
$jsonobj = ConvertFrom-Json '{"Number":123, "String":"日本語 記号''\"{}<>", "DateTimeStr":"2021/1/1 01:02:03", "Array":[1,2,3], "Hash":{"Key1":"value1", "Key2":"value2"}, "Null":null}'
# MakeMd SKIP_START
$jsonstr
$jsonobj
# MakeMd SKIP_END
<#

上記だと、PowerShell 3.0 以降でないと動作しないので、古い環境でも動作するように、簡易的な関数を考えてみました。
ただし、ハッシュデータをJSON文字列に変換する関数のみ。その逆の変換は、手間がかかりそうなので割愛。

#>
function ConvertToJson($data) {
  if ($data -is [string]) {
    '"' + $data + '"'
  } elseif ($data -is [Array]) {
    $arr = $data | %{
      ConvertToJson $_
    }
    '[' + ($arr -join ', ') + ']'
  } elseif ($data -is [Hashtable]) {
    $arr = $data.GetEnumerator() | sort Key | %{
      '"' + $_.Key + '": ' + (ConvertToJson $_.Value)
    }
    '{' + ($arr -join ', ') + '}'
  } else {
    $data
  }
}
$hash = @{
  Number = 123;
  String = "abc";
  Array = @(1,2,3,@(4,5));
  Hash = @{Key1="value1"; Key2="value2"};
}
$jsonstr = ConvertToJson $hash
# MakeMd SKIP_START
$jsonstr
# MakeMd SKIP_END
