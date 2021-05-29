<#
.SYNOPSIS
  PowerShell標準機能で OAuth 2.0 クライアントを作成（OAuth 2.0 認可コードグラントタイプ）
.DESCRIPTION
  参考
  [OAuth 2.0 ? OAuth](https://oauth.net/2/)
  [The OAuth 2.0 Authorization Framework](https://openid-foundation-japan.github.io/rfc6749.ja.html)
#>

. (Join-Path $PSScriptRoot "Oauth2Util.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

<#
.SYNOPSIS
  OAuth 2.0 認可コードグラントタイプにおける認可リクエスト
.INPUTS
  $optionParams - 追加パラメータの連想配列
    例：@{redirect_uri="xxx"; scope="xxx"; state="xxx"}
  $dialog - ダイアログボックスでユーザ入力を受け付ける場合$true。デフォルトではコンソールから読み込む。
.OUTPUTS
  認可コードの文字列
#>
function Oauth2AuthCode_InvokeUserAuth($url, $clientId, $optionParams, $message=$OAUTH2_CODE_MSG, $dialog) {
  $params = @{
    response_type = 'code'
    client_id = $clientId
  }
  if ($optionParams) { $params += $optionParams }
  $arr = $params.GetEnumerator() | Sort-Object Name | ForEach-Object {
    [System.Web.HttpUtility]::UrlEncode($_.Name) + '=' + [System.Web.HttpUtility]::UrlEncode($_.Value)
  }
  $url += '?' + ($arr -join '&')
  Write-Verbose $url
  Start-Process $url
  return Oauth2_ReadUserCode $message $dialog
}

<#
.SYNOPSIS
  OAuth 2.0 認可コードグラントタイプにおけるアクセストークンリクエスト
.INPUTS
  $optionParams - 追加パラメータの連想配列
    例：@{redirect_uri="xxx"; client_id="xxx"}
.OUTPUTS
  アクセストークンの文字列
#>
function Oauth2AuthCode_InvokeAccessToken($url, $authCode, $optionParams) {
  $params = @{
    grant_type = 'authorization_code'
    code = $authCode
  }
  if ($optionParams) { $params += $optionParams }
  try {
    return Invoke-RestMethod $url -Method 'POST' -Body $params
  } catch {
    PrintWebException $_
    throw $_
  }
}

<#
.SYNOPSIS
  OAuth 2.0 認可コードグラントタイプにおけるリフレッシュトークンリクエスト
.INPUTS
  $optionParams - 追加パラメータの連想配列
    例：@{scope="xxx"}
.OUTPUTS
  アクセストークンの文字列
#>
function Oauth2AuthCode_InvokeRefreshToken($url, $refreshToken, $optionParams) {
  $params = @{
    grant_type = "refresh_token"
    refresh_token = $refreshToken
  }
  if ($optionParams) { $params += $optionParams }
  try {
    return Invoke-RestMethod $url -Method 'POST' -Body $params
  } catch {
    PrintWebException $_
    throw $_
  }
}

<#
.SYNOPSIS
  OAuth 2.0 認可コードグラントタイプにおけるリソースAPIリクエスト
#>
function Oauth2AuthCode_InvokeApi($method, $url, $accessToken, $optionParams) {
  $headers = @{
    'Authorization' = "Bearer $accessToken"
  }
  try {
    return Invoke-RestMethod $url -Method $method -Headers $headers -Body $optionParams
  } catch {
    PrintWebException $_
    throw $_
  }
}

<#
.SYNOPSIS
  OAuth 2.0 認可コードグラントタイプクラス
#>
class Oauth2AuthCodeClient {
  $clientId
  $clientSecret
  $redirectUri
  $authUrl
  $accessUrl
  $accessToken
  $refreshToken
  # 一時的な変数
  $authCode

  Oauth2AuthCodeClient() {
  }
  Oauth2AuthCodeClient($clientId, $clientSecret, $redirectUri, $authUrl, $accessUrl) {
    $this.clientId = $clientId
    $this.clientSecret = $clientSecret
    $this.redirectUri = $redirectUri
    $this.authUrl = $authUrl
    $this.accessUrl = $accessUrl
  }

  InvokeUserAuth($optionParams, $message, $dialog) {
    $this.authCode = Oauth2AuthCode_InvokeUserAuth $this.authUrl $this.clientId -otherParams $optionParams -message $message -dialog $dialog
  }

  InvokeAccessToken($optionParams) {
    $res = Oauth2AuthCode_InvokeAccessToken $this.accessUrl $this.authCode -otherParams $optionParams
    $this.accessToken = $res.access_token
    $this.refreshToken = $res.refresh_token
    $this.authCode = $null
  }

  InvokeRefreshToken($optionParams) {
    $res = Oauth2AuthCode_InvokeRefreshToken $this.accessUrl $this.refreshToken -otherParams $optionParams
    $this.accessToken = $res.access_token
  }

  [object] InvokeApi($method, $url, $optionParams) {
    return Oauth2AuthCode_InvokeApi $method $url $this.accessToken $optionParams
  }

  Save($path) {
    SaveSecretObject $path $this
  }

  Load($path) {
    $data = LoadSecretObject $path
    $data.psobject.properties | ForEach-Object {
      Add-Member -InputObject $this -MemberType NoteProperty -Name $_.Name -Value $_.Value -Force
    }
  }
}
