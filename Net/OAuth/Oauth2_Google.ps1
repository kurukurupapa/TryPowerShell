<#
.SYNOPSIS
  PowerShell標準機能で OAuth 2.0 クライアントを作成（Google API）
.DESCRIPTION
  参考
  [OAuth 2.0 for Mobile & Desktop Apps ?|? Google Identity Platform](https://developers.google.com/identity/protocols/oauth2/native-app)
  [GoogleAPIのOAuth2.0スコープ ?|? Google Identity Platform ?|? Google Developers](https://developers.google.com/identity/protocols/oauth2/scopes)
  前提
  Google Cloud Platform で OAuth 2.0 クライアントを登録し、クライアントID、クライアントシークレットを払い出しておく。
  [ホーム ? Test01 ? Google Cloud Platform](https://console.cloud.google.com/home/dashboard?project=test01-e645b)
#>

. (Join-Path $PSScriptRoot "Oauth2AuthCodeClient.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
# $DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'
$CODE_MSG = "完了画面に表示されたコードを入力してください。"

# OAuthフローを1ステップずつ確認（認可コードグラントタイプ）
# 事前に、$clientId, $clientSecret, $redirectUri, $authUrl, $accessUrl を設定しておく。
$infoPath = Join-Path $home "PsOauth2Client_Google.dat"
if (Test-Path $infoPath) {
  Import-OauthClientInfo $infoPath | Tee-Object -Variable info
}

# １．認可リクエスト
# stateパラメータを設定することが推奨されるが今回は省略。
$authCode = Invoke-Oauth2UserAuth "https://accounts.google.com/o/oauth2/v2/auth" $info.ClientId @{
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  scope = "email profile https://www.googleapis.com/auth/drive.metadata.readonly"
} -Message $CODE_MSG -Dialog $true

# ２．アクセストークンリクエスト
Invoke-Oauth2AccessToken "https://oauth2.googleapis.com/token" $authCode @{
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  client_id = $info.ClientId
  client_secret = $info.ClientSecret
} | Tee-Object -Variable res
Add-OauthClientInfo $info $res | Tee-Object -Variable info

# 保存
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable info

# ３．リソースAPI
Invoke-Oauth2Api 'GET' "https://www.googleapis.com/drive/v2/files" $info.AccessToken | ConvertTo-Json

# ４．リフレッシュトークンリクエスト
Invoke-Oauth2RefreshToken "https://oauth2.googleapis.com/token" $info.RefreshToken @{
  client_id = $info.ClientId
  client_secret = $info.ClientSecret
} | Tee-Object -Variable res
Add-OauthClientInfo $info $res | Tee-Object -Variable info
