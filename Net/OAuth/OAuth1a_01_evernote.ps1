# PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
# Evernote API で動作確認する。

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# OAuthフローを1ステップずつ確認
# 事前に、$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl を設定しておく。
$DebugPreference = 'Continue'
$dataPath = Join-Path $home "PsOauth1aClient_Evernote.dat"
if (Test-Path $dataPath) {
  LoadSecretObject $dataPath | Tee-Object -Variable data
}

# １．リクエストトークン
# oauth_callbackがoobだと、400 Bad Request になるので、URLを設定する（存在しなくてもよい）。
$callbackUrl = 'https://dummy.evernote.com'
InvokeRequestToken 'GET' $data.requestUrl $data.consumerKey $data.consumerSecret -callback $callbackUrl | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# ２．ユーザ認可
$verifier = InvokeUserAuthorization $data.authUrl $res.oauth_token -dialog -message "遷移エラー画面のURLから oauth_verifier の値を入力してください。"
# URLの例： http://www.sample.com/?oauth_token=xxx&oauth_verifier=xxx&sandbox_lnb=false
# verifierを貼り付けたときに、時々、文字が欠けるので注意。

# ３．アクセストークン
# レスポンスのoauth_token_secretはブランクとなる。
InvokeAccessToken 'GET' $data.accessUrl $data.consumerKey $data.consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier | Tee-Object -Variable res
$data.accessToken = $res.oauth_token
$data.accessTokenSecret = $res.oauth_token_secret
$data.edam_shard = $res.edam_shard
$data.edam_userId = $res.edam_userId
$data.edam_expires = $res.edam_expires
$data.edam_noteStoreUrl = $res.edam_noteStoreUrl
$data.edam_webApiUrlPrefix = $res.edam_webApiUrlPrefix

# 保存
$dataPath = Join-Path $home "PsOauth1aClient_Evernote.dat"
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath | Tee-Object -Variable data

# ４．リソースAPI
# TODO
# InvokeOauthApi 'POST' "https://sandbox.evernote.com/edam/note/$($data.edam_shard)" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret



# クラス版
$dataPath = Join-Path $home "PsOauth1aClient_Evernote.dat"
if (Test-Path $dataPath) {
  $client = New-Object Oauth1aClient
  $client.Load($dataPath)
} else {
  # 事前に $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl を設定しておく
  $client = New-Object Oauth1aClient($data.consumerKey, $data.consumerSecret, $data.requestUrl, $data.authUrl, $data.accessUrl)
  $client.InvokeRequestToken('GET', 'https://dummy.evernote.com')
  $client.InvokeUserAuthorization($true)
  $client.InvokeAccessToken('GET')
  $client.Save($dataPath)
}
