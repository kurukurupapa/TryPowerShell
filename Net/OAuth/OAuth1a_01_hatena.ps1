# PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
# はてなAPI で動作確認する。

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'


# OAuthフローを1ステップずつ確認
# 事前に、$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl を設定しておく。
$DebugPreference = 'Continue'

# １．リクエストトークン
$params = @{ scope = "read_public,write_public" }
ParseOauthResponse(InvokeOauthApi 'POST' $requestUrl $consumerKey $consumerSecret -callback 'oob' -optionParams $params) | Tee-Object -Variable res

# ２．ユーザ認可
InvokeUserAuthorization $res.oauth_token
$verifier = Read-Host "完了画面に表示されたトークンを入力してください。"

# ３．アクセストークン
ParseOauthResponse(InvokeOauthApi 'POST' $accessUrl $consumerKey $consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier) | Tee-Object -Variable res

# 保存
$dataPath = Join-Path $home "PsOauth1aLocalClient_Hatena.dat"
SaveSecretObject $dataPath @{
  consumerKey = $consumerKey
  consumerSecret = $consumerSecret
  requestUrl = $requestUrl
  authUrl = $authUrl
  accessUrl = $accessUrl
  accessToken = $res.oauth_token
  accessTokenSecret = $res.oauth_token_secret
}
LoadSecretObject $dataPath | Tee-Object -Variable data

# リソースAPI
InvokeOauthApi 'GET' "http://n.hatena.com/applications/my.json" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret

$url = "https://dummy.hatenablog.ne.jp/"
$params = @{
  url = $url
  tags = "PsOauth1aLocalClient"
  comment = "PsOauth1aLocalClient コメント `"#$%&+,-./:;<=>?@[\]^_`{|}~"
  # NG記号 !'()*
}
InvokeOauthApi 'POST' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params
$params = @{ url = $url }
InvokeOauthApi 'GET' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params

# TODO
InvokeOauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params
#=> 401 Unauthorized
InvokeOauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams $params
#=> {"message":"`url` parameter is required"}
