# PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
# Zaim API で動作確認する。
# ZaimAPIへのアプリ登録では、サービス種類を「クライアントアプリ」、アクセスレベルを読み込みのみにした。でも、サービス種類を「ブラウザアプリ」にしても動作した。

. (Join-Path $PSScriptRoot "OAuth1a_01_oauth.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'

# OAuthフローを1ステップずつ確認
# 事前に、$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl を設定しておく。
$infoPath = Join-Path $home "PsOauth1aClient_Zaim.dat"
if (Test-Path $infoPath) {
  Import-OauthClientInfo $infoPath | Tee-Object -Variable info
}

# １．リクエストトークン
Invoke-RequestToken POST $info.RequestUrl $info.ConsumerKey $info.ConsumerSecret 'oob' | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# ２．ユーザ認可
$verifier = Invoke-UserAuthorization $info.AuthUrl $res.oauth_token -Dialog -Message "完了画面に表示されたトークンを入力してください。"

# ３．アクセストークン
Invoke-AccessToken POST $info.AccessUrl $info.ConsumerKey $info.ConsumerSecret $res.oauth_token $res.oauth_token_secret $verifier | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx
$info.AccessToken = $res.oauth_token
$info.AccessTokenSecret = $res.oauth_token_secret

# 保存
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable info

# ４．リソースAPI
Invoke-OauthApi GET 'https://api.zaim.net/v2/home/user/verify' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret | ConvertTo-Json
Invoke-OauthApi GET 'https://api.zaim.net/v2/home/account' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -AuthParams @{ mapping = 1 } | ConvertTo-Json
Invoke-OauthApi GET 'https://api.zaim.net/v2/home/category' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -AuthParams @{ mapping = 1 } | ConvertTo-Json
Invoke-OauthApi GET 'https://api.zaim.net/v2/home/genre' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -AuthParams @{ mapping = 1 } | ConvertTo-Json
$params = @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}
Invoke-OauthApi GET 'https://api.zaim.net/v2/home/money' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -BodyParams $params | ConvertTo-Json
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
Invoke-OauthApi POST 'https://api.zaim.net/v2/home/money/income' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -BodyParams $params | ConvertTo-Json



# # クラス版
# $infoPath = Join-Path $home "PsOauth1aClient_Zaim.dat"
# if (Test-Path $infoPath) {
#   $client = New-Object Oauth1aClient
#   $client.Load($infoPath)
# } else {
#   # 事前に $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl を設定しておく
#   $client = New-Object Oauth1aClient($info.ConsumerKey, $info.ConsumerSecret, $info.RequestUrl, $info.AuthUrl, $info.AccessUrl)
#   $client.InvokeRequestToken('POST', 'oob')
#   $client.InvokeUserAuthorization($true)
#   $client.InvokeAccessToken('POST')
#   $client.Save($infoPath)
# }
# 
# $client.Invoke('GET', 'https://api.zaim.net/v2/home/user/verify') | ConvertTo-Json
# $params = @{ mapping = 1 }
# $client.Invoke('GET', 'https://api.zaim.net/v2/home/account', $null, $params) | ConvertTo-Json
# $client.Invoke('GET', 'https://api.zaim.net/v2/home/category', $null, $params) | ConvertTo-Json
# $client.Invoke('GET', 'https://api.zaim.net/v2/home/genre', $null, $params) | ConvertTo-Json
# $params = @{
#   mapping = 1
#   start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
#   end_date = Get-Date -Format "yyyy-MM-dd"
# }
# $client.Invoke('GET', 'https://api.zaim.net/v2/home/money', $null, $params) | ConvertTo-Json
# $params = @{
#   mapping = 1
#   category_id = 19
#   date = Get-Date -Format "yyyy-MM-dd"
#   amount = 1000000
#   to_account_id = 1
#   place = "Dummy ダミー ショップ"
#   comment = "OAuth 1.0a Client Test `"#$%&+,-./:;<=>?@[\]^_`{|}~"
#   # comment = "OAuth 1.0a Client Test !`"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
#   # NG記号 !'()*
# }
# $client.Invoke('POST', 'https://api.zaim.net/v2/home/money/income', $null, $params) | ConvertTo-Json
