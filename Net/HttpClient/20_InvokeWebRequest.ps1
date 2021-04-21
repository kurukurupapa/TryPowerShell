<#

# HTTPクライアント

HTTPアクセスするためのクライアント機能は、Invoke-WebRequestコマンドレット、Invoke-RestMethodコマンドレットとして提供されていました。
ただし、PowerShell 3.0 以降です。
古い環境では、これらのコマンドレットが使えないので、替わりに .NET Framework を使うことで、実現できました。

主要コマンドレット/クラス

- Invoke-WebRequestコマンドレット：PowerShell 3.0 以降
- Invoke-RestMethodコマンドレット：PowerShell 3.0 以降
- System.Net.Http.HttpClientクラス：.NET Framework 4.5 以降（なので、PowerShell 4.0 以降）
- System.Net.WebClientクラス：.NET Framework 1.1 以降（なので、どのPowerShellバージョンでも使用可能）

## Invoke-WebRequestコマンドレット GETメソッド

例：Google検索

#>
$url = 'https://www.google.com/search'
$params = @{"q"="Powershell"}

# 方式１．コンテンツをレスポンスオブジェクトとして取得
$res = Invoke-WebRequest $url -Body $params
# MakeMd SKIP_START
$res.StatusCode.ToString() + " " + $res.StatusDescription 
$res.Headers
$res.Content.Substring(0, 1000)
# MakeMd SKIP_END

# 方式２．コンテンツをファイルに保存
Invoke-WebRequest $url -Body $params -OutFile 'D:\tmp\out.txt'
# MakeMd SKIP_START
Get-Content 'D:\tmp\out.txt' | Select-Object -First 5
# MakeMd SKIP_END

# 方式３．エラー考慮
try {
  $res = Invoke-WebRequest $url -Body $params 
  $res.StatusCode.ToString() + " " + $res.StatusDescription 
  $res.Headers
  $res.Content
} catch {
  $error[0].Exception.Response.StatusCode.value__
}
<#

例：Yahoo! JAPAN 日本語形態素解析WebAPI（GET）

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

例：Yahoo! JAPAN 日本語形態素解析WebAPI（POST）

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

例：日本語係り受け解析（POSTメソッド、JSONリクエスト）

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
<#

## Invoke-RestMethodコマンドレット GETメソッド

例：Yahoo! JAPAN 日本語形態素解析WebAPI（GET）

#>
$url = "https://jlp.yahooapis.jp/MAService/V1/parse"
$params = @{
  "appid" = $clientid;
  "results" = "ma,uniq";
  "uniq_filter" = "9|10";
  "sentence" = "庭には二羽ニワトリがいる。"}
$xmldoc = Invoke-RestMethod $url -Body $params
Write-Output $xmldoc.OuterXml

# エラーを考慮する場合
try {
  $xmldoc = Invoke-RestMethod $url -Body $params
  Write-Output $xmldoc.OuterXml
} catch {
  $error[0].Exception.Response.StatusCode.value__
}
<#

## Invoke-RestMethodコマンドレット POSTメソッド

例：Yahoo! JAPAN 日本語形態素解析WebAPI（POST）

#>
$url = "https://jlp.yahooapis.jp/MAService/V1/parse" 
$headers = @{
  "User-Agent" = "Yahoo AppID: $clientid";
  "Content-Type" = "application/x-www-form-urlencoded"}

# 方式１．POSTデータを文字列で指定。
$poststr = "results=ma,uniq" +
  "&uniq_filter=" + [System.Web.HttpUtility]::UrlEncode("9|10") +
  "&sentence=" + [System.Web.HttpUtility]::UrlEncode("庭には二羽ニワトリがいる。")
$xmldoc = Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body $poststr
Write-Output $xmldoc.OuterXml

# 方式２．POSTデータを連想配列で指定。自動でURLエンコードされる。
$params = @{
  "results" = "ma,uniq"; 
  "uniq_filter" = "9|10"; 
  "sentence" = "庭には二羽ニワトリがいる。"}
$xmldoc = Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body $params
Write-Output $xmldoc.OuterXml
<#

