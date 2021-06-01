# PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
# Evernote API で動作確認する。

. (Join-Path $PSScriptRoot "OAuth1a_01_oauth.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'

# OAuthフローを1ステップずつ確認
# 事前に、$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl を設定しておく。
$infoPath = Join-Path $home "PsOauth1aClient_Evernote.dat"
if (Test-Path $infoPath) {
  Import-OauthClientInfo $infoPath | Tee-Object -Variable info
}

# １．リクエストトークン
# oauth_callbackがoobだと、400 Bad Request になるので、URLを設定する（存在しなくてもよい）。
$callbackUrl = 'https://dummy.evernote.com'
Invoke-RequestToken 'GET' $info.RequestUrl $info.ConsumerKey $info.ConsumerSecret $callbackUrl | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# ２．ユーザ認可
$verifier = Invoke-UserAuthorization $info.AuthUrl $res.oauth_token -Dialog -Message "遷移エラー画面のURLから oauth_verifier の値を入力してください。"
# URLの例： http://www.sample.com/?oauth_token=xxx&oauth_verifier=xxx&sandbox_lnb=false
# verifierを貼り付けたときに、時々、文字が欠けるので注意。

# ３．アクセストークン
# レスポンスのoauth_token_secretはブランクとなる。
Invoke-AccessToken 'GET' $info.AccessUrl $info.ConsumerKey $info.ConsumerSecret $res.oauth_token $res.oauth_token_secret $verifier | Tee-Object -Variable res
$info.AccessToken = $res.oauth_token
$info.AccessTokenSecret = $res.oauth_token_secret
$info.EdamShard = $res.edam_shard
$info.EdamUserId = $res.edam_userId
$info.EdamExpires = $res.edam_expires
$info.EdamNoteStoreUrl = $res.edam_noteStoreUrl
$info.EdamWebApiUrlPrefix = $res.edam_webApiUrlPrefix

# 保存
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable info

# ４．リソースAPI
# TODO
# Invoke-OauthApi 'POST' "https://sandbox.evernote.com/edam/note/$($info.EdamShard)" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret



# # クラス版
# if (Test-Path $infoPath) {
#   $client = New-Object Oauth1aClient
#   $client.Load($infoPath)
# } else {
#   # 事前に $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl を設定しておく
#   $client = New-Object Oauth1aClient($info.ConsumerKey, $info.ConsumerSecret, $info.RequestUrl, $info.AuthUrl, $info.AccessUrl)
#   $client.InvokeRequestToken('GET', 'https://dummy.evernote.com')
#   $client.InvokeUserAuthorization($true)
#   $client.InvokeAccessToken('GET')
#   $client.Save($infoPath)
# }
