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
# 事前に、$clientId, $clientSecret, $redirectUri, $authUrl, $accessUrl を設定しておく。
$dataPath = Join-Path $home "PsOauth2Client_Qiita.dat"
if (Test-Path $dataPath) {
  LoadSecretObject $dataPath | Tee-Object -Variable data
}

# １．認可リクエスト
# redirect_uri不要。Qiitaにアプリケーション登録したときのリダイレクト先URLが使われる。
# stateパラメータを設定することが推奨されるが今回は簡略化。
$authCode = Oauth2AuthCode_InvokeUserAuth $data.authUrl $data.clientId @{
  scope = "read_qiita write_qiita"
  state = "abc"
} -message $CODE_MSG -dialog $true

# ２．アクセストークンリクエスト
# stateパラメータを設定することが推奨されるが今回は簡略化。
Oauth2AuthCode_InvokeAccessToken $data.accessUrl $authCode @{
  client_id = $data.clientId
  client_secret = $data.clientSecret
  state = "abc"
} -contentType 'application/json' | Tee-Object -Variable res | ConvertTo-Json
# レスポンス例：{"client_id":"xxx", "scopes":["read_qiita"], "token": "xxx"}
$data.accessToken = $res.token

# 保存
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath | Tee-Object -Variable data

# ３．リソースAPI

# 認証中のユーザ
Oauth2AuthCode_InvokeApi 'GET' "https://qiita.com/api/v2/authenticated_user" $data.accessToken | Tee-Object -Variable res | ConvertTo-Json
$userId = $res.id

# 記事
# 認証中ユーザの記事一覧を作成日時の降順で取得
Oauth2AuthCode_InvokeApi GET "https://qiita.com/api/v2/authenticated_user/items" $data.accessToken @{
  page = 1
  per_page = 3
} | Tee-Object -Variable res | ConvertTo-Json
$res | Select-Object id, updated_at, title
$itemId = $res[0].id
# 記事を取得
Oauth2AuthCode_InvokeApi GET "https://qiita.com/api/v2/items/$itemId" $data.accessToken | ConvertTo-Json

# 新たに記事を作成
Oauth2AuthCode_InvokeApi POST "https://qiita.com/api/v2/items" $data.accessToken @{
  title = "Example title"
  body = "# Example"
  private = $true
  tags = @(@{"name"="Ruby"; "versions"=@("0.0.1")})
} -contentType "application/json" | Tee-Object -Variable res | ConvertTo-Json
$newItemId1 = $res.id
Oauth2AuthCode_InvokeApi POST "https://qiita.com/api/v2/items" $data.accessToken @{
  title = "Dummy記事"
  body = "# Dummy`nDummy記事です。`nDummy記事です。`nDummy記事です。"
  private = $true
  tags = @(@{"name"="PowerShell"})
} -contentType "application/json;charset=UTF-8" | Tee-Object -Variable res | ConvertTo-Json
$newItemId2 = $res.id

# 上記で作成した記事を削除
Oauth2AuthCode_InvokeApi DELETE "https://qiita.com/api/v2/items/$newItemId1" $data.accessToken
Oauth2AuthCode_InvokeApi DELETE "https://qiita.com/api/v2/items/$newItemId2" $data.accessToken

# タグ
# ユーザがフォローしているタグ一覧をフォロー日時の降順で取得
Oauth2AuthCode_InvokeApi GET "https://qiita.com/api/v2/users/$userId/following_tags" $data.accessToken @{
  page = 1
  per_page = 3
} | Tee-Object -Variable res | ConvertTo-Json
$res | Select-Object id, items_count, followers_count
