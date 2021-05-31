<#
.SYNOPSIS
  PowerShell標準機能で OAuth 2.0 クライアントを作成（Qiita API）
.DESCRIPTION
  参考
  [Qiita API v2ドキュメント - Qiita:Developer](https://qiita.com/api/v2/docs)
  前提
  Qiitaアカウント設定で、アプリケーションを登録し、クライアントID、クライアントシークレットを払い出しておく。
  [Qiita](https://qiita.com/settings/applications)
#>

. (Join-Path $PSScriptRoot "Oauth2AuthCodeClient.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
# $DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'
$CODE_MSG = "遷移エラー画面のURLからcodeの値を入力してください。"

# OAuthフローを1ステップずつ確認（認可コードグラントタイプ）
# 事前に、$clientId, $clientSecret, $redirectUri を設定しておく。
$infoPath = Join-Path $home "PsOauth2Client_Qiita.dat"
if (Test-Path $infoPath) {
  Import-OauthClientInfo $infoPath | Tee-Object -Variable info
}

# １．認可リクエスト
# redirect_uri不要。Qiitaにアプリケーション登録したときのリダイレクト先URLが使われる。
# stateパラメータを設定することが推奨されるが今回は簡略化。
$authCode = Invoke-Oauth2UserAuth "https://qiita.com/api/v2/oauth/authorize" $info.ClientId @{
  scope = "read_qiita write_qiita"
  state = "abc"
} -Message $CODE_MSG -Dialog $true

# ２．アクセストークンリクエスト
# stateパラメータを設定することが推奨されるが今回は簡略化。
Invoke-Oauth2AccessToken "https://qiita.com/api/v2/access_tokens" $authCode @{
  client_id = $info.ClientId
  client_secret = $info.ClientSecret
  state = "abc"
} -ContentType 'application/json' | Tee-Object -Variable res | ConvertTo-Json
# レスポンス例：{"client_id":"xxx", "scopes":["read_qiita"], "token": "xxx"}
$info.AccessToken = $res.token

# 保存
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable info

# ３．リソースAPI

# 認証中のユーザ
Invoke-Oauth2Api GET "https://qiita.com/api/v2/authenticated_user" $info.AccessToken | Tee-Object -Variable res | ConvertTo-Json
$userId = $res.id

# 記事
# 認証中ユーザの記事一覧を作成日時の降順で取得
Invoke-Oauth2Api GET "https://qiita.com/api/v2/authenticated_user/items" $info.AccessToken @{
  page = 1
  per_page = 3
} | Tee-Object -Variable res | ConvertTo-Json
$res | Select-Object id, updated_at, title
$itemId = $res[0].id
# 記事を取得
Invoke-Oauth2Api GET "https://qiita.com/api/v2/items/$itemId" $info.AccessToken | ConvertTo-Json

# 新たに記事を作成
Invoke-Oauth2Api POST "https://qiita.com/api/v2/items" $info.AccessToken @{
  title = "Example title"
  body = "# Example"
  private = $true
  tags = @(@{"name"="Ruby"; "versions"=@("0.0.1")})
} -ContentType "application/json" | Tee-Object -Variable res | ConvertTo-Json
$newItemId1 = $res.id
Invoke-Oauth2Api POST "https://qiita.com/api/v2/items" $info.AccessToken @{
  title = "Dummy記事"
  body = "# Dummy`nDummy記事です。`nDummy記事です。`nDummy記事です。"
  private = $true
  tags = @(@{"name"="PowerShell"})
} -ContentType "application/json;charset=UTF-8" | Tee-Object -Variable res | ConvertTo-Json
$newItemId2 = $res.id

# 上記で作成した記事を削除
Invoke-Oauth2Api DELETE "https://qiita.com/api/v2/items/$newItemId1" $info.AccessToken
Invoke-Oauth2Api DELETE "https://qiita.com/api/v2/items/$newItemId2" $info.AccessToken

# タグ
# ユーザがフォローしているタグ一覧をフォロー日時の降順で取得
Invoke-Oauth2Api GET "https://qiita.com/api/v2/users/$userId/following_tags" $info.AccessToken @{
  page = 1
  per_page = 3
} | Tee-Object -Variable res | ConvertTo-Json
$res | Select-Object id, items_count, followers_count