例：日本語係り受け解析（POSTメソッド、JSONリクエスト）

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
$res = Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body $postbytes
Write-Output (ConvertTo-Json $res -Depth 100)
<#

## WebClientクラス GETメソッド

例：Google検索

#>
$url = 'https://www.google.com/search'
$wc = New-Object System.Net.WebClient 
$wc.QueryString.Add("q", "Powershell")

# 方式１．コンテンツを取得し保存。テキストのエンコード変換なしの模様。 
$wc.DownloadFile($url, 'D:\tmp\out.txt')

# 方式２．コンテンツをバイト配列として取得 
$resbytes = $wc.DownloadData($url) 

# 方式３．コンテンツを文字列として取得。必要なら$wc.Encodingにエンコードを指定する。 
$resstr = $wc.DownloadString($url)

# エラーを考慮する場合
try {
  $resstr = $wc.DownloadString($url)
} catch {
  $error[0].Exception.InnerException.Response.StatusCode.value__
}

# 後片付け 
$wc.Dispose()
<#

例：Yahoo! JAPAN 日本語形態素解析WebAPI（GET）

#>
$url = "https://jlp.yahooapis.jp/MAService/V1/parse"
$wc = New-Object System.Net.WebClient
$wc.Encoding = [System.Text.Encoding]::UTF8
$wc.QueryString.Add("appid", $clientid)
$wc.QueryString.Add("results", "ma,uniq")
$wc.QueryString.Add("uniq_filter", "9|10")
$wc.QueryString.Add("sentence", "庭には二羽ニワトリがいる。")
$resstr = $wc.DownloadString($url)
$wc.Dispose()
Write-Output $resstr
<#

## WebClientクラス POSTメソッド

例：Yahoo! JAPAN 日本語形態素解析WebAPI（POST）

#>
Add-Type -AssemblyName System.Web
$url = "https://jlp.yahooapis.jp/MAService/V1/parse"
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Yahoo AppID: $clientid")
$wc.Headers.Add("Content-Type", "application/x-www-form-urlencoded")
$wc.Encoding = [System.Text.Encoding]::UTF8

# 方式１．POSTデータを文字列で設定
$poststr = "results=ma,uniq" +  
  "&uniq_filter=" + [System.Web.HttpUtility]::UrlEncode("9|10") + 
  "&sentence=" + [System.Web.HttpUtility]::UrlEncode("庭には二羽ニワトリがいる。")
$resstr = $wc.UploadString($url, $poststr) 
Write-Output $resstr

# 方式２．POSTデータを名前と値のコレクションで設定
$posthash = New-Object System.Collections.Specialized.NameValueCollection 
$posthash.Add("results", "ma,uniq") 
$posthash.Add("uniq_filter", "9|10") 
$posthash.Add("sentence", "庭には二羽ニワトリがいる。") 
$resbytes = $wc.UploadValues($url, $posthash) 
$resstr = [System.Text.Encoding]::UTF8.GetString($resbytes)
Write-Output $resstr

# 方式３．POSTデータをバイト配列で設定（byte[] UploadData(string url, byte[] postdata)）
# →省略

# 後片付け
$wc.Dispose() 
<#

例：日本語係り受け解析（POSTメソッド、JSONリクエスト）

#>
Add-Type -AssemblyName System.Web
$url = 'https://jlp.yahooapis.jp/DAService/V2/parse'
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Yahoo AppID: $clientid")
$wc.Headers.Add("Content-Type", "application/x-www-form-urlencoded")
$wc.Encoding = [System.Text.Encoding]::UTF8
# JSONリクエスト。もしASCII文字だけなら$wc.UploadString()を使用可能。
$poststr = '{"id":"123","jsonrpc":"2.0","method":"jlp.daservice.parse","params":{' +
  '"q":"うちの庭には二羽鶏がいます"' +
  '}}'
$postbytes = [System.Text.Encoding]::UTF8.GetBytes($poststr)
$resbytes = $wc.UploadData($url, $postbytes)
$resstr = [System.Text.Encoding]::UTF8.GetString($resbytes)
Write-Output $resstr
# 後片付け
$wc.Dispose()
