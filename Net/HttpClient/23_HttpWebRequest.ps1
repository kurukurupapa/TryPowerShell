<#

## HttpWebRequest/HttpWebResponse GETメソッド

例：Google検索（GETメソッド）

#>
$url = 'https://www.google.com/search?q=Powershell'
$req = [System.Net.WebRequest]::Create($url)
$res = $req.GetResponse()
echo ($res.StatusCode.value__.ToString() + " " + $res.StatusDescription)
$stream = $res.GetResponseStream()
$reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
echo $reader.ReadToEnd()
$res.Close()  # $stream.Close(),$reader.Close()でも良いし、3つとも実行しても良い。

# エラーを考慮する場合
try {
  $url = 'https://www.google.com/存在しないページ'
  $req = [System.Net.WebRequest]::Create($url)
  $res = $req.GetResponse()
  echo ($res.StatusCode.value__.ToString() + " " + $res.StatusDescription)
  $stream = $res.GetResponseStream()
  $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
  echo $reader.ReadToEnd()
  $res.Close()
} catch {
  # ステータスコード
  echo $_.Exception.InnerException.Response.StatusCode.value__
  # レスポンスボディ
  $stream = $_.Exception.InnerException.Response.GetResponseStream()
  $reader = New-Object System.IO.StreamReader $stream
  $reader.BaseStream.Position = 0
  $reader.DiscardBufferedData()
  echo $reader.ReadToEnd()
  $stream.Close()  # $reader.Close()でも良いし、2つとも実行しても良い。
}
<#

例：Yahoo! JAPAN 日本語形態素解析WebAPI（GETメソッド）

#>
$clientid = "あなたの Yahoo! JAPAN WebAPI 用クライアントID を設定する"
$url = "https://jlp.yahooapis.jp/MAService/V1/parse" +
  "?appid=" + $clientid +
  "&results=ma,uniq" +
  "&uniq_filter=9|10" +
  "&sentence=庭には二羽ニワトリがいる。"
$url = [Uri]::EscapeUriString($url)
$req = [System.Net.WebRequest]::Create($url)
$res = $req.GetResponse()
echo ($res.StatusCode.value__.ToString() + " " + $res.StatusDescription)
$stream = $res.GetResponseStream()
$reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
echo $reader.ReadToEnd()
$res.Close()
<#

## HttpWebRequest/HttpWebResponse POSTメソッド

例：Yahoo! JAPAN 日本語形態素解析WebAPI（POSTメソッド、KeyValue風リクエスト）

#>
# データ準備
Add-Type -AssemblyName System.Web
$url = "https://jlp.yahooapis.jp/MAService/V1/parse"
$postStr = "results=ma,uniq" +  
  "&uniq_filter=" + [System.Web.HttpUtility]::UrlEncode("9|10") + 
  "&sentence=" + [System.Web.HttpUtility]::UrlEncode("庭には二羽ニワトリがいる。")
$postBytes = [System.Text.Encoding]::UTF8.GetBytes($postStr)
# リクエスト送信
$req = [System.Net.WebRequest]::Create($url)
$req.Method = "POST"
$req.UserAgent = "Yahoo AppID: $clientid"
$req.ContentType = "application/x-www-form-urlencoded"
$req.ContentLength = $postBytes.Length
$stream = $req.GetRequestStream()
$stream.Write($postBytes, 0, $postBytes.Length)
$stream.Close()
# レスポンス受信
$res = $req.GetResponse()
echo ($res.StatusCode.value__.ToString() + " " + $res.StatusDescription)
$stream = $res.GetResponseStream()
$reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
echo $reader.ReadToEnd()
$res.Close()
<#

例：日本語係り受け解析（POSTメソッド、JSONリクエスト）

#>
Add-Type -AssemblyName System.Web
$url = 'https://jlp.yahooapis.jp/DAService/V2/parse'
$postStr = '{"id":"123","jsonrpc":"2.0","method":"jlp.daservice.parse","params":{' +
  '"q":"うちの庭には二羽鶏がいます"' +
  '}}'
$postBytes = [System.Text.Encoding]::UTF8.GetBytes($postStr)
# リクエスト送信
$req = [System.Net.WebRequest]::Create($url)
$req.Method = "POST"
$req.UserAgent = "Yahoo AppID: $clientid"
$req.ContentType = "application/json"
$req.ContentLength = $postBytes.Length
$stream = $req.GetRequestStream()
$stream.Write($postBytes, 0, $postBytes.Length)
$stream.Close()
# レスポンス受信
$res = $req.GetResponse()
echo ($res.StatusCode.value__.ToString() + " " + $res.StatusDescription)
$stream = $res.GetResponseStream()
$reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
echo $reader.ReadToEnd()
$res.Close()
