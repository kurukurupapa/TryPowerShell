# PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
# はてなAPI で動作確認する。

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# OAuthフローを1ステップずつ確認
# 事前に、$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl を設定しておく。
$DebugPreference = 'Continue'
$dataPath = Join-Path $home "PsOauth1aClient_Hatena.dat"
if (Test-Path $dataPath) {
  LoadSecretObject $dataPath | Tee-Object -Variable data
}

# １．リクエストトークン
$params = @{ scope = "read_public,write_public,read_private" }
InvokeRequestToken 'POST' $data.requestUrl $data.consumerKey $data.consumerSecret -callback 'oob' -authParams $params | Tee-Object -Variable res

# ２．ユーザ認可
$verifier = InvokeUserAuthorization $data.authUrl $res.oauth_token -dialog -message "完了画面に表示されたトークンを入力してください。"

# ３．アクセストークン
InvokeAccessToken 'POST' $data.accessUrl $data.consumerKey $data.consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier | Tee-Object -Variable res
$data.accessToken = $res.oauth_token
$data.accessTokenSecret = $res.oauth_token_secret

# 保存
$dataPath = Join-Path $home "PsOauth1aClient_Hatena.dat"
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath | Tee-Object -Variable data

# ４．リソースAPI

# はてなの OAuth アプリケーション用 API
# [はてなの OAuth アプリケーション用 API - Hatena Developer Center](http://developer.hatena.ne.jp/ja/documents/nano/apis/oauth)
InvokeOauthApi 'GET' "http://n.hatena.com/applications/my.json" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret
# →リクエストトークン取得時のscope設定に、スコープが足りない場合、"oauth_problem=additional_authorization_required"が返却された。

# はてなブックマーク REST API
# [はてなブックマーク REST API - Hatena Developer Center](http://developer.hatena.ne.jp/ja/documents/bookmark/apis/rest/)
$url = "https://dummy.hatenablog.ne.jp/"
$params1 = @{ url = $url }
$params2 = @{
  url = $url
  tags = "PsOauth1aLocalClient"
  comment = "PsOauth1aLocalClient コメント `"#$%&+,-./:;<=>?@[\]^_`{|}~"
  # NG記号 !'()*
}
InvokeOauthApi 'POST' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params2
InvokeOauthApi 'GET' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params1
# InvokeOauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params1
#=> 401 Unauthorized
# InvokeOauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams $params1
#=> {"message":"`url` parameter is required"}
InvokeOauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -queryParams $params1
#=> OK
InvokeOauthApi 'GET' "https://bookmark.hatenaapis.com/rest/1/my/tags" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret | ConvertTo-Json
# →consumer key の払い出し時に、read_privateのスコープを付けていないと、"403 Forbidden Insufficient scope"が返却された。

# はてなブログAtomPub
# [はてなブログAtomPub - Hatena Developer Center](http://developer.hatena.ne.jp/ja/documents/blog/apis/atom)
$hatenaId = "kurukuru-papa"
$blogId = "kurukurupapa.hatenablog.com"
InvokeOauthApi 'GET' "https://blog.hatena.ne.jp/$hatenaId/$blogId/atom" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret
#=> <p class="error-box">oauth_problem=additional_authorization_required</p>
InvokeOauthApi 'GET' "https://blog.hatena.ne.jp/$hatenaId/$blogId/atom/entry" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret
#=> <p class="error-box">oauth_problem=additional_authorization_required</p>
# →追加のスコープが必要な模様。気が向いたら試してみる。



# クラス版
$dataPath = Join-Path $home "PsOauth1aClient_Hatena.dat"
if (Test-Path $dataPath) {
  $client = New-Object Oauth1aClient
  $client.Load($dataPath)
} else {
  # TODO
  # 事前に $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl を設定しておく
  $params = @{ scope = "read_public,write_public,read_private" }
  $client = New-Object Oauth1aClient($data.consumerKey, $data.consumerSecret, $data.requestUrl, $data.authUrl, $data.accessUrl)
  $client.InvokeRequestToken('POST', 'oob', $params, $null)
  $client.InvokeUserAuthorization($true)
  $client.InvokeAccessToken('POST')
  $client.Save($dataPath)
}

# はてなの OAuth アプリケーション用 API
$client.Invoke('GET', 'http://n.hatena.com/applications/my.json')

# はてなブックマーク REST API
$url = "https://dummy.hatenablog.ne.jp/"
$params1 = @{ url = $url }
$params2 = @{
  url = $url
  tags = "PsOauth1aLocalClient"
  comment = "PsOauth1aLocalClient コメント `"#$%&+,-./:;<=>?@[\]^_`{|}~"
  # NG記号 !'()*
}
$client.Invoke('POST', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $params2)
$client.Invoke('GET', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $params1)
$client.Invoke('DELETE', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $null, $params1)
$client.Invoke('GET', "https://bookmark.hatenaapis.com/rest/1/my/tags") | ConvertTo-Json
