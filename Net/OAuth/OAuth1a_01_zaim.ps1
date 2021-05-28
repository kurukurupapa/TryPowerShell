# PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
# Zaim API で動作確認する。
# ZaimAPIへのアプリ登録では、サービス種類を「クライアントアプリ」、アクセスレベルを読み込みのみにした。でも、サービス種類を「ブラウザアプリ」にしても動作した。

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# OAuthフローを1ステップずつ確認
# 事前に、$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl を設定しておく。
$DebugPreference = 'Continue'
$dataPath = Join-Path $home "PsOauth1aClient_Zaim.dat"
if (Test-Path $dataPath) {
  LoadSecretObject $dataPath | Tee-Object -Variable data
}

# １．リクエストトークン
InvokeRequestToken 'POST' $data.requestUrl $data.consumerKey $data.consumerSecret -callback 'oob' | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# ２．ユーザ認可
$verifier = InvokeUserAuthorization $data.authUrl $res.oauth_token -dialog -message "完了画面に表示されたトークンを入力してください。"

# ３．アクセストークン
InvokeAccessToken 'POST' $data.accessUrl $data.consumerKey $data.consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx
$data.accessToken = $res.oauth_token
$data.accessTokenSecret = $res.oauth_token_secret

# 保存
$dataPath = Join-Path $home "PsOauth1aClient_Zaim.dat"
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath | Tee-Object -Variable data

# ４．リソースAPI
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/user/verify' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret | ConvertTo-Json
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/account' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -authParams @{ mapping = 1 } | ConvertTo-Json
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/category' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -authParams @{ mapping = 1 } | ConvertTo-Json
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/genre' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -authParams @{ mapping = 1 } | ConvertTo-Json
$params = @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/money' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params | ConvertTo-Json
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
InvokeOauthApi 'POST' 'https://api.zaim.net/v2/home/money/income' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params | ConvertTo-Json



# クラス版
$dataPath = Join-Path $home "PsOauth1aClient_Zaim.dat"
if (Test-Path $dataPath) {
  $client = New-Object Oauth1aClient
  $client.Load($dataPath)
} else {
  # 事前に $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl を設定しておく
  $client = New-Object Oauth1aClient($data.consumerKey, $data.consumerSecret, $data.requestUrl, $data.authUrl, $data.accessUrl)
  $client.InvokeRequestToken('POST', 'oob')
  $client.InvokeUserAuthorization($true)
  $client.InvokeAccessToken('POST')
  $client.Save($dataPath)
}

$client.Invoke('GET', 'https://api.zaim.net/v2/home/user/verify') | ConvertTo-Json
$params = @{ mapping = 1 }
$client.Invoke('GET', 'https://api.zaim.net/v2/home/account', $null, $params) | ConvertTo-Json
$client.Invoke('GET', 'https://api.zaim.net/v2/home/category', $null, $params) | ConvertTo-Json
$client.Invoke('GET', 'https://api.zaim.net/v2/home/genre', $null, $params) | ConvertTo-Json
$params = @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}
$client.Invoke('GET', 'https://api.zaim.net/v2/home/money', $null, $params) | ConvertTo-Json
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
$client.Invoke('POST', 'https://api.zaim.net/v2/home/money/income', $null, $params) | ConvertTo-Json
