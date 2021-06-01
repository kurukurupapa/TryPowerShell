<#
.SYNOPSIS
  PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
.DESCRIPTION
  �E�A�N�Z�X�g�[�N���̗L��������Ď擾���l�����Ă��܂���B
  �Q�l
  [OAuth Core 1.0a](https://oauth.net/core/1.0a/#sig_base_example)
  [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)
#>

. (Join-Path $PSScriptRoot "OauthUtil.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# $VerbosePreference = 'Continue'
# $DebugPreference = 'SilentlyContinue'

<#
.SYNOPSIS
  Signature Base String ���擾
#>
function Get-SignatureBaseString($Method, $Url, $Params) {
  $arr = $Params.GetEnumerator() | Sort-Object Name | ForEach-Object {
    # $_.Name + '=' + $_.Value
    [Uri]::EscapeDataString($_.Name) + '=' + [Uri]::EscapeDataString($_.Value)
  }
  $signatureBaseString = $Method.ToUpper() + '&' + [Uri]::EscapeDataString($Url.ToLower()) + '&' + [Uri]::EscapeDataString($arr -join '&')
  Write-Debug ("SignatureBaseString: " + $signatureBaseString -replace ('&',"&`n  ") -replace ('%26',"%26`n  "))
  return $signatureBaseString
}
# Get-SignatureBaseString "POST" "https://sample.com" @{a="1";b="2";c="A B"}

<#
.SYNOPSIS
  oauth_signature���擾
#>
function Get-Signature($SignatureBaseString, $ConsumerSecret, $TokenSecret) {
  $key = [Uri]::EscapeDataString($ConsumerSecret) + '&' + [Uri]::EscapeDataString($TokenSecret)
  $hmacsha1 = New-Object System.Security.Cryptography.HMACSHA1
  $hmacsha1.Key = [System.Text.Encoding]::ASCII.GetBytes($key)
  $signature = [System.Convert]::ToBase64String($hmacsha1.ComputeHash(
    [System.Text.Encoding]::ASCII.GetBytes($SignatureBaseString)))
  Write-Debug "Signature: $signature, Key: $key"
  return $signature
}
# Get-Signature "abc" "def" "ghi"

<#
.SYNOPSIS
  Authorization�w�b�_�[���擾
#>
function Get-AuthorizationHeader($Params, $Signature) {
  $Params['oauth_signature'] = $Signature
  $arr = $Params.GetEnumerator() | Sort-Object Name | ForEach-Object {
    [Uri]::EscapeDataString($_.Name) + '="' + [Uri]::EscapeDataString($_.Value) + '"'
  }
  $result = "OAuth " + ($arr -join ",")
  Write-Debug ("Authorization header: " + $result -replace (',',",`n  "))
  return $result
}
# GetAuthorization @{a="1";b="2"} "abc"

<#
.SYNOPSIS
  ���X�|���X�����
#>
function ParseOauthResponse($ResponseStr) {
  Write-Debug "Response: $ResponseStr"
  $hash = @{}
  $ResponseStr.Split('&') | ForEach-Object {
    $name, $value = $_.Split('=')
    $hash[[Uri]::UnescapeDataString($name)] = [Uri]::UnescapeDataString($value)
  }
  return $hash
}
# ParseOauthResponse "oauth_token=aaa&oauth_token_secret=bbb&oauth_callback_confirmed=true"

<#
.SYNOPSIS
  OAuth1.0a��API�Ăяo�������s
.DESCRIPTION
  ������ $token, $tokenSecret, $verifier, $callback, $authParams, $bodyParams, $queryParams �́A�K�v�ɉ����Đݒ肷��B
  $callback, $authParams �́AAuthorization�w�b�_�[��oauth_signature�̌v�Z�Ɋ܂߂�B
  $bodyParams �́AGET�p�����[�^�܂���POST�f�[�^�ƂȂ�B
  $queryParams �́A��{�g�p���Ȃ����A���N�G�X�g���\�b�h�ɂ�炸�AURL�ɃN�G���������ݒ肵�����Ƃ��Ɏg�p����B
  ���N�G�X�g�g�[�N���擾���́A$token, $tokenSecret, $verifier �Ȃ��A�K�v�ɉ����� $callback ��ݒ肷��B
  �A�N�Z�X�g�[�N���擾���́A$token, $tokenSecret �Ƀ��N�G�X�g�g�[�N���擾���ʂ�ݒ肵�A$verifier �Ƀ��[�U�F���ʂ�ݒ肷��B
  ���\�[�XAPI�Ăяo�����́A$token, $tokenSecret �ɃA�N�Z�X�g�[�N���擾���ʂ�ݒ肵�A�K�v�ɉ����� $authParams, $bodyParams, $queryParams ��ݒ肷��B
#>
function Invoke-OauthApi($Method, $Url, $ConsumerKey, $ConsumerSecret,
  $Token, $TokenSecret, $Verifier, $Callback, $AuthParams, $BodyParams, $QueryParams,
  $SignatureMethod='HMAC-SHA1') {

  # oauth_nonce�́A��ӂȒl�ł���΂悢�̂ŁA�Ƃ肠�����^�C���X�^���v����쐬����B
  $timestamp = [int]((Get-Date) - [Datetime]"1970/1/1 00:00:00 GMT").TotalSeconds
  $nonce = "NONCE" + $timestamp
  # oauth_token���l�Ȃ��̏ꍇ�AZaimAPI�œ���m�F�����Ƃ���A���ږ�����Ńu�����N�ioauth_token=�j�ł��A���ږ����ƂȂ��ł����v�������B
  $params = @{
    "oauth_consumer_key" = $ConsumerKey
    "oauth_nonce" = $nonce
    "oauth_signature_method" = $SignatureMethod
    "oauth_timestamp" = $timestamp
    "oauth_version" = "1.0"
  }
  if ($Token) { $params["oauth_token"] = $Token }
  if ($Verifier) { $params['oauth_verifier'] = $Verifier }
  if ($Callback) { $params['oauth_callback'] = $Callback }
  if ($AuthParams) { $params += $AuthParams }
  $allParams = $params.Clone()
  if ($BodyParams) { $allParams += $BodyParams }
  if ($QueryParams) { $allParams += $QueryParams }
  $signatureBaseString = Get-SignatureBaseString $Method $Url $allParams
  $signature = Get-Signature $signatureBaseString $ConsumerSecret $TokenSecret
  $authorizationHeader = Get-AuthorizationHeader $params $signature

  if ($QueryParams) {
    $arr = $QueryParams.GetEnumerator() | Sort-Object Name | ForEach-Object {
      [System.Web.HttpUtility]::UrlEncode($_.Name) + '=' + [System.Web.HttpUtility]::UrlEncode($_.Value)
    }
    $Url += '?' + ($arr -join '&')
  }

  try {
    $headers = @{
      Authorization = $authorizationHeader
      'User-Agent' = $OAUTH1A_USER_AGENT
    }
    if ($Method -eq 'POST') {
      $headers['Content-Type'] = 'application/x-www-form-urlencoded'
    }
    return Invoke-RestMethod $Url -Method $Method -Headers $headers -Body $BodyParams
  } catch {
    Write-WebException $_
    throw $_
  }
}
# Invoke-OauthApi 'DELETE' "https://kurukurupapap.com/oauth1a" "consumerKey" "consumerSecret" "callback" -QueryParams @{q1=1;q2="abc";"symbol!#"="$%< >+*"}
# Invoke-OauthApi 'DELETE' "https://kurukurupapap.com/oauth1a?a=1" "consumerKey" "consumerSecret" "callback" -QueryParams @{q1=1;q2="abc";"symbol!#"="$%< >+*"}

<#
.SYNOPSIS
  ���N�G�X�g�g�[�N���擾
.DESCRIPTION
  [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step1) 6.1. Obtaining an Unauthorized Request Token
  [POST oauth/request_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/request_token)
  [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)
  ���[�J���A�v���̃��N�G�X�g�g�[�N���擾�����ł́Aoauth_callback��"oob"(out-of-band)��ݒ肵�Ȃ���΂Ȃ�Ȃ��l�����ǁA�T�[�r�X�v���o�C�_�[�ɂ���ẮA���������URL���K�v�ȏꍇ������B
  OAuth 1.0a �̎d�l�Ƃ��ẮAoauth_* �ȊO�̒ǉ��p�����[�^������Ƃ������APOST�f�[�^/GET�p�����[�^��ݒ肷��悤�Ɍ�����B����ǉ��p�����[�^�Ȃ��Ȃ̂Ŋ֌W�Ȃ����ǁB
#>
function Invoke-RequestToken($Method, $RequestUrl, $ConsumerKey, $ConsumerSecret,
  $Callback, $AuthParams, $BodyParams, $QueryParams) {
  Write-Verbose "���N�G�X�g�g�[�N���擾"
  return ParseOauthResponse (
    Invoke-OauthApi $Method $RequestUrl $ConsumerKey $ConsumerSecret -Callback $Callback `
      -AuthParams $AuthParams -BodyParams $BodyParams -QueryParams $QueryParams)
}

<#
.SYNOPSIS
  ���[�U�F��URL�̎��s�i�u���E�U���J���j
.DESCRIPTION
  [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step2) 6.2. Obtaining User Authorization
  [GET oauth/authorize | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/authorize)
#>
function Invoke-UserAuthorization($AuthUrl, $RequestToken, [switch]$Dialog,
  $Message=$OAUTH1A_VERIFIER_MSG) {
  Write-Verbose "���[�U�F��"
  $url = $AuthUrl + "?oauth_token=" + [System.Web.HttpUtility]::UrlEncode($RequestToken)
  Write-Verbose $url
  Start-Process $url
  return Read-UserInput $Message $Dialog
}

<#
.SYNOPSIS
  �A�N�Z�X�g�[�N���擾
.DESCRIPTION
  [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step3) 6.3. Obtaining an Access Token
  [POST oauth/access_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/access_token)
  �A�N�Z�X�g�[�N���擾�����ł́Aoauth_callback��"oob"(out-of-band)��ݒ肷�邩�Aoauth_callback���̂𑗐M���Ȃ��͗l�B
#>
function Invoke-AccessToken($Method, $AccessUrl, $ConsumerKey, $ConsumerSecret,
  $Token, $TokenSecret, $Verifier) {
  Write-Verbose "�A�N�Z�X�g�[�N���擾"
  return ParseOauthResponse (
    Invoke-OauthApi $Method $AccessUrl $ConsumerKey $ConsumerSecret $Token $TokenSecret $Verifier)
}

# # �N���X��
# class Oauth1aClient {
#   $ConsumerKey
#   $ConsumerSecret
#   $RequestUrl
#   $AuthUrl
#   $AccessUrl
#   $AccessToken
#   $AccessTokenSecret
#   # �ꎞ�I�ȕϐ�
#   $RequestToken
#   $RequestTokenSecret
#   $Verifier
# 
#   Oauth1aClient() {
#   }
#   Oauth1aClient($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl) {
#     $this.ConsumerKey = $consumerKey
#     $this.ConsumerSecret = $consumerSecret
#     $this.RequestUrl = $requestUrl
#     $this.AuthUrl = $authUrl
#     $this.AccessUrl = $accessUrl
#   }
# 
#   InvokeRequestToken($method, $callback) {
#     $this.InvokeRequestToken($method, $callback, $null, $null, $null)
#   }
#   InvokeRequestToken($method, $callback, $authParams, $bodyParams) {
#     $this.InvokeRequestToken($method, $callback, $authParams, $bodyParams, $null)
#   }
#   InvokeRequestToken($method, $callback, $authParams, $bodyParams, $queryParams) {
#     $res = Invoke-RequestToken $method $this.RequestUrl $this.ConsumerKey $this.ConsumerSecret `
#       $callback $authParams $bodyParams $queryParams
#     $this.RequestToken = $res.oauth_token
#     $this.RequestTokenSecret = $res.oauth_token_secret
#   }
# 
#   InvokeUserAuthorization($dialog) {
#     $this.Verifier = Invoke-UserAuthorization $this.AuthUrl $this.RequestToken -Dialog
#   }
# 
#   InvokeAccessToken($method) {
#     $res = Invoke-AccessToken $method $this.AccessUrl $this.ConsumerKey $this.ConsumerSecret `
#       $this.RequestToken $this.RequestTokenSecret $this.Verifier
#     $this.AccessToken = $res.oauth_token
#     $this.AccessTokenSecret = $res.oauth_token_secret
#   }
# 
#   [object] Invoke($method, $url) {
#     return $this.Invoke($method, $url, $null, $null, $null)
#   }
#   [object] Invoke($method, $url, $optionParams) {
#     return $this.Invoke($method, $url,
#       $optionParams["auth"], $optionParams["body"], $optionParams["query"])
#   }
#   [object] Invoke($method, $url, $authParams, $bodyParams) {
#     return $this.Invoke($method, $url, $authParams, $bodyParams, $null)
#   }
#   [object] Invoke($method, $url, $authParams, $bodyParams, $queryParams) {
#     return Invoke-OauthApi $method $url $this.consumerKey $this.consumerSecret `
#       -Token $this.accessToken -TokenSecret $this.accessTokenSecret `
#       -AuthParams $authParams -BodyParams $bodyParams -QueryParams $queryParams
#   }
# 
#   Save($path) {
#     Export-OauthClientInfo $path $this
#   }
# 
#   Load($path) {
#     $data = Import-OauthClientInfo $path
#     $data.psobject.properties | ForEach-Object {
#       $this.($_.Name) = $_.Value
#     }
#   }
# }
# # $path = Join-Path $home "PsOauth1aClient_Dummy.dat"
# # $client = New-Object Oauth1aClient
# # $client.Save($path)
# # $client.Load($path)
