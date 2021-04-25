<#

# エンコーディング

HTTPアクセスするときに必要となるエンコーディングについて、メモしておきます。

## テキストのエンコーディング

.NET Framwork の Encodingクラスを使用して、テキストのエンコーディングを変更することができました。

- .NET Framework 1.1 以降
- [Encoding クラス (System.Text) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.text.encoding?view=net-5.0)

#>
$enc = [System.Text.Encoding]::UTF8
$enc = [System.Text.Encoding]::GetEncoding("SJIS")
# 指定したエンコーディングに変換した文字列のバイト配列を取得
$bytes = $enc.GetBytes("日本語テキストです")
# バイト配列を指定したエンコーディングとして解釈して文字列を取得
$str = $enc.GetString($bytes)
# MakeMd SKIP_START
# 結果確認
$bytes
$str
# MakeMd SKIP_END
<#

## パーセントエンコーディング

次の2種類がある。

- パーセントエンコーディングによる符号化 ： URLのパス部分を符号化する方式。半角スペースが「%20」となる。RFC3986。
- application/x-www-form-urlencodedによる符号化 ： HTTPのPOSTメソッドで送信する文字列に対する符号化方式。半角スペースが「+」となる。

パーセントエンコーディングによる符号化は、.NET Framework の Uriクラスを使用して、実現できました。

- .NET Framework 2.0 以降（PowerShell 2.0 以降）
- .NET Framework 4.0以前と4.5以降で、エンコード対象の記号が少し異なる。

#>
$url = 'https://www.google.com/search?q=Powershell 日本語'
# 文字列全体をエンコード
$encstr = [Uri]::EscapeDataString($url)      #=> "https%3A%2F%2Fwww.google.com%2Fsearch%3Fq%3DPowershell%20%E6%97%A5%E6%9C%AC%E8%AA%9E"
$decstr = [Uri]::UnescapeDataString($encstr)
# MakeMd SKIP_START
$encstr
$decstr
# MakeMd SKIP_END
# 予約文字以外をエンコード
$encstr = [Uri]::EscapeUriString($url)       #=> "https://www.google.com/search?q=Powershell%20%E6%97%A5%E6%9C%AC%E8%AA%9E"
$decstr = [Uri]::UnescapeDataString($encstr)
# MakeMd SKIP_START
$encstr
$decstr
# MakeMd SKIP_END
<#

application/x-www-form-urlencodedによる符号化は、.NET Framework の HttpUtilityクラスを使用して、実現できました。

- .NET Framework 1.1 以降（PowerShell 1.0 以降）

#>
Add-Type -AssemblyName System.Web
$str = "POSTデータ abc :/?&=<>"
# エンコード。デフォルトでUTF8を使用。必要なら第2引数にEncodingを指定する。
$encstr = [System.Web.HttpUtility]::UrlEncode($str)  #=> "POST%e3%83%87%e3%83%bc%e3%82%bf+abc+%3a%2f%3f%26%3d%3c%3e"
# デコード。デフォルトでUTF8を使用。必要なら第2引数にEncodingを指定する。
$decstr = [System.Web.HttpUtility]::UrlDecode($encstr)
# MakeMd SKIP_START
$encstr
$decstr
# MakeMd SKIP_END
