<#

# HTTPクライアント

HTTPアクセスするためのクライアント機能は、Invoke-WebRequestコマンドレット、Invoke-RestMethodコマンドレットとして提供されていました。
ただし、PowerShell 3.0 以降です。
古い環境では、これらのコマンドレットが使えないので、替わりに .NET Framework を使うことで、実現できました。

主要コマンドレット/クラス

- Invoke-WebRequestコマンドレット：PowerShell 3.0 以降
- Invoke-RestMethodコマンドレット：PowerShell 3.0 以降
- HttpClientクラス：.NET Framework 4.5 以降（なので、PowerShell 4.0 以降。Invoke-WebRequest/Invoke-RestMethodコマンドレットで概ね同じことができると思ったので今回未使用。）
- WebClientクラス：.NET Framework 1.1 以降（なので、どのPowerShellバージョンでも使用可能。HttpWebRequest/HttpWebResponseクラスより少し便利。）
- HttpWebRequest/HttpWebResponseクラス：.NET Framework 1.1 以降（なので、どのPowerShellバージョンでも使用可能。WebClientクラスより細かいことができる。）

上記のように、HTTPアクセスするためのコマンドレットやクラスが色々用意されています。
正直、どれを使えばよいのか迷ってしまったのですが、一通り触ってみて、次のように使い分ければよいのかな、と思いました。

- PowerShell 3.0 以降の環境
  - APIをコールするなら、Invoke-RestMethodコマンドレット
  - Webページを取得するなら、Invoke-WebRequestコマンドレット
- PowerShell 2.0 以前の環境
  - 基本、WebClientクラス
  - リクエスト/レスポンスを細かく制御したいなら、HttpWebRequest/HttpWebResponseクラス

## Invoke-WebRequestコマンドレット GETメソッド

例：Google検索（GETメソッド、KeyValue風リクエスト、HTMLレスポンス）

#>
$url = 'https://www.google.com/search'
$params = @{"q"="Powershell"}

# 方式１．コンテンツをレスポンスオブジェクトとして取得
$res = Invoke-WebRequest $url -Body $params
# MakeMd SKIP_START
$res.GetType().FullName  #=> "Microsoft.PowerShell.Commands.HtmlWebResponseObject"
$res.StatusCode.ToString() + " " + $res.StatusDescription 
$res.Headers
$res.Content.Substring(0, 1000) #先頭だけ表示してみる
# MakeMd SKIP_END

# 方式２．コンテンツをファイルに保存
Invoke-WebRequest $url -Body $params -OutFile 'D:\tmp\out.txt'
# MakeMd SKIP_START
Get-Content 'D:\tmp\out.txt' | Select-Object -First 5
# MakeMd SKIP_END

# 補足．エラー考慮
try {
  $res = Invoke-WebRequest 'https://www.google.com/存在しないページ'
  $res.StatusCode.ToString() + " " + $res.StatusDescription 
  $res.Headers
  $res.Content
} catch {
  # ステータスコード
  echo $_.Exception.Response.StatusCode.value__
  # レスポンスボディ
  $stream = $_.Exception.Response.GetResponseStream()
  $reader = New-Object System.IO.StreamReader $stream
  $reader.BaseStream.Position = 0
  $reader.DiscardBufferedData()
  echo $reader.ReadToEnd()
  $reader.Close()  # Closeは$readerと$streamの一方を呼び出せばよい。両方呼び出しても害はない
  $stream.Close()
}

# 補足．レスポンスHTMLを解析
$res = Invoke-WebRequest 'https://weather.yahoo.co.jp/weather/jp/13/4410.html'
$res.ParsedHtml.title
$res.ParsedHtml.getElementById("wrnrpt").innerText
$res.ParsedHtml.getElementsByName("description") | %{ $_.GetAttribute("content") }
$res.ParsedHtml.getElementsByTagName("title") | %{ $_.innerText }
<#

- Invoke-WebRequestに、-SessionVariableパラメータを設定するとセッション情報を変数に保存できて、次のInvoke-WebRequest実行時に、-WebSessionパラメータを設定してセッション情報を引き継いだアクセスができるらしい。

例：Yahoo! JAPAN 日本語形態素解析WebAPI（GETメソッド、KeyValue風リクエスト、XMLレスポンス）

#>
$clientid = "あなたの Yahoo! JAPAN WebAPI 用クライアントID を設定する"
$url = "https://jlp.yahooapis.jp/MAService/V1/parse"
$params = @{
  "appid" = $clientid;
  "results" = "ma,uniq";
  "uniq_filter" = "9|10";
  "sentence" = "庭には二羽ニワトリがいる。"}
$res = Invoke-WebRequest $url -Body $params
$xmlobj = [Xml]$res.Content
$xmlobj.OuterXml
<#

## Invoke-WebRequestコマンドレット POSTメソッド

例：Yahoo! JAPAN 日本語形態素解析WebAPI（POSTメソッド、KeyValue風リクエスト、XMLレスポンス）

#>
$url = "https://jlp.yahooapis.jp/MAService/V1/parse" 
$headers = @{
  "User-Agent" = "Yahoo AppID: $clientid";
  "Content-Type" = "application/x-www-form-urlencoded"}

# 方式１．POSTデータを文字列で指定。
$poststr = "results=ma,uniq" +
  "&uniq_filter=" + [System.Web.HttpUtility]::UrlEncode("9|10") +
  "&sentence=" + [System.Web.HttpUtility]::UrlEncode("庭には二羽ニワトリがいる。")
$res = Invoke-WebRequest $url -Method 'POST' -Headers $headers -Body $poststr
$xmlobj = [Xml]$res.Content
$xmlobj.OuterXml

# 方式２．POSTデータを連想配列で指定。自動でURLエンコードされる。
$params = @{
  "results" = "ma,uniq"; 
  "uniq_filter" = "9|10"; 
  "sentence" = "庭には二羽ニワトリがいる。"}
$res = Invoke-WebRequest $url -Method 'POST' -Headers $headers -Body $params
$xmlobj = [Xml]$res.Content
$xmlobj.OuterXml
<#

例：日本語係り受け解析（POSTメソッド、JSONリクエスト/レスポンス）

#>
$url = 'https://jlp.yahooapis.jp/DAService/V2/parse'
$headers = @{
  "User-Agent" = "Yahoo AppID: $clientid";
  "Content-Type" = "application/x-www-form-urlencoded"}
# JSONリクエスト。もしASCII文字だけならエンコード不要。
$poststr = ConvertTo-Json @{
  id="123"; jsonrpc="2.0"; method="jlp.daservice.parse";
  params=@{q="うちの庭には二羽鶏がいます"}}
$postbytes = [System.Text.Encoding]::UTF8.GetBytes($poststr)
$res = Invoke-WebRequest $url -Method 'POST' -Headers $headers -Body $postbytes
$jsonobj = ConvertFrom-Json $res.Content
Write-Output (ConvertTo-Json $jsonobj -Depth 100)
