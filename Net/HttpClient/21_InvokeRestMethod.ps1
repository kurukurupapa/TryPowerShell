<#

## Invoke-RestMethodコマンドレット

### GETメソッド

例：Yahoo! JAPAN 日本語形態素解析WebAPI（GET）

#>
$clientid = "あなたの Yahoo! JAPAN WebAPI 用クライアントID を設定する"
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
  $xmldoc = Invoke-RestMethod "https://jlp.yahooapis.jp/存在しないページ" -Body $params
  Write-Output $xmldoc.OuterXml
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
<#

### POSTメソッド

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
