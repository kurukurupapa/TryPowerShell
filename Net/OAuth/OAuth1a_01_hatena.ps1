# PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
# はてなAPI で動作確認する。

. (Join-Path $PSScriptRoot "OAuth1a_01_oauth.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'

# OAuthフローを1ステップずつ確認
# 事前に、$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl を設定しておく。
$infoPath = Join-Path $home "PsOauth1aClient_Hatena.dat"
if (Test-Path $infoPath) {
  Import-OauthClientInfo $infoPath | Tee-Object -Variable data
}

# １．リクエストトークン
$params = @{ scope = "read_public,write_public,read_private" }
Invoke-RequestToken POST $info.RequestUrl $info.ConsumerKey $info.ConsumerSecret 'oob' -AuthParams $params | Tee-Object -Variable res

# ２．ユーザ認可
$verifier = Invoke-UserAuthorization $info.AuthUrl $res.oauth_token -Dialog -Message "完了画面に表示されたトークンを入力してください。"

# ３．アクセストークン
Invoke-AccessToken POST $info.AccessUrl $info.ConsumerKey $info.ConsumerSecret $res.oauth_token $res.oauth_token_secret $verifier | Tee-Object -Variable res
$info.AccessToken = $res.oauth_token
$info.AccessTokenSecret = $res.oauth_token_secret

# 保存
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable data

# ４．リソースAPI

# はてなの OAuth アプリケーション用 API
# [はてなの OAuth アプリケーション用 API - Hatena Developer Center](http://developer.hatena.ne.jp/ja/documents/nano/apis/oauth)
Invoke-OauthApi GET "http://n.hatena.com/applications/my.json" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret
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
Start-Sleep 1
Invoke-OauthApi POST "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -BodyParams $params2
Start-Sleep 1
Invoke-OauthApi GET "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -BodyParams $params1
Start-Sleep 1
# Invoke-OauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -BodyParams $params1
#=> 401 Unauthorized
# Invoke-OauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -OptionParams $params1
#=> {"message":"`url` parameter is required"}
Invoke-OauthApi DELETE "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -QueryParams $params1
#=> OK
Start-Sleep 1
Invoke-OauthApi GET "https://bookmark.hatenaapis.com/rest/1/my/tags" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret | ConvertTo-Json
# →consumer key の払い出し時に、read_privateのスコープを付けていないと、"403 Forbidden Insufficient scope"が返却された。

# はてなブログAtomPub
# [はてなブログAtomPub - Hatena Developer Center](http://developer.hatena.ne.jp/ja/documents/blog/apis/atom)
# $hatenaId = "kurukuru-papa"
# $blogId = "kurukurupapa.hatenablog.com"
# Invoke-OauthApi GET "https://blog.hatena.ne.jp/$hatenaId/$blogId/atom" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret
#=> <p class="error-box">oauth_problem=additional_authorization_required</p>
# Invoke-OauthApi GET "https://blog.hatena.ne.jp/$hatenaId/$blogId/atom/entry" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret
#=> <p class="error-box">oauth_problem=additional_authorization_required</p>
# →追加のスコープが必要な模様。気が向いたら試してみる。



# # クラス版
# if (Test-Path $infoPath) {
#   $client = New-Object Oauth1aClient
#   $client.Load($infoPath)
# } else {
#   # TODO
#   # 事前に $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl を設定しておく
#   $params = @{ scope = "read_public,write_public,read_private" }
#   $client = New-Object Oauth1aClient($info.ConsumerKey, $info.ConsumerSecret, $info.RequestUrl, $info.AuthUrl, $info.AccessUrl)
#   $client.InvokeRequestToken('POST', 'oob', $params, $null)
#   $client.InvokeUserAuthorization($true)
#   $client.InvokeAccessToken('POST')
#   $client.Save($infoPath)
# }
# 
# # はてなの OAuth アプリケーション用 API
# $client.Invoke('GET', 'http://n.hatena.com/applications/my.json')
# 
# # はてなブックマーク REST API
# $url = "https://dummy.hatenablog.ne.jp/"
# $params1 = @{ url = $url }
# $params2 = @{
#   url = $url
#   tags = "PsOauth1aLocalClient"
#   comment = "PsOauth1aLocalClient コメント `"#$%&+,-./:;<=>?@[\]^_`{|}~"
#   # NG記号 !'()*
# }
# $client.Invoke('POST', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $params2)
# $client.Invoke('GET', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $params1)
# $client.Invoke('DELETE', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $null, $params1)
# $client.Invoke('GET', "https://bookmark.hatenaapis.com/rest/1/my/tags") | ConvertTo-Json
