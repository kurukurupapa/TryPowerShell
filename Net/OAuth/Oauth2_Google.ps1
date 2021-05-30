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
$dataPath = Join-Path $home "PsOauth2Client_Google.dat"
if (Test-Path $dataPath) {
  LoadSecretObject $dataPath | Tee-Object -Variable data
}

# １．認可リクエスト
# stateパラメータを設定することが推奨されるが今回は省略。
$authCode = Oauth2AuthCode_InvokeUserAuth $data.authUrl $data.clientId @{
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  scope = "email profile https://www.googleapis.com/auth/drive.metadata.readonly"
} -message $CODE_MSG -dialog $true

# ２．アクセストークンリクエスト
Oauth2AuthCode_InvokeAccessToken $data.accessUrl $authCode @{
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  client_id = $data.clientId
  client_secret = $data.clientSecret
} | Tee-Object -Variable res
Oauth2_AddResponse $data $res | Tee-Object -Variable data

# 保存
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath | Tee-Object -Variable data

# ３．リソースAPI
Oauth2AuthCode_InvokeApi 'GET' "https://www.googleapis.com/drive/v2/files" $data.accessToken | ConvertTo-Json

# ４．リフレッシュトークンリクエスト
Oauth2AuthCode_InvokeRefreshToken $data.accessUrl $data.refreshToken @{
  client_id = $data.clientId
  client_secret = $data.clientSecret
} | Tee-Object -Variable res
Oauth2_AddResponse $data $res | Tee-Object -Variable data



# クラス版
if (Test-Path $dataPath) {
  $client = New-Object Oauth2AuthCodeClient
  $client.Load($dataPath)
} else {
  # 事前に、$clientId, $clientSecret, $redirectUri, $authUrl, $accessUrl を設定しておく。
  $client = New-Object Oauth2AuthCodeClient($data.clientId, $data.clientSecret, $data.redirectUri, $data.authUrl, $data.accessUrl)
  $client.InvokeUserAuth(@{
    redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
    scope = "email profile https://www.googleapis.com/auth/drive.metadata.readonly"
  }, $CODE_MSG, $true)
  $client.InvokeAccessToken(@{
    redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
    client_id = $client.clientId
    client_secret = $client.clientSecret
  })
  $client.Save($dataPath)
}

$client.InvokeApi('GET', "https://www.googleapis.com/drive/v2/files", $null) | ConvertTo-Json
