<#
.SYNOPSIS
  PowerShell標準機能で OAuth 2.0 クライアントを作成（OAuth 2.0 認可コードグラントタイプ）
.DESCRIPTION
  参考
  [OAuth 2.0 ? OAuth](https://oauth.net/2/)
  [The OAuth 2.0 Authorization Framework](https://openid-foundation-japan.github.io/rfc6749.ja.html)
#>

. (Join-Path $PSScriptRoot "OauthUtil.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

<#
.SYNOPSIS
  OAuth 2.0 認可コードグラントタイプにおける認可リクエスト
.INPUTS
  $OptionParams - 追加パラメータの連想配列
    例：@{redirect_uri="xxx"; scope="xxx"; state="xxx"}
  $Dialog - ダイアログボックスでユーザ入力を受け付ける場合$true。デフォルトではコンソールから読み込む。
.OUTPUTS
  認可コードの文字列
#>
function Invoke-Oauth2UserAuth($Url, $ClientId, $OptionParams, $Message=$OAUTH2_CODE_MSG, $Dialog) {
  Write-Verbose "認可リクエスト"
  $params = @{
    response_type = 'code'
    client_id = $ClientId
  }
  if ($OptionParams) { $params += $OptionParams }
  $arr = $params.GetEnumerator() | Sort-Object Name | ForEach-Object {
    [System.Web.HttpUtility]::UrlEncode($_.Name) + '=' + [System.Web.HttpUtility]::UrlEncode($_.Value)
  }
  $url2 = $Url + '?' + ($arr -join '&')
  Write-Verbose $url2
  Start-Process $url2
  return Read-UserInput $Message $Dialog
}

<#
.SYNOPSIS
  OAuth 2.0 認可コードグラントタイプにおけるアクセストークンリクエスト
.INPUTS
  $OptionParams - 追加パラメータの連想配列
    例：@{redirect_uri="xxx"; client_id="xxx"}
  $ContentType - OAuth2.0仕様では、'application/x-www-form-urlencoded'となる。
.OUTPUTS
  アクセストークンの文字列
#>
function Invoke-Oauth2AccessToken($Url, $AuthCode, $OptionParams,
  $ContentType='application/x-www-form-urlencoded') {
  Write-Verbose "アクセストークンリクエスト"
  $headers = @{
    'User-Agent' = $OAUTH2_USER_AGENT
    'Content-Type' = $ContentType
  }
  $params = @{
    grant_type = 'authorization_code'
    code = $AuthCode
  }
  if ($OptionParams) { $params += $OptionParams }
  $body = ConvertTo-WrappedHttpBody $params $ContentType
  Write-ObjectDebug "HTTP request body" $body.Value
  try {
    return Invoke-RestMethod $Url -Method 'POST' -Headers $headers -Body $body.Value
  } catch {
    Write-WebException $_
    throw $_
  }
}

<#
.SYNOPSIS
  OAuth 2.0 認可コードグラントタイプにおけるリフレッシュトークンリクエスト
.INPUTS
  $OptionParams - 追加パラメータの連想配列
    例：@{scope="xxx"}
.OUTPUTS
  アクセストークンの文字列
#>
function Invoke-Oauth2RefreshToken($Url, $RefreshToken, $OptionParams) {
  Write-Verbose "リフレッシュトークンリクエスト"
  $params = @{
    grant_type = "refresh_token"
    refresh_token = $RefreshToken
  }
  if ($OptionParams) { $params += $OptionParams }
  Write-ObjectDebug "HTTP request body" $params
  try {
    return Invoke-RestMethod $Url -Method 'POST' -Body $params
  } catch {
    Write-WebException $_
    throw $_
  }
}

<#
.SYNOPSIS
  OAuth 2.0 認可コードグラントタイプにおけるリソースAPIリクエスト
#>
function Invoke-Oauth2Api($Method, $Url, $AccessToken, $OptionParams, $ContentType, $QueryParams) {
  $headers = @{
    'Authorization' = "Bearer $AccessToken"
  }
  if ($ContentType) { $headers += @{ 'Content-Type' = $ContentType }}
  $body = ConvertTo-WrappedHttpBody $OptionParams $ContentType
  if ($QueryParams) {
    $arr = $QueryParams.GetEnumerator() | Sort-Object Name | ForEach-Object {
      [System.Web.HttpUtility]::UrlEncode($_.Name) + '=' + [System.Web.HttpUtility]::UrlEncode($_.Value)
    }
    $Url += '?' + ($arr -join '&')
  }
  Write-Debug "Content-Type $ContentType"
  Write-ObjectDebug "HTTP request body" $body.Value
  try {
    return Invoke-RestMethod $Url -Method $Method -Headers $headers -Body $body.Value
  } catch {
    Write-WebException $_
    throw $_
  }
}
