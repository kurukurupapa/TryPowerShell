# PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
# Evernote API で動作確認する。

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# OAuthフローを1ステップずつ確認
# 事前に、$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl を設定しておく。
$DebugPreference = 'Continue'

# １．リクエストトークン
# oauth_callbackがoobだと、400 Bad Request になるので、URLを設定する（存在しなくてもよい）。
$callbackUrl = 'https://dummy.evernote.com'
ParseOauthResponse(InvokeOauthApi 'GET' $requestUrl $consumerKey $consumerSecret -callback $callbackUrl) | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# ２．ユーザ認可
InvokeUserAuthorization $res.oauth_token
$verifier = Read-Host "遷移エラー画面のURLから oauth_verifier の値を入力してください。"
#=> http://www.sample.com/?oauth_token=xxx&oauth_verifier=xxx&sandbox_lnb=false

# ３．アクセストークン
# レスポンスのoauth_token_secretはブランクとなる。
ParseOauthResponse(InvokeOauthApi 'GET' $accessUrl $consumerKey $consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier) | Tee-Object -Variable res

# 保存
$dataPath = Join-Path $home "PsOauth1aLocalClient_Evernote.dat"
SaveSecretObject $dataPath @{
  consumerKey = $consumerKey
  consumerSecret = $consumerSecret
  requestUrl = $requestUrl
  authUrl = $authUrl
  accessUrl = $accessUrl
  accessToken = $res.oauth_token
  accessTokenSecret = $res.oauth_token_secret
  edam_shard = $res.edam_shard
  edam_userId = $res.edam_userId
  edam_expires = $res.edam_expires
  edam_noteStoreUrl = $res.edam_noteStoreUrl
  edam_webApiUrlPrefix = $res.edam_webApiUrlPrefix
}
LoadSecretObject $dataPath | Tee-Object -Variable data

# ４．リソースAPI
# TODO
