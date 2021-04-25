<#

## WebClientクラス GETメソッド

例：Google検索（GETメソッド）

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
  $resstr = $wc.DownloadString('https://www.google.com/存在しないページ')
} catch {
  # ステータスコード
  echo $_.Exception.InnerException.Response.StatusCode.value__
  # レスポンスボディ
  $stream = $_.Exception.InnerException.Response.GetResponseStream()
  $reader = New-Object System.IO.StreamReader $stream
  $reader.BaseStream.Position = 0
  $reader.DiscardBufferedData()
  echo $reader.ReadToEnd()
  $reader.Close()  # Closeは$readerと$streamの一方を呼び出せばよい。両方呼び出しても害はない
  $stream.Close()
}

# 後片付け
$wc.Dispose()
<#

例：Yahoo! JAPAN 日本語形態素解析WebAPI（GET）

#>
$clientid = "あなたの Yahoo! JAPAN WebAPI 用クライアントID を設定する"
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

例：日本語係り受け解析（POSTメソッド、JSONリクエスト/レスポンス）

#>
Add-Type -AssemblyName System.Web
$url = 'https://jlp.yahooapis.jp/DAService/V2/parse'
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Yahoo AppID: $clientid")
$wc.Headers.Add("Content-Type", "application/json")
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
