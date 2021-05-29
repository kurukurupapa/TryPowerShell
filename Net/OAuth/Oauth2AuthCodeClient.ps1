# PowerShell標準機能で OAuth 2.0 クライアントを作成してみる
# OAuth 2.0 認可コードグラントタイプ
# 参考
# [OAuth 2.0 ? OAuth](https://oauth.net/2/)
# [The OAuth 2.0 Authorization Framework](https://openid-foundation-japan.github.io/rfc6749.ja.html)

. (Join-Path $PSScriptRoot "Oauth2Util.ps1")

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

function Oauth2AuthCode_InvokeUserAuth($url, $clientId, $redirectUri, $scope, $state,
  $otherParams, $message, $dialog) {
  $params = @{
    response_type = 'code'
    client_id = $clientId
  }
  if ($redirectUri) { $params['redirect_uri'] = $redirectUri }
  if ($scope) { $params['scope'] = $scope }
  if ($state) { $params['state'] = $state }
  if ($otherParams) { $params += $otherParams }
  $arr = $params.GetEnumerator() | sort Name | %{
    [System.Web.HttpUtility]::UrlEncode($_.Name) + '=' + [System.Web.HttpUtility]::UrlEncode($_.Value)
  }
  $url += '?' + ($arr -join '&')
  Write-Verbose $url
  Start-Process $url
  return Oauth2_ReadUserCode $message $dialog
}

function Oauth2AuthCode_InvokeAccessToken($url, $authCode, $redirectUri, $clientId, $otherParams) {
  $params = @{
    grant_type = 'authorization_code'
    code = $authCode
  }
  if ($redirectUri) { $params['redirect_uri'] = $redirectUri }
  if ($clientId) { $params['client_id'] = $clientId }
  if ($otherParams) { $params += $otherParams }
  try {
    return Invoke-RestMethod $url -Method 'POST' -Body $params
  } catch {
    PrintWebException $_
    throw $_
  }
}

function Oauth2AuthCode_InvokeRefreshToken($url, $refreshToken, $scope, $otherParams) {
  $params = @{
    grant_type = "refresh_token"
    refresh_token = $refreshToken
  }
  if ($scope) { $params['scope'] = $scope }
  if ($otherParams) { $params += $otherParams }
  try {
    return Invoke-RestMethod $url -Method 'POST' -Body $params
  } catch {
    PrintWebException $_
    throw $_
  }
}

function Oauth2AuthCode_InvokeApi($method, $url, $accessToken, $otherParams) {
  $headers = @{
    'Authorization' = "Bearer $accessToken"
  }
  try {
    return Invoke-RestMethod $url -Method $method -Headers $headers -Body $otherParams
  } catch {
    PrintWebException $_
    throw $_
  }
}

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
    $data.psobject.properties | %{
      # $this.($_.Name) = $_.Value
      Add-Member -InputObject $this -MemberType NoteProperty -Name $_.Name -Value $_.Value -Force
    }
  }
}
