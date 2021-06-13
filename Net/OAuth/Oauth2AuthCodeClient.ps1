<#
.SYNOPSIS
  PowerShell�W���@�\�� OAuth 2.0 �N���C�A���g���쐬�iOAuth 2.0 �F�R�[�h�O�����g�^�C�v�j
.DESCRIPTION
  �Q�l
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
  OAuth 2.0 �F�R�[�h�O�����g�^�C�v�ɂ�����F���N�G�X�g
.INPUTS
  $OptionParams - �ǉ��p�����[�^�̘A�z�z��
    ��F@{redirect_uri="xxx"; scope="xxx"; state="xxx"}
  $Dialog - �_�C�A���O�{�b�N�X�Ń��[�U���͂��󂯕t����ꍇ$true�B�f�t�H���g�ł̓R���\�[������ǂݍ��ށB
.OUTPUTS
  �F�R�[�h�̕�����
#>
function Invoke-Oauth2UserAuth($Url, $ClientId, $OptionParams, $Message=$OAUTH2_CODE_MSG, $Dialog) {
  Write-Verbose "�F���N�G�X�g"
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
  OAuth 2.0 �F�R�[�h�O�����g�^�C�v�ɂ�����A�N�Z�X�g�[�N�����N�G�X�g
.INPUTS
  $OptionParams - �ǉ��p�����[�^�̘A�z�z��
    ��F@{redirect_uri="xxx"; client_id="xxx"}
  $ContentType - OAuth2.0�d�l�ł́A'application/x-www-form-urlencoded'�ƂȂ�B
.OUTPUTS
  �A�N�Z�X�g�[�N���̕�����
#>
function Invoke-Oauth2AccessToken($Url, $AuthCode, $OptionParams,
  $ContentType='application/x-www-form-urlencoded') {
  Write-Verbose "�A�N�Z�X�g�[�N�����N�G�X�g"
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
  OAuth 2.0 �F�R�[�h�O�����g�^�C�v�ɂ����郊�t���b�V���g�[�N�����N�G�X�g
.INPUTS
  $OptionParams - �ǉ��p�����[�^�̘A�z�z��
    ��F@{scope="xxx"}
.OUTPUTS
  �A�N�Z�X�g�[�N���̕�����
#>
function Invoke-Oauth2RefreshToken($Url, $RefreshToken, $OptionParams) {
  Write-Verbose "���t���b�V���g�[�N�����N�G�X�g"
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
  OAuth 2.0 �F�R�[�h�O�����g�^�C�v�ɂ����郊�\�[�XAPI���N�G�X�g
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
