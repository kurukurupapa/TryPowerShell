<#
.SYNOPSIS
  PowerShell�W���@�\�� OAuth 2.0 �N���C�A���g���쐬�iOAuth 2.0 �F�R�[�h�O�����g�^�C�v�j
.DESCRIPTION
  �Q�l
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
  OAuth 2.0 �F�R�[�h�O�����g�^�C�v�ɂ�����F���N�G�X�g
.INPUTS
  $optionParams - �ǉ��p�����[�^�̘A�z�z��
    ��F@{redirect_uri="xxx"; scope="xxx"; state="xxx"}
  $dialog - �_�C�A���O�{�b�N�X�Ń��[�U���͂��󂯕t����ꍇ$true�B�f�t�H���g�ł̓R���\�[������ǂݍ��ށB
.OUTPUTS
  �F�R�[�h�̕�����
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
  OAuth 2.0 �F�R�[�h�O�����g�^�C�v�ɂ�����A�N�Z�X�g�[�N�����N�G�X�g
.INPUTS
  $optionParams - �ǉ��p�����[�^�̘A�z�z��
    ��F@{redirect_uri="xxx"; client_id="xxx"}
.OUTPUTS
  �A�N�Z�X�g�[�N���̕�����
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
  OAuth 2.0 �F�R�[�h�O�����g�^�C�v�ɂ����郊�t���b�V���g�[�N�����N�G�X�g
.INPUTS
  $optionParams - �ǉ��p�����[�^�̘A�z�z��
    ��F@{scope="xxx"}
.OUTPUTS
  �A�N�Z�X�g�[�N���̕�����
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
  OAuth 2.0 �F�R�[�h�O�����g�^�C�v�ɂ����郊�\�[�XAPI���N�G�X�g
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
  OAuth 2.0 �F�R�[�h�O�����g�^�C�v�N���X
#>
class Oauth2AuthCodeClient {
  $clientId
  $clientSecret
  $redirectUri
  $authUrl
  $accessUrl
  $accessToken
  $refreshToken
  # �ꎞ�I�ȕϐ�
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
