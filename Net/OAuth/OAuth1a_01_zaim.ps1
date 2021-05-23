# PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
# Zaim API で動作確認する。
# ZaimAPIへのアプリ登録では、サービス種類を「クライアントアプリ」、アクセスレベルを読み込みのみにした。
# でも、サービス種類を「ブラウザアプリ」にしても動作した。

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# OAuthフローを1ステップずつ確認
# 事前に、$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl を設定しておく。
$DebugPreference = 'Continue'

# リクエストトークン
ParseOauthResponse(InvokeOauthApi 'POST' $requestUrl $consumerKey $consumerSecret -callback 'oob') | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# ユーザ認可
InvokeUserAuthorization $res.oauth_token
$verifier = Read-Host "完了画面に表示されたトークンを入力してください。"

# アクセストークン
ParseOauthResponse(InvokeOauthApi 'POST' $accessUrl $consumerKey $consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier) | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx

# 保存
$dataPath = Join-Path $home "PsOauth1aLocalClient_Zaim.dat"
$data = @{
  consumerKey = $consumerKey
  consumerSecret = $consumerSecret
  requestUrl = $requestUrl
  authUrl = $authUrl
  accessUrl = $accessUrl
  accessToken = $res.oauth_token
  accessTokenSecret = $res.oauth_token_secret
}
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath

# リソースAPI
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/user/verify' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret | ConvertTo-Json -Depth 100
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/account' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams @{ mapping = 1 } | ConvertTo-Json -Depth 100
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/category' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams @{ mapping = 1 } | ConvertTo-Json -Depth 100
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/genre' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams @{ mapping = 1 } | ConvertTo-Json -Depth 100
$params = @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/money' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret $params -body $params | ConvertTo-Json -Depth 100
$params = @{
  mapping = 1
  category_id = 19
  date = Get-Date -Format "yyyy-MM-dd"
  amount = 1000000
  to_account_id = 1
  place = "Dummy ダミー ショップ"
  comment = "OAuth 1.0a Client Test `"#$%&+,-./:;<=>?@[\]^_`{|}~"
  # comment = "OAuth 1.0a Client Test !`"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
  # NG記号 !'()*
}
InvokeOauthApi 'POST' 'https://api.zaim.net/v2/home/money/income' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams $params -body $params | ConvertTo-Json -Depth 100

# クラス版
$dataPath = Join-Path $home "PsOauth1aLocalClient_Zaim.dat"
if (Test-Path $dataPath) {
  $client = New-Object Oauth1aLocalClient
  $client.Load($dataPath)
} else {
  # 事前に $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl を設定しておく
  $client = New-Object Oauth1aLocalClient($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl)
  $client.InvokeOauthFlow()
  $client.Save($dataPath)
}

$client.Invoke('GET', 'https://api.zaim.net/v2/home/user/verify') | ConvertTo-Json -Depth 100
$client.Invoke('GET', 'https://api.zaim.net/v2/home/account', @{ mapping = 1 }) | ConvertTo-Json -Depth 100
$client.Invoke('GET', 'https://api.zaim.net/v2/home/category', @{ mapping = 1 }) | ConvertTo-Json -Depth 100
$client.Invoke('GET', 'https://api.zaim.net/v2/home/genre', @{ mapping = 1 }) | ConvertTo-Json -Depth 100
$params = @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}
$client.Invoke('GET', 'https://api.zaim.net/v2/home/money', $params, $params) | ConvertTo-Json -Depth 100
$params = @{
  mapping = 1
  category_id = 19
  date = Get-Date -Format "yyyy-MM-dd"
  amount = 1000000
  to_account_id = 1
  place = "Dummy ダミー ショップ"
  comment = "OAuth 1.0a Client Test `"#$%&+,-./:;<=>?@[\]^_`{|}~"
  # comment = "OAuth 1.0a Client Test !`"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
  # NG記号 !'()*
}
$client.Invoke('POST', 'https://api.zaim.net/v2/home/money/income', $params, $params) | ConvertTo-Json -Depth 100
